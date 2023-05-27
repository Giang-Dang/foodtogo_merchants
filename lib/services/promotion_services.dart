import 'dart:convert';
import 'dart:io';

import 'package:foodtogo_merchants/models/dto/promotion_dto.dart';
import 'package:foodtogo_merchants/models/promotion.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/secrets.dart';
import 'package:http/http.dart' as http;

class PromotionServices {
  static const _apiUrl = 'api/PromotionAPI';

  Future<Promotion?> get(int promotionId) async {
    final promotionDTO = await getDTO(promotionId);

    if (promotionDTO == null) {
      return null;
    }

    final promotion = Promotion(
      id: promotionId,
      discountCreatorMerchanId: promotionDTO.discountCreatorMerchanId,
      code: promotionDTO.code,
      name: promotionDTO.name,
      discountPercentage: promotionDTO.discountPercentage,
      discountAmount: promotionDTO.discountAmount,
      startDate: promotionDTO.startDate,
      endDate: promotionDTO.endDate,
    );

    return promotion;
  }

  Future<PromotionDTO?> getDTO(int promotionId) async {
    final jwtToken = UserServices.jwtToken;
    final newApiUrl = '$_apiUrl/$promotionId';
    final url = Uri.http(Secrets.FoodToGoAPILink, newApiUrl);

    final responseJson = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (responseJson.statusCode == HttpStatus.ok) {
      final responseData = json.decode(responseJson.body);

      final promotionDTO = PromotionDTO.fromJson(responseData['result']);

      return promotionDTO;
    }

    return null;
  }
}
