// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zikr_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ZikrModelAdapter extends TypeAdapter<ZikrModel> {
  @override
  final int typeId = 1;

  @override
  ZikrModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ZikrModel(
      title: fields[0] as String,
      content: fields[1] as String,
      count: fields[2] as int,
      category: fields[3] == null ? "عام" : fields[3] as String,
      dailyGoal: fields[4] == null ? 100 : fields[4] as int,
      totalCount: fields[5] == null ? 0 : fields[5] as int,
      notificationTime: fields[6] as DateTime?,
      isNotificationEnabled: fields[7] == null ? false : fields[7] as bool,
      lastUpdatedDate: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ZikrModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.count)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.dailyGoal)
      ..writeByte(5)
      ..write(obj.totalCount)
      ..writeByte(6)
      ..write(obj.notificationTime)
      ..writeByte(7)
      ..write(obj.isNotificationEnabled)
      ..writeByte(8)
      ..write(obj.lastUpdatedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZikrModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
