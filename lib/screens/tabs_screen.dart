import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/screens/merchant_register_screen.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/widgets/me.dart';
import 'package:foodtogo_merchants/widgets/merchants_list.dart';
import 'package:foodtogo_merchants/widgets/user_order_list.dart';

enum TabName { Merchant, Order, Me }

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  int _selectedPageIndex = 0;
  Widget _activePage = const MerchantsList();

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
      if (_selectedPageIndex == TabName.Merchant.index) {
        _activePage = const MerchantsList();
      } else if (_selectedPageIndex == TabName.Order.index) {
        _activePage =
            UserOrdersListWidget(userId: int.parse(UserServices.strUserId));
      } else if (_selectedPageIndex == TabName.Me.index) {
        _activePage = const Me();
      } else {
        _activePage = const MerchantsList();
      }
    });
  }

  _onFloatingActionButtonPressed() {
    if (_selectedPageIndex == TabName.Merchant.index) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const MerchantRegisterScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppBar? appBar = AppBar(
      backgroundColor: KColors.kBackgroundColor,
      title: Text(
        'FoodToGo - Merchants',
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: KColors.kPrimaryColor,
              fontSize: 24,
            ),
      ),
    );

    if (_selectedPageIndex == TabName.Me.index) {
      appBar = null;
    }
    return Scaffold(
      appBar: appBar,
      body: _activePage,
      floatingActionButton: _selectedPageIndex == 0
          ? SizedBox(
              width: 50,
              height: 50,
              child: FloatingActionButton(
                onPressed: _onFloatingActionButtonPressed,
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
          _selectPage(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.restaurant,
              color: KColors.kLightTextColor,
            ),
            label: 'Merchants',
            activeIcon: Icon(
              Icons.restaurant,
              color: KColors.kPrimaryColor,
            ),
            backgroundColor: KColors.kOnBackgroundColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.receipt_long_outlined,
              color: KColors.kLightTextColor,
            ),
            label: 'Waiting Orders',
            activeIcon: Icon(
              Icons.receipt_long_outlined,
              color: KColors.kPrimaryColor,
            ),
            backgroundColor: KColors.kOnBackgroundColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
              color: KColors.kLightTextColor,
            ),
            label: 'Me',
            activeIcon: Icon(
              Icons.person,
              color: KColors.kPrimaryColor,
            ),
            backgroundColor: KColors.kOnBackgroundColor,
          ),
        ],
      ),
    );
  }
}
