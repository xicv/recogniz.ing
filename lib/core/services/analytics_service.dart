import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/transcription.dart';

/// Enhanced analytics service for deeper insights
class AnalyticsService {
  static const double geminiInputCostPerMillion = 0.00025;
  static const double geminiOutputCostPerMillion = 0.0005;
  static const double averageWordsPerMinute = 140;
  static const double averageWordsPerTranscription = 150;

  /// Calculate comprehensive statistics from transcriptions
  static EnhancedStatistics calculateEnhancedStats(List<Transcription> transcriptions) {
    if (transcriptions.isEmpty) {
      return EnhancedStatistics.empty();
    }

    // Basic metrics
    final totalTranscriptions = transcriptions.length;
    final totalTokens = transcriptions.fold<int>(0, (sum, t) => sum + t.tokenUsage);
    final totalDuration = transcriptions.fold<double>(0, (sum, t) => sum + t.audioDurationSeconds);
    final totalWords = _countTotalWords(transcriptions);

    // Time-based metrics
    final now = DateTime.now();
    final usageByDay = _calculateUsageByDay(transcriptions, now);
    final usageByHour = _calculateUsageByHour(transcriptions);
    final weeklyPattern = _calculateWeeklyPattern(transcriptions);
    final monthlyUsage = _calculateMonthlyUsage(transcriptions, now);

    // Productivity metrics
    final avgWPM = totalDuration > 0 ? (totalWords / totalDuration) * 60 : 0.0;
    final timeSaved = _calculateTimeSaved(totalWords);
    final efficiencyScore = _calculateEfficiencyScore(avgWPM);

    // Cost analysis
    final totalCost = _calculateTotalCost(totalTokens);
    final costPerTranscription = totalTranscriptions > 0 ? totalCost / totalTranscriptions : 0.0;
    final valueVsTraditional = _calculateValueVsTraditional(totalCost, totalWords);

    // Quality metrics
    final avgProcessingTime = totalDuration / totalTranscriptions;
    final avgAccuracy = _estimateAccuracy(transcriptions);
    final audioQualityScore = _calculateAudioQuality(transcriptions);

    // Predictive insights
    final usageForecast = _forecastUsage(usageByDay);
    final recommendations = _generateRecommendations(
      avgWPM,
      totalCost,
      transcriptions.length,
      audioQualityScore,
    );

    return EnhancedStatistics(
      // Basic
      totalTranscriptions: totalTranscriptions,
      totalTokens: totalTokens,
      totalDurationMinutes: totalDuration / 60,
      totalWords: totalWords,

      // Time patterns
      usageByDay: usageByDay,
      usageByHour: usageByHour,
      weeklyPattern: weeklyPattern,
      monthlyUsage: monthlyUsage,
      streakDays: _calculateStreakDays(transcriptions, now),

      // Productivity
      avgWordsPerMinute: avgWPM.toDouble(),
      timeSavedMinutes: timeSaved,
      efficiencyScore: efficiencyScore.toDouble(),

      // Cost
      totalCost: totalCost,
      costPerTranscription: costPerTranscription.toDouble(),
      valueVsTraditionalSavings: valueVsTraditional,

      // Quality
      avgProcessingTimeSeconds: avgProcessingTime,
      estimatedAccuracy: avgAccuracy,
      audioQualityScore: audioQualityScore,

      // Insights
      usageForecast: usageForecast,
      recommendations: recommendations,
    );
  }

  static int _countTotalWords(List<Transcription> transcriptions) {
    return transcriptions.fold<int>(0, (sum, t) {
      return sum + _countWords(t.processedText);
    });
  }

  static int _countWords(String text) {
    return text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
  }

  static Map<DateTime, int> _calculateUsageByDay(List<Transcription> transcriptions, DateTime now) {
    final Map<DateTime, int> usageByDay = {};
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    for (final transcription in transcriptions) {
      if (transcription.createdAt.isAfter(thirtyDaysAgo)) {
        final day = DateTime(
          transcription.createdAt.year,
          transcription.createdAt.month,
          transcription.createdAt.day,
        );
        usageByDay[day] = (usageByDay[day] ?? 0) + 1;
      }
    }

    return usageByDay;
  }

