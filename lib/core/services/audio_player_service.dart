// =============================================================================
// audio_player_service.dart - Wrapper de just_audio
// -----------------------------------------------------------------------------
// Servicio singleton que envuelve `just_audio.AudioPlayer` con una API simple:
//   - load(url, timestamps) - precarga audio + JSON de timestamps.
//   - play(), pause(), stop(), seekTo(ms)
//   - onPositionChanged - stream de posicion en ms (para resaltado).
//   - setSpeed(1.0|1.25|1.5|0.75)
//
// En Fase 1 se integrara con `audio_service` para background audio.
// =============================================================================

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../constants/app_constants.dart';
import '../utils/logger.dart';

/// Timestamp de una palabra para sincronizacion de resaltado.
/// (No es modelo freezed porque es efimero y vive solo en runtime.)
class AudioWordTimestamp {
  const AudioWordTimestamp({
    required this.word,
    required this.startMs,
    required this.endMs,
  });

  final String word;
  final int startMs;
  final int endMs;
}

/// Servicio reproductor de audio.
///
/// Una sola instancia compartida por toda la app. El reader screen la usa para
/// reproducir el cuento y resaltar palabra actual.
class AudioPlayerService {
  AudioPlayerService() : _player = AudioPlayer();

  final AudioPlayer _player;

  /// Lista de timestamps de palabras del audio actual.
  List<AudioWordTimestamp> _timestamps = const [];

  /// Stream de posicion en milisegundos (emite cada 100ms mientras reproduce).
  Stream<int> get onPositionChangedMs {
    return _player.positionStream.map((p) => p.inMilliseconds).distinct();
  }

  /// Stream de estado de reproduccion.
  Stream<bool> get onPlayingChanged => _player.playingStream;

  /// Stream de finalizacion (emite cuando el audio termina).
  Stream<void> get onCompleted => _player.playerStateStream
      .where((s) => s.processingState == ProcessingState.completed)
      .map((_) {});

  /// Duracion total en milisegundos (0 si no se ha cargado).
  Future<int> get durationMs async =>
      (await _player.duration)?.inMilliseconds ?? 0;

  /// Posicion actual en milisegundos.
  int get currentMs => _player.position.inMilliseconds;

  /// Carga un audio desde una URL y opcionalmente los timestamps.
  Future<void> load({
    required String audioUrl,
    List<AudioWordTimestamp>? timestamps,
  }) async {
    AppLogger.info('AudioPlayerService.load: $audioUrl');
    _timestamps = timestamps ?? const [];
    try {
      await _player.setUrl(audioUrl);
      await _player.setSpeed(AppConstants.defaultAudioSpeed);
    } catch (e, st) {
      AppLogger.error('AudioPlayerService.load error', e, st);
      rethrow;
    }
  }

  /// Inicia reproduccion (o resume si esta pausado).
  Future<void> play() async {
    try {
      await _player.play();
    } catch (e, st) {
      AppLogger.error('AudioPlayerService.play error', e, st);
      rethrow;
    }
  }

  /// Pausa la reproduccion.
  Future<void> pause() async {
    await _player.pause();
  }

  /// Detiene y rebobina al inicio.
  Future<void> stop() async {
    await _player.stop();
    await _player.seek(Duration.zero);
  }

  /// Salta a una posicion en milisegundos.
  Future<void> seekToMs(int ms) async {
    await _player.seek(Duration(milliseconds: ms));
  }

  /// Cambia velocidad de reproduccion.
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  /// Devuelve la palabra correspondiente a [positionMs], o null si no hay match.
  /// Usado por el reader para resaltar palabra actual.
  String? wordAtMs(int positionMs) {
    for (final ts in _timestamps) {
      if (positionMs >= ts.startMs && positionMs < ts.endMs) {
        return ts.word;
      }
    }
    return null;
  }

  /// Devuelve el indice de la palabra actual (para resaltado por indice).
  int wordIndexAtMs(int positionMs) {
    for (var i = 0; i < _timestamps.length; i++) {
      final ts = _timestamps[i];
      if (positionMs >= ts.startMs && positionMs < ts.endMs) {
        return i;
      }
    }
    return -1;
  }

  /// Libera recursos. Llamar al hacer dispose del widget que lo usa.
  void dispose() {
    _player.dispose();
  }
}

/// Provider de Riverpod para `AudioPlayerService`.
///
/// Se mantiene vivo mientras la app esta corriendo (no se hace autoDispose
/// porque el audio debe continuar al navegar entre screens del cuento).
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(service.dispose);
  return service;
});
