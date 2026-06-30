import 'package:flutter/material.dart';

import '../app/shared/theme/colors.dart';
import '../services/auth_service.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirmacao = TextEditingController();
  final _service = AuthService();
  bool _carregando = false;
  bool _ocultarSenha = true;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    _confirmacao.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);
    try {
      await _service.cadastro(_email.text, _senha.text);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/filmes', (_) => false);
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Icon(Icons.movie_filter_outlined,
                        size: 72, color: AppColors.verdePrincipal),
                    const SizedBox(height: 16),
                    const Text('Crie sua conta e monte sua lista favorita.'),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) => value == null ||
                              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())
                          ? 'Informe um e-mail válido.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _campoSenha('Senha', _senha),
                    const SizedBox(height: 16),
                    _campoSenha('Confirmar senha', _confirmacao, confirmacao: true),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _carregando ? null : _cadastrar,
                        child: _carregando
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Cadastrar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campoSenha(String label, TextEditingController controller,
      {bool confirmacao = false}) {
    return TextFormField(
      controller: controller,
      obscureText: _ocultarSenha,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _ocultarSenha = !_ocultarSenha),
          icon: Icon(_ocultarSenha ? Icons.visibility : Icons.visibility_off),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'A senha não pode estar vazia.';
        if (confirmacao && value != _senha.text) return 'As senhas precisam ser iguais.';
        return null;
      },
    );
  }
}
