import '../entity/filme_entity.dart';

abstract class IFilmeService {
  Future<List<FilmeEntity>> buscarFilmes(String pesquisa);

  Future<List<FilmeEntity>> listarFilmesPopulares();

  Future<DetalheFilmeEntity> buscarDetalhesFilme(String id);
}