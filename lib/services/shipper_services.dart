import 'dart:convert';
import 'dart:io';
import 'dart:js_util';

import 'package:foodtogo_merchants/models/dto/shipper_dto.dart';
import 'package:foodtogo_merchants/models/order_success_rate.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/secrets.dart';
import 'package:foodtogo_merchants/models/shipper.dart';
import 'package:http/http.dart' as http;

class ShipperServices {
  static const apiUrl = 'api/ShipperAPI';
  Future<Shipper?> get(int shipperId) async {
    final shipperDTO = await getDTO(shipperId);
    final rating = await getAvgRating(shipperId, "Shipper");
    final OrderSuccessRate? orderSuccessRate =
        await getSuccessRate(shipperId, "Shipper");
    if (shipperDTO != null && rating != null && orderSuccessRate != null) {
      return Shipper(
        userId: shipperDTO.userId,
        firstName: shipperDTO.firstName,
        lastName: shipperDTO.lastName,
        middleName: shipperDTO.middleName,
        vehicleType: shipperDTO.vehicleType,
        vehicleNumberPlate: shipperDTO.vehicleNumberPlate,
        rating: rating,
        successOrderCount: orderSuccessRate.successOrderCount,
        cancelledOrderCount: orderSuccessRate.cancelledOrderCount,
      );
    }
    return null;
  }

  Future<ShipperDTO?> getDTO(int shipperId) async {
    final newApiUrl = '$apiUrl/$shipperId';
    final jwtToken = UserServices.jwtToken;

    final url = Uri.http(Secrets.FoodToGoAPILink, newApiUrl);

    final resonseJson = await http.get(url, headers: {
      'Authorization': 'Bearer $jwtToken',
    });

    if (resonseJson.statusCode == HttpStatus.ok) {
      final responseObject = json.decode(resonseJson.body);

      var shipperDTO = ShipperDTO(
        userId: responseObject['result']['userId'],
        firstName: responseObject['result']['firstName'],
        lastName: responseObject['result']['lastName'],
        middleName: responseObject['result']['middleName'],
        vehicleType: responseObject['result']['vehicleType'],
        vehicleNumberPlate: responseObject['result']['vehicleNumberPlate'],
      );

      return shipperDTO;
    }
    return null;
  }

  Future<double?> getAvgRating(int userId, String asType) async {
    const newApiUrl = '$apiUrl/avgrating';
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

  Future<OrderSuccessRate?> getSuccessRate(int userId, String asType) async {
    const newApiUrl = '$apiUrl/successrate';
    final jwtToken = UserServices.jwtToken;
    final url = Uri.http(Secrets.FoodToGoAPILink, newApiUrl, {
      'userId': userId.toString(),
      'asType': asType,
    });

    final resonseJson = await http.get(url, headers: {
      'Authorization': 'Bearer $jwtToken',
    });

    if (resonseJson.statusCode == HttpStatus.ok) {
      final responseObject = json.decode(resonseJson.body);
      final orderSuccessRate = OrderSuccessRate(
        successOrderCount: responseObject['result']['success'],
        cancelledOrderCount: responseObject['result']['cancelled'],
      );

      return orderSuccessRate;
    }
    return null;
  }
}
