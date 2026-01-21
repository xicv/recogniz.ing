// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_key_usage_stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyUsageAdapter extends TypeAdapter<DailyUsage> {
  @override
  final int typeId = 15;

  @override
  DailyUsage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyUsage(
      transcriptionCount: fields[0] as int,
      tokens: fields[1] as int,
      durationMinutes: fields[2] as double,
      words: fields[3] as int,
      date: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DailyUsage obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.transcriptionCount)
      ..writeByte(1)
      ..write(obj.tokens)
      ..writeByte(2)
      ..write(obj.durationMinutes)
      ..writeByte(3)
      ..write(obj.words)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyUsageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ApiKeyUsageStatsAdapter extends TypeAdapter<ApiKeyUsageStats> {
  @override
  final int typeId = 16;

  @override
  ApiKeyUsageStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ApiKeyUsageStats(
      apiKeyId: fields[0] as String,
      totalTranscriptions: fields[1] as int,
      totalTokens: fields[2] as int,
      totalDurationMinutes: fields[3] as double,
      totalWords: fields[4] as int,
      firstUsedAt: fields[5] as DateTime?,
      lastUsedAt: fields[6] as DateTime?,
      dailyUsage: (fields[7] as List).cast<DailyUsage>(),
      totalEstimatedCost: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ApiKeyUsageStats obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.apiKeyId)
      ..writeByte(1)
      ..write(obj.totalTranscriptions)
      ..writeByte(2)
      ..write(obj.totalTokens)
      ..writeByte(3)
      ..write(obj.totalDurationMinutes)
      ..writeByte(4)
      ..write(obj.totalWords)
      ..writeByte(5)
      ..write(obj.firstUsedAt)
      ..writeByte(6)
      ..write(obj.lastUsedAt)
      ..writeByte(7)
      ..write(obj.dailyUsage)
      ..writeByte(8)
      ..write(obj.totalEstimatedCost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiKeyUsageStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
