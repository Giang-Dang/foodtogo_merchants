import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/order.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/widgets/order_list_item.dart';

class MerchantOrdersListWidget extends ConsumerStatefulWidget {
  const MerchantOrdersListWidget({
    Key? key,
    required this.ordersList,
    required this.orderListName,
  }) : super(key: key);

  final List<Order> ordersList;
  final String orderListName;

  @override
  ConsumerState<MerchantOrdersListWidget> createState() =>
      _MerchantOrdersListWidgetState();
}

class _MerchantOrdersListWidgetState
    extends ConsumerState<MerchantOrdersListWidget> {
  List<Order> _ordersList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ordersList = widget.ordersList;

    Widget content = const Center(
      child: CircularProgressIndicator(
        color: KColors.kPrimaryColor,
      ),
    );

    if (_ordersList.isEmpty) {
      content = Center(
        child: Text(
          'You do not have any ${widget.orderListName} yet.',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: 18,
              ),
        ),
      );
    } else {
      content = Container(
        color: KColors.kOnBackgroundColor,
        child: ListView.builder(
          itemCount: _ordersList.length,
          itemBuilder: (context, index) =>
              OrderListItem(order: _ordersList[index]),
        ),
      );
    }

    return content;
  }
}
