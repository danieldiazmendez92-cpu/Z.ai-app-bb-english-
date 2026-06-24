import 'dart:async';

import 'package:uuid/uuid.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/child_profile.dart';
import '../../domain/entities/parental_settings.dart';
import '../../domain/repositories/child_profile_repository.dart';

/// Repositorio de perfiles de niños DEMO.
///
/// Mantiene todo en memoria. Pre-crea 1 hijo para que el flujo sea
/// más rápido de probar.
class DemoChildProfileRepository implements ChildProfileRepository {
  DemoChildProfileRepository({String? userUid})
      : _userUid = userUid,
        _children = userUid == null
            ? []
            : [
                ChildProfile(
                  childId: 'demo-child-001',
                  userUid: userUid,
                  name: 'Sofi',
                  age: 4,
                  avatarUrl: '🦊',
                  interests: ['animals', 'adventure', 'bedtime'],
                  createdAt: DateTime(2026, 6, 1),
                  lastActiveAt: DateTime.now(),
                ),
              ],
        _parentalSettings = ParentalSettings(
          userUid: userUid ?? 'demo',
          dailyLimitMinutes: 30,
          blockedCategories: [],
          allowOfflineDownload: true,
          allowAnalytics: false,
          allowPersonalizedAds: false,
        );

  final String? _userUid;
  final List<ChildProfile> _children;
  ParentalSettings _parentalSettings;
  final _uuid = const Uuid();

  final StreamController<List<ChildProfile>> _childrenController =
      StreamController<List<ChildProfile>>.broadcast();

  @override
  Future<ChildProfile> createChild({
    required String name,
    required int age,
    required String avatarUrl,
    List<String> interests = const [],
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_children.where((c) => c.deletedAt == null).length >= 4) {
      throw const ValidationFailure(
          'Alcanzaste el límite de 4 perfiles de niños.');
    }
    final child = ChildProfile(
      childId: _uuid.v4(),
      userUid: _userUid ?? 'demo',
      name: name,
      age: age,
      avatarUrl: avatarUrl,
      interests: interests,
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
    _children.add(child);
    _emitChildren();
    return child;
  }

  @override
  Future<ChildProfile> updateChild({
    required String childId,
    String? name,
    int? age,
    String? avatarUrl,
    List<String>? interests,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _children.indexWhere((c) => c.childId == childId);
    if (idx == -1) throw const NotFoundFailure('Perfil no encontrado');
    final updated = _children[idx].copyWith(
      name: name ?? _children[idx].name,
      age: age ?? _children[idx].age,
      avatarUrl: avatarUrl ?? _children[idx].avatarUrl,
      interests: interests ?? _children[idx].interests,
    );
    _children[idx] = updated;
    _emitChildren();
    return updated;
  }

  @override
  Future<void> softDeleteChild(String childId) async {
    final idx = _children.indexWhere((c) => c.childId == childId);
    if (idx == -1) return;
    _children[idx] = _children[idx].copyWith(deletedAt: DateTime.now());
    _emitChildren();
  }

  @override
  Future<List<ChildProfile>> getChildrenForUser(String userUid) async {
    return _children.where((c) => c.deletedAt == null).toList();
  }

  @override
  Stream<List<ChildProfile>> watchChildrenForUser(String userUid) {
    // Emitir estado inicial
    Future.microtask(() => _emitChildren());
    return _childrenController.stream;
  }

  void _emitChildren() {
    _childrenController.add(_children.where((c) => c.deletedAt == null).toList());
  }

  @override
  Future<ChildProfile> getChild(String childId) async {
    final child = _children.firstWhere(
      (c) => c.childId == childId,
      orElse: () => throw const NotFoundFailure('Perfil no encontrado'),
    );
    return child;
  }

  @override
  Future<void> updateLastActive(String childId) async {
    final idx = _children.indexWhere((c) => c.childId == childId);
    if (idx != -1) {
      _children[idx] = _children[idx].copyWith(lastActiveAt: DateTime.now());
    }
  }

  @override
  Future<ParentalSettings> getParentalSettings(String userUid) async {
    return _parentalSettings;
  }

  @override
  Future<void> updateParentalSettings(ParentalSettings settings) async {
    _parentalSettings = settings;
  }

  void dispose() {
    _childrenController.close();
  }
}
