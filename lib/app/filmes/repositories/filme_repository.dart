import 'dart:convert';

import 'package:http/http.dart' as http;

import '../entity/detalhe_filme_entity.dart';
import '../entity/filme_entity.dart';
import '../entity/tipo_lista_filme_enum.dart';
import 'filme_repository_interface.dart';

class FilmeRepository implements IFilmeRepository {
  static const String _token =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkYWZmOTU2NDE4NzZlMjFkMDc5ZTRlZmZhYzVmNzZjYyIsIm5iZiI6MTc3OTMzNjQ4Mi40NDIsInN1YiI6IjZhMGU4NTIyYjA2M2U0OGZiMGRmYWFmMSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.VAryAKSiTHqlgFnLzR_KdXdXFlMwSz5Pn1uk19NwP68';

  static const String _authority = 'api.themoviedb.org';

  Map<String, String> get _headers {
    return {
      'Authorization': 'Bearer $_token',
      'accept': 'application/json',
    };
  }

  @override
  Future<List<FilmeEntity>> buscarFilmes(String pesquisa) async {
    if (pesquisa.trim().isEmpty) {
      return [];
    }

    final url = Uri.https(
      _authority,
      '/3/search/movie',
      {
        'query': pesquisa.trim(),
        'language': 'pt-BR',
        'page': '1',
      },
    );

    final response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar filmes');
    }

    final data = jsonDecode(response.body);

    final List filmesJson = data['results'] ?? [];

    return filmesJson
        .map((filmeJson) => FilmeEntity.fromMap(filmeJson))
        .toList();
  }

  @override
  Future<DetalheFilmeEntity> buscarDetalhesFilme(String id) async {
    final url = Uri.https(
      _authority,
      '/3/movie/$id',
      {
        'language': 'pt-BR',
      },
    );

    final response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar detalhes do filme');
    }

    final data = jsonDecode(response.body);

    return DetalheFilmeEntity.fromMap(data);
  }

  @override
  Future<List<FilmeEntity>> listarFilmes(
      TipoListaFilmes tipo,
      ) async {
    String path;

    switch (tipo) {
      case TipoListaFilmes.maisAvaliados:
        path = '/3/movie/top_rated';
        break;

      case TipoListaFilmes.emCartaz:
        path = '/3/movie/now_playing';
        break;

      case TipoListaFilmes.tendencias:
        path = '/3/trending/movie/day';
        break;

      case TipoListaFilmes.populares:
        path = '/3/movie/popular';
        break;
    }

    final url = Uri.https(
      _authority,
      path,
      {
        'language': 'pt-BR',
        'page': '1',
      },
    );

    final response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar filmes');
    }

    final data = jsonDecode(response.body);

    final List filmesJson = data['results'] ?? [];

    return filmesJson
        .map((filmeJson) => FilmeEntity.fromMap(filmeJson))
        .toList();
  }
}