import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/offline_download_service.dart';

/// Widget que muestra el estado de descarga de un cuento.
///
/// Estados:
/// - No descargado: botón "Descargar" con icono
/// - Descargando: progress bar con %
/// - Descargado: icono check + opción eliminar
class DownloadButton extends ConsumerStatefulWidget {
  const DownloadButton({
    super.key,
    required this.storyId,
  });

  final String storyId;

  @override
  ConsumerState<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends ConsumerState<DownloadButton> {
  bool _isDownloading = false;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    final isDownloaded = ref.watch(isStoryDownloadedProvider(widget.storyId));

    return isDownloaded.when(
      loading: () => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      data: (downloaded) {
        if (_isDownloading) {
          return _buildDownloading(context);
        }
        if (downloaded) {
          return _buildDownloaded(context);
        }
        return _buildNotDownloaded(context);
      },
      error: (_, __) => const Icon(Icons.error_outline, size: 24),
    );
  }

  Widget _buildNotDownloaded(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.download_outlined),
      tooltip: 'Descargar para offline',
      onPressed: _startDownload,
    );
  }

  Widget _buildDownloading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              value: _progress,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 8),
          Text('${(_progress * 100).round()}%'),
        ],
      ),
    );
  }

  Widget _buildDownloaded(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.check_circle, color: Colors.green),
      tooltip: 'Disponible offline',
      onSelected: (value) async {
        if (value == 'remove') {
          await _removeDownload();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'remove',
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.red),
            title: Text('Eliminar descarga'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _progress = 0;
    });

    try {
      final service = await ref.read(offlineDownloadServiceProvider.future);
      await service.downloadStory(
        widget.storyId,
        onProgress: (p) {
          setState(() => _progress = p);
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al descargar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
        // Refrescar el provider
        ref.invalidate(isStoryDownloadedProvider(widget.storyId));
      }
    }
  }

  Future<void> _removeDownload() async {
    final service = await ref.read(offlineDownloadServiceProvider.future);
    await service.removeDownload(widget.storyId);
    ref.invalidate(isStoryDownloadedProvider(widget.storyId));
  }
}

/// Banner que se muestra cuando no hay conexión a internet.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, ref) {
    // En una app real, esto observaría connectivityProvider
    // Para MVP, lo dejamos como widget estático para usar cuando sea relevante
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.shade100,
      child: Row(
        children: [
          Icon(Icons.wifi_off, size: 18, color: Colors.orange.shade800),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Sin conexión. Mostrando cuentos descargados.',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
