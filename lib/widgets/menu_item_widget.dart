import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/menu_item.dart';
import 'package:foodtogo_merchants/providers/menu_item_list_provider.dart';
import 'package:foodtogo_merchants/screens/edit_menu_item_screen.dart';
import 'package:foodtogo_merchants/services/menu_item_image_services.dart';
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

  _updateMenuItem() async {
    final menuItemImageServices = MenuItemImageServices();
    final image = await menuItemImageServices.getByMenuItem(widget.menuItem.id);

    setState(() {
      _menuItem = MenuItem(
        id: widget.menuItem.id,
        merchantId: widget.menuItem.merchantId,
        itemType: widget.menuItem.itemType,
        name: widget.menuItem.name,
        description: widget.menuItem.description,
        unitPrice: widget.menuItem.unitPrice,
        imagePath: image.path,
      );
    });
  }

  _onTapEditListTile(MenuItem menuItem) {
    if (_menuItem != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditMenuItemScreen(menuItem: menuItem),
        ),
      );
    }
  }

  void _onTapDeleteListTile(MenuItem menuItem) {}

  @override
  void initState() {
    super.initState();
    _updateMenuItem();
  }

  @override
  Widget build(BuildContext context) {
    if (_menuItem != null && ref.watch(menuItemsListProvider).isNotEmpty) {
      _menuItem = ref
          .watch(menuItemsListProvider)
          .firstWhere((element) => element.id == _menuItem!.id);
    }

    Widget contain = const ListTile(
      leading: CircularProgressIndicator(),
      title: Text('Loading...'),
    );

    if (_menuItem != null) {
      final imageUrl =
          Uri.http(Secrets.FoodToGoAPILink, _menuItem!.imagePath).toString();

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
              offset: Offset(0, -5),
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
              _menuItem!.description,
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
            trailing: Transform.translate(
              offset: const Offset(12, 0),
              child: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: KColors.kPrimaryColor,
                ),
                onPressed: () {
                  _onTapDeleteListTile(_menuItem!);
                },
              ),
            ),
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
