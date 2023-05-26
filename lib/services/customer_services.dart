import 'dart:convert';
import 'dart:io';

import 'package:foodtogo_merchants/models/customer.dart';
import 'package:foodtogo_merchants/models/dto/customer_dto.dart';
import 'package:foodtogo_merchants/models/order_success_rate.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/secrets.dart';
import 'package:http/http.dart' as http;

class CustomerServices {
  static const apiUrl = 'api/CustomerAPI';
  Future<Customer?> get(int customerId) async {
    final customerDTO = await getDTO(customerId);
    final rating = await getAvgRating(customerId, "Customer");
    final OrderSuccessRate? orderSuccessRate =
        await getSuccessRate(customerId, "Customer");
    if (customerDTO != null && rating != null && orderSuccessRate != null) {
      return Customer(
        customerId: customerDTO.customerId,
        firstName: customerDTO.firstName,
        lastName: customerDTO.lastName,
        middleName: customerDTO.middleName,
        address: customerDTO.address,
        rating: rating,
        successOrderCount: orderSuccessRate.successOrderCount,
        cancelledOrderCount: orderSuccessRate.cancelledOrderCount,
      );
    }
    return null;
  }

  Future<CustomerDTO?> getDTO(int customerId) async {
    final newApiUrl = '$apiUrl/$customerId';
    final jwtToken = UserServices.jwtToken;

    final url = Uri.http(Secrets.FoodToGoAPILink, newApiUrl);

    final resonseJson = await http.get(url, headers: {
      'Authorization': 'Bearer $jwtToken',
    });

    if (resonseJson.statusCode == HttpStatus.ok) {
      final responseObject = json.decode(resonseJson.body);

      var customerDTO = CustomerDTO(
        customerId: responseObject['result']['userId'],
        firstName: responseObject['result']['firstName'],
        lastName: responseObject['result']['lastName'],
        middleName: responseObject['result']['middleName'],
        address: responseObject['result']['address'],
      );

      return customerDTO;
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
