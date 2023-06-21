import 'package:flutter/material.dart';
import 'package:foodtogo_merchants/models/promotion.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:intl/intl.dart';

final dateFormatter = DateFormat.yMMMMd();

class PromotionDetailsScreen extends StatelessWidget {
  const PromotionDetailsScreen({Key? key, required this.promotion})
      : super(key: key);

  final Promotion promotion;

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          promotion.name,
          style: const TextStyle(color: KColors.kPrimaryColor),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        width: deviceWidth,
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text(
                'Name: ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(promotion.name),
            ),
            ListTile(
              title: const Text(
                'Start Date: ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(dateFormatter.format(promotion.startDate)),
            ),
            ListTile(
              title: const Text(
                'End Date: ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(dateFormatter.format(promotion.endDate)),
            ),
            ListTile(
              title: const Text(
                'Discount percentage: ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${promotion.discountPercentage.toString()} %'),
            ),
            ListTile(
              title: const Text(
                'Discount amount: ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(promotion.discountAmount.toStringAsFixed(1)),
            ),
            ListTile(
              title: const Text(
                'Total quantity: ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(promotion.quantity.toString()),
            ),
            ListTile(
              title: const Text(
                'Quantity left: ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(promotion.quantityLeft.toString()),
            ),
            ListTile(
              title: const Text(
                'Description: ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                promotion.description,
                softWrap: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
