import '../entity/filme_entity.dart';

abstract class IFilmeRepository {
  Future<List<FilmeEntity>> buscarFilmes(String pesquisa);

  Future<List<FilmeEntity>> listarFilmesPopulares();

  Future<DetalheFilmeEntity> buscarDetalhesFilme(String id);
}