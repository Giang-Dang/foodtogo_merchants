import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/screens/merchant_register_screen.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/widgets/merchants_list.dart';

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
      switch (_selectedPageIndex) {
        case 0:
          _activePage = const MerchantsList();
          break;
        case 1:
          _activePage = Text('Orders Page');
          break;
        case 2:
          _activePage = Text('Me Page');
          break;
        default:
          _activePage = MerchantsList();
          break;
      }
    });
  }

  _onFloatingActionButtonPressed() {
    if (_selectedPageIndex == 0) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const MerchantRegisterScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: KColors.kBackgroundColor,
        title: Text(
          'FoodToGo - Merchants',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: KColors.kPrimaryColor,
                fontSize: 24,
              ),
        ),
      ),
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
            label: 'Merchant',
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
            label: 'Orders',
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
