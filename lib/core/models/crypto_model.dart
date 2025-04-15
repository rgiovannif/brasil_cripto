import 'package:json_annotation/json_annotation.dart';

part 'crypto_model.g.dart';

@JsonSerializable()
class Crypto {
  final String id;
  final String symbol;
  final String name;
  @JsonKey(name: 'current_price')
  final num? currentPrice;
  @JsonKey(name: 'price_change_percentage_24h')
  final num? priceChange24h;
  final String image;
  @JsonKey(name: 'description', fromJson: _descriptionFromJson)
  final String? description;

  Crypto({
    required this.id,
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.priceChange24h,
    required this.image,
    this.description,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) => _$CryptoFromJson(json);
  Map<String, dynamic> toJson() => _$CryptoToJson(this);

  static String? _descriptionFromJson(dynamic json) {
    if (json == null) return null;

    /// Tenta pegar a descrição em português primeiro
    if (json is Map<String, dynamic>) {
      if (json['pt'] is String) {
        return json['pt'];
      }

      /// Se não tiver em português, tenta em inglês
      if (json['en'] is String) {
        return json['en'];
      }
    }
    return null;
  }
}
