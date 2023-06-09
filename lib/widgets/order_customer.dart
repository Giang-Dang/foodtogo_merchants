import 'package:flutter/material.dart';
import 'package:foodtogo_merchants/models/enum/user_type.dart';
import 'package:foodtogo_merchants/models/order.dart';
import 'package:foodtogo_merchants/screens/rating_user_screen.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/widgets/rating_bar_indicator.dart';
import 'package:foodtogo_merchants/widgets/rating_button.dart';

class OrderCustomer extends StatelessWidget {
  const OrderCustomer({
    Key? key,
    required this.order,
  }) : super(key: key);

  final Order order;

  _navigateToRatingScreen(
      {required BuildContext context,
      required UserType fromUserType,
      required UserType toUserType,
      required Order order}) {
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RatingUserScreen(
              order: order, fromUserType: fromUserType, toUserType: toUserType),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Customer',
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
                leading: const Icon(Icons.person),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${order.customer.lastName} ${order.customer.middleName} ${order.customer.firstName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    RatingBarIndicator(
                      rating: order.customer.rating,
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 20.0,
                      direction: Axis.horizontal,
                    ),
                  ],
                ),
                trailing: Transform.translate(
                  offset: const Offset(10, 2),
                  child: RatingButton(
                    onButtonPressed: () {
                      _navigateToRatingScreen(
                          context: context,
                          fromUserType: UserType.Merchant,
                          toUserType: UserType.Customer,
                          order: order);
                    },
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: Text(order.customer.phoneNumber),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: Text(order.customer.email),
              ),
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: Text(
                    '${order.customer.successOrderCount} order(s) / ${order.customer.cancelledOrderCount + order.customer.successOrderCount} order(s)'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
