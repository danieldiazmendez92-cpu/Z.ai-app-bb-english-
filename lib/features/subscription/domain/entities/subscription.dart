import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription.freezed.dart';
part 'subscription.g.dart';

/// Estado de la suscripción premium del usuario.
///
/// Se sincroniza con la colección `subscriptions` de Firestore vía
/// Cloud Functions `playWebhook` y `appStoreWebhook`.
@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    /// ID compuesto: '{userUid}_{platform}'
    required String subscriptionId,

    required String userUid,

    /// 'monthly' | 'annual'
    required String plan,

    /// 'android' | 'ios'
    required String platform,

    /// SKU en la store. Ej: 'premium_monthly', 'premium_annual'
    required String storeProductId,

    required DateTime startedAt,
    required DateTime expiresAt,

    required bool autoRenew,

    /// 'active' | 'expired' | 'canceled' | 'grace_period'
    required String status,

    String? lastReceiptId,
    DateTime? canceledAt,

    /// True si está en período de trial gratuito (7 días).
    @Default(false) bool isTrial,

    /// Fecha de fin del trial (si aplica).
    DateTime? trialEndsAt,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);

  const Subscription._();

  /// True si la suscripción está activa (incluye grace period).
  bool get isActive =>
      status == 'active' ||
      status == 'grace_period' ||
      (status == 'canceled' && DateTime.now().isBefore(expiresAt));

  /// True si está cancelada pero sigue vigente hasta expiresAt.
  bool get isCanceledButActive =>
      status == 'canceled' && DateTime.now().isBefore(expiresAt);

  /// Días restantes hasta expiración.
  int get daysRemaining {
    final diff = expiresAt.difference(DateTime.now());
    return diff.inDays < 0 ? 0 : diff.inDays;
  }
}

/// Planes disponibles.
enum SubscriptionPlan {
  monthly('premium_monthly', 4.99, 'Mensual'),
  annual('premium_annual', 39.99, 'Anual');

  const SubscriptionPlan(this.storeProductId, this.priceUsd, this.displayName);

  final String storeProductId;
  final double priceUsd;
  final String displayName;

  /// Ahorro porcentual del anual vs mensual.
  double get savings {
    if (this == SubscriptionPlan.annual) {
      final monthlyEquivalent = 4.99 * 12;
      return ((monthlyEquivalent - priceUsd) / monthlyEquivalent) * 100;
    }
    return 0;
  }
}
