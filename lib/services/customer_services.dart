import 'dart:convert';
import 'dart:io';

import 'package:foodtogo_merchants/models/customer.dart';
import 'package:foodtogo_merchants/models/dto/customer_dto.dart';
import 'package:foodtogo_merchants/models/order_success_rate.dart';
import 'package:foodtogo_merchants/services/order_success_rate_services.dart';
import 'package:foodtogo_merchants/services/user_rating_services.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/secrets.dart';
import 'package:http/http.dart' as http;

class CustomerServices {
  static const apiUrl = 'api/CustomerAPI';
  Future<Customer?> get(int customerId) async {
    final UserRatingServices userRatingServices = UserRatingServices();
    final OrderSuccessRateServices orderSuccessRateServices =
        OrderSuccessRateServices();
    final UserServices userServices = UserServices();

    final customerDTO = await getDTO(customerId);
    final userDTO = await userServices.get(customerId);
    final rating =
        await userRatingServices.getAvgRating(customerId, "Customer");
    final OrderSuccessRate? orderSuccessRate =
        await orderSuccessRateServices.getSuccessRate(customerId, "Customer");
    if (customerDTO != null &&
        userDTO != null &&
        rating != null &&
        orderSuccessRate != null) {
      return Customer(
        customerId: customerDTO.customerId,
        firstName: customerDTO.firstName,
        lastName: customerDTO.lastName,
        middleName: customerDTO.middleName,
        address: customerDTO.address,
        phoneNumber: userDTO.phoneNumber,
        email: userDTO.email,
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
        customerId: responseObject['result']['customerId'],
        firstName: responseObject['result']['firstName'],
        lastName: responseObject['result']['lastName'],
        middleName: responseObject['result']['middleName'],
        address: responseObject['result']['address'],
      );

      return customerDTO;
    }
    return null;
  }
}
