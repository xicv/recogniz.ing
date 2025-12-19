import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Custom list widgets for consistent app-wide styling
class AppLists {
  const AppLists._();

  /// Standard list tile with leading, title, and optional subtitle
  static Widget tile({
    Widget? leading,
    required Widget title,
    Widget? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    EdgeInsetsGeometry? contentPadding,
    Color? tileColor,
    bool selected = false,
  }) {
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      onLongPress: onLongPress,
      contentPadding: contentPadding,
      tileColor: tileColor,
      selected: selected,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// List tile with icon
  static Widget iconTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color? iconColor,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return tile(
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onTap: onTap,
      contentPadding: contentPadding,
    );
  }

  /// List tile with checkbox
  static Widget checkboxTile({
    required BuildContext context,
    required bool value,
    required ValueChanged<bool?>? onChanged,
    required String title,
    String? subtitle,
    bool enabled = true,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: enabled ? onChanged : null,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      contentPadding: contentPadding,
      activeColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// List tile with switch
  static Widget switchTile({
    required BuildContext context,
    required bool value,
    required ValueChanged<bool>? onChanged,
    required String title,
    String? subtitle,
    bool enabled = true,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: enabled ? onChanged : null,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      contentPadding: contentPadding,
      activeColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// List tile with radio button
  static Widget radioTile<T>({
    required BuildContext context,
    required T value,
    required T groupValue,
    required ValueChanged<T?>? onChanged,
    required String title,
    String? subtitle,
    bool enabled = true,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return RadioListTile<T>(
      value: value,
      groupValue: groupValue,
      onChanged: enabled ? onChanged : null,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      contentPadding: contentPadding,
      activeColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// List tile that expands to show more content
  static Widget expandableTile({
    required Widget title,
    required List<Widget> children,
    Widget? leading,
    Widget? trailing,
    EdgeInsetsGeometry? contentPadding,
    bool initiallyExpanded = false,
  }) {
    return ExpansionTile(
      leading: leading,
      title: title,
      trailing: trailing,
      tilePadding: contentPadding,
      children: children,
      initiallyExpanded: initiallyExpanded,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Divider list tile for visual separation
  static Widget divider({
    required BuildContext context,
    double height = 1,
    double thickness = 1,
    Color? color,
    double? indent,
  }) {
    return Divider(
      height: height,
      thickness: thickness,
      color: color ?? Theme.of(context).dividerColor,
      indent: indent,
    );
  }

  /// Section header tile
  static Widget sectionHeader({
    required BuildContext context,
    required String title,
    String? subtitle,
    Widget? action,
    EdgeInsetsGeometry? padding,
  }) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  /// Grouped list with section headers
  static Widget groupedList({
    required BuildContext context,
    required List<ListGroup> groups,
    EdgeInsetsGeometry? padding,
  }) {
    return ListView.separated(
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groups.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final group = groups[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (group.title != null) ...[
              sectionHeader(context: context, title: group.title!),
              const SizedBox(height: 8),
            ],
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: group.items,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Empty state widget for lists
  static Widget emptyState({
    required BuildContext context,
    required String title,
    String? subtitle,
    IconData icon = LucideIcons.inbox,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action,
            ],
          ],
        ),
      ),
    );
  }

  /// Searchable list widget
  static Widget searchableList<T>({
    required List<T> items,
    required Widget Function(BuildContext, T) itemBuilder,
    required String Function(T) searchFilter,
    String searchHint = 'Search...',
    Widget? emptyState,
    EdgeInsetsGeometry? padding,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        String query = '';

        return Column(
          children: [
            TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon: const Icon(Icons.search_outlined),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: query.isEmpty
                  ? ListView.builder(
                      padding: padding,
                      itemCount: items.length,
                      itemBuilder: (context, index) =>
                          itemBuilder(context, items[index]),
                    )
                  : StreamBuilder<List<T>>(
                      stream: Stream.value(
                        items
                            .where((item) => searchFilter(item)
                                .toLowerCase()
                                .contains(query.toLowerCase()))
                            .toList(),
                      ),
                      builder: (context, snapshot) {
                        final filteredItems = snapshot.data ?? [];
                        return filteredItems.isEmpty
                            ? emptyState ??
                                AppLists.emptyState(
                                    context: context, title: 'No results found')
                            : ListView.builder(
                                padding: padding,
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) =>
                                    itemBuilder(context, filteredItems[index]),
                              );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Represents a group in a grouped list
class ListGroup {
  final String? title;
  final List<Widget> items;

  const ListGroup({
    this.title,
    required this.items,
  });
}
