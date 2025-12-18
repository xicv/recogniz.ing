# Component Library Documentation

This document describes the standardized UI components used throughout the Recogniz.ing application.

## Overview

The component library provides a consistent set of reusable widgets that follow Material Design 3 principles and ensure a cohesive user experience across the app.

## 📦 Component Categories

### 1. AppButtons (`lib/widgets/shared/app_buttons.dart`)

Standardized button widgets for consistent interactions.

#### Primary Button
```dart
AppButtons.primary(
  onPressed: () => print('Clicked'),
  child: Text('Submit'),
  fullWidth: true, // Optional
  isLoading: false, // Optional loading state
)
```

#### Secondary Button
```dart
AppButtons.secondary(
  onPressed: () => print('Clicked'),
  child: Text('Cancel'),
)
```

#### Icon Button
```dart
AppButtons.icon(
  icon: LucideIcons.settings,
  onPressed: () => print('Settings'),
  tooltip: 'Settings',
)
```

#### Floating Action Button
```dart
AppButtons.floating(
  onPressed: () => print('Action'),
  icon: LucideIcons.plus,
  mini: false, // Optional mini version
)
```

### 2. AppInputs (`lib/widgets/shared/app_inputs.dart`)

Input field components with consistent styling and validation.

#### Text Input
```dart
AppInputs.text(
  context: context,
  controller: _controller,
  labelText: 'Email',
  hintText: 'Enter your email',
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    return null;
  },
)
```

#### Password Field
```dart
AppInputs.password(
  context: context,
  controller: _passwordController,
  labelText: 'Password',
  showVisibilityToggle: true,
)
```

#### Search Input
```dart
AppInputs.search(
  context: context,
  controller: _searchController,
  hintText: 'Search...',
  onClear: () => _searchController.clear(),
)
```

#### Dropdown
```dart
AppInputs.dropdown<String>(
  context: context,
  value: _selectedValue,
  items: [
    DropdownMenuItem(value: 'option1', child: Text('Option 1')),
    DropdownMenuItem(value: 'option2', child: Text('Option 2')),
  ],
  onChanged: (value) => setState(() => _selectedValue = value),
)
```

#### Switch
```dart
AppInputs.switch_(
  context: context,
  value: _isEnabled,
  onChanged: (value) => setState(() => _isEnabled = value!),
  label: Text('Enable notifications'),
  subtitle: 'Receive push notifications',
)
```

### 3. AppCards (`lib/widgets/shared/app_cards.dart`)

Card components for consistent content grouping.

#### Basic Card
```dart
AppCards.basic(
  child: Text('Card content'),
  onTap: () => print('Card tapped'),
  margin: EdgeInsets.all(16),
)
```

#### Card with Header
```dart
AppCards.withHeader(
  header: Text('Card Title'),
  child: Text('Card content'),
  actions: [
    IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () => print('More options'),
    ),
  ],
)
```

#### Info Card
```dart
AppCards.info(
  context: context,
  child: Text('Information message'),
  icon: Icons.info,
  iconColor: Colors.blue,
)
```

#### Warning Card
```dart
AppCards.warning(
  context: context,
  child: Text('Warning message'),
)
```

#### Error Card
```dart
AppCards.error(
  context: context,
  child: Text('Error message'),
)
```

#### Success Card
```dart
AppCards.success(
  context: context,
  child: Text('Success message'),
)
```

### 4. AppLists (`lib/widgets/shared/app_lists.dart`)

List components for displaying data consistently.

#### Standard List Tile
```dart
AppLists.tile(
  leading: Icon(Icons.person),
  title: Text('John Doe'),
  subtitle: Text('Software Engineer'),
  trailing: Icon(Icons.chevron_right),
  onTap: () => print('Tile tapped'),
)
```

#### Icon List Tile
```dart
AppLists.iconTile(
  context: context,
  icon: LucideIcons.home,
  title: 'Home',
  subtitle: 'Go to home screen',
  onTap: () => print('Navigate home'),
)
```

