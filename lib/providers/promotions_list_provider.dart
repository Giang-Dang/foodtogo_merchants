import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/promotion.dart';

class PromotionsListNotifier extends StateNotifier<List<Promotion>> {
  PromotionsListNotifier() : super([]);

  void update(List<Promotion> promotionsList) {
    state = promotionsList;
  }
}

final promotionsListProvider =
    StateNotifierProvider<PromotionsListNotifier, List<Promotion>>(
  (ref) => PromotionsListNotifier(),
);
