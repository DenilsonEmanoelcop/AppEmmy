import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:io';

class ValidadorScreen extends StatefulWidget {
  const ValidadorScreen({super.key});

  @override
  State<ValidadorScreen> createState() => _ValidadorScreenState();
}

class _ValidadorScreenState extends State<ValidadorScreen> {
  String? _deviceId;
  String? _chaveInserida;
  bool liberado = false;

  @override
  void initState() {
    super.initState();
    _carregarDeviceId();
    _verificarLicencaSalva();
  }

  Future<void> _carregarDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    String id = 'sem_id';

    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      id = info.id ?? 'sem_id';
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      id = info.identifierForVendor ?? 'sem_id';
    }

    setState(() {
      _deviceId = id;
    });
  }

  Future<void> _verificarLicencaSalva() async {
    final prefs = await SharedPreferences.getInstance();
    final salva = prefs.getString('licenca');
    if (salva != null) {
      setState(() => liberado = true);
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
    }
  }

  String gerarChaveLicenca(String codigoCliente) {
    final hash = sha256.convert(utf8.encode(codigoCliente)).toString();
    final chaveBruta = hash.substring(0, 16).toUpperCase();
    final chaveFormatada = chaveBruta.replaceAllMapped(RegExp(r".{4}"), (m) => "${m.group(0)}-").replaceAll(RegExp(r"-$"), "");
    return chaveFormatada;
  }

  Future<void> _validarChave() async {
    if (_deviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aguardando identificação do dispositivo...')),
      );
      return;
    }

    final chaveEsperada = gerarChaveLicenca(_deviceId!);

    print('Device ID: $_deviceId');
    print('Chave Esperada: $chaveEsperada');
    print('Chave Inserida: $_chaveInserida');

    if (_chaveInserida != null && _chaveInserida == chaveEsperada) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('licenca', _chaveInserida!);
      setState(() => liberado = true);
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chave de licença inválida')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (liberado) {
      return const SizedBox();
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Validação de Licença'),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_deviceId != null)
                Text(
                  'Digite a chave para o dispositivo:\nID: $_deviceId',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                )
              else
                const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(labelText: 'Chave de Licença'),
                onChanged: (v) => _chaveInserida = v.trim().toUpperCase(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _validarChave,
                child: const Text('Validar e Liberar Acesso'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
