import 'package:flutter/material.dart';
import 'package:foodtogo_merchants/models/enum/order_status.dart';
import 'package:foodtogo_merchants/models/order.dart';
import 'package:foodtogo_merchants/services/order_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';

class OrderStatusWidget extends StatelessWidget {
  const OrderStatusWidget({
    Key? key,
    required this.order,
  }) : super(key: key);

  final Order order;

  @override
  Widget build(BuildContext context) {
    final orderServices = OrderServices();

    final orderStatusInfo =
        orderServices.getOrderStatusInfo(order.status);

    final isCancelled =
        order.status == OrderStatus.Cancelled.name.toLowerCase();

    return Column(
      children: [
        Text(
          'Status',
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: KColors.kLightTextColor,
                fontSize: 22,
              ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: KColors.kOnBackgroundColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  orderStatusInfo,
                  style: TextStyle(
                      color: orderServices.getOrderColor(order.status),
                      fontWeight: FontWeight.bold),
                ),
              ),
              if (isCancelled)
                ListTile(
                  title: const Text('Cancelled By:'),
                  subtitle: Text(order.cancelledBy.toString()),
                ),
              if (isCancelled)
                ListTile(
                  title: const Text('Reason:'),
                  subtitle: Text(order.cancellationReason ?? 'Unknown'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
