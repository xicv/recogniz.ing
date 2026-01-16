// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_prompt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomPromptAdapter extends TypeAdapter<CustomPrompt> {
  @override
  final int typeId = 1;

  @override
  CustomPrompt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomPrompt(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      promptTemplate: fields[3] as String,
      isDefault: fields[4] as bool,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CustomPrompt obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.promptTemplate)
      ..writeByte(4)
      ..write(obj.isDefault)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomPromptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
