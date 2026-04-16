// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracker_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackerSessionAdapter extends TypeAdapter<TrackerSession> {
  @override
  final int typeId = 0;

  @override
  TrackerSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackerSession(
      id: fields[0] as String,
      subject: fields[1] as String,
      hours: fields[2] as double,
      mood: fields[3] as int,
      date: fields[4] as DateTime,
      tags: fields[5] == null ? [] : (fields[5] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, TrackerSession obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subject)
      ..writeByte(2)
      ..write(obj.hours)
      ..writeByte(3)
      ..write(obj.mood)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackerSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
