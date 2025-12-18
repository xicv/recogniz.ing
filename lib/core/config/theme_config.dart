import 'dart:convert';
import 'package:flutter/services.dart';

class ThemeColors {
  final String primary;
  final String primaryLight;
  final String primaryDark;
  final String accent;
  final String success;
  final String warning;
  final String error;
  final String background;
  final String surface;
  final String textPrimary;
  final String textSecondary;

  const ThemeColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
  });
}

class ThemeBorderRadius {
  final int small;
  final int medium;
  final int large;
  final int xlarge;

  const ThemeBorderRadius({
    required this.small,
    required this.medium,
    required this.large,
    required this.xlarge,
  });
}

class ThemeSpacing {
  final int xs;
  final int sm;
  final int md;
  final int lg;
  final int xl;
  final int xxl;

  const ThemeSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  });
}

class ThemeElevation {
  final int card;
  final int button;
  final int fab;

  const ThemeElevation({
    required this.card,
    required this.button,
    required this.fab,
  });
}

class ThemePadding {
  final int small;
  final int medium;
  final int large;

  const ThemePadding({
    required this.small,
    required this.medium,
    required this.large,
  });
}

class ThemeConfig {
  final String name;
  final String displayName;
  final ThemeColors colors;
  final ThemeBorderRadius borderRadius;
  final ThemeSpacing spacing;
  final ThemeElevation elevation;
  final ThemePadding padding;

  const ThemeConfig({
    required this.name,
    required this.displayName,
    required this.colors,
    required this.borderRadius,
    required this.spacing,
    required this.elevation,
    required this.padding,
  });

  static Future<ThemeConfig> fromAsset(String themeName) async {
    final String jsonString = await rootBundle.loadString('config/themes/${themeName}_theme.json');
    final Map<String, dynamic> json = jsonDecode(jsonString);

    return ThemeConfig(
      name: json['name'],
      displayName: json['displayName'],
      colors: ThemeColors(
        primary: json['colors']['primary'],
        primaryLight: json['colors']['primaryLight'],
        primaryDark: json['colors']['primaryDark'],
        accent: json['colors']['accent'],
        success: json['colors']['success'],
        warning: json['colors']['warning'],
        error: json['colors']['error'],
        background: json['colors']['background'],
        surface: json['colors']['surface'],
        textPrimary: json['colors']['textPrimary'],
        textSecondary: json['colors']['textSecondary'],
      ),
      borderRadius: ThemeBorderRadius(
        small: json['borderRadius']['small'],
        medium: json['borderRadius']['medium'],
        large: json['borderRadius']['large'],
        xlarge: json['borderRadius']['xlarge'],
      ),
      spacing: ThemeSpacing(
        xs: json['spacing']['xs'],
        sm: json['spacing']['sm'],
        md: json['spacing']['md'],
        lg: json['spacing']['lg'],
        xl: json['spacing']['xl'],
        xxl: json['spacing']['xxl'],
      ),
      elevation: ThemeElevation(
        card: json['elevation']['card'],
        button: json['elevation']['button'],
        fab: json['elevation']['fab'],
      ),
      padding: ThemePadding(
        small: json['padding']['small'],
        medium: json['padding']['medium'],
        large: json['padding']['large'],
      ),
    );
  }
}