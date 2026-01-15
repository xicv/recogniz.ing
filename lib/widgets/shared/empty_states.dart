import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_theme.dart';

/// Enhanced empty state widgets with engaging visuals and clear CTAs.
///
/// Empty states are opportunities for user engagement and education.
/// These components provide clear guidance on what to do next while
/// maintaining visual appeal through illustrations and animations.
///
/// Material Design 3 Principles Applied:
/// - Clear visual hierarchy with appropriate spacing
/// - Action-oriented primary actions
/// - Accessible color contrast
/// - Meaningful illustrations using icons
///
/// Usage:
/// ```dart
/// EmptyState.transcription(
///   hasApiKey: true,
///   onStartRecording: () => print('Start recording'),
/// )
/// ```

/// Base empty state widget with illustration, message, and action button.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final Color? iconColor;

  const EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.iconColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration icon
              _buildIcon(context),
              const SizedBox(height: 28),

              // Title
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 12),

              // Message
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 32),

              // Actions
              _buildActions(context).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveIconColor = iconColor ?? colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            effectiveIconColor.withValues(alpha: 0.15),
            effectiveIconColor.withValues(alpha: 0.05),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 52,
        color: effectiveIconColor,
      ),
    ).animate().scale(
          duration: 600.ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildActions(BuildContext context) {
    final children = <Widget>[];

    if (actionLabel != null && onAction != null) {
      children.add(
        FilledButton.icon(
          onPressed: onAction,
          icon: const Icon(LucideIcons.mic, size: 18),
          label: Text(actionLabel!),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
        ),
      );
    }

    if (secondaryActionLabel != null && onSecondaryAction != null) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(width: 12));
      }
      children.add(
        OutlinedButton.icon(
          onPressed: onSecondaryAction,
          icon: const Icon(LucideIcons.settings, size: 18),
          label: Text(secondaryActionLabel!),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
        ),
      );
    }

    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}

/// Empty state for transcriptions page.
///
/// Shows different content based on whether user has API key configured.
class TranscriptionEmptyState extends StatelessWidget {
  final bool hasApiKey;
  final VoidCallback? onStartRecording;
  final VoidCallback? onOpenSettings;

  const TranscriptionEmptyState({
    required this.hasApiKey,
    this.onStartRecording,
    this.onOpenSettings,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (hasApiKey) {
      return EmptyState(
        icon: LucideIcons.mic,
        iconColor: colorScheme.primary,
        title: 'No transcriptions yet',
        message:
            'Tap the record button to capture your voice and transcribe it to text.',
        actionLabel: 'Start Recording',
        onAction: onStartRecording,
      );
    }

    return EmptyState(
      icon: LucideIcons.key,
      iconColor: colorScheme.error,
      title: 'API Key Required',
      message:
          'Add your Gemini API key to start transcribing your voice recordings.',
      actionLabel: 'Add API Key',
      onAction: onOpenSettings,
    );
  }
}

/// Empty state for search results.
///
/// Shows when search yields no results.
class SearchEmptyState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;

  const SearchEmptyState({
    required this.searchQuery,
    this.onClearSearch,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: LucideIcons.search,
      title: 'No results found',
      message:
          'Could not find any transcriptions matching "$searchQuery". Try different keywords.',
      actionLabel: 'Clear Search',
      onAction: onClearSearch,
    );
  }
}

/// Empty state for dictionaries page.
///
/// Encourages users to create their first custom vocabulary set.
class DictionariesEmptyState extends StatelessWidget {
  final bool isSearching;
  final VoidCallback? onCreateDictionary;

