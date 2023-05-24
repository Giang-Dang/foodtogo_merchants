import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/dto/merchant_dto.dart';

class MerchantsListNotifier extends StateNotifier<List<MerchantDTO>> {
  MerchantsListNotifier() : super([]);

  void updateMerchants(List<MerchantDTO> merchantList) {
    state = merchantList;
  }
}

final merchantsListProvider =
    StateNotifierProvider<MerchantsListNotifier, List<MerchantDTO>>(
  (ref) => MerchantsListNotifier(),
);
