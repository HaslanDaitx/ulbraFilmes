import '../entity/detalhe_filme_entity.dart';
import '../services/filme_service_interface.dart';

class DetalheFilmeController {
  final IFilmeService _filmeService;

  DetalheFilmeController(this._filmeService);

  DetalheFilmeEntity? filme;
  bool isLoading = false;
  String mensagem = 'Carregando detalhes do filme';

  Future<void> buscarDetalhesFilme(String id) async {
    final idTratado = id.trim();

    if (idTratado.isEmpty) {
      filme = null;
      mensagem = 'Filme não informado';
      return;
    }

    isLoading = true;
    mensagem = '';

    try {
      filme = await _filmeService.buscarDetalhesFilme(idTratado);
    } catch (e) {
      filme = null;
      mensagem = 'Erro ao carregar detalhes do filme';
    } finally {
      isLoading = false;
    }
  }
}