  const DictionariesEmptyState({
    this.isSearching = false,
    this.onCreateDictionary,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isSearching) {
      return EmptyState(
        icon: LucideIcons.search,
        iconColor: colorScheme.onSurfaceVariant,
        title: 'No dictionaries found',
        message: 'Could not find any dictionaries matching your search.',
        actionLabel: 'Clear Search',
        onAction: onCreateDictionary,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        EmptyState(
          icon: LucideIcons.bookOpen,
          iconColor: colorScheme.primary,
          title: 'No dictionaries yet',
          message:
              'Create custom vocabulary sets to improve transcription accuracy for specific terms.',
          actionLabel: 'Create Dictionary',
          onAction: onCreateDictionary,
        ),
        const SizedBox(height: 32),

        // Feature highlight cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              _FeatureCard(
                icon: LucideIcons.sparkles,
                title: 'Better Accuracy',
                description: 'Custom words are recognized more accurately',
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 12),
              _FeatureCard(
                icon: LucideIcons.globe,
                title: 'Multi-language',
                description: 'Add words from any language',
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 12),
              _FeatureCard(
                icon: LucideIcons.sliders,
                title: 'Context-aware',
                description: 'Specialized terms for your domain',
              ).animate().fadeIn(delay: 700.ms),
            ],
          ),
        ),
      ],
    );
  }
}

/// Empty state for prompts page.
///
/// Encourages users to create custom AI prompt templates.
class PromptsEmptyState extends StatelessWidget {
  final bool isSearching;
  final VoidCallback? onCreatePrompt;

  const PromptsEmptyState({
    this.isSearching = false,
    this.onCreatePrompt,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isSearching) {
      return EmptyState(
        icon: LucideIcons.search,
        iconColor: colorScheme.onSurfaceVariant,
        title: 'No prompts found',
        message: 'Could not find any prompts matching your search.',
        actionLabel: 'Clear Search',
        onAction: onCreatePrompt,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        EmptyState(
          icon: LucideIcons.messageSquare,
          iconColor: colorScheme.primary,
          title: 'No prompts yet',
          message:
              'Create custom AI prompt templates to customize transcription output format.',
          actionLabel: 'Create Prompt',
          onAction: onCreatePrompt,
        ),
        const SizedBox(height: 32),

        // Example prompt cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              _ExamplePromptCard(
                title: 'Meeting Notes',
                template: 'Format as bullet points with action items...',
              ).animate().fadeIn(delay: 500.ms),
              const SizedBox(height: 8),
              _ExamplePromptCard(
                title: 'Journal Entry',
                template: 'Summarize with key themes and emotions...',
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ],
    );
  }
}

/// Empty state for dashboard when no activity.
///
/// Encourages users to start using the app.
class DashboardEmptyState extends StatelessWidget {
  final bool hasApiKey;
  final VoidCallback? onStartRecording;
  final VoidCallback? onOpenSettings;

  const DashboardEmptyState({
    required this.hasApiKey,
    this.onStartRecording,
    this.onOpenSettings,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.barChart3,
                size: 64,
                color: colorScheme.primary,
              ),
            ).animate().scale(
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ),

            const SizedBox(height: 32),

            Text(
              'Start your journey',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            Text(
              hasApiKey
                  ? 'Your voice-to-text transcriptions will appear here. Start recording to see your activity statistics.'
                  : 'Add your Gemini API key to start using voice typing features.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasApiKey)
                  FilledButton.icon(
                    onPressed: onStartRecording,
                    icon: const Icon(LucideIcons.mic),
                    label: const Text('Start Recording'),
                  ).animate().fadeIn(delay: 400.ms)
                else
                  FilledButton.icon(
                    onPressed: onOpenSettings,
                    icon: const Icon(LucideIcons.settings),
                    label: const Text('Add API Key'),
                  ).animate().fadeIn(delay: 400.ms),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Feature highlight card for empty states.
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(
              icon,
              size: 20,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Example prompt card for prompts empty state.
class _ExamplePromptCard extends StatelessWidget {
  final String title;
  final String template;

  const _ExamplePromptCard({
    required this.title,
    required this.template,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(
              LucideIcons.quote,
              size: 14,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  template,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
