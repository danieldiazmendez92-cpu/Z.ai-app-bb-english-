/**
 * Cloud Function `storyIngest`.
 *
 * Orquesta la ingesta de un nuevo cuento al catalogo:
 *   1. Llama a Gemini para generar vocabulario, traduccion ES y 3 preguntas.
 *   2. Llama a Google TTS para generar audio MP3 en ingles + timestamps.
 *   3. Sube MP3 y timestamps JSON a Cloud Storage.
 *   4. Crea documentos en Firestore:
 *      - `stories/{storyId}` ( published = false, pendiente de aprobacion )
 *      - `stories/{storyId}/story_sections/{sectionId}` por seccion
 *      - `stories/{storyId}/vocabulary/{wordId}` por palabra
 *      - `stories/{storyId}/comprehension_questions/{qId}` por pregunta
 *
 * Solo invocable por admin ( custom claim `admin: true` ).
 * Rate limit: 20 / dia ( accion `story_ingest` ).
 *
 * Referencia: `docs/06-roadmap.md` Sprint 1.3, `docs/01-architecture.md`
 * seccion 5.3.
 */

import { onCall, HttpsError, type CallableRequest } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import { FieldValue } from "firebase-admin/firestore";

import { defaultRegion } from "./config";
import { db, bucket } from "./firebase";
import { enforceRateLimit } from "./rate_limiter";
import {
  requireAuth,
  assertNonEmptyString,
  assertIntInRange,
  slugify,
} from "./utils";
import { processStoryWithGemini } from "./gemini_client";
import { synthesizeStoryAudio } from "./tts_client";
import type {
  Story,
  StoryIngestRequest,
  StoryIngestResponse,
  VocabularyWord,
} from "./types";
import { BUSINESS_RULES } from "./config";

/**
 * Callable `storyIngest`.
 *
 * Espera payload `{ title, textEn, sourceAttribution, sourceUrl, categoryId,
 * minAge, maxAge }` y devuelve `{ storyId, audioPath, timestampsPath,
 * vocabularyCount, questionsCount, sectionsCount }`.
 */
