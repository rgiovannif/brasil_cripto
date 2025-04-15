import 'dart:async';
import 'package:brasil_cripto/common/components/crypto_card_component.dart';
import 'package:brasil_cripto/core/models/crypto_model.dart';
import 'package:brasil_cripto/core/routes/app_routes.dart';
import 'package:brasil_cripto/features/crypto_list/viewmodels/crypto_list_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CryptoListScreen extends StatefulWidget {
  const CryptoListScreen({super.key});

  @override
  State<CryptoListScreen> createState() => _CryptoListScreenState();
}

class _CryptoListScreenState extends State<CryptoListScreen> {
  final TextEditingController _searchCryptoController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final CryptoListViewModel _viewModel;
  StreamSubscription? _searchSubscription;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.I<CryptoListViewModel>();
    _searchCryptoController.addListener(_onSearchTextChanged);
    _viewModel.searchController.addListener(_scrollToTopWhenSearchCleared);
  }

  void _onSearchTextChanged() {
    if (_searchCryptoController.text.isEmpty) {
      _viewModel.searchController.text = '';
      _viewModel.refreshData();
      return;
    }

    _searchSubscription?.cancel();
    _searchSubscription = Stream.fromFuture(
      Future.delayed(const Duration(milliseconds: 300)),
    ).listen((_) {
      _viewModel.searchController.text = _searchCryptoController.text;
    });
  }

  void _scrollToTopWhenSearchCleared() {
    if (_viewModel.searchController.text.isEmpty &&
        _scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _searchSubscription?.cancel();
    _searchCryptoController.dispose();
    _scrollController.dispose();
    _viewModel.searchController.removeListener(_scrollToTopWhenSearchCleared);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchCryptoController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.grey),
                    onPressed: () {
                      _searchCryptoController.clear();
                      _viewModel.searchController.text = '';
                      _viewModel.refreshData();
                    },
                  ),
                  hintText: 'Buscar Criptomoeda',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _viewModel.refreshData(),
                  child: StreamBuilder<List<Crypto>>(
                    stream: _viewModel.cryptoListStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return _buildErrorWidget(snapshot.error.toString());
                      }

                      final cryptos = snapshot.data ?? [];
                      if (cryptos.isEmpty &&
                          _searchCryptoController.text.isNotEmpty) {
                        return _buildEmptyWidget();
                      }
                      if (cryptos.isEmpty &&
                          _searchCryptoController.text.isEmpty) {
                        return _buildEmptyWidget();
                      }

                      return _buildCryptoList(cryptos);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCryptoList(List<Crypto> cryptos) {
    return StreamBuilder<Set<String>>(
      stream: _viewModel.favoriteIdsStream,
      builder: (context, favoriteSnapshot) {
        final favoriteIds = favoriteSnapshot.data ?? {};
        return ListView.builder(
          controller: _scrollController,
          itemCount: cryptos.length,
          itemBuilder: (context, index) {
            final crypto = cryptos[index];
            return CryptoCardComponent(
              id: crypto.id,
              name: crypto.name,
              imageUrl: crypto.image,
              price: crypto.currentPrice ?? 0.0,
              percentagePriceVariation: crypto.priceChange24h ?? 0.0,
              clickFavoriteCrypto: () => _viewModel.toggleFavorite(crypto),
              navigation:
                  () => Navigator.pushNamed(
                    context,
                    cryptoDetailsRoute,
                    arguments: crypto.id,
                  ),
              icon: Icon(
                favoriteIds.contains(crypto.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: Colors.red,
              ),
              isFavorite: favoriteIds.contains(crypto.id),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma cryptomoeda encontrada',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Erro: ${error.length > 100 ? "${error.substring(0, 100)}..." : error}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          TextButton(
            onPressed: () => _viewModel.refreshData(),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
