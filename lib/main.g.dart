// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VendaAdapter extends TypeAdapter<Venda> {
  @override
  final int typeId = 0;

  @override
  Venda read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Venda(
      data: fields[0] as DateTime,
      valor: fields[1] as double,
      entrada: fields[2] as double,
      restante: fields[3] as double,
      formaPagamento: fields[4] as String,
      cliente: fields[5] as Cliente,
      produto: fields[6] as Produto,
    );
  }

  @override
  void write(BinaryWriter writer, Venda obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.data)
      ..writeByte(1)
      ..write(obj.valor)
      ..writeByte(2)
      ..write(obj.entrada)
      ..writeByte(3)
      ..write(obj.restante)
      ..writeByte(4)
      ..write(obj.formaPagamento)
      ..writeByte(5)
      ..write(obj.cliente)
      ..writeByte(6)
      ..write(obj.produto);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VendaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
    );
  }

  @override
  void write(BinaryWriter writer, Cliente obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.nome);
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

class ProdutoAdapter extends TypeAdapter<Produto> {
  @override
  final int typeId = 2;

  @override
  Produto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Produto(
      descricao: fields[0] as String,
      precoBase: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Produto obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.descricao)
      ..writeByte(1)
      ..write(obj.precoBase);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProdutoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
