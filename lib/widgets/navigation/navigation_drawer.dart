import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/app_providers.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/transcriptions/transcriptions_page.dart';
import '../../features/settings/settings_page.dart';

class AppNavigationDrawer extends ConsumerStatefulWidget {
  const AppNavigationDrawer({super.key});

  @override
  ConsumerState<AppNavigationDrawer> createState() =>
      _AppNavigationDrawerState();
}

class _AppNavigationDrawerState extends ConsumerState<AppNavigationDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(currentPageProvider);

    return Container(
      width: _isExpanded ? 280 : 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header with app logo and expand/collapse button
          _buildHeader(context),

          const SizedBox(height: 16),

          // Navigation items
          Expanded(
            child: _buildNavigationItems(context, currentPage),
          ),

          // Footer (optional)
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _isExpanded
            ? Row(
                children: [
                  // App logo/icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: AssetImage('assets/icons/app_icon.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // App name (shown when expanded)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recogniz.ing',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          'Voice Typing',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Expand/collapse button
                  IconButton(
                    onPressed: _toggleExpanded,
                    icon: AnimatedRotation(
                      turns: 0.5,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        LucideIcons.chevronRight,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  // App logo/icon (centered when collapsed)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: AssetImage('assets/icons/app_icon.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Expand/collapse button
                  IconButton(
                    onPressed: _toggleExpanded,
                    icon: AnimatedRotation(
                      turns: 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        LucideIcons.chevronRight,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildNavigationItems(BuildContext context, int currentPage) {
    final navigationItems = [
      NavigationItem(
        icon: LucideIcons.fileText,
        label: 'Transcriptions',
        index: 0,
        shortcut: '⌘1',
      ),
      NavigationItem(
        icon: LucideIcons.layoutDashboard,
        label: 'Stats',
        index: 1,
        shortcut: '⌘2',
      ),
      NavigationItem(
        icon: LucideIcons.bookOpen,
        label: 'Dictionaries',
        index: 2,
        shortcut: '⌘3',
      ),
      NavigationItem(
        icon: LucideIcons.messageSquare,
        label: 'Prompts',
        index: 3,
        shortcut: '⌘4',
      ),
      NavigationItem(
        icon: LucideIcons.settings,
        label: 'Settings',
        index: 4,
        shortcut: '⌘5',
      ),
    ];

    return Column(
      children: navigationItems.map((item) {
        final isSelected = currentPage == item.index;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Material(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: Tooltip(
              message: _isExpanded ? '' : '${item.label} (${item.shortcut})',
              child: InkWell(
                onTap: () {
                  ref.read(currentPageProvider.notifier).state = item.index;
                },
                borderRadius: BorderRadius.circular(12),
                hoverColor: Theme.of(context).hoverColor,
                splashColor: Theme.of(context).splashColor,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: _isExpanded ? 16 : 8,
                  ),
                  child: _isExpanded
                      ? Row(
                          children: [
                            Icon(
                              item.icon,
                              color: isSelected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item.label,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                LucideIcons.chevronRight,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                size: 16,
                              ),
                          ],
                        )
                      : Center(
                          child: Icon(
                            item.icon,
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                            size: 24,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter(BuildContext context) {
    // No footer content needed - cleaner navigation drawer
    return const SizedBox.shrink();
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final int index;
  final String? shortcut;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.index,
    this.shortcut,
  });
}
