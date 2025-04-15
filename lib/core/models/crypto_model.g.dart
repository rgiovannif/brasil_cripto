// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crypto_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Crypto _$CryptoFromJson(Map<String, dynamic> json) => Crypto(
  id: json['id'] as String,
  symbol: json['symbol'] as String,
  name: json['name'] as String,
  currentPrice: json['current_price'] as num?,
  priceChange24h: json['price_change_percentage_24h'] as num?,
  image: json['image'] as String,
  description: Crypto._descriptionFromJson(json['description']),
);

Map<String, dynamic> _$CryptoToJson(Crypto instance) => <String, dynamic>{
  'id': instance.id,
  'symbol': instance.symbol,
  'name': instance.name,
  'current_price': instance.currentPrice,
  'price_change_percentage_24h': instance.priceChange24h,
  'image': instance.image,
  'description': instance.description,
};
