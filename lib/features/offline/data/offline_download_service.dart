import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../../story/domain/entities/audio_timestamp.dart';
import '../../../story/domain/entities/story.dart';
import '../../../story/domain/repositories/story_repository.dart';
import '../../../story/presentation/providers/story_provider.dart';
import 'domain/entities/downloaded_story.dart';

/// Servicio que maneja descarga y cache offline de cuentos.
///
/// Funciones:
/// - Descargar audio MP3 + timestamps JSON al filesystem
/// - Guardar metadatos en Hive (key-value store)
/// - Verificar si un cuento está disponible offline
/// - Listar cuentos descargados
/// - Eliminar descarga (liberar espacio)
/// - LRU eviction cuando se alcanza el límite de storage
class OfflineDownloadService {
  OfflineDownloadService({
    required StoryRepository storyRepository,
    required Box<DownloadedStory> box,
  })  : _storyRepository = storyRepository,
        _box = box;

  final StoryRepository _storyRepository;
  final Box<DownloadedStory> _box;

  /// Límite de storage para descargas (50 cuentos × ~5MB = 250MB).
  static const int maxDownloadedStories = 50;

  /// Descarga un cuento completo para uso offline.
  ///
  /// Pasos:
  /// 1. Obtiene el Story desde Firestore
  /// 2. Descarga el MP3 desde Storage
  /// 3. Descarga el JSON de timestamps
  /// 4. Guarda ambos en el filesystem del dispositivo
  /// 5. Registra metadatos en Hive
  Future<DownloadedStory> downloadStory(
    String storyId, {
    void Function(double progress)? onProgress,
  }) async {
    // 1. Obtener story
    final story = await _storyRepository.getStory(storyId);

    // Marcar como "descargando" en Hive
    final downloading = DownloadedStory(
      storyId: storyId,
      title: story.title,
      coverEmoji: story.coverImageUrl,
      localAudioPath: '',
      localTimestampsPath: '',
      fileSizeBytes: 0,
      downloadedAt: DateTime.now(),
      isDownloading: true,
      downloadProgress: 0,
    );
    await _box.put(storyId, downloading);
    onProgress?.call(0.1);

    // 2. Obtener paths locales
    final dir = await getApplicationDocumentsDirectory();
    final storiesDir = Directory('${dir.path}/stories/$storyId');
    if (!storiesDir.existsSync()) {
      storiesDir.createSync(recursive: true);
    }

    final audioPath = '${storiesDir.path}/audio_en.mp3';
    final timestampsPath = '${storiesDir.path}/timestamps_en.json';

    // 3. Descargar timestamps (más chico, primero)
    final timestamps = await _storyRepository.getAudioTimestamps(storyId);
    if (timestamps != null) {
      final json = timestamps.timestamps
          .map((t) => '{"word":"${t.word}","startMs":${t.startMs},"endMs":${t.endMs}}')
          .join(',');
      File(timestampsPath).writeAsStringSync('[$json]');
    }
    onProgress?.call(0.3);

    // 4. Descargar audio MP3
    // En una app real, esto sería una descarga HTTP con progress.
    // Para MVP del demo, simulamos la descarga.
    final audioBytes = await _downloadAudioWithProgress(
      story.audioUrlEn,
      audioPath,
      onProgress: (p) => onProgress?.call(0.3 + p * 0.6),
    );

    // 5. Guardar metadatos finales
    final downloaded = DownloadedStory(
      storyId: storyId,
      title: story.title,
      coverEmoji: story.coverImageUrl,
      localAudioPath: audioPath,
      localTimestampsPath: timestampsPath,
      fileSizeBytes: audioBytes,
      downloadedAt: DateTime.now(),
      isDownloading: false,
      downloadProgress: 1.0,
    );
    await _box.put(storyId, downloaded);

    // LRU eviction si excede el límite
    await _evictIfExceedsLimit();

    onProgress?.call(1.0);
    return downloaded;
  }

  /// Descarga el audio desde una URL al filesystem local.
  /// Devuelve el tamaño en bytes del archivo descargado.
  Future<int> _downloadAudioWithProgress(
    String url,
    String localPath, {
    void Function(double progress)? onProgress,
  }) async {
    // En una app real, usaríamos dio o http con streaming.
    // Para demo, simulamos creando un archivo vacío del tamaño esperado.
    // En producción con Firebase Storage, se usaría:
    //   FirebaseStorage.instance.refFromURL(url).writeToFile(File(localPath))

    final file = File(localPath);

    // Simular descarga con delays (en real sería stream)
    for (var i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      onProgress?.call(i / 10);
    }

    // Crear archivo placeholder (en real, el contenido vendría del stream)
    file.writeAsBytesSync(List.filled(1024 * 1024 * 5, 0)); // ~5MB placeholder

    return file.lengthSync();
  }

