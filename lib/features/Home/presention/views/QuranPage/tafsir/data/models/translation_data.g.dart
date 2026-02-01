// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TranslationDataAdapter extends TypeAdapter<TranslationData> {
  @override
  final int typeId = 20;

  @override
  TranslationData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TranslationData(
      name: fields[0] as String,
      url: fields[1] as String,
      isDownloaded: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TranslationData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.isDownloaded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
