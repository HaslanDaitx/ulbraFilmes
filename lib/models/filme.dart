import 'package:cloud_firestore/cloud_firestore.dart';

class Filme {
  const Filme({
    required this.id,
    required this.titulo,
    required this.ano,
    required this.genero,
    required this.createdAt,
  });

  final String id;
  final String titulo;
  final int ano;
  final String genero;
  final DateTime createdAt;

  factory Filme.fromMap(Map<String, dynamic> map, {String id = ''}) {
    final createdAt = map['createdAt'];
    return Filme(
      id: id,
      titulo: map['titulo'] as String? ?? '',
      ano: (map['ano'] as num?)?.toInt() ?? 0,
      genero: map['genero'] as String? ?? '',
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.tryParse(createdAt?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'ano': ano,
        'genero': genero,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
