import 'dart:async';

import '../../domain/entities/subscription.dart';
import '../../domain/repositories/billing_repository.dart';

/// Repositorio de billing DEMO.
///
/// Simula suscripciones en memoria.
/// En demo mode no se puede comprar de verdad, pero podemos
/// simular "ya tengo premium" para probar features.
class DemoBillingRepository implements BillingRepository {
  DemoBillingRepository({Subscription? initial})
      : _subscription = initial;

  Subscription? _subscription;
  final StreamController<Subscription?> _controller =
      StreamController<Subscription?>.broadcast();

  @override
  Future<Subscription?> getCurrentSubscription() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _subscription;
  }

  @override
  Stream<Subscription?> watchSubscription() {
    Future.microtask(() => _controller.add(_subscription));
    return _controller.stream;
  }

  @override
  Future<bool> purchasePlan(SubscriptionPlan plan,
      {bool startTrial = false}) async {
    await Future.delayed(const Duration(seconds: 2)); // simular compra
    final now = DateTime.now();
    _subscription = Subscription(
      subscriptionId: 'demo-sub',
      userUid: 'demo-user-001',
      plan: plan == SubscriptionPlan.annual ? 'annual' : 'monthly',
      platform: 'android',
      storeProductId: plan.storeProductId,
      startedAt: now,
      expiresAt: now.add(
        plan == SubscriptionPlan.annual
            ? const Duration(days: 365)
            : const Duration(days: 30),
      ),
      autoRenew: true,
      status: 'active',
      isTrial: startTrial,
      trialEndsAt: startTrial ? now.add(const Duration(days: 7)) : null,
    );
    _controller.add(_subscription);
    return true;
  }

  @override
  Future<bool> restorePurchases() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // En demo, no hay nada que restaurar
    return _subscription?.isActive ?? false;
  }

  @override
  Future<bool> isPremium() async {
    return _subscription?.isActive ?? false;
  }

  @override
  Stream<bool> watchIsPremium() {
    return watchSubscription().map((s) => s?.isActive ?? false);
  }

  /// Demo: setear premium manualmente (para probar features premium).
  void setPremium(bool premium) {
    if (premium) {
      final now = DateTime.now();
      _subscription = Subscription(
        subscriptionId: 'demo-sub',
        userUid: 'demo-user-001',
        plan: 'annual',
        platform: 'android',
        storeProductId: 'premium_annual',
        startedAt: now,
        expiresAt: now.add(const Duration(days: 365)),
        autoRenew: true,
        status: 'active',
      );
    } else {
      _subscription = null;
    }
    _controller.add(_subscription);
  }

  void dispose() {
    _controller.close();
  }
}
