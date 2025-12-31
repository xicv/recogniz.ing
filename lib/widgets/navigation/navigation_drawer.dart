import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/app_providers.dart';
import '../../core/services/version_service.dart';
import '../../core/theme/app_theme.dart';

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
  late Animation<double> _widthAnimation;
  bool _isExpanded = false;
  String _appVersion = 'v1.0.0';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _widthAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final version = await VersionService.getVersionDisplayName();
    setState(() {
      _appVersion = 'v$version';
    });
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

    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (context, child) {
        final collapsedWidth = 80.0;
        final expandedWidth = 280.0;
        final currentWidth = collapsedWidth + (expandedWidth - collapsedWidth) * _widthAnimation.value;
        // Use animation value to determine layout state, not just _isExpanded
        final isVisuallyExpanded = _widthAnimation.value > 0.5;

        return Container(
          width: currentWidth,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: colorScheme.outlineVariant.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              // Header with app logo and expand/collapse button
              _buildHeader(context, isVisuallyExpanded),

              const SizedBox(height: 8),

              // Navigation items
              Expanded(
                child: _buildNavigationItems(context, currentPage, isVisuallyExpanded),
              ),

              // Footer with version
              _buildFooter(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isVisuallyExpanded) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: isVisuallyExpanded
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
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
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

  Widget _buildNavigationItems(BuildContext context, int currentPage, bool isVisuallyExpanded) {
    final navigationItems = _getNavigationItems();
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: colorScheme.surface.withOpacity(0.8),
          child: SingleChildScrollView(
            child: Column(
              children: navigationItems.map((item) {
              final isSelected = currentPage == item.index;

              // Collapsed mode: icon only
              if (!isVisuallyExpanded) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: Tooltip(
                    message: item.label,
                    waitDuration: const Duration(milliseconds: 500),
                    child: Material(
                      color: isSelected
                          ? colorScheme.primaryContainer.withOpacity(0.6)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      child: InkWell(
                        onTap: () {
                          ref.read(currentPageProvider.notifier).state = item.index;
                        },
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        hoverColor: colorScheme.onSurface.withOpacity(0.08),
                        splashColor: colorScheme.onSurface.withOpacity(0.12),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                          child: Stack(
                            children: [
                              // Active indicator bar (left side)
                              Positioned(
                                left: 4,
                                top: 0,
                                bottom: 0,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 4,
                                  margin: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : Colors.transparent,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(2),
                                      bottomRight: Radius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                              // Center icon
                              Center(
                                child: Icon(
                                  item.icon,
                                  color: isSelected
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurfaceVariant,
                                  size: 22,
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
                      ? colorScheme.primaryContainer.withOpacity(0.7)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  child: InkWell(
                    onTap: () {
                      ref.read(currentPageProvider.notifier).state = item.index;
                    },
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    hoverColor: colorScheme.surfaceContainerHighest.withOpacity(0.6),
                    splashColor: colorScheme.onSurface.withOpacity(0.1),
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
                            size: 22,
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
                                        : FontWeight.w500,
                                    fontSize: 15,
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
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        _appVersion,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
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

