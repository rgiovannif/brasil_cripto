import 'package:brasil_cripto/common/components/crypto_card_component.dart';
import 'package:brasil_cripto/core/routes/app_routes.dart';
import 'package:brasil_cripto/features/crypto_favorites/viewmodels/favorites_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CryptoFavoriteScreen extends StatefulWidget {
  const CryptoFavoriteScreen({super.key});

  @override
  State<CryptoFavoriteScreen> createState() => _CryptoFavoriteScreenState();
}

class _CryptoFavoriteScreenState extends State<CryptoFavoriteScreen> {
  final _favoritesViewModel = GetIt.I<FavoritesViewModel>();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    await _favoritesViewModel.loadFavorites();
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    String cryptoName,
    String cryptoId,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remover favorito'),
          content: Text(
            'Tem certeza que deseja remover $cryptoName dos favoritos?',
            style: const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _favoritesViewModel.removeFavorite(cryptoId);
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$cryptoName removido dos favoritos'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Remover',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: const Text('Favoritos')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<List<Map>>(
            stream: _favoritesViewModel.favoritesStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro ao carregar favoritos: ${snapshot.error}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma criptomoeda favoritada',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              } else {
                final favorites = snapshot.data!;
                return ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final favorite = favorites[index];
                    final id = favorite['id'] as String? ?? '';
                    final name =
                        favorite['name'] as String? ?? 'Nome desconhecido';
                    final imageUrl = favorite['imageUrl'] as String? ?? '';
                    final currentPrice = favorite['currentPrice'] as num? ?? 0;
                    final priceChange24h =
                        favorite['priceChange24h'] as num? ?? 0;

                    if (id.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: CryptoCardComponent(
                        isFavorite: true,
                        isFavoriteScreen: true,
                        id: id,
                        name: name,
                        price: currentPrice.toDouble(),
                        percentagePriceVariation: priceChange24h.toDouble(),
                        imageUrl: imageUrl,
                        navigation: () {
                          Navigator.pushNamed(
                            context,
                            cryptoDetailsRoute,
                            arguments: id,
                          );
                        },
                        icon: const Icon(Icons.remove, color: Colors.red),
                        clickFavoriteCrypto: () {
                          _showDeleteConfirmationDialog(context, name, id);
                        },
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
