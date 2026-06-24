/**
 * Cliente de Gemini API ( @google/generative-ai ) usado por `storyIngest`.
 *
 * Responsabilidades:
 *  - Generar glosario de vocabulario ( palabra EN + traduccion ES + fonetica ).
 *  - Generar traduccion al espanol del cuento completo ( dividida en secciones ).
 *  - Generar 3 preguntas de comprension con 4 opciones cada una.
 *
 * El modelo responde en JSON strict mode. Si el parsing falla, se lanza error
 * y la Cloud Function aborta el ingesta ( no se crea el cuento ).
 */

import { GoogleGenerativeAI } from "@google/generative-ai";
import { logger } from "firebase-functions/v2";

import { geminiApiKey, geminiModel } from "./config";
import type { GeminiStoryResult, StoryIngestRequest } from "./types";

/** Inicializacion lazy del cliente de Gemini. */
let aiClient: GoogleGenerativeAI | null = null;
function getClient(): GoogleGenerativeAI {
  // Leemos la API key en runtime ( no en module load ) para que los tests
  // puedan setear la env var despues del import.
  const apiKey =
    process.env.GEMINI_API_KEY ||
    // eslint-disable-next-line @typescript-eslint/no-require-imports
    (require("./config") as { geminiApiKey?: string }).geminiApiKey;
  if (!apiKey) {
    throw new Error(
      "GEMINI_API_KEY no configurada. Define la variable de entorno.",
    );
  }
  if (!aiClient) {
    aiClient = new GoogleGenerativeAI(apiKey);
  }
  return aiClient;
}

/** Schema JSON esperado en la respuesta de Gemini. */
const RESPONSE_SCHEMA = {
  type: "object",
  properties: {
    vocabulary: {
      type: "array",
      items: {
        type: "object",
        properties: {
          word_en: { type: "string" },
          word_es: { type: "string" },
          phonetic: { type: "string" },
          example_sentence: { type: "string" },
          example_translation: { type: "string" },
          is_highlighted: { type: "boolean" },
        },
        required: ["word_en", "word_es", "is_highlighted"],
      },
    },
    sections: {
      type: "array",
      items: {
        type: "object",
        properties: {
          text_en: { type: "string" },
          text_es: { type: "string" },
        },
        required: ["text_en", "text_es"],
      },
    },
    questions: {
      type: "array",
      items: {
        type: "object",
        properties: {
          question_text: { type: "string" },
          options: {
            type: "array",
            items: { type: "string" },
            minItems: 4,
            maxItems: 4,
          },
          correct_index: { type: "integer", minimum: 0, maximum: 3 },
          explanation: { type: "string" },
        },
        required: ["question_text", "options", "correct_index", "explanation"],
      },
    },
  },
  required: ["vocabulary", "sections", "questions"],
} as const;

/**
 * Llama a Gemini para procesar un cuento.
 *
 * @param req Datos del cuento a procesar.
 * @returns Resultado estructurado listo para escribir a Firestore.
 */
export async function processStoryWithGemini(
  req: StoryIngestRequest,
): Promise<GeminiStoryResult> {
  logger.info(`Llamando a Gemini para procesar cuento: "${req.title}"`, {
    model: geminiModel,
  });

  const client = getClient();
  const model = client.getGenerativeModel({
    model: geminiModel,
    generationConfig: {
      temperature: 0.4, // bajamos temperatura para respuestas mas deterministas
      topK: 32,
      topP: 0.9,
      responseMimeType: "application/json",
      // @ts-expect-error - responseSchema existe en la SDK pero el tipo no lo expone bien
      responseSchema: RESPONSE_SCHEMA,
    },
  });

  const prompt = buildPrompt(req);

  try {
    const result = await model.generateContent(prompt);
    const text = result.response.text();
    const parsed = JSON.parse(text) as GeminiStoryResult;

    // Validaciones minimas
    if (
      !Array.isArray(parsed.vocabulary) ||
      !Array.isArray(parsed.sections) ||
      !Array.isArray(parsed.questions)
    ) {
      throw new Error("Respuesta de Gemini no contiene los arrays esperados.");
    }

    if (parsed.questions.length < 1) {
      throw new Error("Gemini no genero preguntas de comprension.");
    }

    logger.info(
      `Gemini OK: ${parsed.vocabulary.length} palabras, ${parsed.sections.length} secciones, ${parsed.questions.length} preguntas`,
    );

    return {
      vocabulary: parsed.vocabulary.map((v) => ({
        word_en: v.word_en,
        word_es: v.word_es,
        phonetic: v.phonetic ?? null,
        example_sentence: v.example_sentence ?? null,
        example_translation: v.example_translation ?? null,
        image_url: null,
        is_highlighted: v.is_highlighted ?? false,
      })),
      translationEs: parsed.sections.map((s) => s.text_es).join("\n\n"),
      questions: parsed.questions,
      sections: parsed.sections,
    };
  } catch (err) {
    logger.error("Error llamando a Gemini", err);
    throw new Error(
      `Fallo el procesamiento con Gemini: ${err instanceof Error ? err.message : String(err)}`,
    );
  }
}

/**
 * Construye el prompt para Gemini.
 *
 * Se especifica:
 *  - Idioma del output ( JSON ).
 *  - Audiencia ( ninos de `minAge` a `maxAge` ).
 *  - Cantidad de palabras a resaltar ( is_highlighted ).
 *  - Cantidad de preguntas ( 3 ).
 */
function buildPrompt(req: StoryIngestRequest): string {
  return [
    "Sos un asistente experto en literatura infantil y educacion bilingue.",
    "Vas a procesar el siguiente cuento en ingles para ninos de " +
      `${req.minAge} a ${req.maxAge} anos.`,
    "",
    "## Tareas",
    "1. Genera un glosario de vocabulario ( 5-15 palabras relevantes ) con:",
    "   - word_en: palabra en ingles.",
    "   - word_es: traduccion al espanol.",
    "   - phonetic: transcripcion IPA (ej: /wʊlf/).",
    "   - example_sentence: oracion simple en ingles usando la palabra.",
    "   - example_translation: traduccion de la oracion.",
    "   - is_highlighted: true para las 5 palabras mas importantes.",
    "2. Divide el cuento en 5-15 secciones y traduce cada una al espanol.",
    "   Cada seccion debe ser un parrafo coherente.",
    "3. Genera 3 preguntas de comprension con 4 opciones cada una,",
    "   indicando correct_index (0-3) y una explicacion corta.",
    "   Las preguntas deben ser apropiadas para la edad indicada.",
    "",
    "## Cuento a procesar",
    `Titulo: ${req.title}`,
    `Fuente: ${req.sourceAttribution} (${req.sourceUrl})`,
    "",
    "## Texto del cuento",
    req.textEn,
    "",
    "## Formato de salida",
    "Devolve EXCLUSIVAMENTE JSON con esta estructura:",
    "{",
    '  "vocabulary": [{ "word_en": "...", "word_es": "...", "phonetic": "...",',
    '    "example_sentence": "...", "example_translation": "...",',
    '    "is_highlighted": false }],',
    '  "sections": [{ "text_en": "...", "text_es": "..." }],',
    '  "questions": [{ "question_text": "...", "options": ["a","b","c","d"],',
    '    "correct_index": 0, "explanation": "..." }]',
    "}",
  ].join("\n");
}
