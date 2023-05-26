import 'package:foodtogo_merchants/models/order.dart';

class OrderServices {
  static const apiUrl = 'api/OrderAPI';
  Future<Order?> getByMerchant({
    int? merchantId,
    int? customerId,
    int? shipperId,
    int? promotionId,
    String? searchStatus,
    DateTime? searchPlacedDate,
    int? pageSize,
    int? pageNumber,
  }) async {
    
  }
}
