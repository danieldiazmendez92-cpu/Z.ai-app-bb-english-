/**
 * scripts/seed_stories.ts
 * ───────────────────────────────────────────────────────────────────────────
 * Script utilitario para cargar cuentos de dominio público (Project Gutenberg)
 * en el catálogo de StoryEnglish Kids, llamando a la Cloud Function `storyIngest`.
 *
 * USO
 * ===
 *   # Pre-requisitos:
 *   #   1. Firebase Emulator corriendo (firebase emulators:start) O acceso a
 *   #      un proyecto Firebase dev/prod con un usuario que tenga custom claim
 *   #      `admin: true`.
 *   #   2. Dependencias de Cloud Functions instaladas:
 *   #      cd firebase/functions && npm ci
 *   #
 *   # Ejecutar desde la raíz del repo:
 *   npx tsx scripts/seed_stories.ts --project=dev --limit=5
 *   npx tsx scripts/seed_stories.ts --project=emulator --limit=5 --dry-run
 *   npx tsx scripts/seed_stories.ts --project=prod --only=3 --force
 *
 * FLAGS
 * =====
 *   --project=<dev|prod|emulator>   Requerido. Indica a qué backend disparar.
 *   --limit=<N>                     Cuántos cuentos cargar (default: todos).
 *   --only=<index>                  Cargar solo el cuento en esa posición (0-based).
 *   --dry-run                       Solo loguear qué se enviaría, sin llamar a la CF.
 *   --force                         No frenar ante errores parciales (se sigue el batch).
 *   --verbose                       Loggeo detallado.
 *   --help, -h                      Mostrar ayuda.
 *
 * NOTAS
 * =====
 * - Este script es un esqueleto: los textos de los cuentos son extractos cortos
 *   (3-5 frases) para demostración. Para cargar cuentos completos, editar la
 *   lista SEED_STORIES o implementar la función `fetchGutenbergText(url)` que
 *   descargue el .txt desde gutenberg.org y lo trunque a 5000 palabras (límite
 *   de la Cloud Function storyIngest, ver src/story_ingest.ts).
 * - Requiere autenticación: si se apunta a dev/prod, el UID del usuario que se
 *   autentica debe tener custom claim `admin: true` (configurable vía
 *   `firebase auth:import` o desde Cloud Functions con `admin.auth().setCustomUserClaims`).
 * - Para emulator, no se requiere auth.
 * - Logging estructurado a stdout para integración con CI/CD si se desea.
 *
 * Salida: 0 si todos los cuentos se cargaron OK, distinto de 0 si alguno falló
 * (salvo --force, en cuyo caso sigue y reporta al final).
 *
 * Tracking: P0-D (Agente D). Mejoras futuras:
 *   - T1.3.4: Implementar fetchGutenbergText con parsing del formato .txt de
 *     Gutenberg (eliminar headers/footers legales).
 *   - T1.3.5: Agregar metadata de categoría y rango de edad por cuento.
 *   - T4.1.2: Cargar cuentos desde un CSV/JSONL en vez de hardcoded.
 */

import * as crypto from "node:crypto";

// ─── Tipos ────────────────────────────────────────────────────────────────

interface SeedStory {
  /** Título del cuento en inglés (tal como aparece en Gutenberg). */
  title: string;
  /** URL al .txt en Project Gutenberg (formato plain text UTF-8). */
  sourceUrl: string;
  /** URL a la página HTML del libro en gutenberg.org (para atribución). */
  gutenbergBookUrl: string;
  /** Autor (para atribución). */
  author: string;
  /** Año de publicación original (aproximado, para contexto). */
  yearPublished: number;
  /** Categoría en nuestro catálogo. Debe existir en Firestore `categories`. */
  categoryId: string;
  /** Edad mínima recomendada (2-7). */
  minAge: number;
  /** Edad máxima recomendada. */
  maxAge: number;
  /** Tags para discovery (búsqueda y filtros). */
  tags: string[];
  /** Extracto del texto en inglés (para demo; en prod se descargaría completo). */
  textEn: string;
}

interface StoryIngestResponse {
  storyId: string;
  audioPath: string;
  timestampsPath: string;
  vocabularyCount: number;
  questionsCount: number;
  sectionsCount: number;
}

interface SeedResult {
  index: number;
  title: string;
  ok: boolean;
  storyId?: string;
  error?: string;
  durationMs: number;
}

// ─── Datos de seed ────────────────────────────────────────────────────────
// 5 cuentos de dominio público de Project Gutenberg.
// Textos son extractos cortos para demo; en prod se descargarían completos
// desde sourceUrl (ver fetchGutenbergText TODO).

