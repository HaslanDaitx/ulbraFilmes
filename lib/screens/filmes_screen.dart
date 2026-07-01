import 'package:flutter/material.dart';

import '../app/filmes/repositories/filme_repository.dart';
import '../app/shared/theme/app_filled_button.dart';
import '../app/shared/theme/colors.dart';
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

  void _atualizar() {
    _filmes = _filmeService.listar();
  }

  Future<void> _buscarDadosFilme({
    required BuildContext dialogContext,
    required TextEditingController titulo,
    required TextEditingController ano,
    required TextEditingController imagemUrl,
    required TextEditingController descricao,
  }) async {
    final pesquisa = titulo.text.trim();

    if (pesquisa.isEmpty) {
      _erro('Informe o título para buscar os dados.');
      return;
    }

    try {
      final filmesEncontrados = await FilmeRepository().buscarFilmes(pesquisa);

      if (!dialogContext.mounted) return;

      if (filmesEncontrados.isEmpty) {
        _erro('Nenhum filme encontrado.');
        return;
      }

      final filmeApi = filmesEncontrados.first;

      titulo.text = filmeApi.titulo;

      final anoEncontrado = int.tryParse(filmeApi.ano);
      if (anoEncontrado != null) {
        ano.text = anoEncontrado.toString();
      }

      if (filmeApi.posterUrl.isNotEmpty) {
        imagemUrl.text = filmeApi.posterUrl;
      }

      if (filmeApi.sinopse.isNotEmpty) {
        descricao.text = filmeApi.sinopse;
      }

      ScaffoldMessenger.of(dialogContext).showSnackBar(
        const SnackBar(
          content: Text('Informações encontradas com sucesso!'),
        ),
      );
    } catch (_) {
      _erro('Não foi possível buscar os dados do filme.');
    }
  }

  Future<void> _abrirDetalhes(Filme filme) async {
    final atualizou = await Navigator.pushNamed(
      context,
      '/detalhe-filme',
      arguments: filme,
    );

    if (atualizou == true && mounted) {
      setState(_atualizar);
    }
  }

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
    final imagemUrl = TextEditingController();
    final descricao = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final filme = await showDialog<Filme>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.fundo,
        title: const Text('Adicionar filme'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Título',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: titulo,
                        decoration: InputDecoration(
                          hintText: 'Digite o título do filme',
                          suffixIcon: IconButton(
                            tooltip: 'Buscar informações',
                            icon: const Icon(Icons.search),
                            onPressed: () => _buscarDadosFilme(
                              dialogContext: context,
                              titulo: titulo,
                              ano: ano,
                              imagemUrl: imagemUrl,
                              descricao: descricao,
                            ),
                          ),
                        ),
                        validator: _obrigatorio,
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                  TextFormField(
                    controller: ano,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Ano',
                    ),
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: genero,
                  decoration: const InputDecoration(labelText: 'Gênero'),
                  validator: _obrigatorio,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descricao,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Sinopse',
                  ),
                ),
              ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: AppColors.verdePrincipal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AppFilledButton(
            text: 'Salvar',
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              FocusManager.instance.primaryFocus?.unfocus();

              final novoFilme = Filme(
                id: '',
                titulo: titulo.text.trim(),
                ano: int.parse(ano.text),
                genero: genero.text.trim(),
                imagemUrl: imagemUrl.text.trim(),
                descricao: descricao.text.trim(),
                createdAt: DateTime.now(),
              );

              await Future.delayed(const Duration(milliseconds: 100));

              if (!context.mounted) return;

              Navigator.of(context).pop(novoFilme);
            },
          ),
        ],
      ),
    );

    if (filme == null) return;

    try {
      await _filmeService.criar(filme);

      if (mounted) {
        setState(_atualizar);
      }
    } catch (_) {
      _erro('Não foi possível adicionar o filme. Tente novamente.');
    }
  }

  String? _obrigatorio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo é obrigatório.';
    }

    return null;
  }

  Future<void> _remover(Filme filme) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir filme'),
        content: Text('Deseja realmente excluir "${filme.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () async {
              FocusManager.instance.primaryFocus?.unfocus();

              await Future.delayed(const Duration(milliseconds: 100));

              if (!context.mounted) return;

              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou != true) return;

    try {
      await _filmeService.remover(filme.id);

      if (mounted) {
        setState(_atualizar);
      }
    } catch (_) {
      _erro('Não foi possível remover o filme. Tente novamente.');
    }
  }

  void _erro(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
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
              mensagem:
              'Sua lista está vazia.\nAdicione seu primeiro filme favorito!',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filmes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final filme = filmes[index];

              return _FilmeCard(
                filme: filme,
                onTap: () => _abrirDetalhes(filme),
                onRemover: () => _remover(filme),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.verdePrincipal,
        foregroundColor: AppColors.dourado,
        onPressed: _adicionar,
        label: const Text(
          'Adicionar Filme',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _FilmeCard extends StatelessWidget {
  const _FilmeCard({
    required this.filme,
    required this.onTap,
    required this.onRemover,
  });

  final Filme filme;
  final VoidCallback onTap;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 150,
          child: Row(
            children: [
              _ImagemFilme(imagemUrl: filme.imagemUrl),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              filme.titulo,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 2, right: 2),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: onRemover,
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.delete_outline,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${filme.ano} • ${filme.genero}'),
                      const Spacer(),
                      Text(
                        'Ver detalhes',
                        style: TextStyle(
                          color: AppColors.verdePrincipal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.dourado,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagemFilme extends StatelessWidget {
  const _ImagemFilme({
    required this.imagemUrl,
  });

  final String imagemUrl;

  @override
  Widget build(BuildContext context) {
    if (imagemUrl.trim().isEmpty) {
      return Container(
        width: 105,
        height: double.infinity,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: const Icon(
          Icons.movie,
          size: 48,
        ),
      );
    }

    return SizedBox(
      width: 105,
      height: double.infinity,
      child: Image.network(
        imagemUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 48,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EstadoLista extends StatelessWidget {
  const _EstadoLista({
    required this.icon,
    required this.mensagem,
    this.onTentarNovamente,
  });

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
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
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