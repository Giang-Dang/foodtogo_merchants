import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/dto/update_dto/merchant_update_dto.dart';
import 'package:foodtogo_merchants/models/merchant.dart';
import 'package:foodtogo_merchants/providers/merchants_list_provider.dart';
import 'package:foodtogo_merchants/screens/edit_merchant_screen.dart';
import 'package:foodtogo_merchants/screens/open_hours_screen.dart';
import 'package:foodtogo_merchants/services/merchant_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/widgets/rating_bar_indicator.dart';

class YourMerchantWidget extends ConsumerStatefulWidget {
  const YourMerchantWidget({
    Key? key,
    required this.merchant,
  }) : super(key: key);

  final Merchant merchant;

  @override
  ConsumerState<YourMerchantWidget> createState() => _YourMerchantWidgetState();
}

class _YourMerchantWidgetState extends ConsumerState<YourMerchantWidget> {
  bool _isDeleted = false;

  _deleteMerchant(Merchant merchant) async {
    final MerchantServices merchantServices = MerchantServices();

    final updateDTO = MerchantUpdateDTO(
      merchantId: merchant.merchantId,
      userId: merchant.userId,
      name: merchant.name,
      address: merchant.address,
      phoneNumber: merchant.phoneNumber,
      geoLatitude: merchant.geoLatitude,
      geoLongitude: merchant.geoLongitude,
      isDeleted: true,
      rating: merchant.rating,
    );

    final isSuccess =
        await merchantServices.update(updateDTO, merchant.merchantId);

    if (!isSuccess) {
      log('_YourMerchantWidgetState._deleteMerchant() isSuccess == false');
      return;
    }

    final merchantList = await merchantServices.getAllMerchantsFromUser();

    if (mounted) {
      ref.watch(merchantsListProvider.notifier).updateMerchants(merchantList);
      setState(() {
        _isDeleted = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isDeleted = widget.merchant.isDeleted;
  }

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
                    (_isDeleted ? '[Deleted] ' : '') + merchant.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: KColors.kPrimaryColor),
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
                    onTap: () {
                      if (context.mounted) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              EditMerchantScreen(merchant: merchant),
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
                      Icons.schedule,
                      color: KColors.kPrimaryColor,
                    ),
                    title: const Text('Set up the opening times'),
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
                // //Set up the override opening times
                // const SizedBox(height: 10),
                // Material(
                //   elevation: 3,
                //   borderRadius: BorderRadius.circular(10.0),
                //   color: KColors.kOnBackgroundColor,
                //   child: ListTile(
                //     leading: const Icon(
                //       Icons.date_range,
                //       color: KColors.kPrimaryColor,
                //     ),
                //     title: const Text('Set up the override opening times'),
                //     onTap: () {},
                //   ),
                // ),
                const SizedBox(height: 10),
                const Divider(thickness: 1, color: KColors.kOnBackgroundColor),
                const SizedBox(height: 10),
                Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(10.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.delete,
                      color: _isDeleted ? Colors.grey : KColors.kPrimaryColor,
                    ),
                    title: Text(
                      'Delete Merchant',
                      style: TextStyle(
                          color:
                              _isDeleted ? Colors.grey : KColors.kPrimaryColor),
                    ),
                    onTap: _isDeleted
                        ? null
                        : () {
                            _deleteMerchant(merchant);
                          },
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
