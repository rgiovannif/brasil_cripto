import 'dart:async';

import 'package:brasil_cripto/core/models/crypto_grafic_model.dart';
import 'package:brasil_cripto/core/models/crypto_model.dart';
import 'package:brasil_cripto/core/services/coin_gecko_service.dart';
import 'package:brasil_cripto/core/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class CryptoDetailsViewModel with ChangeNotifier {
  final CoinGeckoService _coinGeckoService = GetIt.I<CoinGeckoService>();
  final HiveService _hiveService = GetIt.I<HiveService>();

  /// Stream que emite os detalhes da criptomoeda. Inicializado com `null`.
  final BehaviorSubject<Crypto?> _cryptoDetail =
      BehaviorSubject<Crypto?>.seeded(null);

  /// Stream que indica se a criptomoeda atual é um favorito. Inicializado com `false`.
  final BehaviorSubject<bool> _isFavorite = BehaviorSubject<bool>.seeded(false);

  /// ID da criptomoeda para a qual os detalhes estão sendo buscados.
  final String cryptoId;

  /// Stream que emite os dados do gráfico da criptomoeda. Inicializado com uma lista vazia.
  final BehaviorSubject<List<CryptoGraficModel>> _cryptoChartData =
      BehaviorSubject<List<CryptoGraficModel>>.seeded([]);

  /// Subscription para o stream de detalhes da criptomoeda do serviço.
  StreamSubscription<Crypto?>? _cryptoDetailSubscription;

  /// Getter para o stream de detalhes da criptomoeda.
  Stream<Crypto?> get cryptoDetailStream => _cryptoDetail.stream;

  /// Getter para o stream que indica se a criptomoeda é favorita.
  Stream<bool> get isFavoriteStream => _isFavorite.stream;

  /// Getter para o stream dos dados do gráfico da criptomoeda.
  Stream<List<CryptoGraficModel>> get cryptoChartDataStream =>
      _cryptoChartData.stream;

  /// Construtor que recebe o ID da criptomoeda e inicializa a busca de dados.
  CryptoDetailsViewModel({required this.cryptoId}) {
    _init();
  }

  /// Método inicializador que busca os detalhes da criptomoeda, verifica se é favorita
  /// e busca os dados do gráfico.
  Future<void> _init() async {
    await _coinGeckoService.fetchCryptoDetail(cryptoId);

    // Busca a lista de todos os favoritos e verifica se a criptomoeda atual está nela.
    final favorites = _hiveService.getAllFavorites();
    _isFavorite.add(favorites.any((fav) => fav['id'] == cryptoId));

    // Busca os dados do gráfico da criptomoeda para os últimos 30 dias com intervalo diário.
    try {
      final chartData = await _coinGeckoService.getMarketChart(
        cryptoId,
        days: '30',
        interval: 'daily',
      );
      if (!_cryptoChartData.isClosed) {
        _cryptoChartData.add(chartData);
      }
    } catch (e) {
      debugPrint('Erro ao buscar dados do gráfico: $e');
      if (!_cryptoChartData.isClosed) {
        _cryptoChartData.addError('Erro ao carregar gráfico');
      }
    }

    // Escuta as atualizações do stream de detalhes da criptomoeda do serviço.
    _cryptoDetailSubscription = _coinGeckoService.cryptoDetailStream.listen((
      detail,
    ) {
      // Se o detalhe recebido não for nulo, corresponder ao ID atual e o stream não estiver fechado,
      // adiciona o detalhe ao stream deste ViewModel.
      if (detail != null && detail.id == cryptoId && !_cryptoDetail.isClosed) {
        _cryptoDetail.add(detail);
      }
    });
  }

  /// Método para alternar o estado de favorito da criptomoeda.
  Future<void> toggleFavorite() async {
    final currentDetail = _cryptoDetail.valueOrNull;
    if (currentDetail == null) return;

    try {
      final isCurrentlyFavorite = _isFavorite.valueOrNull ?? false;

      if (isCurrentlyFavorite) {
        await _hiveService.removeFavorite(cryptoId);
      } else {
        await _hiveService.addFavorite(
          currentDetail.id,
          currentDetail.name,
          currentDetail.image,
          currentDetail.currentPrice,
          currentDetail.priceChange24h,
        );
      }

      // Atualiza o stream de favorito com o novo estado.
      _isFavorite.add(!isCurrentlyFavorite);
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao alternar favorito: $e');
    }
  }

  /// Método para liberar os recursos quando o ViewModel não é mais necessário.
  @override
  void dispose() {
    // Cancela a subscription para evitar vazamentos de memória.
    _cryptoDetailSubscription?.cancel();
    // Fecha os BehaviorSubject para liberar os streams.
    _cryptoDetail.close();
    _isFavorite.close();
    _cryptoChartData.close();
    super.dispose();
  }
}
