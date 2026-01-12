// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcription.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TranscriptionAdapter extends TypeAdapter<Transcription> {
  @override
  final int typeId = 0;

  @override
  Transcription read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transcription(
      id: fields[0] as String,
      rawText: fields[1] as String,
      processedText: fields[2] as String,
      createdAt: fields[3] as DateTime,
      tokenUsage: fields[4] as int,
      promptId: fields[5] as String,
      audioDurationSeconds: fields[6] as double,
      isFavorite: fields[7] as bool?,
      audioBackupPath: fields[8] as String?,
      errorMessage: fields[10] as String?,
      retryCount: fields[11] == null ? 0 : fields[11] as int,
      completedAt: fields[12] as DateTime?,
      detectedLanguage: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Transcription obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.rawText)
      ..writeByte(2)
      ..write(obj.processedText)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.tokenUsage)
      ..writeByte(5)
      ..write(obj.promptId)
      ..writeByte(6)
      ..write(obj.audioDurationSeconds)
      ..writeByte(7)
      ..write(obj.isFavorite)
      ..writeByte(8)
      ..write(obj.audioBackupPath)
      ..writeByte(9)
      ..write(obj.statusIndex)
      ..writeByte(10)
      ..write(obj.errorMessage)
      ..writeByte(11)
      ..write(obj.retryCount)
      ..writeByte(12)
      ..write(obj.completedAt)
      ..writeByte(13)
      ..write(obj.detectedLanguage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranscriptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
