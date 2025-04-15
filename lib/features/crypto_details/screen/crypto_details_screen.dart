import 'package:brasil_cripto/core/models/crypto_grafic_model.dart';
import 'package:brasil_cripto/core/models/crypto_model.dart';
import 'package:brasil_cripto/features/crypto_details/viewmodels/crypto_details_viewmodel.dart';
import 'package:brasil_cripto/features/crypto_details/widgets/crypto_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CryptoDetailsScreen extends StatefulWidget {
  final String cryptoId;

  const CryptoDetailsScreen({super.key, required this.cryptoId});

  @override
  State<CryptoDetailsScreen> createState() => _CryptoDetailsScreenState();
}

class _CryptoDetailsScreenState extends State<CryptoDetailsScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CryptoDetailsViewModel(cryptoId: widget.cryptoId),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Detalhes da Crypto'),
          actions: [
            Consumer<CryptoDetailsViewModel>(
              builder: (context, viewModel, _) {
                return StreamBuilder<bool>(
                  stream: viewModel.isFavoriteStream,
                  builder: (context, snapshot) {
                    final isFavorite = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: isFavorite ? Colors.amber : null,
                      ),
                      onPressed: viewModel.toggleFavorite,
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Consumer<CryptoDetailsViewModel>(
            builder: (context, viewModel, _) {
              return StreamBuilder<Crypto?>(
                stream: viewModel.cryptoDetailStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    );
                  }

                  final crypto = snapshot.data!;
                  final priceChange = crypto.priceChange24h ?? 0;
                  final isPositive = priceChange >= 0;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.network(
                              crypto.image,
                              width: 50,
                              height: 50,
                              errorBuilder:
                                  (_, __, ___) =>
                                      const Icon(Icons.monetization_on),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              crypto.symbol.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.amberAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currencyFormat.format(crypto.currentPrice),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              isPositive
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color: isPositive ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${priceChange.toStringAsFixed(2)}%',
                              style: TextStyle(
                                color: isPositive ? Colors.green : Colors.red,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '24h',
                              style: TextStyle(
                                color: Color.fromARGB(255, 238, 232, 232),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        StreamBuilder<List<CryptoGraficModel>>(
                          stream: viewModel.cryptoChartDataStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Erro ao carregar gráfico: ${snapshot.error}',
                                ),
                              );
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text('Sem dados para o gráfico'),
                              );
                            }
                            return CryptoLineChart(data: snapshot.data!);
                          },
                        ),
                        const SizedBox(height: 32),
                        Text(
                          crypto.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          crypto.description ?? 'Descrição não disponível.',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
