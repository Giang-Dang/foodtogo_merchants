class Promotion {
  final int id;
  final int discountCreatorMerchanId;
  final String code;
  final String name;
  final int discountPercentage;
  final double discountAmount;
  final DateTime startDate;
  final DateTime endDate;

  const Promotion(
      {required this.id,
      required this.discountCreatorMerchanId,
      required this.code,
      required this.name,
      required this.discountPercentage,
      required this.discountAmount,
      required this.startDate,
      required this.endDate});

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
        id: json['id'],
        discountCreatorMerchanId: json['discountCreatorMerchanId'],
        code: json['code'],
        name: json['name'],
        discountPercentage: json['discountPercentage'],
        discountAmount: json['discountAmount'].toDouble(),
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']));
  }
}