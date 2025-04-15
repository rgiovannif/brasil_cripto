import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String _favoritesBoxName = 'favorites';
  late Box<Map> _favoritesBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _favoritesBox = await Hive.openBox<Map>(_favoritesBoxName);
  }

  Future<void> clearAllFavorites() async {
    await _favoritesBox.clear();
  }

  Future<void> addFavorite(
    String id,
    String name,
    String? imageUrl,
    num? currentPrice,
    num? priceChange24h,
  ) async {
    if (id.isEmpty) {
      throw ArgumentError('ID não pode ser vazio');
    }
    await _favoritesBox.put(id, {
      'id': id,
      'name': name,
      'imageUrl': imageUrl ?? '',
      'currentPrice': currentPrice,
      'priceChange24h': priceChange24h,
    });
  }

  Future<void> removeFavorite(String id) async {
    await _favoritesBox.delete(id);
  }

  List<Map> getAllFavorites() {
    return _favoritesBox.values.toList();
  }

  Future<bool> isFavorite(String id) async {
    return _favoritesBox.containsKey(id);
  }

  Future<void> close() async {
    await _favoritesBox.close();
  }

  Map? getFavorite(String id) {
    return _favoritesBox.get(id);
  }
}
