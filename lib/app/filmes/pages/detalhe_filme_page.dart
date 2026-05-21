import 'package:flutter/material.dart';
import '../../shared/theme/colors.dart';
import '../controllers/detalhe_filme_controller.dart';
import '../entity/filme_entity.dart';
import '../repositories/filme_repository.dart';
import '../services/filme_service.dart';

class DetalheFilmePage extends StatefulWidget {
  final String id;

  const DetalheFilmePage({
    super.key,
    required this.id,
  });

  @override
  State<DetalheFilmePage> createState() => _DetalheFilmePageState();
}

class _DetalheFilmePageState extends State<DetalheFilmePage> {
  late final DetalheFilmeController _controller;

  @override
  void initState() {
    super.initState();

    final repository = FilmeRepository();
    final service = FilmeService(repository);

    _controller = DetalheFilmeController(service);

    _buscarDetalhes();
  }

  Future<void> _buscarDetalhes() async {
    await _controller.buscarDetalhesFilme(widget.id);

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalhes do Filme',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: _buildConteudo(),
      ),
    );
  }

  Widget _buildConteudo() {
    if (_controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_controller.filme == null) {
      return Center(
        child: Text(_controller.mensagem),
      );
    }

    final filme = _controller.filme!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _PosterFilme(filme: filme),
          const SizedBox(height: 24),
          Text(
            filme.titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textoPrincipal,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 14,
            runSpacing: 8,
            children: [
              _InfoIcone(
                icon: Icons.calendar_month,
                texto: filme.ano,
              ),
              _InfoIcone(
                icon: Icons.access_time,
                texto: filme.duracaoFormatada,
              ),
              _InfoIcone(
                icon: Icons.star,
                texto: filme.notaFormatada,
                iconColor: AppColors.dourado,
              ),
              _InfoIcone(
                icon: Icons.category,
                texto: filme.generosFormatados,
              ),
            ],
          ),
          const SizedBox(height: 28),
          const _TituloSecao(texto: 'Sinopse'),
          const SizedBox(height: 10),
          Text(
            filme.sinopse.isEmpty ? 'Sinopse não informada.' : filme.sinopse,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          const _TituloSecao(texto: 'Informações'),
          const SizedBox(height: 10),
          _InfoLinha(
            label: 'Título original',
            value: filme.tituloOriginal,
          ),
          _InfoLinha(
            label: 'Lançamento',
            value: filme.dataLancamento.isEmpty
                ? 'Não informado'
                : filme.dataLancamento,
          ),
        ],
      ),
    );
  }
}

class _PosterFilme extends StatelessWidget {
  final DetalheFilmeEntity filme;

  const _PosterFilme({
    required this.filme,
  });

  bool get possuiPoster => filme.posterUrl.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: possuiPoster
          ? Image.network(
        filme.posterUrl,
        height: 360,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const _PosterIndisponivel();
        },
      )
          : const _PosterIndisponivel(),
    );
  }
}

class _TituloSecao extends StatelessWidget {
  final String texto;

  const _TituloSecao({
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textoPrincipal,
        ),
      ),
    );
  }
}

class _InfoLinha extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLinha({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty || value == 'N/A') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textoPrincipal,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class _PosterIndisponivel extends StatelessWidget {
  const _PosterIndisponivel();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 330,
      width: double.infinity,
      color: AppColors.cinzaClaro,
      child: const Icon(
        Icons.movie,
        size: 70,
      ),
    );
  }
}

class _InfoIcone extends StatelessWidget {
  final IconData icon;
  final String texto;
  final Color? iconColor;

  const _InfoIcone({
    required this.icon,
    required this.texto,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    if (texto.isEmpty || texto == 'N/A' || texto == 'Não informado') {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor ?? AppColors.textoSecundario,
        ),
        const SizedBox(width: 4),
        Text(
          texto,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}