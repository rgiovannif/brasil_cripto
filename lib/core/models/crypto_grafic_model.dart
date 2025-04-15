class CryptoGraficModel {
  final double time;
  final double price;

  CryptoGraficModel({required this.time, required this.price});

  factory CryptoGraficModel.fromJson(List<dynamic> json) {
    return CryptoGraficModel(
      time: json[0].toDouble(),
      price: json[1].toDouble(),
    );
  }
}