const SEED_STORIES: readonly SeedStory[] = [
  {
    title: "Little Red Riding Hood",
    sourceUrl: "https://www.gutenberg.org/cache/epub/21592/pg21592.txt",
    gutenbergBookUrl: "https://www.gutenberg.org/ebooks/21592",
    author: "Traditional (Brothers Grimm adaptation)",
    yearPublished: 1857,
    categoryId: "fairy-tales",
    minAge: 3,
    maxAge: 7,
    tags: ["classic", "forest", "wolf", "grandmother", "warning"],
    textEn:
      "Once upon a time there was a little girl who was loved by everyone who looked at her, " +
      "but most of all by her grandmother. Once she gave the little girl a little cap made of red velvet. " +
      "It suited her so well that she would never wear anything else, and so she was called Little Red Riding Hood. " +
      "One day her mother said to her, 'Come, Little Red Riding Hood, here is a piece of cake and a bottle of wine. " +
      "Take them to your grandmother, she is ill and weak, and they will do her good.'",
  },
  {
    title: "The Three Little Pigs",
    sourceUrl: "https://www.gutenberg.org/cache/epub/18155/pg18155.txt",
    gutenbergBookUrl: "https://www.gutenberg.org/ebooks/18155",
    author: "Traditional (L. Leslie Brooke adaptation)",
    yearPublished: 1904,
    categoryId: "fairy-tales",
    minAge: 3,
    maxAge: 7,
    tags: ["classic", "pigs", "wolf", "houses", "perseverance"],
    textEn:
      "Once upon a time there was an old Sow with three little Pigs, and as she had not enough to keep them, " +
      "she sent them out to seek their fortune. The first that went off met a Man with a bundle of straw, " +
      "and said to him, 'Please, Man, give me that straw to build me a house.' " +
      "The Man did, and the little Pig built a house with it. " +
      "Presently came along a Wolf, and knocked at the door, and said, 'Little Pig, little Pig, let me come in.'",
  },
  {
    title: "Goldilocks and the Three Bears",
    sourceUrl: "https://www.gutenberg.org/cache/epub/21234/pg21234.txt",
    gutenbergBookUrl: "https://www.gutenberg.org/ebooks/21234",
    author: "Traditional (Robert Southey adaptation)",
    yearPublished: 1837,
    categoryId: "fairy-tales",
    minAge: 3,
    maxAge: 6,
    tags: ["classic", "bears", "porridge", "curiosity", "manners"],
    textEn:
      "Once upon a time there were Three Bears, who lived together in a house of their own, in a wood. " +
      "One of them was a Little, Small, Wee Bear; one was a Middle-sized Bear, and the other was a Great, Huge Bear. " +
      "They had each a pot for their porridge; a little pot for the Little, Small, Wee Bear; " +
      "and a middle-sized pot for the Middle Bear, and a great pot for the Great, Huge Bear.",
  },
  {
    title: "The Ugly Duckling",
    sourceUrl: "https://www.gutenberg.org/cache/epub/23975/pg23975.txt",
    gutenbergBookUrl: "https://www.gutenberg.org/ebooks/23975",
    author: "Hans Christian Andersen",
    yearPublished: 1843,
    categoryId: "fairy-tales",
    minAge: 4,
    maxAge: 7,
    tags: ["classic", "duckling", "swan", "transformation", "self-esteem"],
    textEn:
      "It was so glorious out in the country; it was summer; the corn-fields were yellow, the oats were green, " +
      "the hay had been made up in cocks in the green meadows, and the stork went about on his long red legs, " +
      "and chattered Egyptian, for the language he had learnt from his mother. " +
      "In the midst of the sunshine there stood an old manor-house that had a deep moat around it. " +
      "From the wall and down to the water's edge grew great burdocks, so high that little children could stand upright under them.",
  },
  {
    title: "The Tale of Peter Rabbit",
    sourceUrl: "https://www.gutenberg.org/cache/epub/14838/pg14838.txt",
    gutenbergBookUrl: "https://www.gutenberg.org/ebooks/14838",
    author: "Beatrix Potter",
    yearPublished: 1902,
    categoryId: "animals",
    minAge: 2,
    maxAge: 6,
    tags: ["classic", "rabbit", "garden", "mischief", "consequences"],
    textEn:
      "Once upon a time there were four little Rabbits, and their names were—Flopsy, Mopsy, Cotton-tail, and Peter. " +
      "They lived with their Mother in a sand-bank, underneath the root of a very big fir-tree. " +
      "'Now, my dears,' said old Mrs. Rabbit one morning, 'you may go into the fields or down the lane, " +
      "but don't go into Mr. McGregor's garden: your Father had an accident there; he was put in a pie by Mrs. McGregor.'",
  },
] as const;

