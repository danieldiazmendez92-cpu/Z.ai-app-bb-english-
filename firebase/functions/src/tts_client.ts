/**
 * Cliente de Google Cloud Text-to-Speech.
 *
 * Responsabilidades:
 *  - Sintetizar audio MP3 en ingles ( voz Neural2 ) del cuento.
 *  - Generar timestamps por palabra usando SSML con <mark> tags.
 *
 * Estrategia para timestamps:
 *  - Se construye un SSML donde cada palabra va seguida de un <mark name="N"/>.
 *  - Se llama a `synthesizeSpeech` con `enableTimePointing: ['SSML_MARK']`.
 *  - El response incluye `timepoints` con el nombre del mark y el tiempo en
 *    segundos desde el inicio del audio.
 *  - A partir de eso construimos el array `{ word, start_ms, end_ms }`
 *    donde `end_ms` de la palabra N = `start_ms` de la palabra N+1.
 */

import { TextToSpeechClient } from "@google-cloud/text-to-speech";
import { logger } from "firebase-functions/v2";

import { ttsVoiceEn } from "./config";
import type { TtsResult, WordTimestamp } from "./types";

let ttsClient: TextToSpeechClient | null = null;
function getClient(): TextToSpeechClient {
  if (!ttsClient) {
    ttsClient = new TextToSpeechClient();
  }
  return ttsClient;
}

/**
 * Sintetiza el cuento a audio MP3 + timestamps.
 *
 * @param storyText Texto completo del cuento en ingles ( ya sanitizado ).
 * @returns Buffer MP3 + array de timestamps por palabra.
 */
export async function synthesizeStoryAudio(
  storyText: string,
): Promise<TtsResult> {
  logger.info("Llamando a Google TTS para sintetizar cuento", {
    textLength: storyText.length,
    voice: ttsVoiceEn,
  });

  const client = getClient();

  // Construimos SSML: cada palabra seguida de un mark. Ignoramos signos de
  // puntuacion al generar marks para que `word` sea "limpia".
  const words = storyText
    .replace(/\s+/g, " ")
    .trim()
    .split(" ")
    .filter((w) => w.length > 0);

  // Limitamos a 5000 palabras por request ( limite practico de TTS ).
  if (words.length > 5000) {
    logger.warn(
      `Cuento con ${words.length} palabras, truncando a 5000 para TTS`,
    );
  }
  const truncatedWords = words.slice(0, 5000);

  const ssmlParts: string[] = ['<speak>'];
  truncatedWords.forEach((word, idx) => {
    // Escapar caracteres XML
    const safe = word
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;");
    ssmlParts.push(`${safe}<mark name="w${idx}"/>`);
  });
  ssmlParts.push("</speak>");
  const ssml = ssmlParts.join(" ");

  // El cliente de TTS devuelve un GaxfyPromise que se destructurea como tupla.
  // Hacemos cast a any para evitar problemas con el tipo de retorno.
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const request: any = {
    input: { ssml },
    voice: {
      languageCode: "en-US",
      name: ttsVoiceEn,
    },
    audioConfig: {
      audioEncoding: "MP3",
      speakingRate: 0.95, // ligeramente mas lento para ninos
      pitch: 0,
    },
    // enableTimePointing no esta en el tipo IAudioConfig pero la API lo acepta.
    enableTimePointing: ["SSML_MARK"],
  };
  const result: any = await client.synthesizeSpeech(request);
  const response = result[0] as {
    audioContent?: Buffer | string;
    timepoints?: Array<{ markName: string; timeSeconds: number }>;
  };

  if (!response.audioContent) {
    throw new Error("TTS no devolvio audioContent");
  }

  const audioBuffer = Buffer.isBuffer(response.audioContent)
    ? response.audioContent
    : Buffer.from(response.audioContent as string, "base64");

  // Construir timestamps a partir de timepoints
  const timepoints = response.timepoints ?? [];

  if (timepoints.length === 0) {
    logger.warn(
      "TTS no devolvio timepoints. Generando timestamps aproximados.",
    );
    return {
      audioBuffer,
      timestamps: approximateTimestamps(truncatedWords, audioBuffer.length),
    };
  }

  const timestamps: WordTimestamp[] = [];
  for (let i = 0; i < timepoints.length; i++) {
    const tp = timepoints[i]!;
    const startMs = Math.round(tp.timeSeconds * 1000);
    const endMs =
      i + 1 < timepoints.length
        ? Math.round(timepoints[i + 1]!.timeSeconds * 1000)
        : startMs + 300; // ultima palabra: 300ms por defecto
    timestamps.push({
      word: truncatedWords[i] ?? "",
      start_ms: startMs,
      end_ms: endMs,
    });
  }

  logger.info(
    `TTS OK: audio ${audioBuffer.length} bytes, ${timestamps.length} timestamps`,
  );

  return { audioBuffer, timestamps };
}

/**
 * Fallback si TTS no devuelve timepoints: estima 250ms por palabra.
 */
function approximateTimestamps(
  words: string[],
  _audioLengthBytes: number,
): WordTimestamp[] {
  const result: WordTimestamp[] = [];
  let cursor = 0;
  for (const word of words) {
    result.push({ word, start_ms: cursor, end_ms: cursor + 250 });
    cursor += 250;
  }
  return result;
}
