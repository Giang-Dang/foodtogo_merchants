import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/order.dart';
import 'package:foodtogo_merchants/screens/order_details_screen.dart';
import 'package:foodtogo_merchants/services/order_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:intl/intl.dart';

final timeFormatter = DateFormat('HH:mm:ss');
final dateFormatter = DateFormat.MMMd();

class OrderListItem extends ConsumerStatefulWidget {
  const OrderListItem({
    Key? key,
    required this.order,
  }) : super(key: key);

  final Order order;

  @override
  ConsumerState<OrderListItem> createState() => _MerchantOrderListItemState();
}

class _MerchantOrderListItemState extends ConsumerState<OrderListItem> {
  _onTapListTile(Order order) {
    if (context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(order: order),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final OrderServices orderServices = OrderServices();

    Widget contain = const ListTile(
      leading: CircularProgressIndicator(),
      title: Text('Loading...'),
    );

    contain = Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: orderServices.getOrderColor(order.status).withOpacity(0.08)),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          onTap: () {
            _onTapListTile(order);
          },
          title: Transform.translate(
            offset: const Offset(0, -3),
            child: Row(children: [
              const Icon(
                Icons.sports_motorsports,
                size: 20,
                color: KColors.kLightTextColor,
              ),
              Text(
                " : ${order.shipper.lastName} ${order.shipper.middleName} ${order.shipper.firstName}    ",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: orderServices.getOrderColor(order.status),
                      fontSize: 15,
                    ),
              ),
              const Icon(
                Icons.two_wheeler,
                size: 20,
                color: KColors.kLightTextColor,
              ),
              Text(
                " : ${order.shipper.vehicleNumberPlate}",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: orderServices.getOrderColor(order.status),
                      fontSize: 15,
                    ),
              ),
            ]),
          ),
          subtitle: Transform.translate(
            offset: const Offset(0, 5),
            child: Row(
              children: [
                const Icon(
                  Icons.attach_money,
                  size: 17,
                  color: KColors.kLightTextColor,
                ),
                Text(
                  ': ${order.orderPrice.toStringAsFixed(1)};',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.calendar_month,
                  size: 17,
                  color: KColors.kLightTextColor,
                ),
                Text(
                  ': ${dateFormatter.format(order.placedTime)} ${timeFormatter.format(order.placedTime)};',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.schedule,
                  size: 17,
                  color: KColors.kLightTextColor,
                ),
                Text(
                  ': ${timeFormatter.format(order.eta)};  ',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return contain;
  }
}
