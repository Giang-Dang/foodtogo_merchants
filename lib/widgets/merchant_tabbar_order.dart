import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/enum/order_status.dart';
import 'package:foodtogo_merchants/models/order.dart';
import 'package:foodtogo_merchants/providers/orders_list_provider.dart';
import 'package:foodtogo_merchants/services/order_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/widgets/merchant_orders_list_widget.dart';

class MerchantTabbarOrder extends ConsumerStatefulWidget {
  const MerchantTabbarOrder({
    Key? key,
    required this.merchantId,
  }) : super(key: key);

  final int merchantId;

  @override
  ConsumerState<MerchantTabbarOrder> createState() =>
      _MerchantTabbarOrderState();
}

class _MerchantTabbarOrderState extends ConsumerState<MerchantTabbarOrder>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Order> _ordersList = [];
  Timer? _initTimer;

  _getMerchantOrdersListFromServer(int merchantId) async {
    final OrderServices orderServices = OrderServices();

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final ordersList = await orderServices.getAll(merchantId: merchantId);

    if (ordersList == null) {
      log('_getMerchantOrdersListFromServer() ordersList == null');
      return;
    }
    if (mounted) {
      ref.watch(ordersListProvider.notifier).updateOrdersList(ordersList);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _ordersList = ordersList;
      });
    }
  }

  List<Order> _getWaitingOrdersList(List<Order> ordersList) {
    final resultsList = ordersList
        .where((order) =>
            order.status == OrderStatus.Getting.name.toLowerCase() ||
            order.status == OrderStatus.DriverAtMerchant.name.toLowerCase())
        .toList();

    if (resultsList.isNotEmpty) {
      resultsList.sort((a, b) {
        if (a.status == OrderStatus.DriverAtMerchant.name.toLowerCase() &&
            b.status != OrderStatus.DriverAtMerchant.name.toLowerCase()) {
          return -1;
        } else {
          return 1;
        }
      });
    }
    return resultsList;
  }

  List<Order> _getDeliveringOrdersList(List<Order> ordersList) {
    final resultsList = ordersList
        .where((order) =>
            order.status == OrderStatus.Delivering.name.toLowerCase() ||
            order.status ==
                OrderStatus.DriverAtDeliveryPoint.name.toLowerCase())
        .toList();

    if (resultsList.isNotEmpty) {
      resultsList.sort((a, b) {
        if (a.status == OrderStatus.DriverAtDeliveryPoint.name.toLowerCase() &&
            b.status != OrderStatus.DriverAtDeliveryPoint.name.toLowerCase()) {
          return -1;
        } else {
          return 1;
        }
      });
    }
    return resultsList;
  }

  List<Order> _getCompletedOrdersList(List<Order> ordersList) {
    final resultsList = ordersList
        .where(
            (order) => order.status == OrderStatus.Completed.name.toLowerCase())
        .toList();

    return resultsList;
  }

  List<Order> _getCancelledOrdersList(List<Order> ordersList) {
    final resultsList = ordersList
        .where(
            (order) => order.status == OrderStatus.Cancelled.name.toLowerCase())
        .toList();

    return resultsList;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
    _initTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      _getMerchantOrdersListFromServer(widget.merchantId);
      _initTimer?.cancel();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _initTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initTimer != null) {
      if (!_initTimer!.isActive) {
        final orderListFromProvider = ref.watch(ordersListProvider);
        if (_ordersList != orderListFromProvider &&
            orderListFromProvider.isNotEmpty) {
          _ordersList = orderListFromProvider;
        }
      }
    }
    Widget content = const Center(
      child: CircularProgressIndicator(
        color: KColors.kPrimaryColor,
      ),
    );

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
        content = Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // give the tab bar a height [can change hheight to preferred height]
              Container(
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(
                    25.0,
                  ),
                ),
                child: TabBar(
                  isScrollable: true,
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      10.0,
                    ),
                    color: KColors.kPrimaryColor,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black,
                  tabs: const [
                    Tab(text: '  Waiting  '),
                    Tab(text: '  Delivering  '),
                    Tab(text: '  Completed  '),
                    Tab(text: '  Cancelled  '),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    MerchantOrdersListWidget(
                      ordersList: _getWaitingOrdersList(_ordersList),
                      orderListName: 'waiting order',
                    ),
                    MerchantOrdersListWidget(
                      ordersList: _getDeliveringOrdersList(_ordersList),
                      orderListName: 'delivering order',
                    ),
                    MerchantOrdersListWidget(
                      ordersList: _getCompletedOrdersList(_ordersList),
                      orderListName: 'completed order',
                    ),
                    MerchantOrdersListWidget(
                      ordersList: _getCancelledOrdersList(_ordersList),
                      orderListName: 'cancelled order',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    }
    return content;
  }
}
