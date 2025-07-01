import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _senhaController = TextEditingController();
  String? _senhaSalva;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _verificarSenha();
  }

  Future<void> _verificarSenha() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _senhaSalva = prefs.getString('senha');
      _isLoading = false;
    });
  }

  Future<void> _autenticar() async {
    final prefs = await SharedPreferences.getInstance();
    if (_senhaSalva == null) {
      await prefs.setString('senha', _senhaController.text);
      Navigator.pushReplacementNamed(context, '/');
    } else if (_senhaController.text == _senhaSalva) {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha incorreta!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _senhaSalva == null
                    ? 'Crie uma senha para acessar o app'
                    : 'Digite sua senha',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _autenticar,
                child: Text(_senhaSalva == null ? 'Criar Senha' : 'Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
