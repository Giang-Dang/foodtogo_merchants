import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/enum/order_status.dart';
import 'package:foodtogo_merchants/models/order.dart';
import 'package:foodtogo_merchants/providers/merchants_list_provider.dart';
import 'package:foodtogo_merchants/providers/orders_list_provider.dart';
import 'package:foodtogo_merchants/services/order_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/widgets/order_list_item.dart';

class UserOrdersListWidget extends ConsumerStatefulWidget {
  const UserOrdersListWidget({
    Key? key,
    required this.userId,
  }) : super(key: key);

  final int userId;

  @override
  ConsumerState<UserOrdersListWidget> createState() =>
      _UserOrdersListWidgetState();
}

class _UserOrdersListWidgetState extends ConsumerState<UserOrdersListWidget> {
  bool _isLoading = true;
  List<Order> _ordersList = [];
  Timer? _initTimer;

  _getUserOrdersListFromServer(int userId) async {
    final OrderServices orderServices = OrderServices();

    setState(() {
      _isLoading = true;
    });

    final merchantsList = ref.read(merchantsListProvider);

    List<Order>? ordersList = [];
    for (var merchant in merchantsList) {
      var tempMerchantsList =
          await orderServices.getAll(merchantId: merchant.merchantId);
      if (tempMerchantsList != null) {
        ordersList!.addAll(tempMerchantsList);
      } else {
        ordersList = null;
        break;
      }
    }

    if (ordersList != null) {
      ordersList.sort((a, b) {
        if (a.status == OrderStatus.DriverAtMerchant.name &&
            b.status != OrderStatus.DriverAtMerchant.name) {
          return -1;
        } else {
          return 1;
        }
      });
    }

    ref.watch(ordersListProvider.notifier).updateOrdersList(ordersList ?? []);

    setState(() {
      _isLoading = false;
      if (ordersList != null) {
        _ordersList = ordersList;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _getUserOrdersListFromServer(widget.userId);
      _initTimer?.cancel();
    });
  }

  @override
  void dispose() {
    _initTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: CircularProgressIndicator(
        color: KColors.kPrimaryColor,
      ),
    );
    ;

    if (!_isLoading) {
      if (_ordersList.isEmpty) {
        content = Center(
          child: Text(
            'You do not have any order yet.',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 18,
                ),
          ),
        );
      } else {
        content = content = Container(
          color: KColors.kBackgroundColor,
          child: ListView.builder(
            itemCount: _ordersList.length,
            itemBuilder: (context, index) =>
                OrderListItem(order: _ordersList[index]),
          ),
        );
      }
    }

    return content;
  }
}
