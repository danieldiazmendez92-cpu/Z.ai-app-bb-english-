/**
 * Cloud Function `achievementEngine`.
 *
 * Lee los progresos y datos del nino, evalua todos los logros definidos en
 * `achievements` y crea documentos en `user_achievements` para los logros que
 * el nino acaba de desbloquear ( y que no tenia ya ).
 *
 * Criterios soportados ( `achievements.criteria_type` ):
 *  - stories_completed: cantidad de cuentos completados.
 *  - streak_days: racha de dias consecutivos leyendo.
 *  - words_learned: cantidad de palabras vistas en popup de vocabulario.
 *  - categories_explored: cantidad de categorias distintas con al menos 1
 *    cuento leido.
 *  - perfect_comprehension: cuentos completados con respuesta correcta en la
 *    pregunta de comprension.
 *  - total_minutes_read: minutos totales leyendo.
 *
 * Referencia: `docs/04-firestore-schema.md` secciones 11-13,
 * `docs/06-roadmap.md` Sprint 2.1 ( T2.1.2 ).
 */

import { logger } from "firebase-functions/v2";
import { FieldValue } from "firebase-admin/firestore";

import { db } from "./firebase";
import type {
  Achievement,
  AchievementCriteriaType,
  UserAchievement,
} from "./types";

/**
 * Evalua todos los logros para un nino dado y crea nuevos `user_achievements`.
 *
 * @param childId  UID del perfil del nino.
 * @returns Array de IDs de logros recien desbloqueados.
 */
export async function evaluateAchievementsForChild(
  childId: string,
): Promise<string[]> {
  logger.info(`Evaluando logros para childId=${childId}`);

  try {
    // 1. Cargar todos los logros definidos.
    const achievementsSnap = await db.collection("achievements").get();
    const allAchievements = achievementsSnap.docs.map(
      (d) => d.data() as Achievement,
    );

    if (allAchievements.length === 0) {
      logger.info("No hay logros definidos en la coleccion achievements.");
      return [];
    }

    // 2. Cargar logros ya desbloqueados por el nino.
    const unlockedSnap = await db
      .collection("user_achievements")
      .where("child_id", "==", childId)
      .get();
    const unlockedIds = new Set(
      unlockedSnap.docs.map((d) => (d.data() as UserAchievement).achievement_id),
    );

    // 3. Calcular metrics del nino.
    const metrics = await computeChildMetrics(childId);

    // 4. Evaluar cada logro no desbloqueado.
    const newlyUnlocked: string[] = [];
    const batch = db.batch();

    for (const achievement of allAchievements) {
      if (unlockedIds.has(achievement.achievement_id)) continue;
      if (achievement.is_hidden) {
        // Los logros ocultos se evaluan tambien ( la ocultidad solo afecta UI ).
      }

      const value = metrics[achievement.criteria_type] ?? 0;
      if (value >= achievement.criteria_threshold) {
        const uaId = `${childId}_${achievement.achievement_id}`;
        batch.set(db.collection("user_achievements").doc(uaId), {
          user_achievement_id: uaId,
          child_id: childId,
          achievement_id: achievement.achievement_id,
          unlocked_at: FieldValue.serverTimestamp(),
        });
        newlyUnlocked.push(achievement.achievement_id);
        logger.info(
          `Logro desbloqueado: ${achievement.achievement_id} para child=${childId}`,
          { value, threshold: achievement.criteria_threshold },
        );
      }
    }

    if (newlyUnlocked.length > 0) {
      await batch.commit();
      logger.info(
        `${newlyUnlocked.length} logros nuevos desbloqueados para child=${childId}`,
      );
    } else {
      logger.info(`Sin nuevos logros para child=${childId}`);
    }

    return newlyUnlocked;
  } catch (err) {
    logger.error(
      `Error evaluando logros para childId=${childId}`,
      err,
    );
    return [];
  }
}

