class Promotion {
  final int id;
  final int discountCreatorMerchanId;
  final String name;
  final String description;
  final int discountPercentage;
  final double discountAmount;
  final DateTime startDate;
  final DateTime endDate;
  final int quantity;
  final int quantityLeft;

  const Promotion({
    required this.id,
    required this.discountCreatorMerchanId,
    required this.name,
    this.description = '',
    required this.discountPercentage,
    required this.discountAmount,
    required this.startDate,
    required this.endDate,
    required this.quantity,
    required this.quantityLeft,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'],
      discountCreatorMerchanId: json['discountCreatorMerchanId'],
      name: json['name'],
      description: json['description'],
      discountPercentage: json['discountPercentage'],
      discountAmount: json['discountAmount'].toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      quantity: json['quantity'],
      quantityLeft: json['quantityLeft'],
    );
  }
}