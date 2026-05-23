import '../entity/detalhe_filme_entity.dart';
import '../entity/filme_entity.dart';
import '../entity/tipo_lista_filme_enum.dart';

abstract class IFilmeRepository {
  Future<List<FilmeEntity>> buscarFilmes(String pesquisa);

  Future<List<FilmeEntity>> listarFilmes(
      TipoListaFilmes tipo,
      );

  Future<DetalheFilmeEntity> buscarDetalhesFilme(String id);
}