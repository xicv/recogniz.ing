// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_key_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApiKeyInfoAdapter extends TypeAdapter<ApiKeyInfo> {
  @override
  final int typeId = 13;

  @override
  ApiKeyInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ApiKeyInfo(
      id: fields[0] as String,
      name: fields[1] as String,
      apiKey: fields[2] as String,
      createdAt: fields[3] as DateTime,
      rateLimitedAt: fields[4] as DateTime?,
      isSelected: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ApiKeyInfo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.apiKey)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.rateLimitedAt)
      ..writeByte(5)
      ..write(obj.isSelected);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiKeyInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
