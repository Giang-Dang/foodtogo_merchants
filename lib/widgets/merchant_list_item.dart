import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/current_selection.dart';
import 'package:foodtogo_merchants/models/dto/merchant_dto.dart';
import 'package:foodtogo_merchants/models/merchant.dart';
import 'package:foodtogo_merchants/providers/menu_item_list_provider.dart';
import 'package:foodtogo_merchants/screens/merchant_tabs_screen.dart';
import 'package:foodtogo_merchants/services/menu_item_services.dart';
import 'package:foodtogo_merchants/services/merchant_profile_image_services.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/settings/secrets.dart';
import 'package:transparent_image/transparent_image.dart';

class MerchantListItem extends ConsumerStatefulWidget {
  const MerchantListItem({
    super.key,
    required this.merchant,
  });

  final MerchantDTO merchant;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MechantListItemState();
  }
}

class _MechantListItemState extends ConsumerState<MerchantListItem> {
  final jwtToken = UserServices.jwtToken;
  Merchant? _merchant;
  Timer? _initTimer;

  _updateMerchant() async {
    final merchantProfileImageServices = MerchantProfileImageServices();
    final image = await merchantProfileImageServices
        .getByMerchantId(widget.merchant.merchantId);

    setState(() {
      _merchant = Merchant(
        merchantId: widget.merchant.merchantId,
        userId: widget.merchant.userId,
        name: widget.merchant.name,
        address: widget.merchant.address,
        phoneNumber: widget.merchant.phoneNumber,
        geoLatitude: widget.merchant.geoLatitude,
        geoLongitude: widget.merchant.geoLongitude,
        imagePath: image!.path,
      );
    });
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
      _updateMerchant();
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
      final imageUrl =
          Uri.http(Secrets.FoodToGoAPILink, _merchant!.imagePath).toString();
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
            title: Text(
              _merchant!.name,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: KColors.kPrimaryColor,
                  ),
            ),
            subtitle: Text(
              _merchant!.address,
              overflow: TextOverflow.ellipsis,
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
