import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/merchant.dart';
import 'package:foodtogo_merchants/providers/menu_item_list_provider.dart';
import 'package:foodtogo_merchants/providers/merchants_list_provider.dart';
import 'package:foodtogo_merchants/screens/merchant_tabs_screen.dart';
import 'package:foodtogo_merchants/services/menu_item_services.dart';
import 'package:foodtogo_merchants/services/merchant_profile_image_services.dart';
import 'package:foodtogo_merchants/services/user_rating_services.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/settings/secrets.dart';
import 'package:transparent_image/transparent_image.dart';

class MerchantListItem extends ConsumerStatefulWidget {
  const MerchantListItem({
    super.key,
    required this.merchant,
  });

  final Merchant merchant;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MechantListItemState();
  }
}

class _MechantListItemState extends ConsumerState<MerchantListItem> {
  final jwtToken = UserServices.jwtToken;
  Merchant? _merchant;
  Timer? _initTimer;

  _updateMerchant(Merchant merchant) async {
    final merchantProfileImageServices = MerchantProfileImageServices();
    final UserRatingServices userRatingServices = UserRatingServices();

    final image =
        await merchantProfileImageServices.getByMerchantId(merchant.merchantId);
    final rating =
        await userRatingServices.getAvgRating(merchant.userId, 'Customer') ??
            0.0;
    if (mounted) {
      setState(() {
        _merchant = Merchant(
          merchantId: merchant.merchantId,
          userId: merchant.userId,
          name: merchant.name,
          address: merchant.address,
          phoneNumber: merchant.phoneNumber,
          isDeleted: merchant.isDeleted,
          geoLatitude: merchant.geoLatitude,
          geoLongitude: merchant.geoLongitude,
          imagePath: image!.path,
          rating: rating,
        );
      });
    }
  }

  _onTapListTile() async {
    if (_merchant != null) {
      final MenuItemServices menuItemServices = MenuItemServices();
      final menuItemsList =
          await menuItemServices.getAllMenuItems(_merchant!.merchantId);
      ref
          .watch(menuItemsListProvider.notifier)
          .updateMenuItemsList(menuItemsList ?? []);

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MerchantTabsScreen(merchant: _merchant!),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateMerchant(widget.merchant);
      _initTimer?.cancel();
    });
  }

  @override
  void dispose() {
    _initTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget contain = const ListTile(
      leading: CircularProgressIndicator(),
      title: Text('Loading...'),
    );

    if (_merchant != null) {
      final isDeleted = widget.merchant.isDeleted;

      final merchantFromProvider = ref
          .watch(merchantsListProvider)
          .firstWhere((e) => e.merchantId == _merchant!.merchantId);
      if (merchantFromProvider != _merchant) {
        _updateMerchant(merchantFromProvider);
      }

      final imageUrl =
          Uri.http(Secrets.kFoodToGoAPILink, _merchant!.imagePath).toString();
      contain = Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
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
            title: Text(
              _merchant!.name,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: isDeleted
                        ? KColors.kLightTextColor
                        : KColors.kPrimaryColor,
                  ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RatingBarIndicator(
                  rating: _merchant!.rating,
                  itemBuilder: (context, index) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 15.0,
                  direction: Axis.horizontal,
                ),
                Text(
                  isDeleted
                      ? '[Merchant Has Been Deleted]'
                      : _merchant!.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            leading: FadeInImage(
              placeholder: MemoryImage(kTransparentImage),
              image: NetworkImage(imageUrl, headers: {
                'Authorization': 'Bearer $jwtToken',
              }),
              fit: BoxFit.cover,
              height: 50,
              width: 80,
            ),
            isThreeLine: false,
          ),
        ),
      );
    }

    return contain;
  }
}
