import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/dto/merchant_dto.dart';
import 'package:foodtogo_merchants/screens/create_menu_item_screen.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/models/merchant.dart';
import 'package:foodtogo_merchants/widgets/menu.dart';
import 'package:foodtogo_merchants/widgets/merchant_orders_list_widget.dart';

enum MerchantScreenTabName {
  Menu,
  Order,
  YourMechant,
}

class MerchantTabsScreen extends ConsumerStatefulWidget {
  const MerchantTabsScreen({Key? key, required this.merchant})
      : super(key: key);

  final Merchant merchant;

  @override
  ConsumerState<MerchantTabsScreen> createState() => _MerchantTabsScreenState();
}

class _MerchantTabsScreenState extends ConsumerState<MerchantTabsScreen> {
  int _selectedPageIndex = 0;
  Widget? _activePage;
  void _selectPage(int index, Merchant merchant) {
    setState(() {
      _selectedPageIndex = index;
      if (_selectedPageIndex == MerchantScreenTabName.Menu.index) {
        _activePage = Menu(merchant: merchant);
      } else if (_selectedPageIndex == MerchantScreenTabName.Order.index) {
        _activePage = MerchantOrdersListWidget(
          merchantId: merchant.merchantId,
        );
      } else if (_selectedPageIndex == MerchantScreenTabName.YourMechant.index) {
        _activePage = Text('Your Store Page');
        ;
      } else {
        _activePage = Menu(merchant: merchant);
      }
    });
  }

  _onFloatingActionButtonPressed(Merchant merchant) {
    if (_selectedPageIndex == MerchantScreenTabName.Menu.index) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CreateMenuItemScreen(merchant: merchant),
        ),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _activePage = Menu(merchant: widget.merchant);
  }

  @override
  Widget build(BuildContext context) {
    final merchant = widget.merchant;
    AppBar? appBar = AppBar(
      backgroundColor: KColors.kBackgroundColor,
      title: Text(
        merchant.name,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: KColors.kPrimaryColor,
              fontSize: 24,
            ),
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: _activePage,
      floatingActionButton:
          _selectedPageIndex == MerchantScreenTabName.Menu.index
              ? SizedBox(
                  width: 50,
                  height: 50,
                  child: FloatingActionButton(
                    onPressed: () {
                      _onFloatingActionButtonPressed(merchant);
                    },
                    elevation: 10.0,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.add),
                  ),
                )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: KColors.kLightTextColor,
        unselectedFontSize: 10,
        selectedItemColor: KColors.kPrimaryColor,
        selectedFontSize: 12,
        showUnselectedLabels: true,
        currentIndex: _selectedPageIndex,
        onTap: (index) {
          _selectPage(index, merchant);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.restaurant_menu_outlined,
              color: KColors.kLightTextColor,
            ),
            label: 'Menu',
            activeIcon: Icon(
              Icons.restaurant_menu,
              color: KColors.kPrimaryColor,
            ),
            backgroundColor: KColors.kOnBackgroundColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.receipt_long_outlined,
              color: KColors.kLightTextColor,
            ),
            label: 'Orders',
            activeIcon: Icon(
              Icons.receipt_long_outlined,
              color: KColors.kPrimaryColor,
            ),
            backgroundColor: KColors.kOnBackgroundColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.storefront,
              color: KColors.kLightTextColor,
            ),
            label: 'Your Mechant',
            activeIcon: Icon(
              Icons.storefront,
              color: KColors.kPrimaryColor,
            ),
            backgroundColor: KColors.kOnBackgroundColor,
          ),
        ],
      ),
    );
  }
}
