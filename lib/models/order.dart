import 'package:foodtogo_merchants/models/customer.dart';
import 'package:foodtogo_merchants/models/merchant.dart';
import 'package:foodtogo_merchants/models/promotion.dart';
import 'package:foodtogo_merchants/models/shipper.dart';

class Order {
  final int id;
  final Merchant merchant;
  final Shipper? shipper;
  final Customer customer;
  final Promotion? promotion;
  final DateTime placedTime;
  final DateTime eta;
  final DateTime? deliveryCompletionTime;
  final double orderPrice;
  final double shippingFee;
  final double appFee;
  final double promotionDiscount;
  final String status;
  final String? cancelledBy;
  final String? cancellationReason;

  const Order(
      {required this.id,
      required this.merchant,
      this.shipper,
      required this.customer,
      this.promotion,
      required this.placedTime,
      required this.eta,
      this.deliveryCompletionTime,
      required this.orderPrice,
      required this.shippingFee,
      required this.appFee,
      required this.promotionDiscount,
      required this.status,
      this.cancelledBy,
      this.cancellationReason});
}
