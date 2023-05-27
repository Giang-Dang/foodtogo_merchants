import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/enum/order_status.dart';
import 'package:foodtogo_merchants/models/order.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/settings/secrets.dart';
import 'package:transparent_image/transparent_image.dart';
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
  _onTapListTile() {}

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final jwtToken = UserServices.jwtToken;

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
        color: KColors.kOnBackgroundColor,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          onTap: () {
            _onTapListTile();
          },
          title: Transform.translate(
            offset: const Offset(0, -3),
            child: Row(children: [
              const Icon(Icons.sports_motorsports, size: 24),
              Text(
                " : ${order.shipper.lastName} ${order.shipper.middleName} ${order.shipper.firstName}    ",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: order.status == OrderStatus.DriverAtMerchant.name
                          ? KColors.kSuccessColor
                          : KColors.kPrimaryColor,
                      fontSize: 17,
                    ),
              ),
              const Icon(Icons.two_wheeler, size: 24),
              Text(
                " : ${order.shipper.vehicleNumberPlate}",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: order.status == OrderStatus.DriverAtMerchant.name
                          ? KColors.kSuccessColor
                          : KColors.kPrimaryColor,
                      fontSize: 17,
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
                ),
                Text(
                  ': ${order.orderPrice.toStringAsFixed(1)};',
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.calendar_month,
                  size: 17,
                ),
                Text(
                  ': ${dateFormatter.format(order.placedTime)} ${timeFormatter.format(order.placedTime)};',
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 5),
                const Icon(
                  Icons.schedule,
                  size: 17,
                ),
                Text(
                  ': ${timeFormatter.format(order.eta)};  ',
                  overflow: TextOverflow.ellipsis,
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
