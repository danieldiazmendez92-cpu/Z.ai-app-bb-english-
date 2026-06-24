import 'dart:async';

import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import '../utils/logger.dart';
import 'audio_player_service.dart';

/// Servicio de audio DEMO que simula reproducción sin audio real.
///
/// Útil para probar el reader (resaltado sincronizado, controles) sin
/// necesidad de archivos MP3 o conexión a internet.
///
/// Simula:
/// - play()/pause()/stop()
/// - positionStream (avanza 100ms por tick)
/// - duration (calculada de los timestamps)
/// - seek (salta a posición)
/// - speed (afecta velocidad de avance)
class DemoAudioPlayerService implements AudioPlayerService {
  DemoAudioPlayerService();

  Timer? _timer;
  int _positionMs = 0;
  int _durationMs = 0;
  double _speed = 1.0;
  bool _isPlaying = false;
  bool _isCompleted = false;

  final StreamController<int> _positionController =
      StreamController<int>.broadcast();
  final StreamController<bool> _playingController =
      StreamController<bool>.broadcast();
  final StreamController<void> _completedController =
      StreamController<void>.broadcast();

  List<AudioWordTimestamp> _timestamps = const [];

  @override
  Stream<int> get onPositionChangedMs => _positionController.stream;

  @override
  Stream<bool> get onPlayingChanged => _playingController.stream;

  @override
  Stream<void> get onCompleted => _completedController.stream;

  @override
  Future<int> get durationMs async => _durationMs;

  @override
  int get currentMs => _positionMs;

  @override
  Future<void> load({
    required String audioUrl,
    List<AudioWordTimestamp>? timestamps,
  }) async {
    AppLogger.info('DemoAudioPlayerService.load: $audioUrl');
    _timestamps = timestamps ?? const [];

    // Calcular duración basada en el último timestamp
    if (_timestamps.isNotEmpty) {
      _durationMs = _timestamps.last.endMs;
    } else {
      // Sin timestamps: asumir 3 minutos
      _durationMs = 180000;
    }

    _positionMs = 0;
    _isCompleted = false;
    AppLogger.info('Demo audio loaded. Duration: ${_durationMs}ms');
  }

  @override
  Future<void> play() async {
    if (_isPlaying) return;
    if (_isCompleted) {
      // Si terminó, rebobinar al inicio
      _positionMs = 0;
      _isCompleted = false;
    }

    _isPlaying = true;
    _playingController.add(true);

    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!_isPlaying) return;

      // Avanzar según speed
      _positionMs += (100 * _speed).round();

      // Emitir nueva posición
      _positionController.add(_positionMs);

      // Verificar fin
      if (_positionMs >= _durationMs) {
        _positionMs = _durationMs;
        _isPlaying = false;
        _isCompleted = true;
        _playingController.add(false);
        _completedController.add(null);
        _timer?.cancel();
      }
    });
  }

  @override
  Future<void> pause() async {
    _isPlaying = false;
    _timer?.cancel();
    _playingController.add(false);
  }

  @override
  Future<void> stop() async {
    _isPlaying = false;
    _timer?.cancel();
    _positionMs = 0;
    _playingController.add(false);
  }

  @override
  Future<void> seekToMs(int ms) async {
    _positionMs = ms.clamp(0, _durationMs);
    _positionController.add(_positionMs);
    _isCompleted = _positionMs >= _durationMs;
  }

  @override
  Future<void> setSpeed(double speed) async {
    _speed = speed;
  }

  @override
  String? wordAtMs(int positionMs) {
    for (final ts in _timestamps) {
      if (positionMs >= ts.startMs && positionMs < ts.endMs) {
        return ts.word;
      }
    }
    return null;
  }

  @override
  int wordIndexAtMs(int positionMs) {
    for (var i = 0; i < _timestamps.length; i++) {
      final ts = _timestamps[i];
      if (positionMs >= ts.startMs && positionMs < ts.endMs) {
        return i;
      }
    }
    return -1;
  }

  void dispose() {
    _timer?.cancel();
    _positionController.close();
    _playingController.close();
    _completedController.close();
  }
}
