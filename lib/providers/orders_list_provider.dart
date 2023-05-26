import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/order.dart';

class OrdersListNotifier extends StateNotifier<List<Order>> {
  OrdersListNotifier() : super([]);

  void updateOrdersList(List<Order> merchantList) {
    state = merchantList;
  }
}

final ordersListProvider =
    StateNotifierProvider<OrdersListNotifier, List<Order>>(
  (ref) => OrdersListNotifier(),
);