  static List<int> _calculateUsageByHour(List<Transcription> transcriptions) {
    final List<int> hourlyUsage = List.filled(24, 0);

    for (final transcription in transcriptions) {
      final hour = transcription.createdAt.hour;
      hourlyUsage[hour]++;
    }

    return hourlyUsage;
  }

  static List<int> _calculateWeeklyPattern(List<Transcription> transcriptions) {
    final List<int> weeklyPattern = List.filled(7, 0);

    for (final transcription in transcriptions) {
      final dayOfWeek = transcription.createdAt.weekday - 1; // Monday = 0
      weeklyPattern[dayOfWeek]++;
    }

    return weeklyPattern;
  }

  static List<double> _calculateMonthlyUsage(List<Transcription> transcriptions, DateTime now) {
    final List<double> monthlyUsage = List.filled(12, 0);
    final twelveMonthsAgo = DateTime(now.year - 1, now.month, now.day);

    for (final transcription in transcriptions) {
      if (transcription.createdAt.isAfter(twelveMonthsAgo)) {
        final monthDiff = (now.year - transcription.createdAt.year) * 12 +
                         (now.month - transcription.createdAt.month);
        if (monthDiff < 12) {
          monthlyUsage[11 - monthDiff]++;
        }
      }
    }

    return monthlyUsage;
  }

