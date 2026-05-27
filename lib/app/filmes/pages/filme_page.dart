import 'dart:async';

import 'package:flutter/material.dart';

import '../../shared/theme/colors.dart';
import '../controllers/filme_controller.dart';
import '../entity/enum/tipo_lista_filme_enum.dart';
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

  TipoListaFilmes _tipoSelecionado = TipoListaFilmes.populares;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    final repository = FilmeRepository();
    final service = FilmeService(repository);

    _controller = FilmeController(service);

    _listarFilmes();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _pesquisaController.dispose();
    super.dispose();
  }

  Future<void> _buscarFilmes() async {
    await _controller.buscarFilmes(_pesquisaController.text);

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _listarFilmes() async {
    await _controller.listarFilmes(_tipoSelecionado);

    if (!mounted) return;

    setState(() {});
  }

  void _onPesquisaAlterada(String texto) {
    _debounce?.cancel();

    if (texto.trim().isEmpty) {
      _listarFilmes();
      return;
    }

    _debounce = Timer(_debounceDuration, () {
      _buscarFilmes();
    });
  }

  void _limparPesquisa() {
    _debounce?.cancel();
    _pesquisaController.clear();
    _listarFilmes();
  }

  Future<void> _trocarTipoLista(TipoListaFilmes tipo) async {
    if (_tipoSelecionado == tipo && _pesquisaController.text.isEmpty) {
      return;
    }

    _debounce?.cancel();
    _tipoSelecionado = tipo;
    _pesquisaController.clear();

    await _listarFilmes();
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
                onLimpar: _limparPesquisa,
                onChanged: _onPesquisaAlterada,
              ),
              const SizedBox(height: 12),
              _buildFiltros(),
              const SizedBox(height: _pagePadding),
              Expanded(child: _buildConteudo()),
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
      title: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          _voltarInicio();
        },
        child: const Text(
          'ULBRA Filmes',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      actions: const [SizedBox(width: 72)],
    );
  }

  Widget _buildFiltros() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFiltroChip(
          titulo: 'Avaliados',
          tipo: TipoListaFilmes.maisAvaliados,
        ),
        _buildFiltroChip(titulo: 'Cartaz', tipo: TipoListaFilmes.emCartaz),
        _buildFiltroChip(
          titulo: 'Tendências',
          tipo: TipoListaFilmes.tendencias,
        ),
      ],
    );
  }

  Widget _buildConteudo() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.filmes.isEmpty) {
      return Center(
        child: Text(_controller.mensagem, textAlign: TextAlign.center),
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

  Widget _buildFiltroChip({
    required String titulo,
    required TipoListaFilmes tipo,
  }) {
    final selecionado = _tipoSelecionado == tipo;

    return ChoiceChip(
      label: Text(titulo),
      selected: selecionado,
      onSelected: (_) {
        FocusScope.of(context).unfocus();
        _trocarTipoLista(tipo);
      },
      selectedColor: AppColors.verdePrincipal,
      backgroundColor: AppColors.dourado.withValues(alpha: 0.20),
      labelStyle: TextStyle(
        color: selecionado ? AppColors.branco : AppColors.textoPrincipal,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(
        color: selecionado ? AppColors.verdePrincipal : AppColors.dourado,
      ),
      showCheckmark: false,
    );
  }

  Future<void> _voltarInicio() async {
    _debounce?.cancel();

    _pesquisaController.clear();

    _tipoSelecionado = TipoListaFilmes.populares;

    await _listarFilmes();
  }
}

