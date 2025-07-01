// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cliente.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClienteAdapter extends TypeAdapter<Cliente> {
  @override
  final int typeId = 1;

  @override
  Cliente read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Cliente(
      nome: fields[0] as String,
      telefone: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Cliente obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.nome)
      ..writeByte(1)
      ..write(obj.telefone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClienteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
