// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 3;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      geminiApiKey: fields[0] as String?,
      selectedPromptId: fields[1] as String,
      selectedVocabularyId: fields[2] as String,
      globalHotkey: fields[3] as String,
      darkMode: fields[4] as bool,
      autoCopyToClipboard: fields[5] as bool,
      showNotifications: fields[6] as bool,
      criticalInstructions: fields[7] as String?,
      startAtLogin: fields[10] as bool,
      transcriptionLanguage: fields[11] == null ? 'auto' : fields[11] as String,
      audioCompressionPreference: fields[13] == null
          ? AudioCompressionPreference.auto
          : fields[13] as AudioCompressionPreference,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.geminiApiKey)
      ..writeByte(1)
      ..write(obj.selectedPromptId)
      ..writeByte(2)
      ..write(obj.selectedVocabularyId)
      ..writeByte(3)
      ..write(obj.globalHotkey)
      ..writeByte(4)
      ..write(obj.darkMode)
      ..writeByte(5)
      ..write(obj.autoCopyToClipboard)
      ..writeByte(6)
      ..write(obj.showNotifications)
      ..writeByte(7)
      ..write(obj.criticalInstructions)
      ..writeByte(10)
      ..write(obj.startAtLogin)
      ..writeByte(11)
      ..write(obj.transcriptionLanguage)
      ..writeByte(13)
      ..write(obj.audioCompressionPreference);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AudioCompressionPreferenceAdapter
    extends TypeAdapter<AudioCompressionPreference> {
  @override
  final int typeId = 12;

  @override
  AudioCompressionPreference read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AudioCompressionPreference.auto;
      case 1:
        return AudioCompressionPreference.alwaysCompressed;
      case 2:
        return AudioCompressionPreference.uncompressed;
      default:
        return AudioCompressionPreference.auto;
    }
  }

  @override
  void write(BinaryWriter writer, AudioCompressionPreference obj) {
    switch (obj) {
      case AudioCompressionPreference.auto:
        writer.writeByte(0);
        break;
      case AudioCompressionPreference.alwaysCompressed:
        writer.writeByte(1);
        break;
      case AudioCompressionPreference.uncompressed:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioCompressionPreferenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
