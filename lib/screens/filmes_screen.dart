import 'package:flutter/material.dart';

import '../models/filme.dart';
import '../services/auth_service.dart';
import '../services/filme_service.dart';

class FilmesScreen extends StatefulWidget {
  const FilmesScreen({super.key});

  @override
  State<FilmesScreen> createState() => _FilmesScreenState();
}

class _FilmesScreenState extends State<FilmesScreen> {
  final _filmeService = FilmeService();
  final _authService = AuthService();
  late Future<List<Filme>> _filmes;

  @override
  void initState() {
    super.initState();
    _atualizar();
  }

  void _atualizar() => _filmes = _filmeService.listar();

  Future<void> _logout() async {
    try {
      await _authService.logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } on AuthException catch (error) {
      _erro(error.message);
    }
  }

  Future<void> _adicionar() async {
    final titulo = TextEditingController();
    final ano = TextEditingController();
    final genero = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final filme = await showDialog<Filme>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar filme'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titulo,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: _obrigatorio,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: ano,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Ano'),
                  validator: (value) {
                    final numero = int.tryParse(value ?? '');
                    if (numero == null || numero < 1888 || numero > 2100) {
                      return 'Informe um ano válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: genero,
                  decoration: const InputDecoration(labelText: 'Gênero'),
                  validator: _obrigatorio,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(
                context,
                Filme(
                  id: '',
                  titulo: titulo.text.trim(),
                  ano: int.parse(ano.text),
                  genero: genero.text.trim(),
                  createdAt: DateTime.now(),
                ),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    titulo.dispose();
    ano.dispose();
    genero.dispose();
    if (filme == null) return;
    try {
      await _filmeService.criar(filme);
      if (mounted) setState(_atualizar);
    } catch (_) {
      _erro('Não foi possível adicionar o filme. Tente novamente.');
    }
  }

  String? _obrigatorio(String? value) => value == null || value.trim().isEmpty
      ? 'Este campo é obrigatório.'
      : null;

  Future<void> _remover(Filme filme) async {
    try {
      await _filmeService.remover(filme.id);
      if (mounted) setState(_atualizar);
    } catch (_) {
      _erro('Não foi possível remover o filme. Tente novamente.');
    }
  }

  void _erro(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Image.asset('assets/images/logoUlbra.png'),
        ),
        title: const Text(
          'Meus filmes favoritos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<List<Filme>>(
        future: _filmes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _EstadoLista(
              icon: Icons.cloud_off_outlined,
              mensagem: 'Não foi possível carregar seus filmes.',
              onTentarNovamente: () => setState(_atualizar),
            );
          }
          final filmes = snapshot.data ?? [];
          if (filmes.isEmpty) {
            return const _EstadoLista(
              icon: Icons.movie_outlined,
              mensagem: 'Sua lista está vazia.\nAdicione seu primeiro filme favorito!',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filmes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final filme = filmes[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.movie)),
                  title: Text(filme.titulo,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${filme.ano} • ${filme.genero}'),
                  trailing: IconButton(
                    tooltip: 'Excluir',
                    onPressed: () => _remover(filme),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionar,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar filme'),
      ),
    );
  }
}

class _EstadoLista extends StatelessWidget {
  const _EstadoLista({required this.icon, required this.mensagem, this.onTentarNovamente});
  final IconData icon;
  final String mensagem;
  final VoidCallback? onTentarNovamente;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(mensagem, textAlign: TextAlign.center),
              if (onTentarNovamente != null) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: onTentarNovamente,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ],
          ),
        ),
      );
}
