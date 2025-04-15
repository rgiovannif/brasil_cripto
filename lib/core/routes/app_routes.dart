import 'package:brasil_cripto/features/crypto_details/screen/crypto_details_screen.dart';
import 'package:flutter/material.dart';

const String cryptoDetailsRoute = '/crypto-detail';

Route<dynamic>? generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case cryptoDetailsRoute:
      try {
        final cryptoId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => CryptoDetailsScreen(cryptoId: cryptoId),
          settings: settings,
        );
      } catch (e) {
        return _buildErrorRoute(
          message: 'ID da criptomoeda inválido',
          settings: settings,
        );
      }
    default:
      return null;
  }
}

/// Método auxiliar para criar rotas de erro
MaterialPageRoute _buildErrorRoute({
  required String message,
  required RouteSettings settings,
}) {
  return MaterialPageRoute(
    builder:
        (_) => Scaffold(
          appBar: AppBar(title: const Text('Erro')),
          body: Center(child: Text(message)),
        ),
    settings: settings,
  );
}
