import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/dto/merchant_dto.dart';

class MerchantsNotifier extends StateNotifier<List<MerchantDTO>> {
  MerchantsNotifier() : super([]);

  void updateMerchants(List<MerchantDTO> merchantList) {
    state = merchantList;
  }
}

final merchantProvider =
    StateNotifierProvider<MerchantsNotifier, List<MerchantDTO>>(
  (ref) => MerchantsNotifier(),
);
