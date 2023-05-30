import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/merchant.dart';

class MerchantsListNotifier extends StateNotifier<List<Merchant>> {
  MerchantsListNotifier() : super([]);

  void updateMerchants(List<Merchant> merchantList) {
    merchantList.sort(
      (a, b) {
        if (b.isDeleted && !a.isDeleted) {
          return -1;
        }
        return 0;
      },
    );
    state = merchantList;
  }
}

final merchantsListProvider =
    StateNotifierProvider<MerchantsListNotifier, List<Merchant>>(
  (ref) => MerchantsListNotifier(),
);
