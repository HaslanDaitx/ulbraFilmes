class FilmeEntity {
  final int id;
  final String titulo;
  final String tituloOriginal;
  final String dataLancamento;
  final String sinopse;
  final String poster;
  final double nota;

  FilmeEntity({
    required this.id,
    required this.titulo,
    required this.tituloOriginal,
    required this.dataLancamento,
    required this.sinopse,
    required this.poster,
    required this.nota,
  });

  factory FilmeEntity.fromMap(Map<String, dynamic> map) {
    return FilmeEntity(
      id: map['id'] ?? 0,
      titulo: map['title'] ?? '',
      tituloOriginal: map['original_title'] ?? '',
      dataLancamento: map['release_date'] ?? '',
      sinopse: map['overview'] ?? '',
      poster: map['poster_path'] ?? '',
      nota: _parseDouble(map['vote_average']),
    );
  }

  String get ano {
    if (dataLancamento.isEmpty) {
      return 'Não informado';
    }

    return dataLancamento.split('-').first;
  }

  String get posterUrl {
    if (poster.isEmpty) {
      return '';
    }

    return 'https://image.tmdb.org/t/p/w500$poster';
  }

  String get notaFormatada {
    return nota.toStringAsFixed(1);
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
