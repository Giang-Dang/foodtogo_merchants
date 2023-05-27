import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/enum/order_status.dart';
import 'package:foodtogo_merchants/models/order.dart';
import 'package:foodtogo_merchants/providers/orders_list_provider.dart';
import 'package:foodtogo_merchants/services/order_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/widgets/order_list_item.dart';

class MerchantOrdersListWidget extends ConsumerStatefulWidget {
  const MerchantOrdersListWidget({
    Key? key,
    required this.merchantId,
  }) : super(key: key);

  final int merchantId;

  @override
  ConsumerState<MerchantOrdersListWidget> createState() =>
      _MerchantOrdersListWidgetState();
}

class _MerchantOrdersListWidgetState
    extends ConsumerState<MerchantOrdersListWidget> {
  bool _isLoading = true;
  List<Order> _ordersList = [];
  Timer? _initTimer;

  _getMerchantOrdersListFromServer(int merchantId) async {
    final OrderServices orderServices = OrderServices();

    setState(() {
      _isLoading = true;
    });

    final ordersList = await orderServices.getAll(merchantId: merchantId);

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

    ref.watch(ordersListProvider.notifier).updateOrdersList(_ordersList ?? []);

    setState(() {
      _isLoading = false;
      _ordersList = ordersList ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
    _initTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _getMerchantOrdersListFromServer(widget.merchantId);
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