  static int _calculateStreakDays(List<Transcription> transcriptions, DateTime now) {
    if (transcriptions.isEmpty) return 0;

    final sortedTranscriptions = List<Transcription>.from(transcriptions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    int streak = 0;
    DateTime currentDate = DateTime(now.year, now.month, now.day);

    for (final transcription in sortedTranscriptions) {
      final transcriptionDate = DateTime(
        transcription.createdAt.year,
        transcription.createdAt.month,
        transcription.createdAt.day,
      );

      if (transcriptionDate.isAfter(currentDate.subtract(const Duration(days: 1)))) {
        if (transcriptionDate.isAtSameMomentAs(currentDate) ||
            transcriptionDate.isAtSameMomentAs(currentDate.subtract(const Duration(days: 1)))) {
          streak++;
          currentDate = currentDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      } else {
        break;
      }
    }

    return streak;
  }

  static double _calculateTimeSaved(int totalWords) {
    // Time to type vs time to speak (assuming 3x faster to speak)
    final typingTime = totalWords / averageWordsPerMinute;
    final speakingTime = typingTime / 3;
    return typingTime - speakingTime;
  }

  static double _calculateEfficiencyScore(double avgWPM) {
    // Compare voice WPM to average typing WPM (40 WPM)
    const avgTypingWPM = 40.0;
    return min(100, (avgWPM / avgTypingWPM) * 100);
  }

  static double _calculateTotalCost(int totalTokens) {
    // Assume 50% input, 50% output tokens
    final inputTokens = (totalTokens * 0.5);
    final outputTokens = (totalTokens * 0.5);

    return (inputTokens / 1000000) * geminiInputCostPerMillion +
           (outputTokens / 1000000) * geminiOutputCostPerMillion;
  }

  static double _calculateValueVsTraditional(double totalCost, int totalWords) {
    // Traditional transcription services cost ~\$1 per minute
    final traditionalCost = totalWords / averageWordsPerTranscription * 1.0;
    return traditionalCost - totalCost;
  }

  static double _estimateAccuracy(List<Transcription> transcriptions) {
    // Estimate accuracy based on edit patterns and audio quality
    // This is a placeholder - real implementation would track user edits
    return 0.95; // 95% estimated accuracy
  }

  static double _calculateAudioQuality(List<Transcription> transcriptions) {
    // Calculate based on duration vs output ratio
    final totalDuration = transcriptions.fold<double>(0, (sum, t) => sum + t.audioDurationSeconds);
    final totalWords = _countTotalWords(transcriptions);

    if (totalDuration == 0) return 0;

    final wordsPerSecond = totalWords / totalDuration;
    // Optimal is 2-3 words per second for speech
    final optimalWordsPerSecond = 2.5;
    final score = 1 - (wordsPerSecond - optimalWordsPerSecond).abs() / optimalWordsPerSecond;
    return max(0, min(1, score));
  }

  static List<double> _forecastUsage(Map<DateTime, int> usageByDay) {
    // Simple linear regression for forecasting
    if (usageByDay.length < 7) return List.filled(7, 0.0);

    final values = usageByDay.values.toList();
    double sumX = 0;
    double sumY = 0;
    double sumXY = 0;
    double sumXX = 0;

    for (int i = 0; i < values.length; i++) {
      sumX += i;
      sumY += values[i];
      sumXY += i * values[i];
      sumXX += i * i;
    }

    final n = values.length.toDouble();
    final slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    // Forecast next 7 days
    final List<double> forecast = [];
    for (int i = 0; i < 7; i++) {
      final x = values.length + i;
      forecast.add(slope * x + intercept);
    }

    return forecast;
  }

  static List<String> _generateRecommendations(
    double avgWPM,
    double totalCost,
    int transcriptionCount,
    double audioQuality,
  ) {
    final List<String> recommendations = [];

    if (avgWPM < 100) {
      recommendations.add('Try speaking more clearly to improve transcription speed');
    }

    if (totalCost > 10) {
      recommendations.add('Consider setting a monthly budget for API usage');
    }

    if (transcriptionCount < 5) {
      recommendations.add('Use voice typing regularly to build a productivity habit');
    }

    if (audioQuality < 0.7) {
      recommendations.add('Check your microphone placement for better audio quality');
    }

    return recommendations;
  }
}

/// Enhanced statistics model
class EnhancedStatistics {
  final int totalTranscriptions;
  final int totalTokens;
  final double totalDurationMinutes;
  final int totalWords;

  // Time patterns
  final Map<DateTime, int> usageByDay;
  final List<int> usageByHour;
  final List<int> weeklyPattern;
  final List<double> monthlyUsage;
  final int streakDays;

  // Productivity
  final double avgWordsPerMinute;
  final double timeSavedMinutes;
  final double efficiencyScore;

  // Cost
  final double totalCost;
  final double costPerTranscription;
  final double valueVsTraditionalSavings;

  // Quality
  final double avgProcessingTimeSeconds;
  final double estimatedAccuracy;
  final double audioQualityScore;

  // Insights
  final List<double> usageForecast;
  final List<String> recommendations;

  const EnhancedStatistics({
    required this.totalTranscriptions,
    required this.totalTokens,
    required this.totalDurationMinutes,
    required this.totalWords,
    required this.usageByDay,
    required this.usageByHour,
    required this.weeklyPattern,
    required this.monthlyUsage,
    required this.streakDays,
    required this.avgWordsPerMinute,
    required this.timeSavedMinutes,
    required this.efficiencyScore,
    required this.totalCost,
    required this.costPerTranscription,
    required this.valueVsTraditionalSavings,
    required this.avgProcessingTimeSeconds,
    required this.estimatedAccuracy,
    required this.audioQualityScore,
    required this.usageForecast,
    required this.recommendations,
  });

  factory EnhancedStatistics.empty() {
    return EnhancedStatistics(
      totalTranscriptions: 0,
      totalTokens: 0,
      totalDurationMinutes: 0,
      totalWords: 0,
      usageByDay: {},
      usageByHour: List.filled(24, 0),
      weeklyPattern: List.filled(7, 0),
      monthlyUsage: List.filled(12, 0),
      streakDays: 0,
      avgWordsPerMinute: 0,
      timeSavedMinutes: 0,
      efficiencyScore: 0,
      totalCost: 0,
      costPerTranscription: 0,
      valueVsTraditionalSavings: 0,
      avgProcessingTimeSeconds: 0,
      estimatedAccuracy: 0,
      audioQualityScore: 0,
      usageForecast: List.filled(7, 0),
      recommendations: [],
    );
  }
}