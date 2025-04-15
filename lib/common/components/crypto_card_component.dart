import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CryptoCardComponent extends StatelessWidget {
  final String id;
  final String name;
  final num price;
  final num percentagePriceVariation;
  final Function()? navigation;
  final Icon icon;
  final Function()? clickFavoriteCrypto;
  final String imageUrl;
  final bool isFavorite;
  final bool isFavoriteScreen;

  const CryptoCardComponent({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    required this.percentagePriceVariation,
    required this.navigation,
    required this.icon,
    required this.clickFavoriteCrypto,
    required this.imageUrl,
    required this.isFavorite,
    this.isFavoriteScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final formattedPrice = currencyFormat.format(price);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(255, 241, 238, 238),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: navigation,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Image.network(imageUrl),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.length > 20 ? '${name.substring(0, 20)}...' : name,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Row(
                      children: [
                        Text(formattedPrice),
                        const SizedBox(width: 24),
                        Row(
                          children: [
                            if (percentagePriceVariation > 0)
                              const Icon(Icons.trending_up, color: Colors.green)
                            else if (percentagePriceVariation < 0)
                              const Icon(Icons.trending_down, color: Colors.red)
                            else
                              const Icon(
                                Icons.trending_flat,
                                color: Colors.grey,
                              ),
                            const SizedBox(width: 4),
                            Text(
                              '${percentagePriceVariation.toStringAsFixed(2)}%',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
          IconButton(
            onPressed: clickFavoriteCrypto,
            icon: Icon(
              isFavoriteScreen
                  ? Icons.delete
                  : isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
