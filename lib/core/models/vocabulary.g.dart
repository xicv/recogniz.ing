// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VocabularySetAdapter extends TypeAdapter<VocabularySet> {
  @override
  final int typeId = 2;

  @override
  VocabularySet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VocabularySet(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      words: (fields[3] as List).cast<String>(),
      isDefault: fields[4] as bool,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, VocabularySet obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.words)
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
      other is VocabularySetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
