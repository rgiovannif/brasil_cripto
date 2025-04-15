import 'package:brasil_cripto/core/models/crypto_grafic_model.dart';
import 'package:brasil_cripto/core/models/crypto_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

class CoinGeckoService {
  final Dio _dio;
  final _cryptoListStreamController = BehaviorSubject<List<Crypto>>.seeded([]);
  final _cryptoDetailStreamController = BehaviorSubject<Crypto?>.seeded(null);
  final _marketChartStreamController =
      BehaviorSubject<List<CryptoGraficModel>>.seeded([]);
  Timer? _updateTimer;
  final List<Crypto> _lastFullList = [];

  Stream<List<Crypto>> get cryptoListStream =>
      _cryptoListStreamController.stream;
  Stream<Crypto?> get cryptoDetailStream =>
      _cryptoDetailStreamController.stream;
  Stream<List<CryptoGraficModel>> get marketChartStream =>
      _marketChartStreamController.stream;
  List<Crypto> get lastFetchedList => _lastFullList;

  /// Inicializa o serviço com uma instância customizável de Dio.
  CoinGeckoService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              baseUrl: 'https://api.coingecko.com/api/v3/',
            ),
          ) {
    _startPeriodicUpdates();
  }

  /// Busca a lista de criptomoedas da API e atualiza o stream.
  Future<void> _fetchCryptoList() async {
    if (_cryptoListStreamController.isClosed) return;

    try {
      final response = await _dio.get(
        'coins/markets',
        queryParameters: {
          'vs_currency': 'usd',
          'order': 'market_cap_desc',
          'per_page': 100,
          'page': 1,
          'sparkline': false,
        },
      );

      final cryptoList =
          (response.data as List).map((json) => Crypto.fromJson(json)).toList();

      if (!_cryptoListStreamController.isClosed) {
        _cryptoListStreamController.add(cryptoList);
      }
    } on DioException catch (e) {
      if (!_cryptoListStreamController.isClosed) {
        _cryptoListStreamController.addError(_handleDioError(e));
      }
    } catch (e) {
      if (!_cryptoListStreamController.isClosed) {
        _cryptoListStreamController.addError(
          'Erro desconhecido: ${e.toString()}',
        );
      }
    }
  }

  /// Busca detalhes de uma criptomoeda específica por ID e atualiza o stream.
  Future<void> fetchCryptoDetail(String id) async {
    if (_cryptoDetailStreamController.isClosed) return;

    try {
      final response = await _dio.get(
        'coins/$id',
        queryParameters: {
          'localization': 'false',
          'tickers': 'false',
          'market_data': 'true',
          'community_data': 'false',
          'developer_data': 'false',
          'sparkline': 'false',
        },
      );

      final cryptoDetail = Crypto(
        id: response.data['id'],
        symbol: response.data['symbol'],
        name: response.data['name'],
        currentPrice: response.data['market_data']['current_price']['usd'],
        priceChange24h:
            response.data['market_data']['price_change_percentage_24h'],
        image: response.data['image']['large'],
        description: response.data['description']?['pt'],
      );

      if (!_cryptoDetailStreamController.isClosed) {
        _cryptoDetailStreamController.add(cryptoDetail);
      }
    } on DioException catch (e) {
      if (!_cryptoDetailStreamController.isClosed) {
        _cryptoDetailStreamController.addError(_handleDioError(e));
      }
    } catch (e) {
      if (!_cryptoDetailStreamController.isClosed) {
        _cryptoDetailStreamController.addError(
          'Erro ao buscar detalhes: ${e.toString()}',
        );
      }
    }
  }

  /// Busca dados históricos de preços para montagem de gráficos.
  Future<List<CryptoGraficModel>> getMarketChart(
    String id, {
    String vsCurrency = 'usd',
    String days = '30',
    String interval = 'daily',
  }) async {
    if (_marketChartStreamController.isClosed) return [];

    try {
      final response = await _dio.get(
        'coins/$id/market_chart',
        queryParameters: {
          'vs_currency': vsCurrency,
          'days': days,
          'interval': interval,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> prices = response.data['prices'];
        final chartData =
            prices
                .map(
                  (data) => CryptoGraficModel.fromJson(data as List<dynamic>),
                )
                .toList();

        if (!_marketChartStreamController.isClosed) {
          _marketChartStreamController.add(chartData);
        }
        return chartData;
      } else {
        throw Exception('Status code inválido: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (!_marketChartStreamController.isClosed) {
        _marketChartStreamController.addError(_handleDioError(e));
      }
      rethrow;
    } catch (e) {
      if (!_marketChartStreamController.isClosed) {
        _marketChartStreamController.addError(
          'Erro ao carregar gráfico: ${e.toString()}',
        );
      }
      rethrow;
    }
  }

  /// Reinicia a lista exibida para a última busca completa (cache).
  Future<void> resetToFullList() async {
    if (!_cryptoListStreamController.isClosed && _lastFullList.isNotEmpty) {
      _cryptoListStreamController.add(_lastFullList);
    } else {
      await _fetchCryptoList();
    }
  }

  /// Inicia atualizações periódicas da lista de criptomoedas (a cada 10 segundos).
  void _startPeriodicUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchCryptoList().catchError(
        (e) => debugPrint('Erro na atualização periódica: $e'),
      );
    });
    _fetchCryptoList();
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 404:
          return 'Recurso não encontrado';
        case 429:
          return 'Limite de requisições excedido';
        case 500:
          return 'Erro interno do servidor';
        default:
          return 'Erro na requisição: ${e.response!.statusCode}';
      }
    } else {
      return 'Erro de conexão: ${e.message}';
    }
  }

  /// Libera recursos (streams e timer) para evitar vazamentos de memória.
  /// Deve ser chamado quando o serviço não for mais usado
  void dispose() {
    _updateTimer?.cancel();
    _cryptoListStreamController.close();
    _cryptoDetailStreamController.close();
    _marketChartStreamController.close();
  }
}