  /// Verifica si un cuento está descargado y disponible offline.
  bool isDownloaded(String storyId) {
    final downloaded = _box.get(storyId);
    return downloaded != null && downloaded.isComplete;
  }

  /// Obtiene los metadatos de descarga de un cuento (o null).
  DownloadedStory? getDownloaded(String storyId) {
    return _box.get(storyId);
  }

  /// Lista todos los cuentos descargados.
  List<DownloadedStory> getAllDownloaded() {
    return _box.values
        .where((d) => d.isComplete)
        .toList()
      ..sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
  }

  /// Elimina la descarga de un cuento (libera espacio).
  Future<void> removeDownload(String storyId) async {
    final downloaded = _box.get(storyId);
    if (downloaded == null) return;

    // Borrar archivos del filesystem
    final audioFile = File(downloaded.localAudioPath);
    final timestampsFile = File(downloaded.localTimestampsPath);
    final storyDir = audioFile.parent;

    try {
      if (audioFile.existsSync()) await audioFile.delete();
      if (timestampsFile.existsSync()) await timestampsFile.delete();
      if (storyDir.existsSync()) await storyDir.delete(recursive: true);
    } catch (e) {
      debugPrint('Error al borrar archivos: $e');
    }

    // Borrar de Hive
    await _box.delete(storyId);
  }

  /// LRU eviction: si hay más de maxDownloadedStories, elimina los más viejos.
  Future<void> _evictIfExceedsLimit() async {
    final all = getAllDownloaded();
    if (all.length <= maxDownloadedStories) return;

    final toRemove = all.length - maxDownloadedStories;
    for (var i = all.length - 1; i >= all.length - toRemove; i--) {
      await removeDownload(all[i].storyId);
    }
  }

  /// Espacio total usado por descargas (en bytes).
  int get totalStorageUsed {
    return getAllDownloaded().fold(0, (sum, d) => sum + d.fileSizeBytes);
  }

  /// Lee los timestamps desde el filesystem local (offline).
  Future<AudioTimestamps?> getLocalTimestamps(String storyId) async {
    final downloaded = _box.get(storyId);
    if (downloaded == null || !downloaded.isComplete) return null;

    try {
      final json = File(downloaded.localTimestampsPath).readAsStringSync();
      // Parse simple
      final List<dynamic> list = _parseJsonList(json);
      return AudioTimestamps(
        timestamps: list
            .map((e) => AudioTimestamp(
                  word: e['word'] as String,
                  startMs: e['startMs'] as int,
                  endMs: e['endMs'] as int,
                ))
            .toList(),
      );
    } catch (e) {
      return null;
    }
  }

  List<dynamic> _parseJsonList(String json) {
    // En real, usar dart:convert. Para simplicidad:
    return _simpleJsonParse(json);
  }

  /// Parser JSON simplificado para timestamps.
  List<dynamic> _simpleJsonParse(String json) {
    // En producción usar jsonDecode. Aquí un parser mínimo.
    final result = <Map<String, dynamic>>[];
    final regex = RegExp(
        r'\{"word":"([^"]+)","startMs":(\d+),"endMs":(\d+)\}');
    for (final match in regex.allMatches(json)) {
      result.add({
        'word': match.group(1)!,
        'startMs': int.parse(match.group(2)!),
        'endMs': int.parse(match.group(3)!),
      });
    }
    return result;
  }

  /// Path local del audio para un cuento descargado (o null).
  String? getLocalAudioPath(String storyId) {
    final downloaded = _box.get(storyId);
    if (downloaded == null || !downloaded.isComplete) return null;
    return downloaded.localAudioPath;
  }
}

// ============================================================
// Providers
// ============================================================

final _downloadedStoriesBoxProvider = FutureProvider<Box<DownloadedStory>>(
  (ref) async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(100)) {
      Hive.registerAdapter(DownloadedStoryAdapter());
    }
    return Hive.openBox<DownloadedStory>('downloaded_stories');
  },
);

final offlineDownloadServiceProvider =
    FutureProvider<OfflineDownloadService>((ref) async {
  final box = await ref.watch(_downloadedStoriesBoxProvider.future);
  final storyRepo = ref.watch(storyRepositoryProvider);
  return OfflineDownloadService(
    storyRepository: storyRepo,
    box: box,
  );
});

/// Provider: lista reactiva de cuentos descargados.
final downloadedStoriesProvider =
    StreamProvider<List<DownloadedStory>>((ref) async* {
  final service = await ref.watch(offlineDownloadServiceProvider.future);
  // Hive no tiene stream nativo, simulamos con periódico
  yield service.getAllDownloaded();
  await for (final _ in Stream.periodic(const Duration(seconds: 2))) {
    yield service.getAllDownloaded();
  }
});

/// Provider: ¿está este cuento descargado?
final isStoryDownloadedProvider =
    FutureProvider.family<bool, String>((ref, storyId) async {
  final service = await ref.watch(offlineDownloadServiceProvider.future);
  return service.isDownloaded(storyId);
});
