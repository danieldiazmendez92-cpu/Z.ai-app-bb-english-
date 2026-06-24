// =============================================================================
// story_provider.dart - Providers para feature/story
// =============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:storyenglish_kids/shared/providers/child_profile_provider.dart';
import '../../data/story_repository_impl.dart';
import '../../domain/repositories/story_repository.dart';

/// Provider singleton del [StoryRepository].
final storyRepositoryProvider = Provider<StoryRepository>((ref) {
  return StoryRepositoryImpl();
});
