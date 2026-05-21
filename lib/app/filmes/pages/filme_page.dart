import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/filme_controller.dart';
import '../repositories/filme_repository.dart';
import '../services/filme_service.dart';
import '../widgets/campo_busca.dart';
import '../widgets/filme_card.dart';

class FilmesPage extends StatefulWidget {
  const FilmesPage({super.key});

  @override
  State<FilmesPage> createState() => _FilmesPageState();
}

class _FilmesPageState extends State<FilmesPage> {
  static const Duration _debounceDuration = Duration(milliseconds: 700);
  static const double _pagePadding = 16;
  static const double _gridSpacing = 12;
  static const double _gridAspectRatio = 0.64;

  final TextEditingController _pesquisaController = TextEditingController();

  late final FilmeController _controller;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    final repository = FilmeRepository();
    final service = FilmeService(repository);

    _controller = FilmeController(service);

    _buscarFilmesPopulares();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pesquisaController.dispose();
    super.dispose();
  }

  void _onPesquisaAlterada(String texto) {
    _debounce?.cancel();

    _debounce = Timer(_debounceDuration, _buscarFilmes);
  }

  Future<void> _buscarFilmes() async {
    await _controller.buscarFilmes(_pesquisaController.text);

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _buscarFilmesPopulares() async {
    await _controller.listarFilmesPopulares();

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_pagePadding),
          child: Column(
            children: [
              CampoBusca(
                controller: _pesquisaController,
                onBuscar: _buscarFilmes,
                onChanged: _onPesquisaAlterada,
              ),
              const SizedBox(height: _pagePadding),
              Expanded(
                child: _buildConteudo(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leadingWidth: 75,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Image.asset(
          'assets/images/logoUlbra.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.movie);
          },
        ),
      ),
      title: const Text(
        'ULBRA Filmes',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      actions: const [
        SizedBox(width: 72),
      ],
    );
  }

  Widget _buildConteudo() {
    if (_controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_controller.filmes.isEmpty) {
      return Center(
        child: Text(
          _controller.mensagem,
          textAlign: TextAlign.center,
        ),
      );
    }

    return GridView.builder(
      itemCount: _controller.filmes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: _gridSpacing,
        mainAxisSpacing: _gridSpacing,
        childAspectRatio: _gridAspectRatio,
      ),
      itemBuilder: (context, index) {
        final filme = _controller.filmes[index];

        return FilmeCard(filme: filme);
      },
    );
  }
}