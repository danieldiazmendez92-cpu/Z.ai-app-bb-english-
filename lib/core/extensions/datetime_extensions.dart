// =============================================================================
// datetime_extensions.dart - Extensiones para DateTime
// =============================================================================

import 'package:intl/intl.dart';

/// Extensiones utilitarias para `DateTime`.
extension DateTimeX on DateTime {
  /// `true` si la fecha es el mismo dia (anio/mes/dia) que [other].
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// `true` si la fecha es hoy.
  bool get isToday => isSameDay(DateTime.now());

  /// `true` si la fecha es ayer.
  bool get isYesterday => isSameDay(DateTime.now().subtract(const Duration(days: 1)));

  /// Formatea como 'dd/MM/yyyy' (ej: '24/06/2025').
  String toDateFormat() => DateFormat('dd/MM/yyyy').format(this);

  /// Formatea como 'HH:mm' (ej: '14:30').
  String toTimeFormat() => DateFormat('HH:mm').format(this);

  /// Formatea como 'dd/MM/yyyy HH:mm' (ej: '24/06/2025 14:30').
  String toDateTimeFormat() => DateFormat('dd/MM/yyyy HH:mm').format(this);

  /// Formatea relativo: 'hace 5 min', 'ayer', 'hace 3 dias', '24/06/2025'.
  /// Para UX de listas de actividad reciente.
  String toRelativeFormat([String locale = 'es']) {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (isToday) return 'hoy ${toTimeFormat()}';
    if (isYesterday) return 'ayer ${toTimeFormat()}';
    if (diff.inDays < 7) return 'hace ${diff.inDays} dias';
    return toDateFormat();
  }

  /// Calcula edad en anios a partir de una fecha de nacimiento.
  /// Nota: para nios usamos [age] directo (no birthdate - COPPA).
  int get ageInYears {
    final now = DateTime.now();
    var age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  /// Inicio del dia (00:00:00) - util para queries por dia.
  DateTime get startOfDay => DateTime(year, month, day);

  /// Fin del dia (23:59:59.999) - util para queries por dia.
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Lunes de la semana actual (start of week, ISO).
  DateTime get startOfWeek => subtract(Duration(days: weekday - 1)).startOfDay;

  /// Primer dia del mes actual.
  DateTime get startOfMonth => DateTime(year, month);
}

/// Extensiones utilitarias para `Timestamp` de Firestore (lazy import para
/// evitar dependencia fuerte aqui).
extension FirestoreTimestampX on Object {
  /// Convierte un valor (Timestamp de Firestore o DateTime) a DateTime.
  /// Lanza [FormatException] si el tipo no es soportado.
  DateTime toDateTime() {
    final v = this;
    if (v is DateTime) return v;
    // Para evitar import cloud_firestore aqui, usamos reflection basica:
    // si el objeto tiene `toDate()` (Timestamp), lo llamamos.
    try {
      final dynamic dyn = v;
      return (dyn.toDate() as DateTime);
    } catch (_) {
      throw FormatException('No se pudo convertir $runtimeType a DateTime');
    }
  }
}
