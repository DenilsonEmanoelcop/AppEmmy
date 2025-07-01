import 'package:hive/hive.dart';

part 'cliente.g.dart';

@HiveType(typeId: 1)
class Cliente extends HiveObject {
  @HiveField(0)
  String nome;

  @HiveField(1)
  String telefone;

  Cliente({required this.nome, required this.telefone});
}
