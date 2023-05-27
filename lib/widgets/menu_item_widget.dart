import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/dto/update_dto/menu_item_update_dto.dart';
import 'package:foodtogo_merchants/models/menu_item.dart';
import 'package:foodtogo_merchants/providers/menu_item_list_provider.dart';
import 'package:foodtogo_merchants/screens/edit_menu_item_screen.dart';
import 'package:foodtogo_merchants/services/file_services.dart';
import 'package:foodtogo_merchants/services/menu_item_image_services.dart';
import 'package:foodtogo_merchants/services/menu_item_services.dart';
import 'package:foodtogo_merchants/services/menu_item_type_services.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/settings/secrets.dart';
import 'package:transparent_image/transparent_image.dart';

class MenuItemWidget extends ConsumerStatefulWidget {
  const MenuItemWidget({
    super.key,
    required this.menuItem,
  });

  final MenuItem menuItem;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MechantListItemState();
  }
}

class _MechantListItemState extends ConsumerState<MenuItemWidget> {
  final jwtToken = UserServices.jwtToken;
  MenuItem? _menuItem;
  bool _isLoading = false;

  _onTapEditListTile(MenuItem menuItem) {
    if (_menuItem != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditMenuItemScreen(menuItem: menuItem),
        ),
      );
    }
  }

  void _onTapSwitchListTile(MenuItem? menuItem) async {
    if (menuItem == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final MenuItemServices menuItemServices = MenuItemServices();
    final MenuItemTypeServices menuItemTypeServices = MenuItemTypeServices();

    final menuItemTypeList = await menuItemTypeServices.getAll();
    final menuItemType =
        menuItemTypeList.firstWhere((e) => e.name == menuItem!.itemType);

    final updateDTO = MenuItemUpdateDTO(
      id: menuItem.id,
      merchantId: menuItem.merchantId,
      itemTypeId: menuItemType.id,
      name: menuItem.name,
      description: menuItem.description,
      unitPrice: menuItem.unitPrice,
      isClosed: !menuItem.isClosed,
    );

    final isUpdateSuccess =
        await menuItemServices.updateExcludeUploadImage(menuItem.id, updateDTO);

    if (isUpdateSuccess) {
      menuItem = MenuItem(
        id: menuItem.id,
        merchantId: menuItem.merchantId,
        itemType: menuItem.itemType,
        name: menuItem.name,
        description: menuItem.description,
        unitPrice: menuItem.unitPrice,
        imagePath: menuItem.imagePath,
        isClosed: !menuItem.isClosed,
      );
      Future.delayed(const Duration(milliseconds: 200)).then((_) {
        if (mounted) {
          setState(() {
            _menuItem = menuItem;
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _menuItem = widget.menuItem;
  }

  @override
  Widget build(BuildContext context) {
    Widget contain = const ListTile(
      leading: CircularProgressIndicator(),
      title: Text('Loading...'),
    );

    if (_menuItem != null) {
      final imageUrl =
          Uri.http(Secrets.FoodToGoAPILink, _menuItem!.imagePath).toString();

      Widget trailingContent = const SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(),
      );

      if (!_isLoading) {
        trailingContent = Transform.translate(
          offset: const Offset(12, -5),
          child: IconButton(
            icon: _menuItem!.isClosed
                ? const Icon(
                    Icons.toggle_off,
                    color: KColors.kDanger,
                    size: 50,
                  )
                : const Icon(
                    Icons.toggle_on,
                    color: KColors.kAppleGreen,
                    size: 50,
                  ),
            onPressed: () {
              _onTapSwitchListTile(_menuItem!);
            },
          ),
        );
      }

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
            title: Transform.translate(
              offset: const Offset(0, -5),
              child: Text(
                _menuItem!.name,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: KColors.kLightTextColor,
                      fontSize: 18,
                    ),
              ),
            ),
            subtitle: Text(
              _menuItem!.isClosed ? '[Out of order]' : _menuItem!.description,
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
            trailing: trailingContent,
            onTap: () {
              _onTapEditListTile(_menuItem!);
            },
          ),
        ),
      );
    }

    return contain;
  }
}
