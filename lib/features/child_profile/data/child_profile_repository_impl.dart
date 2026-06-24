import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/collection_names.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/child_profile.dart';
import '../../domain/entities/parental_settings.dart';
import '../../domain/repositories/child_profile_repository.dart';

/// Implementación de [ChildProfileRepository] que usa Cloud Firestore.
class ChildProfileRepositoryImpl implements ChildProfileRepository {
  ChildProfileRepositoryImpl({
    FirebaseFirestore? firestore,
    Uuid? uuid,
    String? currentUserUid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _uuid = uuid ?? const Uuid(),
        _currentUserUid = currentUserUid;

  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  /// UID del usuario actual. Se setea desde el provider al construir.
  /// Si es null, los métodos fallarán con [AuthFailure].
  final String? _currentUserUid;

  String get _uid {
    final uid = _currentUserUid;
    if (uid == null) {
      throw const AuthFailure('No hay usuario autenticado');
    }
    return uid;
  }

  // ============================================================
  // Perfiles de niños
  // ============================================================

  @override
  Future<ChildProfile> createChild({
    required String name,
    required int age,
    required String avatarUrl,
    List<String> interests = const [],
  }) async {
    try {
      final uid = _uid;
      final childId = _uuid.v4();
      final now = DateTime.now();

      // Validar límite de 4 perfiles activos en cliente.
      // Cloud Function también valida server-side.
      final existing = await getChildrenForUser(uid);
      if (existing.length >= 4) {
        throw const ValidationFailure(
            'Alcanzaste el límite de 4 perfiles de niños. '
            'Eliminá uno existente para crear uno nuevo.');
      }

      // Validar edad (2-7)
      if (age < 2 || age > 7) {
        throw const ValidationFailure('La edad debe estar entre 2 y 7 años');
      }

      // Validar nombre (1-20 chars, sin símbolos)
      final trimmedName = name.trim();
      if (trimmedName.isEmpty || trimmedName.length > 20) {
        throw const ValidationFailure(
            'El nombre debe tener entre 1 y 20 caracteres');
      }
      if (RegExp(r'[^\w\sáéíóúñÁÉÍÓÚÑ-]').hasMatch(trimmedName)) {
        throw const ValidationFailure(
            'El nombre solo puede contener letras, números y espacios');
      }

      final data = {
        'child_id': childId,
        'user_uid': uid,
        'name': trimmedName,
        'age': age,
        'avatar_url': avatarUrl,
        'interests': interests,
        'created_at': FieldValue.serverTimestamp(),
        'last_active_at': FieldValue.serverTimestamp(),
        'deleted_at': null,
      };

      await _firestore
          .collection(CollectionNames.childrenProfiles)
          .doc(childId)
          .set(data);

      // Releer para obtener timestamps del servidor
      final doc = await _firestore
          .collection(CollectionNames.childrenProfiles)
          .doc(childId)
          .get();

      return _mapDocToChildProfile(doc);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Error al crear perfil: $e');
    }
  }

  @override
  Future<ChildProfile> updateChild({
    required String childId,
    String? name,
    int? age,
    String? avatarUrl,
    List<String>? interests,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (name != null) {
        final trimmed = name.trim();
        if (trimmed.isEmpty || trimmed.length > 20) {
          throw const ValidationFailure(
              'El nombre debe tener entre 1 y 20 caracteres');
        }
        updates['name'] = trimmed;
      }

      if (age != null) {
        if (age < 2 || age > 7) {
          throw const ValidationFailure(
              'La edad debe estar entre 2 y 7 años');
        }
        updates['age'] = age;
      }

      if (avatarUrl != null) {
        updates['avatar_url'] = avatarUrl;
      }

      if (interests != null) {
        updates['interests'] = interests;
      }

      if (updates.isNotEmpty) {
        await _firestore
            .collection(CollectionNames.childrenProfiles)
            .doc(childId)
            .update(updates);
      }

      final doc = await _firestore
          .collection(CollectionNames.childrenProfiles)
          .doc(childId)
          .get();
      return _mapDocToChildProfile(doc);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Error al actualizar perfil: $e');
    }
  }

  @override
  Future<void> softDeleteChild(String childId) async {
    try {
      await _firestore
          .collection(CollectionNames.childrenProfiles)
          .doc(childId)
          .update({
        'deleted_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw UnknownFailure('Error al eliminar perfil: $e');
    }
  }

  @override
  Future<List<ChildProfile>> getChildrenForUser(String userUid) async {
    try {
      final snap = await _firestore
          .collection(CollectionNames.childrenProfiles)
          .where('user_uid', isEqualTo: userUid)
          .where('deleted_at', isNull: true)
          .orderBy('last_active_at', descending: true)
          .get();

      return snap.docs.map(_mapDocToChildProfile).toList();
    } catch (e) {
      throw UnknownFailure('Error al leer perfiles: $e');
    }
  }

  @override
  Stream<List<ChildProfile>> watchChildrenForUser(String userUid) {
    try {
      return _firestore
          .collection(CollectionNames.childrenProfiles)
          .where('user_uid', isEqualTo: userUid)
          .where('deleted_at', isNull: true)
          .orderBy('last_active_at', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map(_mapDocToChildProfile).toList());
    } catch (e) {
      throw UnknownFailure('Error al observar perfiles: $e');
    }
  }

  @override
  Future<ChildProfile> getChild(String childId) async {
    try {
      final doc = await _firestore
          .collection(CollectionNames.childrenProfiles)
          .doc(childId)
          .get();

      if (!doc.exists) {
        throw const NotFoundFailure('Perfil no encontrado');
      }

      return _mapDocToChildProfile(doc);
    } on Failure {
      rethrow;
    } catch (e) {
      throw UnknownFailure('Error al leer perfil: $e');
    }
  }

  @override
  Future<void> updateLastActive(String childId) async {
    try {
      await _firestore
          .collection(CollectionNames.childrenProfiles)
          .doc(childId)
          .update({
        'last_active_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // No propagar error: este método es best-effort
    }
  }

  // ============================================================
  // Configuración parental
  // ============================================================

  @override
  Future<ParentalSettings> getParentalSettings(String userUid) async {
    try {
      final doc = await _firestore
          .collection(CollectionNames.parentalSettings)
          .doc(userUid)
          .get();

      if (!doc.exists) {
        // Retorna defaults si no existe (Cloud Function debería crearlo
        // automáticamente, pero defensivo)
        return ParentalSettings(userUid: userUid);
      }

      return _mapDocToParentalSettings(doc);
    } catch (e) {
      throw UnknownFailure('Error al leer configuración parental: $e');
    }
  }

  @override
  Future<void> updateParentalSettings(ParentalSettings settings) async {
    try {
      await _firestore
          .collection(CollectionNames.parentalSettings)
          .doc(settings.userUid)
          .set(settings.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw UnknownFailure('Error al guardar configuración parental: $e');
    }
  }

  // ============================================================
  // Helpers de mapeo
  // ============================================================

  ChildProfile _mapDocToChildProfile(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ChildProfile(
      childId: data['child_id'] as String? ?? doc.id,
      userUid: data['user_uid'] as String? ?? '',
      name: data['name'] as String? ?? 'Niño',
      age: (data['age'] as num?)?.toInt() ?? 4,
      avatarUrl: data['avatar_url'] as String? ?? '🐻',
      interests: (data['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      lastActiveAt: (data['last_active_at'] as Timestamp?)?.toDate(),
      deletedAt: (data['deleted_at'] as Timestamp?)?.toDate(),
    );
  }

  ParentalSettings _mapDocToParentalSettings(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ParentalSettings(
      userUid: data['user_uid'] as String? ?? doc.id,
      dailyLimitMinutes: (data['daily_limit_minutes'] as num?)?.toInt() ?? 0,
      blockedCategories:
          (data['blocked_categories'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const [],
      allowOfflineDownload: data['allow_offline_download'] as bool? ?? true,
      allowAnalytics: data['allow_analytics'] as bool? ?? false,
      allowPersonalizedAds: data['allow_personalized_ads'] as bool? ?? false,
      bedtimeStart: data['bedtime_start'] as String?,
      bedtimeEnd: data['bedtime_end'] as String?,
    );
  }
}
