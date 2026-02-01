// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tafsir_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TafsirMetaDataAdapter extends TypeAdapter<TafsirMetaData> {
  @override
  final int typeId = 10;

  @override
  TafsirMetaData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TafsirMetaData(
      id: fields[0] as int,
      name: fields[1] as String,
      author: fields[2] as String,
      language: fields[3] as String,
      isDownloaded: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TafsirMetaData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.language)
      ..writeByte(4)
      ..write(obj.isDownloaded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TafsirMetaDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TafsirContentAdapter extends TypeAdapter<TafsirContent> {
  @override
  final int typeId = 11;

  @override
  TafsirContent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TafsirContent(
      tafsirId: fields[0] as int,
      surahNumber: fields[1] as int,
      ayahNumber: fields[2] as int,
      text: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TafsirContent obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.tafsirId)
      ..writeByte(1)
      ..write(obj.surahNumber)
      ..writeByte(2)
      ..write(obj.ayahNumber)
      ..writeByte(3)
      ..write(obj.text);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TafsirContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
