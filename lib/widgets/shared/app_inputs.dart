import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Extension to get context easily
extension InputGet on Widget {
  static BuildContext? _context;

  static BuildContext? get context => _context;

  static void setContext(BuildContext context) => _context = context;
}

/// Custom-styled input widgets for consistent app-wide styling
class AppInputs {
  const AppInputs._();

  /// Standard text field with consistent styling
  static Widget text({
    TextEditingController? controller,
    String? labelText,
    String? hintText,
    String? errorText,
    String? helperText,
    String? initialValue,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onTap,
    bool obscureText = false,
    bool enabled = true,
    bool readOnly = false,
    int? maxLines = 1,
    int? minLines,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Widget? prefix,
    Widget? suffix,
    EdgeInsetsGeometry? contentPadding,
    String? Function(String?)? validator,
    AutovalidateMode? autovalidateMode,
    FocusNode? focusNode,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      autovalidateMode: autovalidateMode,
      focusNode: focusNode,
      textCapitalization: textCapitalization,
      style: _inputStyle,
      decoration: _inputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        helperText: helperText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        prefix: prefix,
        suffix: suffix,
        contentPadding: contentPadding,
      ),
    );
  }

  /// Password field with toggle visibility
  static Widget password({
    TextEditingController? controller,
    String? labelText,
    String? errorText,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
    bool showVisibilityToggle = true,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool obscureText = true;

        return AppInputs.text(
          controller: controller,
          labelText: labelText ?? 'Password',
          errorText: errorText,
          obscureText: obscureText,
          onChanged: onChanged,
          validator: validator,
          suffixIcon: showVisibilityToggle
              ? IconButton(
                  onPressed: () => setState(() => obscureText = !obscureText),
                  icon: Icon(
                    obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  ),
                )
              : null,
        );
      },
    );
  }

  /// Search field with search icon and clear button
  static Widget search({
    TextEditingController? controller,
    String? hintText,
    ValueChanged<String>? onChanged,
    VoidCallback? onClear,
    bool showClearButton = true,
  }) {
    return AppInputs.text(
      controller: controller,
      hintText: hintText ?? 'Search...',
      onChanged: onChanged,
      prefixIcon: const Icon(Icons.search_outlined),
      suffixIcon: showClearButton && (controller?.text.isNotEmpty == true)
          ? IconButton(
              onPressed: onClear ?? () => controller?.clear(),
              icon: const Icon(Icons.clear_outlined),
              iconSize: 20,
            )
          : null,
    );
  }

  /// Multiline text field for longer input
  static Widget multiline({
    TextEditingController? controller,
    String? labelText,
    String? hintText,
    String? errorText,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
    int minLines = 3,
    int maxLines = 5,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return AppInputs.text(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      onChanged: onChanged,
      validator: validator,
      minLines: minLines,
      maxLines: maxLines,
      contentPadding: contentPadding ?? const EdgeInsets.all(16),
    );
  }

  /// Dropdown field with consistent styling
  static Widget dropdown<T>({
    required List<DropdownMenuItem<T>> items,
    required T? value,
    required ValueChanged<T?>? onChanged,
    String? labelText,
    String? hintText,
    String? errorText,
    Widget? prefixIcon,
    bool isExpanded = true,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      items: items,
      style: _inputStyle,
      decoration: _inputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        prefixIcon: prefixIcon,
      ),
      isExpanded: isExpanded,
    );
  }

  /// Checkbox with consistent styling
  static Widget checkbox({
    required bool value,
    required ValueChanged<bool?>? onChanged,
    required Widget label,
    String? errorText,
    bool enabled = true,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return FormField<bool>(
      initialValue: value,
      validator: errorText != null
          ? (val) => val == true ? null : errorText
          : null,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              value: value,
              onChanged: enabled ? onChanged : null,
              title: label,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: contentPadding ?? EdgeInsets.zero,
              activeColor: Theme.of(state.context).colorScheme.primary,
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    color: Theme.of(state.context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Switch with consistent styling
  static Widget switch_({
    required bool value,
    required ValueChanged<bool>? onChanged,
    required Widget label,
    String? subtitle,
    bool enabled = true,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: enabled ? onChanged : null,
      title: label,
      subtitle: subtitle != null ? Text(subtitle) : null,
      contentPadding: EdgeInsets.zero,
      activeColor: Theme.of(InputGet.context!).colorScheme.primary,
    );
  }

  /// Radio group with consistent styling
  static Widget radioGroup<T>({
    required T value,
    required ValueChanged<T>? onChanged,
    required Map<T, Widget> options,
    String? labelText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText,
            style: Theme.of(InputGet.context!).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
        ],
        ...options.entries.map(
          (entry) => RadioListTile<T>(
            value: entry.key,
            groupValue: value,
            onChanged: (val) => onChanged?.call(val!),
            title: entry.value,
            contentPadding: EdgeInsets.zero,
            activeColor: Theme.of(InputGet.context!).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  /// Slider with consistent styling
  static Widget slider({
    required double value,
    required ValueChanged<double>? onChanged,
    required String label,
    String? Function(double)? labelFormatter,
    double min = 0.0,
    double max = 1.0,
    int? divisions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(InputGet.context!).textTheme.titleSmall,
            ),
            Text(
              labelFormatter?.call(value) ?? value.toStringAsFixed(1),
              style: Theme.of(InputGet.context!).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(InputGet.context!).colorScheme.primary,
                  ),
            ),
          ],
        ),
        Slider(
          value: value,
          onChanged: onChanged,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: Theme.of(InputGet.context!).colorScheme.primary,
        ),
      ],
    );
  }

  /// Default input text style
  static TextStyle get _inputStyle => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );

  /// Default input decoration
  static InputDecoration _inputDecoration({
    String? labelText,
    String? hintText,
    String? errorText,
    String? helperText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Widget? prefix,
    Widget? suffix,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      helperText: helperText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      prefix: prefix,
      suffix: suffix,
      contentPadding: contentPadding ?? const EdgeInsets.all(12),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          color: Theme.of(InputGet.context!).colorScheme.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(
          color: Theme.of(InputGet.context!).colorScheme.error,
        ),
      ),
    );
  }
}