#### Checkbox List Tile
```dart
AppLists.checkboxTile(
  context: context,
  value: _isSelected,
  onChanged: (value) => setState(() => _isSelected = value!),
  title: 'Select option',
)
```

#### Switch List Tile
```dart
AppLists.switchTile(
  context: context,
  value: _isEnabled,
  onChanged: (value) => setState(() => _isEnabled = value!),
  title: 'Enable feature',
)
```

#### Divider
```dart
AppLists.divider(
  context: context,
  height: 1,
  color: Theme.of(context).dividerColor,
)
```

#### Section Header
```dart
AppLists.sectionHeader(
  context: context,
  title: 'Section Title',
  subtitle: 'Section description',
  action: TextButton(
    onPressed: () => print('Action'),
    child: Text('View All'),
  ),
)
```

### 5. AppChips (`lib/widgets/shared/app_chips.dart`)

Chip components for categorization and filtering.

#### Status Chip
```dart
AppChips.status(
  context: context,
  label: 'Active',
  status: ChipStatus.active,
)
```

#### Badge Chip
```dart
AppChips.badge(
  context: context,
  count: '5',
  backgroundColor: Theme.of(context).colorScheme.primary,
)
```

#### Quick Action Chip
```dart
AppChips.quickAction(
  icon: LucideIcons.download,
  label: 'Download',
  onPressed: () => print('Download'),
)
```

### 6. LoadingIndicators (`lib/widgets/shared/loading_indicators.dart`)

Loading components for indicating progress.

#### Small Loading Indicator
```dart
LoadingIndicators.small(
  color: Theme.of(context).colorScheme.primary,
  size: 16,
)
```

#### Large Loading Indicator
```dart
LoadingIndicators.large(
  message: 'Loading...',
  color: Theme.of(context).colorScheme.primary,
)
```

#### Skeleton Loader
```dart
LoadingIndicators.skeleton(
  height: 20,
  width: double.infinity,
)
```

#### Loading Overlay
```dart
LoadingIndicators.fullScreen(
  message: 'Processing...',
  child: Text('Additional content'),
)
```

## 🎨 Theming

All components automatically adapt to the app's theme:
- **Light/Dark Mode**: Components use `Theme.of(context).colorScheme`
- **Custom Colors**: Theme overrides are respected
- **Accessibility**: Components maintain proper contrast ratios

## 📐 Consistency Rules

### 1. Border Radius
- Cards: 12px
- Buttons: 12px
- Inputs: 12px
- Chips: 8px (pill-shaped for some variants)

### 2. Spacing
- Small: 4px
- Medium: 8px
- Large: 16px
- Extra Large: 24px

### 3. Typography
- Components use theme text styles (`textTheme.bodyLarge`, etc.)
- Consistent font sizes and weights
- Proper color contrast for readability

## 🚀 Best Practices

### 1. Accessibility
- All interactive elements have proper semantic labels
- Focus management is handled automatically
- Screen reader support is included

### 2. Performance
- Components use `const` constructors where possible
- Minimal rebuilds with proper state management
- Efficient list rendering with proper keys

### 3. Responsive Design
- Components adapt to different screen sizes
- Proper use of `Expanded` and `Flexible`
- Touch targets meet minimum size requirements (44px)

## 🔧 Customization

### Custom Colors
While components automatically use theme colors, you can override them:
```dart
AppButtons.primary(
  onPressed: () {},
  child: Text('Custom'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.purple,
  ),
)
```

### Custom Sizes
Button sizes are predefined but can be customized:
```dart
SizedBox(
  width: 200,
  child: AppButtons.primary(
    onPressed: () {},
    child: Text('Custom Width'),
  ),
)
```

## 🐛 Troubleshooting

### Common Issues

1. **Context Error**: Ensure all components that require context have it passed
2. **Theme Issues**: Check that MaterialApp has a properly configured theme
3. **Performance**: Avoid rebuilding components unnecessarily

### Debugging
- Use Flutter Inspector to examine component properties
- Check console for theme-related warnings
- Use `flutter analyze` to catch issues early