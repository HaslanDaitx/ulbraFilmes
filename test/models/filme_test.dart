import 'package:flutter_test/flutter_test.dart';
import 'package:ulbra_filmes_app/models/filme.dart';

void main() {
  test('Filme converte dados simples com fromMap', () {
    final filme = Filme.fromMap(
      {
        'titulo': 'Interestelar',
        'ano': 2014,
        'genero': 'Ficção científica',
        'createdAt': '2026-06-29T12:00:00.000',
      },
      id: 'filme-1',
    );

    expect(filme.id, 'filme-1');
    expect(filme.titulo, 'Interestelar');
    expect(filme.ano, 2014);
    expect(filme.genero, 'Ficção científica');
    expect(filme.createdAt, DateTime(2026, 6, 29, 12));
  });
}
