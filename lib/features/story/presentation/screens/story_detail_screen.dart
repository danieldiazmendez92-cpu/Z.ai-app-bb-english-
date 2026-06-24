import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/se_button.dart';
import '../../domain/entities/story.dart';
import '../../domain/entities/vocabulary_word.dart';
import '../../domain/repositories/story_repository.dart';
import '../../presentation/providers/story_provider.dart';

/// Pantalla de detalle de un cuento.
///
/// Muestra:
/// - Portada grande
/// - Título, edad, duración
/// - Descripción/fuente
/// - Vocabulario destacado (preview)
/// - Botón "Leer" que navega al Reader
class StoryDetailScreen extends ConsumerStatefulWidget {
  const StoryDetailScreen({
    super.key,
    required this.storyId,
  });

  final String storyId;

  @override
  ConsumerState<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends ConsumerState<StoryDetailScreen> {
  Story? _story;
  List<VocabularyWord> _vocabulary = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(storyRepositoryProvider);
      final story = await repo.getStory(widget.storyId);
      final vocab = await repo.getStoryVocabulary(widget.storyId);
      if (mounted) {
        setState(() {
          _story = story;
          _vocabulary = vocab.where((v) => v.isHighlighted).take(6).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _story == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              Text(_error ?? 'Cuento no encontrado'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final story = _story!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Portada grande con AppBar transparente
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'story-cover-${story.storyId}',
                child: _buildCover(story),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    story.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Meta info
                  Row(
                    children: [
                      _MetaChip(
                        icon: Icons.cake_outlined,
                        label: story.ageRange,
                      ),
                      const SizedBox(width: 8),
                      _MetaChip(
                        icon: Icons.schedule,
                        label: '${story.durationMinutes} min',
                      ),
                      if (story.hasSpanishAudio) ...[
                        const SizedBox(width: 8),
                        _MetaChip(
                          icon: Icons.translate,
                          label: 'ES',
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Fuente
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.public, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Fuente: ${story.sourceAttribution}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Vocabulario destacado
                  if (_vocabulary.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Palabras que vas a aprender',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _vocabulary.map((v) {
                        return Chip(
                          label: Text('${v.wordEn} = ${v.wordEs}'),
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.1),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Botón leer
                  SEButton(
                    onPressed: () =>
                        context.push(Routes.readerFor(story.storyId)),
                    label: 'Empezar a leer',
                    icon: Icons.play_arrow,
                    size: SEButtonSize.large,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover(Story story) {
    if (story.coverImageUrl.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.primary,
        child: const Center(
          child: Icon(Icons.auto_stories, size: 80, color: Colors.white),
        ),
      );
    }

    // Si es emoji
    if (story.coverImageUrl.length <= 4) {
      return Container(
        color: Theme.of(context).colorScheme.primary,
        child: Center(
          child: Text(
            story.coverImageUrl,
            style: const TextStyle(fontSize: 100),
          ),
        ),
      );
    }

    // Si es URL
    if (story.coverImageUrl.startsWith('http')) {
      return Image.network(
        story.coverImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    return Container(
      color: Theme.of(context).colorScheme.primary,
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
