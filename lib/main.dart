import 'package:brasil_cripto/app.dart';
import 'package:brasil_cripto/core/services/coin_gecko_service.dart';
import 'package:brasil_cripto/core/services/hive_service.dart';
import 'package:brasil_cripto/features/crypto_details/viewmodels/crypto_details_viewmodel.dart';
import 'package:brasil_cripto/features/crypto_favorites/viewmodels/favorites_viewmodel.dart';
import 'package:brasil_cripto/features/crypto_list/viewmodels/crypto_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

final getIt = GetIt.instance;

/// Configura as dependências globais do app (Hive, serviços, ViewModels).
Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  final hiveServiceInstance = HiveService();
  await hiveServiceInstance.init();

  getIt.registerLazySingleton(() => hiveServiceInstance);
  getIt.registerLazySingleton(() => CoinGeckoService());
  getIt.registerFactory(() => CryptoListViewModel());
  getIt.registerFactory(() => CryptoDetailsViewModel(cryptoId: ''));
  getIt.registerFactory(() => FavoritesViewModel());
}

void main() async {
  await init();
  runApp(const App());
}
