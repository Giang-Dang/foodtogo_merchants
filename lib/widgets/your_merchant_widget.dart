import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodtogo_merchants/models/merchant.dart';
import 'package:foodtogo_merchants/screens/open_hours_screen.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';

class YourMerchantWidget extends StatefulWidget {
  const YourMerchantWidget({
    Key? key,
    required this.merchant,
  }) : super(key: key);

  final Merchant merchant;

  @override
  State<YourMerchantWidget> createState() => _YourMerchantWidgetState();
}

class _YourMerchantWidgetState extends State<YourMerchantWidget> {
  @override
  Widget build(BuildContext context) {
    final merchant = widget.merchant;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      width: double.infinity,
      color: KColors.kPrimaryColor.withOpacity(0.2),
      child: ListView(
        children: [
          //Info
          Text(
            'Info:',
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: KColors.kLightTextColor,
                  fontSize: 22,
                ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
              color: KColors.kOnBackgroundColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.storefront),
                  title: Text(
                    merchant.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: RatingBarIndicator(
                    rating: merchant.rating,
                    itemBuilder: (context, index) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 23.0,
                    direction: Axis.horizontal,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(merchant.phoneNumber),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: Text(merchant.address),
                ),
              ],
            ),
          ),
          // //Statistics
          // const SizedBox(height: 20),
          // Text(
          //   'Statistics:',
          //   textAlign: TextAlign.start,
          //   style: Theme.of(context).textTheme.titleLarge!.copyWith(
          //         color: KColors.kLightTextColor,
          //         fontSize: 22,
          //       ),
          // ),
          // const SizedBox(
          //   height: 10,
          // ),
          // Container(
          //   decoration: BoxDecoration(
          //     color: KColors.kOnBackgroundColor,
          //     borderRadius: BorderRadius.circular(10.0),
          //   ),
          //   child: Column(
          //     children: [
          //       ListTile(
          //         title: const Text(
          //           'Successful Orders:',
          //           style: const TextStyle(fontWeight: FontWeight.bold),
          //         ),
          //       ),
          //       ListTile(
          //         leading: const Icon(Icons.phone),
          //         title: Text(merchant.phoneNumber),
          //       ),
          //       ListTile(
          //         leading: const Icon(Icons.home),
          //         title: Text(merchant.address),
          //       ),
          //     ],
          //   ),
          // ),
          //Merchant
          const SizedBox(height: 20),
          Text(
            'Merchant:',
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: KColors.kLightTextColor,
                  fontSize: 22,
                ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: [
                Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(10.0),
                  color: KColors.kOnBackgroundColor,
                  child: ListTile(
                    leading: const Icon(
                      Icons.edit_note,
                      color: KColors.kPrimaryColor,
                    ),
                    title: const Text("Edit your merchant's profile"),
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 10),
                Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(10.0),
                  color: KColors.kOnBackgroundColor,
                  child: ListTile(
                    leading: const Icon(
                      Icons.schedule,
                      color: KColors.kPrimaryColor,
                    ),
                    title: const Text('Set up the opening hours'),
                    onTap: () {
                      if (context.mounted) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => OpenHoursScreen(
                            merchant: merchant,
                          ),
                        ));
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(10.0),
                  color: KColors.kOnBackgroundColor,
                  child: ListTile(
                    leading: const Icon(
                      Icons.date_range,
                      color: KColors.kPrimaryColor,
                    ),
                    title: const Text('Set up the override opening hours'),
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(thickness: 1, color: KColors.kOnBackgroundColor),
                const SizedBox(height: 10),
                Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(10.0),
                  child: ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: KColors.kPrimaryColor,
                    ),
                    title: const Text(
                      'Delete Merchant',
                      style: TextStyle(color: KColors.kPrimaryColor),
                    ),
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 20)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
