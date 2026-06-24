/**
 * Tests unitarios de `story_ingest` con mocks de Gemini y TTS.
 *
 * Como las Cloud Functions v2 son difficiles de testear directamente ( onCall
 * devuelve un tipo complejo ), testemos los modulos individuales que la
 * componen: `gemini_client.processStoryWithGemini` y `tts_client.
 * synthesizeStoryAudio`. Ambos se mockean con `vi.mock`.
 *
 * Para correr: `npm test`
 * Para coverage: `npm run test:coverage`
 */

import { describe, it, expect, vi, beforeEach } from "vitest";

// Mock de @google/generative-ai
// Exponemos un `mockState` para poder variar el comportamiento entre tests.
const mockState = {
  responseText: JSON.stringify({
    vocabulary: [
      {
        word_en: "wolf",
        word_es: "lobo",
        phonetic: "/wʊlf/",
        example_sentence: "The wolf is big.",
        example_translation: "El lobo es grande.",
        is_highlighted: true,
      },
      {
        word_en: "forest",
        word_es: "bosque",
        phonetic: "/ˈfɔrəst/",
        example_sentence: "The forest is dark.",
        example_translation: "El bosque es oscuro.",
        is_highlighted: false,
      },
    ],
    sections: [
      {
        text_en: "Once upon a time.",
        text_es: "Habia una vez.",
      },
      {
        text_en: "The end.",
        text_es: "Fin.",
      },
    ],
    questions: [
      {
        question_text: "Who is the main character?",
        options: ["Wolf", "Girl", "Mother", "Hunter"],
        correct_index: 1,
        explanation: "The girl is the main character.",
      },
      {
        question_text: "Where does the story happen?",
        options: ["City", "Beach", "Forest", "Desert"],
        correct_index: 2,
        explanation: "The story happens in the forest.",
      },
      {
        question_text: "What color is the hood?",
        options: ["Blue", "Red", "Green", "Yellow"],
        correct_index: 1,
        explanation: "The hood is red.",
      },
    ],
  }),
};

vi.mock("@google/generative-ai", () => {
  return {
    GoogleGenerativeAI: class {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      getGenerativeModel(_config: any) {
        return {
          generateContent: vi.fn().mockImplementation(async () => ({
            response: {
              text: () => mockState.responseText,
            },
          })),
        };
      }
    },
  };
});

// Mock de @google-cloud/text-to-speech
vi.mock("@google-cloud/text-to-speech", () => {
  return {
    TextToSpeechClient: class {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      async synthesizeSpeech(_req: any) {
        return [
          {
            audioContent: Buffer.from("fake-mp3-content"),
            timepoints: [
              { markName: "w0", timeSeconds: 0 },
              { markName: "w1", timeSeconds: 0.5 },
              { markName: "w2", timeSeconds: 1.0 },
              { markName: "w3", timeSeconds: 1.5 },
            ],
          },
        ];
      }
    },
  };
});

// Mock de firebase-functions/v2 ( logger )
vi.mock("firebase-functions/v2", () => ({
  logger: {
    info: vi.fn(),
    warn: vi.fn(),
    error: vi.fn(),
    debug: vi.fn(),
  },
}));

// Mock de firebase-admin/firestore ( FieldValue )
vi.mock("firebase-admin/firestore", () => ({
  FieldValue: {
    serverTimestamp: () => ({ _placeholder: "serverTimestamp" }),
    increment: (n: number) => ({ _placeholder: "increment", value: n }),
  },
}));

// Setear env para que el config tenga la API key
process.env.GEMINI_API_KEY = "test-gemini-key";
process.env.GCLOUD_PROJECT = "storyenglish-kids-test";

// Importar DESPUES de los mocks
import { processStoryWithGemini } from "../src/gemini_client";
import { synthesizeStoryAudio } from "../src/tts_client";

describe("gemini_client.processStoryWithGemini", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("debe generar vocabulario, secciones y preguntas correctamente", async () => {
    const result = await processStoryWithGemini({
      title: "Little Red Riding Hood",
      textEn: "Once upon a time. The end.",
      sourceAttribution: "Brothers Grimm",
      sourceUrl: "https://example.com",
      categoryId: "fairy-tales",
      minAge: 4,
      maxAge: 7,
    });

    expect(result.vocabulary).toHaveLength(2);
    expect(result.vocabulary[0]).toMatchObject({
      word_en: "wolf",
      word_es: "lobo",
      phonetic: "/wʊlf/",
      is_highlighted: true,
    });

    expect(result.sections).toHaveLength(2);
    expect(result.sections[0]).toMatchObject({
      text_en: "Once upon a time.",
      text_es: "Habia una vez.",
    });

    expect(result.questions).toHaveLength(3);
    expect(result.questions[0]).toMatchObject({
      question_text: "Who is the main character?",
      correct_index: 1,
      options: ["Wolf", "Girl", "Mother", "Hunter"],
    });

    // translationEs debe ser la concatenacion de las secciones en ES
    expect(result.translationEs).toContain("Habia una vez.");
    expect(result.translationEs).toContain("Fin.");
  });

  it("debe rechazar si la respuesta no contiene los arrays esperados", async () => {
    // Cambiar el estado del mock para que devuelva un JSON invalido.
    const original = mockState.responseText;
    mockState.responseText = JSON.stringify({ foo: "bar" });

    await expect(
      processStoryWithGemini({
        title: "Test",
        textEn: "test text",
        sourceAttribution: "test",
        sourceUrl: "https://example.com",
        categoryId: "test",
        minAge: 3,
        maxAge: 5,
      }),
    ).rejects.toThrow();

    // Restaurar para otros tests
    mockState.responseText = original;
  });
});

describe("tts_client.synthesizeStoryAudio", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("debe sintetizar audio MP3 y generar timestamps por palabra", async () => {
    const result = await synthesizeStoryAudio(
      "Once upon a time there was a wolf",
    );

    expect(result.audioBuffer).toBeInstanceOf(Buffer);
    expect(result.audioBuffer.length).toBeGreaterThan(0);
    expect(result.timestamps.length).toBeGreaterThan(0);

    // Cada timestamp debe tener word, start_ms, end_ms
    result.timestamps.forEach((t) => {
      expect(t).toHaveProperty("word");
      expect(t).toHaveProperty("start_ms");
      expect(t).toHaveProperty("end_ms");
      expect(typeof t.start_ms).toBe("number");
      expect(typeof t.end_ms).toBe("number");
      expect(t.end_ms).toBeGreaterThanOrEqual(t.start_ms);
    });
  });

  it("debe manejar texto vacio sin crashear", async () => {
    const result = await synthesizeStoryAudio("");
    expect(result.audioBuffer).toBeInstanceOf(Buffer);
    expect(Array.isArray(result.timestamps)).toBe(true);
  });
});
