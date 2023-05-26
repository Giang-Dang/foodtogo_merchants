class OrderDTO {
  final int id;
  final int merchantId;
  final int shipperId;
  final int customerId;
  final int promotionId;
  final DateTime placedTime;
  final DateTime eta;
  final DateTime deliveryCompletionTime;
  final double orderPrice;
  final double shippingFee;
  final double appFee;
  final double promotionDiscount;
  final String status;
  final String cancellationReason;

  const OrderDTO(
      {required this.id,
      required this.merchantId,
      required this.shipperId,
      required this.customerId,
      required this.promotionId,
      required this.placedTime,
      required this.eta,
      required this.deliveryCompletionTime,
      required this.orderPrice,
      required this.shippingFee,
      required this.appFee,
      required this.promotionDiscount,
      required this.status,
      this.cancellationReason = ''});

  factory OrderDTO.fromJson(Map<String, dynamic> json) {
    return OrderDTO(
        id: json['id'],
        merchantId: json['merchantId'],
        shipperId: json['shipperId'],
        customerId: json['customerId'],
        promotionId: json['promotionId'],
        placedTime: DateTime.parse(json['placedTime']),
        eta: DateTime.parse(json['eta']),
        deliveryCompletionTime: DateTime.parse(json['deliveryCompletionTime']),
        orderPrice: json['orderPrice'].toDouble(),
        shippingFee: json['shippingFee'].toDouble(),
        appFee: json['appFee'].toDouble(),
        promotionDiscount: json['promotionDiscount'].toDouble(),
        status: json['status'],
        cancellationReason: json['cancellationReason']);
  }
}