// ─── Configuración ────────────────────────────────────────────────────────

const PROJECT_ENDPOINTS: Record<string, { functionsEmulator?: string; projectId: string }> = {
  emulator: {
    functionsEmulator: "http://127.0.0.1:5001",
    projectId: "demo-storyenglish-kids",
  },
  dev: {
    projectId: "storyenglish-kids-dev",
  },
  prod: {
    projectId: "storyenglish-kids-prod",
  },
};

interface ParsedArgs {
  project: "dev" | "prod" | "emulator" | null;
  limit: number | null;
  only: number | null;
  dryRun: boolean;
  force: boolean;
  verbose: boolean;
  help: boolean;
}

function parseArgs(argv: string[]): ParsedArgs {
  const args: ParsedArgs = {
    project: null,
    limit: null,
    only: null,
    dryRun: false,
    force: false,
    verbose: false,
    help: false,
  };

  for (const arg of argv.slice(2)) {
    if (arg === "--help" || arg === "-h") {
      args.help = true;
    } else if (arg === "--dry-run") {
      args.dryRun = true;
    } else if (arg === "--force") {
      args.force = true;
    } else if (arg === "--verbose") {
      args.verbose = true;
    } else if (arg.startsWith("--project=")) {
      const value = arg.slice("--project=".length) as ParsedArgs["project"];
      if (!["dev", "prod", "emulator"].includes(value as string)) {
        throw new Error(`--project inválido: ${value}. Valores válidos: dev|prod|emulator`);
      }
      args.project = value;
    } else if (arg.startsWith("--limit=")) {
      args.limit = parseInt(arg.slice("--limit=".length), 10);
      if (Number.isNaN(args.limit) || args.limit < 1) {
        throw new Error(`--limit inválido: ${arg}`);
      }
    } else if (arg.startsWith("--only=")) {
      args.only = parseInt(arg.slice("--only=".length), 10);
      if (Number.isNaN(args.only) || args.only < 0) {
        throw new Error(`--only inválido: ${arg}`);
      }
    } else {
      throw new Error(`Flag desconocido: ${arg}. Usar --help para ver opciones.`);
    }
  }

  return args;
}

const HELP_TEXT = `
scripts/seed_stories.ts — Cargar cuentos de Project Gutenberg en StoryEnglish Kids

USO:
  npx tsx scripts/seed_stories.ts --project=<dev|prod|emulator> [opciones]

OPCIONES:
  --project=<dev|prod|emulator>  Requerido. Backend al que se le disparan las CFs.
  --limit=<N>                    Cargar solo los primeros N cuentos (default: todos).
  --only=<index>                 Cargar solo el cuento en esa posición (0-based).
  --dry-run                      Solo loguear qué se enviaría, sin llamar a la CF.
  --force                        Continuar aunque un cuento falle (default: abortar).
  --verbose                      Loggeo detallado.
  --help, -h                     Esta ayuda.

EJEMPLOS:
  npx tsx scripts/seed_stories.ts --project=emulator --limit=5
  npx tsx scripts/seed_stories.ts --project=dev --only=0 --dry-run
  npx tsx scripts/seed_stories.ts --project=prod --force --verbose
`.trim();

// ─── Logging ──────────────────────────────────────────────────────────────

type LogLevel = "INFO" | "WARN" | "ERROR" | "DEBUG" | "SUCCESS";

function log(level: LogLevel, message: string, data?: unknown): void {
  const timestamp = new Date().toISOString();
  const line = `[${timestamp}] [${level}] ${message}`;
  if (data !== undefined && (level === "DEBUG" || level === "ERROR")) {
    // Solo loguear data en DEBUG y ERROR para no llenar la consola.
    console.log(line, typeof data === "string" ? data : JSON.stringify(data, null, 2));
  } else {
    console.log(line);
  }
}

// ─── Llamada a storyIngest ────────────────────────────────────────────────

/**
 * Dispara la Cloud Function `storyIngest` ya sea:
 *   - Directamente vía HTTP (emulador): http://127.0.0.1:5001/demo-storyenglish-kids/us-central1/storyIngest
 *   - Vía Firebase Functions callable (dev/prod): requiere Firebase Admin SDK
 *     y credenciales de service account o un custom token de un usuario admin.
 *
 * Para mantener este script sin dependencias externas pesadas (firebase-admin),
 * implementamos dos estrategias:
 *   - emulator: fetch HTTP directo (no requiere auth).
 *   - dev/prod: requiere que el usuario pase un ID token por stdin o variable
 *     de entorno STORYENGLISH_ADMIN_ID_TOKEN. Se hace fetch HTTP con header
 *     Authorization: Bearer <token>.
 */
