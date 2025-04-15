import 'package:brasil_cripto/core/services/hive_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:get_it/get_it.dart';

class FavoritesViewModel {
  final _hiveService = GetIt.I<HiveService>();

  /// Stream que emite a lista de criptomoedas favoritas. Inicializado com uma lista vazia.
  final _favorites = BehaviorSubject<List<Map>>.seeded([]);

  /// Getter para o stream da lista de favoritos.
  Stream<List<Map>> get favoritesStream => _favorites.stream;

  /// Construtor que carrega a lista de favoritos ao ser instanciado.
  FavoritesViewModel() {
    loadFavorites();
  }

  /// Método para carregar a lista de criptomoedas favoritas do serviço Hive.
  Future<void> loadFavorites() async {
    try {
      final favorites =
          _hiveService
              .getAllFavorites()
              .where((fav) => fav['id'] != null)
              .toList();
      _favorites.add(favorites);
    } catch (e) {
      _favorites.addError(e);
    }
  }

  /// Método para remover um favorito com o ID especificado.
  Future<void> removeFavorite(String id) async {
    await _hiveService.removeFavorite(id);
    loadFavorites();
  }

  /// Método para liberar os recursos quando o ViewModel não é mais necessário.
  Future<void> dispose() async {
    await _favorites.close();
  }
}
