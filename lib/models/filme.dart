import 'package:cloud_firestore/cloud_firestore.dart';

class Filme {
  const Filme({
    required this.id,
    required this.titulo,
    required this.ano,
    required this.genero,
    required this.createdAt,
    this.imagemUrl = '',
    this.descricao = '',
  });

  final String id;
  final String titulo;
  final int ano;
  final String genero;
  final DateTime createdAt;
  final String imagemUrl;
  final String descricao;

  factory Filme.fromMap(Map<String, dynamic> map, {String id = ''}) {
    final createdAt = map['createdAt'];

    return Filme(
      id: id,
      titulo: map['titulo'] as String? ?? '',
      ano: (map['ano'] as num?)?.toInt() ?? 0,
      genero: map['genero'] as String? ?? '',
      imagemUrl: map['imagemUrl'] as String? ?? '',
      descricao: map['descricao'] as String? ?? '',
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.tryParse(createdAt?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'titulo': titulo,
    'ano': ano,
    'genero': genero,
    'imagemUrl': imagemUrl,
    'descricao': descricao,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  Filme copyWith({
    String? id,
    String? titulo,
    int? ano,
    String? genero,
    DateTime? createdAt,
    String? imagemUrl,
    String? descricao,
  }) {
    return Filme(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      ano: ano ?? this.ano,
      genero: genero ?? this.genero,
      createdAt: createdAt ?? this.createdAt,
      imagemUrl: imagemUrl ?? this.imagemUrl,
      descricao: descricao ?? this.descricao,
    );
  }
}