import '../entity/filme_entity.dart';
import '../entity/enum/tipo_lista_filme_enum.dart';
import '../services/filme_service_interface.dart';

class FilmeController {
  final IFilmeService _filmeService;

  FilmeController(this._filmeService);

  List<FilmeEntity> filmes = [];
  bool isLoading = false;
  String mensagem = 'Pesquise por um filme para começar';

  Future<void> buscarFilmes(String pesquisa) async {
    final pesquisaTratada = pesquisa.trim();

    if (pesquisaTratada.isEmpty) {
      filmes = [];
      mensagem = 'Digite o nome de um filme';
      return;
    }

    isLoading = true;
    mensagem = '';

    try {
      filmes = await _filmeService.buscarFilmes(pesquisaTratada);

      if (filmes.isEmpty) {
        mensagem = 'Nenhum filme encontrado';
      }
    } catch (e) {
      filmes = [];
      mensagem = 'Erro ao buscar filmes';
    } finally {
      isLoading = false;
    }
  }

  Future<void> listarFilmes(
      TipoListaFilmes tipo,
      ) async {
    isLoading = true;
    mensagem = '';

    try {
      filmes = await _filmeService.listarFilmes(tipo);

      if (filmes.isEmpty) {
        mensagem = 'Nenhum filme encontrado';
      }
    } catch (e) {
      filmes = [];
      mensagem = 'Erro ao carregar filmes';
    } finally {
      isLoading = false;
    }
  }
}