async function callStoryIngest(
  project: "dev" | "prod" | "emulator",
  payload: unknown,
  verbose: boolean
): Promise<StoryIngestResponse> {
  const config = PROJECT_ENDPOINTS[project];
  if (!config) {
    throw new Error(`Proyecto desconocido: ${project}`);
  }

  // La convención de Firebase Functions v2 callable es:
  //   POST https://<region>-<project>.cloudfunctions.net/<functionName>
  // Body: { "data": <payload> }
  // Header: Content-Type: application/json
  // Header: Authorization: Bearer <idToken> (requerido en dev/prod, ignorado en emulator)
  const region = "us-central1";
  const url =
    project === "emulator"
      ? `${config.functionsEmulator}/${config.project}/${region}/storyIngest`
      : `https://${region}-${config.project}.cloudfunctions.net/storyIngest`;

  const headers: Record<string, string> = {
    "Content-Type": "application/json",
  };

  if (project !== "emulator") {
    const idToken = process.env.STORYENGLISH_ADMIN_ID_TOKEN;
    if (!idToken) {
      throw new Error(
        `Para project=${project} se requiere la variable de entorno ` +
          `STORYENGLISH_ADMIN_ID_TOKEN con el ID token de un usuario admin ` +
          `(claim admin: true). Generar con 'firebase auth:print-token <uid>' o ` +
          `custom token + signInWithCustomToken en un script aparte.`
      );
    }
    headers["Authorization"] = `Bearer ${idToken}`;
  }

  if (verbose) {
    log("DEBUG", `POST ${url}`, { payloadPreview: JSON.stringify(payload).slice(0, 200) + "..." });
  }

  const response = await fetch(url, {
    method: "POST",
    headers,
    body: JSON.stringify({ data: payload }),
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(`HTTP ${response.status} ${response.statusText}: ${text}`);
  }

  const json = (await response.json()) as { result?: StoryIngestResponse; error?: unknown };

  // Firebase callable devuelve { result: ... } en éxito, { error: ... } en fallo.
  if (json.error) {
    throw new Error(`Cloud Function error: ${JSON.stringify(json.error)}`);
  }
  if (!json.result) {
    throw new Error(`Respuesta inesperada de Cloud Function: ${JSON.stringify(json)}`);
  }

  return json.result;
}

// ─── TODO: fetchGutenbergText ─────────────────────────────────────────────
// En una versión futura (T1.3.4), implementar:
//
//   async function fetchGutenbergText(url: string): Promise<string> {
//     const res = await fetch(url);
//     if (!res.ok) throw new Error(`Gutenberg fetch failed: ${res.status}`);
//     const raw = await res.text();
//     // Strip Project Gutenberg headers/footers (*** START OF THIS ... ***)
//     const startMarker = "*** START OF THIS PROJECT GUTENBERG EBOOK ***";
//     const endMarker = "*** END OF THIS PROJECT GUTENBERG EBOOK ***";
//     const startIdx = raw.indexOf(startMarker);
//     const endIdx = raw.indexOf(endMarker);
//     let body = raw;
//     if (startIdx >= 0 && endIdx > startIdx) {
//       body = raw.slice(startIdx + startMarker.length, endIdx).trim();
//     }
//     // Truncate to 5000 words max (limit de storyIngest)
//     const words = body.split(/\s+/).slice(0, 5000).join(" ");
//     return words;
//   }
//
// Por ahora usamos textEn hardcoded en SEED_STORIES para no depender de
// red ni de parseo complejo.

// ─── Orquestación ─────────────────────────────────────────────────────────

async function seedOne(
  index: number,
  story: SeedStory,
  args: ParsedArgs
): Promise<SeedResult> {
  const startMs = Date.now();
  log("INFO", `[${index}] Cargando "${story.title}" (author: ${story.author}, age: ${story.minAge}-${story.maxAge})`);

  // Build el payload que espera storyIngest (ver firebase/functions/src/story_ingest.ts)
  const sourceAttribution = `${story.author} (${story.yearPublished}). Fuente: ${story.gutenbergBookUrl} (Project Gutenberg, dominio público).`;

  // Generamos un storyId determinístico basado en el título para idempotencia.
  // (La CF regenera su propio storyId, pero lo logueamos para trazabilidad.)
  const deterministicId = crypto
    .createHash("sha1")
    .update(story.title.toLowerCase())
    .digest("hex")
    .slice(0, 12);

  const payload = {
    title: story.title,
    textEn: story.textEn,
    sourceAttribution,
    sourceUrl: story.sourceUrl,
    categoryId: story.categoryId,
    minAge: story.minAge,
    maxAge: story.maxAge,
    tags: story.tags,
    // El campo _deterministicId lo pasamos para log; la CF no lo usa.
    _deterministicId: deterministicId,
  };

  if (args.dryRun) {
    log("WARN", `[${index}] DRY-RUN: no se llama a storyIngest. Payload preparado.`);
    if (args.verbose) {
      log("DEBUG", `Payload:`, payload);
    }
    return {
      index,
      title: story.title,
      ok: true,
      storyId: `dry-run-${deterministicId}`,
      durationMs: Date.now() - startMs,
    };
  }

  try {
    const result = await callStoryIngest(args.project!, payload, args.verbose);
    log(
      "SUCCESS",
      `[${index}] OK "${story.title}" → storyId=${result.storyId} ` +
        `(vocab: ${result.vocabularyCount}, questions: ${result.questionsCount}, sections: ${result.sectionsCount})`
    );
    return {
      index,
      title: story.title,
      ok: true,
      storyId: result.storyId,
      durationMs: Date.now() - startMs,
    };
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    log("ERROR", `[${index}] FAIL "${story.title}": ${message}`);
    if (args.verbose && err instanceof Error && err.stack) {
      log("DEBUG", "Stack:", err.stack);
    }
    return {
      index,
      title: story.title,
      ok: false,
      error: message,
      durationMs: Date.now() - startMs,
    };
  }
}

async function main(): Promise<number> {
  let args: ParsedArgs;
  try {
    args = parseArgs(process.argv);
  } catch (err) {
    log("ERROR", err instanceof Error ? err.message : String(err));
    console.error("\n" + HELP_TEXT);
    return 2;
  }

  if (args.help) {
    console.log(HELP_TEXT);
    return 0;
  }

  if (!args.project) {
    log("ERROR", "Flag --project es requerido.");
    console.error("\n" + HELP_TEXT);
    return 2;
  }

  // Seleccionar cuentos a procesar
  let storiesToSeed: { index: number; story: SeedStory }[] = SEED_STORIES.map((story, index) => ({
    index,
    story,
  }));

  if (args.only !== null) {
    if (args.only >= storiesToSeed.length) {
      log("ERROR", `--only=${args.only} fuera de rango (hay ${storiesToSeed.length} cuentos).`);
      return 2;
    }
    storiesToSeed = [storiesToSeed[args.only]];
  } else if (args.limit !== null) {
    storiesToSeed = storiesToSeed.slice(0, args.limit);
  }

  log(
    "INFO",
    `Iniciando seed: ${storiesToSeed.length} cuento(s), project=${args.project}, ` +
      `dryRun=${args.dryRun}, force=${args.force}, verbose=${args.verbose}`
  );

  const results: SeedResult[] = [];
  let okCount = 0;
  let failCount = 0;

  for (const { index, story } of storiesToSeed) {
    const result = await seedOne(index, story, args);
    results.push(result);
    if (result.ok) {
      okCount++;
    } else {
      failCount++;
      if (!args.force) {
        log("ERROR", `Abortando batch por fallo en cuento ${index}. Usar --force para continuar.`);
        break;
      }
    }
  }

  // Resumen final
  log("INFO", "─".repeat(60));
  log("INFO", `Resumen: ${okCount} OK, ${failCount} FAIL, de ${storiesToSeed.length} cuentos.`);
  if (failCount > 0) {
    log("WARN", "Cuentos que fallaron:");
    for (const r of results.filter((r) => !r.ok)) {
      log("WARN", `  #${r.index} "${r.title}": ${r.error}`);
    }
  }
  const totalMs = results.reduce((sum, r) => sum + r.durationMs, 0);
  log("INFO", `Tiempo total: ${(totalMs / 1000).toFixed(1)}s.`);

  // Exit code: 0 si todo OK, 1 si alguno falló
  return failCount === 0 ? 0 : 1;
}

// ─── Entry point ──────────────────────────────────────────────────────────

main()
  .then((exitCode) => {
    process.exit(exitCode);
  })
  .catch((err) => {
    log("ERROR", `Error no manejado: ${err instanceof Error ? err.message : String(err)}`);
    if (err instanceof Error && err.stack) {
      log("DEBUG", "Stack:", err.stack);
    }
    process.exit(1);
  });
