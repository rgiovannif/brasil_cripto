import 'dart:async';

import 'package:brasil_cripto/core/models/crypto_model.dart';
import 'package:brasil_cripto/core/services/coin_gecko_service.dart';
import 'package:brasil_cripto/core/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:get_it/get_it.dart';

class CryptoListViewModel with ChangeNotifier {
  final CoinGeckoService _coinGeckoService = GetIt.I<CoinGeckoService>();
  final HiveService _hiveService = GetIt.I<HiveService>();

  /// Controlador para o campo de texto de pesquisa.
  final TextEditingController _searchController = TextEditingController();

  /// Stream que emite a lista de criptomoedas filtrada. Inicializado com uma lista vazia.
  final BehaviorSubject<List<Crypto>> _cryptoList =
      BehaviorSubject<List<Crypto>>.seeded([]);

  /// Stream que emite um conjunto (Set) dos IDs das criptomoedas favoritas. Inicializado com um conjunto vazio.
  final BehaviorSubject<Set<String>> _favoriteIds =
      BehaviorSubject<Set<String>>.seeded({});

  /// Stream que indica se os dados estão sendo carregados. Inicializado com `false`.
  final BehaviorSubject<bool> _isLoading = BehaviorSubject<bool>.seeded(false);

  /// Subscription para o stream da lista de criptomoedas do serviço.
  StreamSubscription? _cryptoListSubscription;

  /// Getter para o stream da lista de criptomoedas.
  Stream<List<Crypto>> get cryptoListStream => _cryptoList.stream;

  /// Getter para o controlador do campo de pesquisa.
  TextEditingController get searchController => _searchController;

  /// Getter para o stream dos IDs das criptomoedas favoritas.
  Stream<Set<String>> get favoriteIdsStream => _favoriteIds.stream;

  /// Getter para o stream que indica o estado de carregamento.
  Stream<bool> get isLoadingStream => _isLoading.stream;

  /// Construtor que inicializa a busca de dados e o carregamento dos IDs dos favoritos.
  CryptoListViewModel() {
    _init();
    _loadFavoriteIds();
  }

  /// Método para recarregar os dados da lista de criptomoedas.
  Future<void> refreshData() async {
    await _init();
  }

  /// Método inicializador que busca a lista de criptomoedas do serviço e configura o listener de pesquisa.
  Future<void> _init() async {
    // Cancela a subscription anterior para evitar múltiplas chamadas.
    await _cryptoListSubscription?.cancel();

    // Escuta o stream da lista de criptomoedas do serviço.
    _cryptoListSubscription = _coinGeckoService.cryptoListStream.listen(
      (data) {
        _cryptoList.add(data);
        _onSearchChanged();
      },
      onError: (error) {
        _cryptoList.addError('Falha ao carregar dados: $error');
      },
    );
    _searchController.addListener(_onSearchChanged);
  }

  /// Método para carregar os IDs das criptomoedas favoritas do serviço Hive.
  Future<void> _loadFavoriteIds() async {
    try {
      final favorites = _hiveService.getAllFavorites();

      // Mapeia a lista de favoritos para obter apenas os IDs, filtrando valores nulos ou vazios,
      // e converte para um Set para garantir unicidade.
      final ids =
          favorites
              .map((fav) => fav['id']?.toString())
              .where((id) => id != null && id.isNotEmpty)
              .toSet();

      _favoriteIds.add(ids.cast<String>());
    } catch (e) {
      _favoriteIds.add({});
    }
  }

  /// Método chamado quando o texto de pesquisa muda, filtrando a lista de criptomoedas.
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    final baseList = _coinGeckoService.lastFetchedList;

    final filteredList =
        query.isEmpty
            ? baseList
            : baseList
                .where(
                  (crypto) =>
                      crypto.name.toLowerCase().contains(query) ||
                      crypto.symbol.toLowerCase().contains(query),
                )
                .toList();

    _cryptoList.add(filteredList);
    notifyListeners();
  }

  /// Método para alternar o estado de favorito de uma criptomoeda específica.
  Future<void> toggleFavorite(Crypto crypto) async {
    try {
      // Cria uma cópia mutável do conjunto atual de IDs favoritos.
      final currentFavorites = Set<String>.from(_favoriteIds.value);

      if (currentFavorites.contains(crypto.id)) {
        await _hiveService.removeFavorite(crypto.id);
        currentFavorites.remove(crypto.id);
      } else {
        await _hiveService.addFavorite(
          crypto.id,
          crypto.name,
          crypto.image,
          crypto.currentPrice,
          crypto.priceChange24h,
        );
        currentFavorites.add(crypto.id);
      }

      _favoriteIds.add(currentFavorites);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao alternar favorito: $e');
    }
  }

  /// Método para liberar os recursos quando o ViewModel não é mais necessário.
  @override
  void dispose() {
    _cryptoListSubscription?.cancel();
    _cryptoList.close();
    _searchController.dispose();
    _favoriteIds.close();
    super.dispose();
  }
}
