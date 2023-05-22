import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';

class TabsScreen extends ConsumerStatefulWidget {
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  int _selectedPageIndex = 0;
  Widget _activePage = Text('activePage');

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
      switch (_selectedPageIndex) {
        case 0:
          _activePage = Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Merchant Page'),
            
          );
          break;
        case 1:
          _activePage = Text('Me Page');
          break;
        default:
          _activePage = Text('Merchant Page');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _activePage,
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
