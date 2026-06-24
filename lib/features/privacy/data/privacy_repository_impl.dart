import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:storyenglish_kids/shared/providers/auth_provider.dart';
import '../../domain/entities/consent_state.dart';
import '../../domain/repositories/privacy_repository.dart';

/// Implementación de [PrivacyRepository] que usa Firebase.
class PrivacyRepositoryImpl implements PrivacyRepository {
  PrivacyRepositoryImpl({
    FirebaseFunctions? functions,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _functions = functions ?? FirebaseFunctions.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  @override
  Future<void> grantConsent(ConsentState consent) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No autenticado');

    await _firestore
        .collection('user_consents')
        .doc(user.uid)
        .set({
      'user_uid': user.uid,
      'necessary': true,
      'analytics': consent.analytics,
      'personalization': consent.personalization,
      'granted_at': FieldValue.serverTimestamp(),
      'privacy_policy_version': '1.0',
    }, SetOptions(merge: true));
  }

  @override
  Future<ConsentState> getConsent() async {
    final user = _auth.currentUser;
    if (user == null) return const ConsentState();

    final doc = await _firestore
        .collection('user_consents')
        .doc(user.uid)
        .get();

    if (!doc.exists) return const ConsentState();

    final d = doc.data()!;
    return ConsentState(
      analytics: d['analytics'] as bool? ?? false,
      personalization: d['personalization'] as bool? ?? false,
    );
  }

  @override
  Future<String> exportUserData() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No autenticado');

    // Llamar a Cloud Function que recopila todos los datos del usuario
    final result = await _functions
        .httpsCallable('exportUserData')
        .call<Map<String, dynamic>>({'uid': user.uid});

    final data = result.data;
    // Generar JSON descargable
    final json = data['json'] as String;
    return json;
  }

  @override
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No autenticado');

    // 1. Marcar perfiles de niños para borrado (COPPA cleanup en 30 días)
    final childrenSnap = await _firestore
        .collection('children_profiles')
        .where('user_uid', isEqualTo: user.uid)
        .get();

    final batch = _firestore.batch();
    for (final doc in childrenSnap.docs) {
      batch.update(doc.reference, {
        'deleted_at': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();

    // 2. Eliminar datos no sensibles inmediatamente
    // (analytics_events, user_progress, user_achievements, reading_sessions)
    await _deleteCollection('user_progress', 'child_id',
        childrenSnap.docs.map((d) => d.id).toList());
    await _deleteCollection('user_achievements', 'child_id',
        childrenSnap.docs.map((d) => d.id).toList());

    // 3. Eliminar doc de parental_settings y user_consents
    await _firestore
        .collection('parental_settings')
        .doc(user.uid)
        .delete();
    await _firestore
        .collection('user_consents')
        .doc(user.uid)
        .delete();

    // 4. Eliminar doc del usuario
    await _firestore.collection('users').doc(user.uid).delete();

    // 5. Eliminar cuenta de Auth (último paso)
    await user.delete();
  }

  Future<void> _deleteCollection(
      String collection, String field, List<String> ids) async {
    if (ids.isEmpty) return;
    final snap = await _firestore
        .collection(collection)
        .where(field, whereIn: ids)
        .get();

    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
