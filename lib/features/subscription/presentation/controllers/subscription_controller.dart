import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import 'package:storyenglish_kids/shared/providers/auth_provider.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/billing_repository.dart';
import '../../data/billing_repository_impl.dart';

/// Estado del flujo de suscripción.
class SubscriptionState {
  const SubscriptionState({
    this.subscription,
    this.isPremium = false,
    this.isLoading = false,
    this.isPurchasing = false,
    this.failure,
    this.lastPurchasePlan,
  });

  final Subscription? subscription;
  final bool isPremium;
  final bool isLoading;
  final bool isPurchasing;
  final Failure? failure;
  final SubscriptionPlan? lastPurchasePlan;

  SubscriptionState copyWith({
    Subscription? subscription,
    bool? isPremium,
    bool? isLoading,
    bool? isPurchasing,
    Failure? failure,
    SubscriptionPlan? lastPurchasePlan,
  }) {
    return SubscriptionState(
      subscription: subscription ?? this.subscription,
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      failure: failure,
      lastPurchasePlan: lastPurchasePlan ?? this.lastPurchasePlan,
    );
  }
}

/// Controller de suscripciones.
class SubscriptionController extends StateNotifier<SubscriptionState> {
  SubscriptionController({
    required BillingRepository repository,
  })  : _repository = repository,
        super(const SubscriptionState(isLoading: true)) {
    _init();
  }

  final BillingRepository _repository;

  Future<void> _init() async {
    // Escuchar cambios de suscripción reactivamente
    _repository.watchSubscription().listen(
      (sub) {
        state = state.copyWith(
          subscription: sub,
          isPremium: sub?.isActive ?? false,
          isLoading: false,
        );
      },
      onError: (e, st) {
        state = state.copyWith(
          isLoading: false,
          failure: UnknownFailure(e.toString()),
        );
      },
    );
  }

  /// Inicia la compra de un plan.
  /// Devuelve true si fue exitosa.
  Future<bool> purchase(SubscriptionPlan plan, {bool startTrial = false}) async {
    state = state.copyWith(
      isPurchasing: true,
      failure: null,
      lastPurchasePlan: plan,
    );

    try {
      final success =
          await _repository.purchasePlan(plan, startTrial: startTrial);
      state = state.copyWith(isPurchasing: false);
      return success;
    } on BillingFailure catch (e) {
      state = state.copyWith(
        isPurchasing: false,
        failure: AuthFailure(e.message),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isPurchasing: false,
        failure: UnknownFailure(e.toString()),
      );
      return false;
    }
  }

  /// Restaura compras previas.
  Future<bool> restore() async {
    state = state.copyWith(isLoading: true, failure: null);
    try {
      final success = await _repository.restorePurchases();
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        failure: UnknownFailure(e.toString()),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(failure: null);
  }
}

// ============================================================
// Providers
// ============================================================

final billingRepositoryProvider = Provider<BillingRepository>((ref) {
  final user = ref.watch(authControllerProvider).valueOrNull;
  if (user == null) {
    throw StateError('User must be authenticated to use BillingRepository');
  }
  return BillingRepositoryImpl(userUid: user.uid);
});

final subscriptionControllerProvider =
    StateNotifierProvider<SubscriptionController, SubscriptionState>((ref) {
  return SubscriptionController(
    repository: ref.watch(billingRepositoryProvider),
  );
});

/// Provider rápido: true si el usuario es premium.
final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionControllerProvider).isPremium;
});
