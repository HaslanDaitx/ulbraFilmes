import 'dart:convert';

import 'package:http/http.dart' as http;

import '../entity/detalhe_filme_entity.dart';
import '../entity/filme_entity.dart';
import '../entity/enum/tipo_lista_filme_enum.dart';
import 'filme_repository_interface.dart';

class FilmeRepository implements IFilmeRepository {
  static const String _token =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkYWZmOTU2NDE4NzZlMjFkMDc5ZTRlZmZhYzVmNzZjYyIsIm5iZiI6MTc3OTMzNjQ4Mi40NDIsInN1YiI6IjZhMGU4NTIyYjA2M2U0OGZiMGRmYWFmMSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.VAryAKSiTHqlgFnLzR_KdXdXFlMwSz5Pn1uk19NwP68';

  static const String _authority = 'api.themoviedb.org';

  Map<String, String> get _headers {
    return {'Authorization': 'Bearer $_token', 'accept': 'application/json'};
  }

  @override
  Future<List<FilmeEntity>> buscarFilmes(String pesquisa) async {
    final pesquisaTratada = pesquisa.trim();

    if (pesquisaTratada.isEmpty) {
      return [];
    }

    final url = Uri.https(_authority, '/3/search/movie', {
      'query': pesquisaTratada,
      'language': 'pt-BR',
      'page': '1',
      'include_adult': 'false',
    });

    final response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar filmes');
    }

    return _mapearListaFilmes(response.body);
  }

  @override
  Future<DetalheFilmeEntity> buscarDetalhesFilme(String id) async {
    final url = Uri.https(_authority, '/3/movie/$id', {'language': 'pt-BR'});

    final response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar detalhes do filme');
    }

    final data = jsonDecode(response.body);

    return DetalheFilmeEntity.fromMap(data);
  }

  @override
  Future<List<FilmeEntity>> listarFilmes(TipoListaFilmes tipo) async {
    final path = _getPathPorTipo(tipo);

    final url = Uri.https(_authority, path, {
      'language': 'pt-BR',
      'page': '1',
      'include_adult': 'false',
    });

    final response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Erro ao carregar filmes');
    }

    return _mapearListaFilmes(response.body);
  }

  String _getPathPorTipo(TipoListaFilmes tipo) {
    switch (tipo) {
      case TipoListaFilmes.maisAvaliados:
        return '/3/movie/top_rated';
      case TipoListaFilmes.emCartaz:
        return '/3/movie/now_playing';
      case TipoListaFilmes.tendencias:
        return '/3/trending/movie/day';
      case TipoListaFilmes.populares:
        return '/3/movie/popular';
    }
  }

  List<FilmeEntity> _mapearListaFilmes(String body) {
    final data = jsonDecode(body);

    final List filmesJson = data['results'] ?? [];

    return filmesJson
        .where((filmeJson) => filmeJson['adult'] != true)
        .map((filmeJson) => FilmeEntity.fromMap(filmeJson))
        .toList();
  }
}
