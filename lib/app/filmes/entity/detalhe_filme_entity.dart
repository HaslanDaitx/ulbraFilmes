class DetalheFilmeEntity {
  final int id;
  final String titulo;
  final String tituloOriginal;
  final String dataLancamento;
  final String sinopse;
  final String poster;
  final double nota;
  final int duracao;
  final List<String> generos;

  DetalheFilmeEntity({
    required this.id,
    required this.titulo,
    required this.tituloOriginal,
    required this.dataLancamento,
    required this.sinopse,
    required this.poster,
    required this.nota,
    required this.duracao,
    required this.generos,
  });

  factory DetalheFilmeEntity.fromMap(Map<String, dynamic> map) {
    return DetalheFilmeEntity(
      id: map['id'] ?? 0,
      titulo: map['title'] ?? '',
      tituloOriginal: map['original_title'] ?? '',
      dataLancamento: map['release_date'] ?? '',
      sinopse: map['overview'] ?? '',
      poster: map['poster_path'] ?? '',
      nota: _parseDouble(map['vote_average']),
      duracao: map['runtime'] ?? 0,
      generos: _parseGeneros(map['genres']),
    );
  }

  String get ano => _formatarAno(dataLancamento);

  String get dataLancamentoFormatada {
    if (dataLancamento.isEmpty) {
      return 'Não informado';
    }

    final partes = dataLancamento.split('-');

    if (partes.length != 3) {
      return dataLancamento;
    }

    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  String get posterUrl => _formatarPosterUrl(poster);

  String get notaFormatada => nota.toStringAsFixed(1);

  String get duracaoFormatada {
    if (duracao <= 0) {
      return 'Não informado';
    }

    return '$duracao min';
  }

  String get generosFormatados {
    if (generos.isEmpty) {
      return 'Não informado';
    }

    return generos.join(', ');
  }
}

double _parseDouble(dynamic value) {
  if (value == null) {
    return 0;
  }

  if (value is int) {
    return value.toDouble();
  }

  if (value is double) {
    return value;
  }

  return double.tryParse(value.toString()) ?? 0;
}

String _formatarAno(String dataLancamento) {
  if (dataLancamento.isEmpty) {
    return 'Não informado';
  }

  return dataLancamento.split('-').first;
}

String _formatarPosterUrl(String poster) {
  if (poster.isEmpty) {
    return '';
  }

  return 'https://image.tmdb.org/t/p/w500$poster';
}

List<String> _parseGeneros(dynamic value) {
  if (value == null) {
    return [];
  }

  return List<String>.from(
    value.map((genero) => genero['name']),
  );
}