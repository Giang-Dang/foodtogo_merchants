import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/dto/merchant_dto.dart';
import 'package:foodtogo_merchants/models/merchant.dart';

class MerchantsListNotifier extends StateNotifier<List<Merchant>> {
  MerchantsListNotifier() : super([]);

  void updateMerchants(List<Merchant> merchantList) {
    state = merchantList;
  }
}

final merchantsListProvider =
    StateNotifierProvider<MerchantsListNotifier, List<Merchant>>(
  (ref) => MerchantsListNotifier(),
);
