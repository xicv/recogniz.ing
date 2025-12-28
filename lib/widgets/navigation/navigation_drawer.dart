import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/app_providers.dart';

/// Enhanced navigation drawer
///
/// Design principles:
/// - Müller-Brockmann: Grid-aligned, mathematical spacing
/// - Dieter Rams: Functional clarity, progressive disclosure
///
/// Key improvements:
/// - Collapsible drawer with smooth animations
/// - Visual hierarchy refinement
/// - Accessibility improvements

class AppNavigationDrawer extends ConsumerStatefulWidget {
  const AppNavigationDrawer({super.key});

  @override
  ConsumerState<AppNavigationDrawer> createState() => _AppNavigationDrawerState();
}

class _AppNavigationDrawerState extends ConsumerState<AppNavigationDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: _isExpanded ? 280 : 80,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header with app logo and expand/collapse button
          _buildHeader(context),

          const SizedBox(height: 8),

          // Navigation items
          Expanded(
            child: _buildNavigationItems(context, currentPage),
          ),

          // Footer with shortcuts hint
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: _isExpanded
            ? Row(
                children: [
                  // App logo/icon
                  _buildAppLogo(),

                  const SizedBox(width: 16),

                  // App name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Recogniz.ing',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Voice Typing',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Expand/collapse button
                  _buildToggleButton(),
                ],
              )
            : Column(
                children: [
                  // App logo (centered when collapsed)
                  _buildAppLogo(),

                  const SizedBox(height: 4),

                  // Expand/collapse button (collapsed)
                  _buildToggleButton(isCollapsed: true),
                ],
              ),
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
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
    );
  }

  Widget _buildToggleButton({bool isCollapsed = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final targetTurns = _isExpanded ? 0.5 : 0.0;

    return IconButton(
      onPressed: _toggleExpanded,
      icon: AnimatedRotation(
        turns: targetTurns,
        duration: const Duration(milliseconds: 200),
        child: Icon(
          LucideIcons.chevronRight,
          color: colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
      tooltip: _isExpanded ? 'Collapse' : 'Expand',
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(36, 36),
      ),
    );
  }

  Widget _buildNavigationItems(BuildContext context, int currentPage) {
    final navigationItems = _getNavigationItems();
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        children: navigationItems.map((item) {
        final isSelected = currentPage == item.index;

        // Collapsed mode: icon only
        if (!_isExpanded) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Tooltip(
              message: item.label,
              waitDuration: const Duration(milliseconds: 500),
              child: Material(
                color: isSelected
                    ? colorScheme.primaryContainer.withOpacity(0.5)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {
                    ref.read(currentPageProvider.notifier).state = item.index;
                  },
                  borderRadius: BorderRadius.circular(12),
                  hoverColor: colorScheme.onSurface.withOpacity(0.06),
                  splashColor: colorScheme.onSurface.withOpacity(0.1),
                  child: Container(
                    height: 48, // Optimized for smaller screens
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        // Active indicator bar (left side) - Increased from 4px to 6px
                        Positioned(
                          left: 4,
                          top: 0,
                          bottom: 0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 6,
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(3),
                                bottomRight: Radius.circular(3),
                              ),
                            ),
                          ),
                        ),

                        // Center content
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.icon,
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                                size: 24,
                              ),
                              if (!isSelected) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.index.toString(),
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // Expanded mode: full layout
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Material(
            color: isSelected
                ? colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                ref.read(currentPageProvider.notifier).state = item.index;
              },
              borderRadius: BorderRadius.circular(12),
              hoverColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              splashColor: colorScheme.onSurface.withOpacity(0.08),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
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
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isSelected)
                      Icon(
                        LucideIcons.chevronRight,
                        color: colorScheme.onPrimaryContainer,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 4),
          // Version info
          Text(
            'v1.1.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 2),
          // Settings link (collapsed) or full button (expanded)
          if (!_isExpanded)
            IconButton(
              onPressed: () => ref.read(currentPageProvider.notifier).state = 4,
              icon: Icon(
                LucideIcons.settings,
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                size: 18,
              ),
              tooltip: 'Settings',
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  List<NavigationItemData> _getNavigationItems() {
    return [
      NavigationItemData(
        icon: LucideIcons.fileText,
        label: 'Transcriptions',
        index: 0,
        shortcut: 'Cmd+1',
      ),
      NavigationItemData(
        icon: LucideIcons.layoutDashboard,
        label: 'Stats',
        index: 1,
        shortcut: 'Cmd+2',
      ),
      NavigationItemData(
        icon: LucideIcons.bookOpen,
        label: 'Dictionaries',
        index: 2,
        shortcut: 'Cmd+3',
      ),
      NavigationItemData(
        icon: LucideIcons.messageSquare,
        label: 'Prompts',
        index: 3,
        shortcut: 'Cmd+4',
      ),
      NavigationItemData(
        icon: LucideIcons.settings,
        label: 'Settings',
        index: 4,
        shortcut: 'Cmd+5',
      ),
    ];
  }
}

// ============================================================
// SUPPORTING WIDGETS
// ============================================================

/// Navigation item data class
class NavigationItemData {
  final IconData icon;
  final String label;
  final int index;
  final String shortcut;

  const NavigationItemData({
    required this.icon,
    required this.label,
    required this.index,
    required this.shortcut,
  });
}

