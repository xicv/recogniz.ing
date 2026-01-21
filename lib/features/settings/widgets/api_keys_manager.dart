import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/providers/api_keys_provider.dart';
import '../../../core/providers/recording_providers.dart';
import '../../../core/theme/app_theme.dart';

/// Widget for managing multiple API keys
class ApiKeysManager extends ConsumerStatefulWidget {
  const ApiKeysManager({super.key});

  @override
  ConsumerState<ApiKeysManager> createState() => _ApiKeysManagerState();
}

class _ApiKeysManagerState extends ConsumerState<ApiKeysManager> {
  @override
  Widget build(BuildContext context) {
    final apiKeys = ref.watch(apiKeysProvider);
    final selectedKey = ref.watch(selectedApiKeyProvider);
    final availableKeys = ref.watch(availableApiKeysProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with count and add button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                LucideIcons.key,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Keys',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${availableKeys.length} of ${apiKeys.length} available',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: availableKeys.length < apiKeys.length
                                ? Colors.orange
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _showAddKeyDialog(context, ref),
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('Add Key'),
              ),
            ],
          ),
        ),

        // API Keys list
        if (apiKeys.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(LucideIcons.keyRound, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No API keys added',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add a key to get started',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          ...apiKeys.map((key) => _ApiKeyCard(
                key: ValueKey(key.id),
                apiKey: key,
                isSelected: selectedKey?.id == key.id,
                onSelect: () => ref.read(apiKeysProvider.notifier).selectApiKey(key.id),
                onDelete: () => _showDeleteConfirmDialog(context, ref, key),
                onEdit: () => _showEditKeyDialog(context, ref, key),
                onClearRateLimit: () => ref.read(apiKeysProvider.notifier).clearRateLimit(key.id),
              )),
      ],
    );
  }

  void _showAddKeyDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final keyController = TextEditingController();
    final isObscured = ValueNotifier(true);
    final isValidating = ValueNotifier(false);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add API Key'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name (optional)',
                    hintText: 'e.g., Personal Key, Work Key',
                    prefixIcon: Icon(LucideIcons.tag),
                  ),
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder(
                  valueListenable: isObscured,
                  builder: (context, obscured, child) {
                    return ValueListenableBuilder(
                      valueListenable: isValidating,
                      builder: (context, validating, child) {
                        return TextField(
                          controller: keyController,
                          obscureText: obscured,
                          enabled: !validating,
                          decoration: InputDecoration(
                            labelText: 'API Key',
                            hintText: 'Enter your Gemini API key',
                            prefixIcon: const Icon(LucideIcons.key),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    obscured ? LucideIcons.eye : LucideIcons.eyeOff,
                                  ),
                                  onPressed: () {
                                    isObscured.value = !obscured;
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Get your key from: https://aistudio.google.com/app/apikey',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: isValidating.value
                    ? null
                    : () async {
                        final key = keyController.text.trim();
                        final name = nameController.text.trim();

                        if (key.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter an API key'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        isValidating.value = true;

                        try {
                          // Validate with GeminiService
                          final geminiService = ref.read(geminiServiceProvider);
                          final (isValid, error) = await geminiService.validateApiKey(key);

                          if (!isValid) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error ?? 'Invalid API key'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                            return;
                          }

                          // Add the key
                          final displayName = name.isNotEmpty
                              ? name
                              : 'Key ${ref.read(apiKeysProvider).length + 1}';

                          await ref.read(apiKeysProvider.notifier).createApiKey(
                                name: displayName,
                                apiKey: key,
                                isSelected: ref.read(apiKeysProvider).isEmpty,
                              );

                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('API key added successfully'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } catch (e) {
                          if (kDebugMode) {
                            debugPrint('[ApiKeysManager] Error adding key: $e');
                          }
                          // Allow adding even if validation fails (network issues, etc.)
                          if (key.startsWith('AIza') && key.length > 30) {
                            final displayName = name.isNotEmpty
                                ? name
                                : 'Key ${ref.read(apiKeysProvider).length + 1}';
                            await ref.read(apiKeysProvider.notifier).createApiKey(
                                  name: displayName,
                                  apiKey: key,
                                  isSelected: ref.read(apiKeysProvider).isEmpty,
                                );
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.toString()}'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } finally {
                          isValidating.value = false;
                        }
                      },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditKeyDialog(BuildContext context, WidgetRef ref, dynamic key) {
    final nameController = TextEditingController(text: key.name);
    final keyController = TextEditingController(text: key.apiKey);
    final isObscured = ValueNotifier(true);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(LucideIcons.tag),
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder(
              valueListenable: isObscured,
              builder: (context, obscured, child) {
                return TextField(
                  controller: keyController,
                  obscureText: obscured,
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    prefixIcon: const Icon(LucideIcons.key),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscured ? LucideIcons.eye : LucideIcons.eyeOff,
                      ),
                      onPressed: () {
                        isObscured.value = !obscured;
                      },
                    ),
                  ),
                  readOnly: true,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                await ref.read(apiKeysProvider.notifier).updateKeyName(key.id, newName);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, dynamic key) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete API Key'),
        content: Text('Are you sure you want to delete "${key.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(apiKeysProvider.notifier).removeApiKey(key.id);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('API key deleted'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Individual API key card widget
class _ApiKeyCard extends ConsumerWidget {
  final dynamic apiKey;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onClearRateLimit;

  const _ApiKeyCard({
    super.key,
    required this.apiKey,
    required this.isSelected,
    required this.onSelect,
    required this.onDelete,
    required this.onEdit,
    required this.onClearRateLimit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRateLimited = apiKey.isRateLimited;
    final isLimitExpired = apiKey.isRateLimitExpired;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : isRateLimited && !isLimitExpired
                  ? Colors.orange
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Leading icon/radio
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                  color: isSelected ? AppColors.primary : null,
                ),
                child: isSelected
                    ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                    : null,
              ),

              const SizedBox(width: 16),

              // Key info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          apiKey.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'SELECTED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (isRateLimited && !isLimitExpired) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'RATE LIMIT REACHED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      apiKey.maskedKey,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'clear_limit':
                      onClearRateLimit();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(LucideIcons.pencil, size: 16),
                        SizedBox(width: 8),
                        Text('Rename'),
                      ],
                    ),
                  ),
                  if (isRateLimited)
                    const PopupMenuItem(
                      value: 'clear_limit',
                      child: Row(
                        children: [
                          Icon(LucideIcons.rotateCcw, size: 16),
                          SizedBox(width: 8),
                          Text('Clear rate limit'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(LucideIcons.trash2, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
