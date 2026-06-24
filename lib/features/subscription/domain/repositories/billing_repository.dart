import 'dart:async';

import '../entities/subscription.dart';

/// Contrato del repositorio de suscripciones.
///
/// Maneja:
/// - Compra de suscripciones vía Google Play Billing / App Store Billing
/// - Validación de receipts (delegada a Cloud Functions)
/// - Restore de compras
/// - Lectura del estado actual de suscripción
abstract class BillingRepository {
  /// Devuelve la suscripción activa del usuario, o null si no tiene.
  Future<Subscription?> getCurrentSubscription();

  /// Stream reactivo del estado de suscripción.
  /// Se actualiza cuando llega un webhook de la store.
  Stream<Subscription?> watchSubscription();

  /// Inicia el flujo de compra de un plan.
  ///
  /// Devuelve true si la compra fue exitosa y validada server-side.
  /// Lanza [BillingFailure] si hay error o el usuario cancela.
  Future<bool> purchasePlan(SubscriptionPlan plan, {bool startTrial = false});

  /// Restaura compras previas del usuario en este dispositivo.
  ///
  /// Útil cuando el usuario reinstala la app o cambia de dispositivo.
  /// Devuelve true si se restauró una suscripción activa.
  Future<bool> restorePurchases();

  /// Verifica si el usuario tiene una suscripción activa.
  /// Atajo para `getCurrentSubscription().isActive`.
  Future<bool> isPremium();

  /// Stream que emite true/false cuando cambia el estado premium.
  Stream<bool> watchIsPremium();
}

/// Errores específicos de billing.
class BillingFailure implements Exception {
  const BillingFailure(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => 'BillingFailure($code): $message';
}
