import '../entity/detalhe_filme_entity.dart';
import '../entity/filme_entity.dart';
import '../entity/tipo_lista_filme_enum.dart';
import '../repositories/filme_repository_interface.dart';
import 'filme_service_interface.dart';

class FilmeService implements IFilmeService {
  final IFilmeRepository _filmeRepository;

  FilmeService(this._filmeRepository);

  @override
  Future<List<FilmeEntity>> buscarFilmes(String pesquisa) {
    final pesquisaTratada = pesquisa.trim();

    if (pesquisaTratada.isEmpty) {
      return Future.value([]);
    }

    return _filmeRepository.buscarFilmes(pesquisaTratada);
  }

  @override
  Future<DetalheFilmeEntity> buscarDetalhesFilme(String id) {
    final idTratado = id.trim();

    if (idTratado.isEmpty) {
      throw Exception('Id do filme não informado');
    }

    return _filmeRepository.buscarDetalhesFilme(idTratado);
  }

  @override
  Future<List<FilmeEntity>> listarFilmes(
      TipoListaFilmes tipo,
      ) {
    return _filmeRepository.listarFilmes(tipo);
  }
}