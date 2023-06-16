import 'package:flutter/material.dart';
import 'package:foodtogo_merchants/models/order.dart';
import 'package:foodtogo_merchants/services/order_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';

class OrderListItemShipperWidget extends StatelessWidget {
  const OrderListItemShipperWidget({
    Key? key,
    required this.order,
  }) : super(key: key);

  final Order order;

  @override
  Widget build(BuildContext context) {
    final orderServices = OrderServices();

    return Transform.translate(
      offset: const Offset(0, -3),
      child: Row(children: [
        const Icon(
          Icons.sports_motorsports,
          size: 20,
          color: KColors.kLightTextColor,
        ),
        Text(
          order.shipper == null
              ? ' : Waiting for driver to deliver...'
              : " : ${order.shipper!.lastName} ${order.shipper!.middleName} ${order.shipper!.firstName}    ",
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: orderServices.getOrderColor(order.status),
                fontSize: 15,
              ),
        ),
        if (order.shipper != null)
          const Icon(
            Icons.two_wheeler,
            size: 20,
            color: KColors.kLightTextColor,
          ),
        if (order.shipper != null)
          Text(
            " : ${order.shipper!.vehicleNumberPlate}",
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: orderServices.getOrderColor(order.status),
                  fontSize: 15,
                ),
          ),
      ]),
    );
  }
}
