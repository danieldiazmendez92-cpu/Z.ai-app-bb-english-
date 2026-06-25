import 'package:freezed_annotation/freezed_annotation.dart';

part 'downloaded_story.freezed.dart';
part 'downloaded_story.g.dart';

/// Metadatos de un cuento descargado para uso offline.
///
/// El contenido binario (audio MP3, timestamps JSON) se guarda en
/// el filesystem del dispositivo. Este documento en Hive guarda
/// los metadatos + paths locales.
@freezed
class DownloadedStory with _$DownloadedStory {
  const factory DownloadedStory({
    required String storyId,
    required String title,
    required String coverEmoji,
    required String localAudioPath,
    required String localTimestampsPath,
    required int fileSizeBytes,
    required DateTime downloadedAt,
    @Default(false) bool isDownloading,
    double? downloadProgress,
  }) = _DownloadedStory;

  factory DownloadedStory.fromJson(Map<String, dynamic> json) =>
      _$DownloadedStoryFromJson(json);

  const DownloadedStory._();

  /// True si está completamente descargado.
  bool get isComplete => !isDownloading && localAudioPath.isNotEmpty;

  /// Tamaño en MB (para mostrar al usuario).
  double get sizeMb => fileSizeBytes / (1024 * 1024);
}
