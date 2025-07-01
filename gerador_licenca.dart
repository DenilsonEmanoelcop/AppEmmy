import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

String gerarChaveLicenca(String codigoCliente) {
  final hash = sha256.convert(utf8.encode(codigoCliente)).toString();
  final chaveBruta = hash.substring(0, 16).toUpperCase();
  final chaveFormatada = chaveBruta.replaceAllMapped(RegExp(r".{4}"), (m) => "${m.group(0)}-").replaceAll(RegExp(r"-$"), "");
  return chaveFormatada;
}

void main() {
  stdout.write('Código do cliente (device ID): ');
  final input = stdin.readLineSync()!;
  final chave = gerarChaveLicenca(input);
  print('Chave de liberação: $chave');
}


