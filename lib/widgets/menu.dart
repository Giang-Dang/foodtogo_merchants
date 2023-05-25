import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/dto/menu_item_dto.dart';
import 'package:foodtogo_merchants/models/dto/merchant_dto.dart';
import 'package:foodtogo_merchants/models/menu_item.dart';
import 'package:foodtogo_merchants/models/merchant.dart';
import 'package:foodtogo_merchants/providers/menu_item_list_provider.dart';
import 'package:foodtogo_merchants/services/menu_item_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/widgets/menu_item_widget.dart';

class Menu extends ConsumerStatefulWidget {
  const Menu({
    Key? key,
    required this.merchant,
  }) : super(key: key);

  final Merchant merchant;

  @override
  ConsumerState<Menu> createState() => _MenuState();
}

class _MenuState extends ConsumerState<Menu> {
  List<MenuItem> _menuItemList = [];
  bool _isLoadingItems = false;

  _loadMenuItemList(int merchantId) async {
    final menuItemServices = MenuItemServices();

    setState(() {
      _isLoadingItems = true;
    });

    final menuItemList = await menuItemServices.getAllMenuItems(merchantId);

    setState(() {
      _menuItemList = menuItemList ?? [];
      _isLoadingItems = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMenuItemList(widget.merchant.merchantId);
  }

  @override
  Widget build(BuildContext context) {
    if (_menuItemList.length < ref.watch(menuItemsListProvider).length) {
      _menuItemList = ref.watch(menuItemsListProvider);
    }

    Widget content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'You don’t have any items in your store yet.',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 18,
                ),
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            "Start creating by pressing the '+' button.",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 14,
                ),
          ),
        ],
      ),
    );

    if (_menuItemList.isNotEmpty) {
      content = Container(
        color: KColors.kBackgroundColor,
        child: ListView.builder(
          itemCount: _menuItemList.length,
          itemBuilder: (context, index) =>
              MenuItemWidget(menuItem: _menuItemList[index]),
        ),
      );
    }
    return content;
  }
}