/**
 * Computa todas las metricas relevantes para evaluacion de logros.
 *
 * @param childId UID del perfil del nino.
 * @returns Mapa de `criteria_type` -> valor actual.
 */
async function computeChildMetrics(
  childId: string,
): Promise<Record<AchievementCriteriaType, number>> {
  // Cargar progresos
  const progressSnap = await db
    .collection("user_progress")
    .where("child_id", "==", childId)
    .get();

  const progresses = progressSnap.docs.map((d) => d.data() as {
    completed: boolean;
    story_id: string;
    time_spent_seconds: number;
    last_read_at: { toDate: () => Date };
  });

  const storiesCompleted = progresses.filter((p) => p.completed).length;

  // Streak de dias consecutivos: ordenar por last_read_at y contar consecutivos
  // hasta hoy / ayer.
  const streak = computeStreak(
    progresses.map((p) => p.last_read_at.toDate()),
  );

  // Words learned: cantidad de entries en user_progress no nos sirve. Para
  // MVP contamos vocabulario mirado leyendo `reading_sessions.sections_read`
  // ( aproximacion ). Idealmente el cliente registra un evento
  // `vocabulary_lookup` por palabra tocada y se cuenta desde ahi.
  // Como placeholder, contamos sessions completas como proxy.
  const sessionsSnap = await db
    .collection("reading_sessions")
    .where("child_id", "==", childId)
    .get();
  const wordsLearned = sessionsSnap.docs.reduce(
    (acc, d) =>
      acc + ((d.data() as { sections_read?: number }).sections_read ?? 0),
    0,
  );

  // Categories explored: leer stories y contar categorias unicas
  const storyIds = progresses.map((p) => p.story_id);
  const categoriesSet = new Set<string>();
  if (storyIds.length > 0) {
    const storiesSnap = await db
      .collection("stories")
      .where("__name__", "in", storyIds.slice(0, 30))
      .get();
    storiesSnap.forEach((d) => {
      const cat = (d.data() as { category_id?: string }).category_id;
      if (cat) categoriesSet.add(cat);
    });
  }
  const categoriesExplored = categoriesSet.size;

  // Perfect comprehension: para MVP lo dejamos en 0 ( requiere tracking de
  // respuestas a comprehension_questions ).
  const perfectComprehension = 0;

  // Total minutes read
  const totalSeconds = progresses.reduce(
    (acc, p) => acc + (p.time_spent_seconds ?? 0),
    0,
  );
  const totalMinutesRead = Math.floor(totalSeconds / 60);

  return {
    stories_completed: storiesCompleted,
    streak_days: streak,
    words_learned: wordsLearned,
    categories_explored: categoriesExplored,
    perfect_comprehension: perfectComprehension,
    total_minutes_read: totalMinutesRead,
  };
}

/**
 * Computa la racha de dias consecutivos leyendo hasta hoy / ayer.
 *
 * @param dates Array de fechas de lectura.
 * @returns Cantidad de dias consecutivos ( 0 si no leyo hoy ni ayer ).
 */
function computeStreak(dates: Date[]): number {
  if (dates.length === 0) return 0;
  const sorted = dates
    .map((d) => startOfDay(d).getTime())
    .sort((a, b) => b - a);
  const unique = Array.from(new Set(sorted));

  const today = startOfDay(new Date()).getTime();
  const yesterday = today - 24 * 60 * 60 * 1000;

  // Streak arranca solo si leyo hoy o ayer
  if (unique[0] !== today && unique[0] !== yesterday) return 0;

  let streak = 1;
  for (let i = 1; i < unique.length; i++) {
    const prev = unique[i - 1]!;
    const curr = unique[i]!;
    if (prev - curr === 24 * 60 * 60 * 1000) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}

function startOfDay(d: Date): Date {
  const r = new Date(d);
  r.setHours(0, 0, 0, 0);
  return r;
}
