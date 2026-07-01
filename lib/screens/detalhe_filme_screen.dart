import 'package:flutter/material.dart';

import '../app/shared/theme/colors.dart';
import '../models/filme.dart';
import '../services/filme_service.dart';

class DetalheFilmeScreen extends StatefulWidget {
  const DetalheFilmeScreen({super.key});

  @override
  State<DetalheFilmeScreen> createState() => _DetalheFilmeScreenState();
}

class _DetalheFilmeScreenState extends State<DetalheFilmeScreen> {
  final _filmeService = FilmeService();

  late Filme filme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    filme = ModalRoute.of(context)!.settings.arguments as Filme;
  }

  Future<void> _excluir() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir filme'),
        content: Text('Deseja realmente excluir "${filme.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
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

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (_) {
      _erro('Não foi possível excluir o filme.');
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
        title: Text(filme.titulo),
        actions: [
          IconButton(
            tooltip: 'Excluir',
            onPressed: _excluir,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: filme.imagemUrl.trim().isEmpty
                        ? Container(
                      height: 340,
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: const Icon(Icons.movie, size: 96),
                    )
                        : Image.network(
                      filme.imagemUrl,
                      height: 340,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Container(
                        height: 340,
                        width: double.infinity,
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: const Icon(Icons.broken_image_outlined, size: 96),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    filme.titulo,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      color: AppColors.verdePrincipal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        backgroundColor: AppColors.verdePrincipal.withValues(alpha: 0.08),
                        side: const BorderSide(color: AppColors.dourado),
                        avatar: const Icon(
                          Icons.calendar_month_outlined,
                          color: AppColors.verdePrincipal,
                          size: 18,
                        ),
                        label: Text(
                          filme.ano.toString(),
                          style: const TextStyle(
                            color: AppColors.verdePrincipal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Chip(
                        backgroundColor: AppColors.verdePrincipal.withValues(alpha: 0.08),
                        side: const BorderSide(color: AppColors.dourado),
                        avatar: const Icon(
                          Icons.local_movies_outlined,
                          color: AppColors.verdePrincipal,
                          size: 18,
                        ),
                        label: Text(
                          filme.genero,
                          style: const TextStyle(
                            color: AppColors.verdePrincipal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Text(
                    'Sinopse',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      color: AppColors.verdePrincipal,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    filme.descricao.trim().isEmpty
                        ? 'Nenhuma sinopse cadastrada.'
                        : filme.descricao,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}