import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/merchant.dart';
import 'package:foodtogo_merchants/providers/menu_item_list_provider.dart';
import 'package:foodtogo_merchants/screens/merchant_tabs_screen.dart';
import 'package:foodtogo_merchants/services/menu_item_services.dart';
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
  Timer? _initTimer;

  _onTapListTile(Merchant merchant) async {
    final MenuItemServices menuItemServices = MenuItemServices();
    final menuItemsList =
        await menuItemServices.getAllMenuItems(merchant.merchantId);
    ref
        .watch(menuItemsListProvider.notifier)
        .updateMenuItemsList(menuItemsList ?? []);

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MerchantTabsScreen(merchant: merchant),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

    final isDeleted = widget.merchant.isDeleted;

    final imageUrl =
        Uri.http(Secrets.kFoodToGoAPILink, widget.merchant.imagePath)
            .toString();

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
            _onTapListTile(widget.merchant);
          },
          title: Text(
            widget.merchant.name,
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
                rating: widget.merchant.rating,
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
                    : widget.merchant.address,
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

    return contain;
  }
}
