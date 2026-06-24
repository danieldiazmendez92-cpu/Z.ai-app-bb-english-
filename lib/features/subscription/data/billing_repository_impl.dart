import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../../core/constants/collection_names.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/billing_repository.dart';

/// Implementación de [BillingRepository] que usa:
/// - `in_app_purchase` para el flujo de compra en cliente (Android + iOS)
/// - Cloud Functions `validatePlayReceipt` / `validateAppStoreReceipt`
///   para validación server-side
/// - Firestore `subscriptions` collection como fuente de verdad
class BillingRepositoryImpl implements BillingRepository {
  BillingRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
    InAppPurchase? inAppPurchase,
    required String userUid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance,
        _inAppPurchase = inAppPurchase ?? InAppPurchase.instance,
        _userUid = userUid;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final InAppPurchase _inAppPurchase;
  final String _userUid;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  @override
  Future<Subscription?> getCurrentSubscription() async {
    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';
      final subId = '${_userUid}_$platform';

      final doc = await _firestore
          .collection(CollectionNames.subscriptions)
          .doc(subId)
          .get();

      if (!doc.exists) return null;
      return _mapDocToSubscription(doc);
    } catch (e) {
      throw UnknownFailure('Error al leer suscripción: $e');
    }
  }

  @override
  Stream<Subscription?> watchSubscription() {
    final platform = Platform.isAndroid ? 'android' : 'ios';
    final subId = '${_userUid}_$platform';

    return _firestore
        .collection(CollectionNames.subscriptions)
        .doc(subId)
        .snapshots()
        .map((doc) => doc.exists ? _mapDocToSubscription(doc) : null);
  }

  @override
  Future<bool> purchasePlan(SubscriptionPlan plan,
      {bool startTrial = false}) async {
    try {
      // 1. Verificar disponibilidad de la store
      final available = await _inAppPurchase.isAvailable();
      if (!available) {
        throw const BillingFailure('La tienda no está disponible');
      }

      // 2. Cargar producto
      final response = await _inAppPurchase.queryProductDetails(
        {plan.storeProductId},
      );
      if (response.error != null) {
        throw BillingFailure(
            'Error al cargar producto: ${response.error!.message}');
      }
      if (response.productDetails.isEmpty) {
        throw BillingFailure(
            'Producto ${plan.storeProductId} no encontrado en la store');
      }

      final product = response.productDetails.first;

      // 3. Escuchar updates de compra
      final completer = Completer<bool>();
      _purchaseSub?.cancel();
      _purchaseSub = _inAppPurchase.purchaseStream.listen(
        (purchases) async {
          await _handlePurchases(purchases, completer);
        },
        onError: (e) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        },
      );

      // 4. Iniciar compra
      final purchaseParam = PurchaseParam(productDetails: product);
      if (startTrial) {
        // Para trial, algunas stores permiten `changeSubscriptionParam`
        // Por simplicidad, hacemos compra normal y el trial se maneja server-side
      }

      final started = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      if (!started) {
        _purchaseSub?.cancel();
        throw const BillingFailure('No se pudo iniciar la compra');
      }

      // 5. Esperar resultado
      return await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          _purchaseSub?.cancel();
          throw const BillingFailure('Timeout en la compra');
        },
      );
    } on BillingFailure {
      rethrow;
    } catch (e) {
      throw BillingFailure(e.toString());
    }
  }

  Future<void> _handlePurchases(
    List<PurchaseDetails> purchases,
    Completer<bool> completer,
  ) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          // Esperar
          continue;

        case PurchaseStatus.error:
          if (!completer.isCompleted) {
            completer.completeError(BillingFailure(
              purchase.error?.message ?? 'Error en la compra',
              code: purchase.error?.code,
            ));
          }
          return;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Validar server-side
          await _validateReceipt(purchase);
          if (!completer.isCompleted) {
            completer.complete(true);
          }
          // Confirmar a la store
          if (Platform.isAndroid) {
            await _inAppPurchase.completePurchase(purchase);
          } else {
            await _inAppPurchase.completePurchase(purchase);
          }
          break;

        case PurchaseStatus.canceled:
          if (!completer.isCompleted) {
            completer.completeError(
              const BillingFailure('Compra cancelada', code: 'canceled'),
            );
          }
          return;
      }
    }
  }

  Future<void> _validateReceipt(PurchaseDetails purchase) async {
    try {
      final platform = Platform.isAndroid ? 'android' : 'ios';
      final functionName =
          platform == 'android' ? 'validatePlayReceipt' : 'validateAppStoreReceipt';

      await _functions.httpsCallable(functionName).call({
        'purchase_token': purchase.verificationData.serverVerificationData,
        'product_id': purchase.productID,
        'platform': platform,
      });
    } on FirebaseFunctionsException catch (e) {
      throw BillingFailure(
        e.message ?? 'Error al validar receipt',
        code: e.code,
      );
    } catch (e) {
      throw BillingFailure('Error al validar: $e');
    }
  }

  @override
  Future<bool> restorePurchases() async {
    try {
      final available = await _inAppPurchase.isAvailable();
      if (!available) return false;

      final completer = Completer<bool>();
      _purchaseSub?.cancel();
      _purchaseSub = _inAppPurchase.purchaseStream.listen(
        (purchases) async {
          await _handlePurchases(purchases, completer);
        },
        onError: (e) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        },
      );

      await _inAppPurchase.restorePurchases();

      try {
        return await completer.future.timeout(
          const Duration(seconds: 30),
          onTimeout: () => false,
        );
      } catch (_) {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isPremium() async {
    final sub = await getCurrentSubscription();
    return sub?.isActive ?? false;
  }

  @override
  Stream<bool> watchIsPremium() {
    return watchSubscription().map((sub) => sub?.isActive ?? false);
  }

  // ============================================================
  // Helpers
  // ============================================================

  Subscription _mapDocToSubscription(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Subscription(
      subscriptionId: d['subscription_id'] as String? ?? doc.id,
      userUid: d['user_uid'] as String? ?? '',
      plan: d['plan'] as String? ?? 'monthly',
      platform: d['platform'] as String? ?? 'android',
      storeProductId: d['store_product_id'] as String? ?? '',
      startedAt: (d['started_at'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      expiresAt: (d['expires_at'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      autoRenew: d['auto_renew'] as bool? ?? false,
      status: d['status'] as String? ?? 'expired',
      lastReceiptId: d['last_receipt_id'] as String?,
      canceledAt: (d['canceled_at'] as Timestamp?)?.toDate(),
      isTrial: d['is_trial'] as bool? ?? false,
      trialEndsAt: (d['trial_ends_at'] as Timestamp?)?.toDate(),
    );
  }

  void dispose() {
    _purchaseSub?.cancel();
  }
}
