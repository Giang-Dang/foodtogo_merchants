import 'dart:convert';
import 'dart:io';

import 'package:foodtogo_merchants/models/dto/user_rating_dto.dart';
import 'package:foodtogo_merchants/models/order_success_rate.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/secrets.dart';
import 'package:http/http.dart' as http;

class UserRatingServices {
  static const _apiUrl = 'api/UserRatingAPI';
  Future<double?> getAvgRating(int userId, String asType) async {
    const newApiUrl = '$_apiUrl/avgrating';
    final jwtToken = UserServices.jwtToken;
    final url = Uri.http(Secrets.FoodToGoAPILink, newApiUrl, {
      'toUserId': userId.toString(),
      'asType': asType,
    });

    final resonseJson = await http.get(url, headers: {
      'Authorization': 'Bearer $jwtToken',
    });

    if (resonseJson.statusCode == HttpStatus.ok) {
      final responseObject = json.decode(resonseJson.body);

      return responseObject['result'].toDouble();
    }
    return null;
  }
}
