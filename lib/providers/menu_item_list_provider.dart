import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/menu_item.dart';

class MenuItemsListNotifier extends StateNotifier<List<MenuItem>> {
  MenuItemsListNotifier() : super([]);

  void updateMenuItemsList(List<MenuItem> menuItemsList) {
    state = menuItemsList;
  }
}

final menuItemsListProvider =
    StateNotifierProvider<MenuItemsListNotifier, List<MenuItem>>(
  (ref) => MenuItemsListNotifier(),
);
