import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Custom app bar widgets for consistent app-wide styling
class AppBars {
  const AppBars._();

  /// Standard app bar with title and optional actions
  static PreferredSizeWidget primary({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
    PreferredSizeWidget? bottom,
  }) {
    return AppBar(
      title: Text(title),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      bottom: bottom,
      centerTitle: true,
    );
  }

  /// App bar with back button
  static PreferredSizeWidget back({
    required String title,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
  }) {
    return AppBar(
      title: Text(title),
      leading: IconButton(
        onPressed:
            onBackPressed ?? () => Navigator.of(AppBarGet.context!).pop(),
        icon: const Icon(LucideIcons.arrowLeft),
      ),
      actions: actions,
      centerTitle: true,
    );
  }

  /// App bar with close button
  static PreferredSizeWidget close({
    required String title,
    VoidCallback? onClose,
    List<Widget>? actions,
  }) {
    return AppBar(
      title: Text(title),
      leading: IconButton(
        onPressed: onClose ?? () => Navigator.of(AppBarGet.context!).pop(),
        icon: const Icon(LucideIcons.x),
      ),
      actions: actions,
      centerTitle: true,
    );
  }

  /// App bar with search functionality
  static PreferredSizeWidget search({
    required String hint,
    ValueChanged<String>? onChanged,
    VoidCallback? onClear,
    TextEditingController? controller,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
  }) {
    return AppBar(
      title: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: true,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: Theme.of(AppBarGet.context!)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.6),
          ),
        ),
        style: TextStyle(
          color: Theme.of(AppBarGet.context!).colorScheme.onSurface,
        ),
      ),
      leading: IconButton(
        onPressed:
            onBackPressed ?? () => Navigator.of(AppBarGet.context!).pop(),
        icon: const Icon(LucideIcons.arrowLeft),
      ),
      actions: [
        if (onClear != null)
          IconButton(
            onPressed: onClear,
            icon: const Icon(LucideIcons.x),
          ),
        if (actions != null) ...actions,
      ],
      centerTitle: true,
    );
  }

  /// Tab bar app bar
  static PreferredSizeWidget tabs({
    required String title,
    required List<Tab> tabs,
    TabController? controller,
    List<Widget>? actions,
    Color? indicatorColor,
  }) {
    return AppBar(
      title: Text(title),
      actions: actions,
      bottom: TabBar(
        controller: controller,
        tabs: tabs,
        indicatorColor: indicatorColor,
      ),
      centerTitle: true,
    );
  }

  /// Transparent app bar with custom content
  static PreferredSizeWidget transparent({
    Widget? title,
    List<Widget>? actions,
    Widget? leading,
    bool automaticallyImplyLeading = true,
  }) {
    return AppBar(
      title: title,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    );
  }

  /// Collapsible app bar for scroll views
  static Widget collapsible({
    required String title,
    required Widget expandedHeight,
    required Widget flexibleSpace,
    List<Widget>? actions,
    double collapsedHeight = kToolbarHeight,
  }) {
    return SliverAppBar(
      title: Text(title),
      actions: actions,
      expandedHeight: expandedHeight is SizedBox ? 200 : null,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(title),
        background: expandedHeight,
      ),
      centerTitle: true,
      pinned: true,
    );
  }
}

/// Extension to get context easily
extension AppBarGet on Widget {
  static BuildContext? _context;

  static BuildContext? get context => _context;

  static void setContext(BuildContext context) => _context = context;
}