export const storyIngest = onCall(
  {
    region: defaultRegion,
    memory: "1GiB",
    timeoutSeconds: 300, // Gemini + TTS pueden tardar
    minInstances: 0,
    maxInstances: 5,
  },
  async (request: CallableRequest<StoryIngestRequest>): Promise<StoryIngestResponse> => {
    const uid = requireAuth(request.auth);
    await enforceRateLimit(uid, "story_ingest");

    // Verificar custom claim admin
    if (!request.auth?.token?.admin) {
      throw new HttpsError(
        "permission-denied",
        "Solo un administrador puede invocar storyIngest.",
      );
    }

    // Validar payload
    const data = request.data;
    const title = assertNonEmptyString(data?.title, "title", 200);
    const textEn = assertNonEmptyString(data?.textEn, "textEn", 50000);
    const sourceAttribution = assertNonEmptyString(
      data?.sourceAttribution,
      "sourceAttribution",
      500,
    );
    const sourceUrl = assertNonEmptyString(data?.sourceUrl, "sourceUrl", 1000);
    const categoryId = assertNonEmptyString(data?.categoryId, "categoryId", 100);
    const minAge = assertIntInRange(
      data?.minAge,
      BUSINESS_RULES.MIN_AGE,
      BUSINESS_RULES.MAX_AGE,
      "minAge",
    );
    const maxAge = assertIntInRange(
      data?.maxAge,
      BUSINESS_RULES.MIN_AGE,
      BUSINESS_RULES.MAX_AGE,
      "maxAge",
    );
    if (minAge > maxAge) {
      throw new HttpsError(
        "invalid-argument",
        "minAge no puede ser mayor que maxAge.",
      );
    }

    logger.info(`Iniciando ingesta de cuento: "${title}"`, {
      uid,
      title,
      textLength: textEn.length,
    });

    try {
      // 1. Generar ID del cuento ( slug del titulo + suffix aleatorio ).
      const storyId = `${slugify(title)}-${Math.random()
        .toString(36)
        .slice(2, 8)}`;

      // 2. Llamar a Gemini ( glosario + traduccion + preguntas ).
      const geminiResult = await processStoryWithGemini({
        title,
        textEn,
        sourceAttribution,
        sourceUrl,
        categoryId,
        minAge,
        maxAge,
      });

      // 3. Llamar a Google TTS ( audio MP3 + timestamps ).
      const ttsResult = await synthesizeStoryAudio(textEn);

      // 4. Subir MP3 y timestamps JSON a Cloud Storage.
      const audioPath = `stories/${storyId}/audio_en.mp3`;
      const timestampsPath = `stories/${storyId}/timestamps_en.json`;

      await Promise.all([
        bucket.file(audioPath).save(ttsResult.audioBuffer, {
          contentType: "audio/mpeg",
          metadata: { cacheControl: "public, max-age=31536000" },
        }),
        bucket
          .file(timestampsPath)
          .save(JSON.stringify({ words: ttsResult.timestamps }), {
            contentType: "application/json",
            metadata: { cacheControl: "public, max-age=31536000" },
          }),
      ]);

      logger.info("Audio y timestamps subidos a Storage", {
        audioPath,
        timestampsPath,
        audioBytes: ttsResult.audioBuffer.length,
      });

      // 5. Crear documento raiz `stories/{storyId}`.
      //    published = false hasta aprobacion manual del admin.
      const now = FieldValue.serverTimestamp();
      const storyData: Omit<Story, "created_at" | "published_at"> = {
        story_id: storyId,
        title,
        category_id: categoryId,
        min_age: minAge,
        max_age: maxAge,
        duration_minutes: Math.ceil(
          ttsResult.timestamps.reduce(
            (acc, t) => Math.max(acc, t.end_ms),
            0,
          ) / 60000,
        ),
        audio_url_en: `gs://${bucket.name}/${audioPath}`,
        audio_url_es: null,
        timestamps_json_url: `gs://${bucket.name}/${timestampsPath}`,
        cover_image_url: "", // el admin sube la portada a posteriori
        source_attribution: sourceAttribution,
        source_url: sourceUrl,
        published: false,
        tags: [],
        view_count: 0,
        avg_rating: null,
        // created_at y published_at se setean con serverTimestamp
      };
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const storyDocData: any = { ...storyData, created_at: now, published_at: null };

      // 6. Batch write: story root + secciones + vocabulario + preguntas.
      const batch = db.batch();
      batch.set(db.collection("stories").doc(storyId), storyDocData);

      // Story sections
      geminiResult.sections.forEach((section, idx) => {
        const sectionId = `sec_${String(idx + 1).padStart(3, "0")}`;
        batch.set(
          db
            .collection("stories")
            .doc(storyId)
            .collection("story_sections")
            .doc(sectionId),
          {
            section_id: sectionId,
            story_id: storyId,
            order: idx + 1,
            text_en: section.text_en,
            text_es: section.text_es,
            illustration_url: null,
          },
        );
      });

      // Vocabulary
      geminiResult.vocabulary.forEach((word, idx) => {
        const wordId = `word_${String(idx + 1).padStart(3, "0")}`;
        const wordDoc: VocabularyWord = {
          word_id: wordId,
          story_id: storyId,
          word_en: word.word_en,
          word_es: word.word_es,
          phonetic: word.phonetic,
          example_sentence: word.example_sentence,
          example_translation: word.example_translation,
          image_url: word.image_url,
          is_highlighted: word.is_highlighted,
        };
        batch.set(
          db
            .collection("stories")
            .doc(storyId)
            .collection("vocabulary")
            .doc(wordId),
          wordDoc,
        );
      });

      // Comprehension questions
      geminiResult.questions.forEach((q, idx) => {
        const qId = `q_${String(idx + 1).padStart(2, "0")}`;
        batch.set(
          db
            .collection("stories")
            .doc(storyId)
            .collection("comprehension_questions")
            .doc(qId),
          {
            question_id: qId,
            story_id: storyId,
            question_text: q.question_text,
            options: q.options,
            correct_index: q.correct_index,
            explanation: q.explanation,
          },
        );
      });

      await batch.commit();
      logger.info(`Cuento "${storyId}" creado en Firestore ( published=false )`);

      return {
        storyId,
        audioPath,
        timestampsPath,
        vocabularyCount: geminiResult.vocabulary.length,
        questionsCount: geminiResult.questions.length,
        sectionsCount: geminiResult.sections.length,
      };
    } catch (err) {
      logger.error(`Error en storyIngest para "${title}"`, err);
      if (err instanceof HttpsError) throw err;
      throw new HttpsError(
        "internal",
        `Fallo la ingesta del cuento: ${err instanceof Error ? err.message : String(err)}`,
      );
    }
  },
);
