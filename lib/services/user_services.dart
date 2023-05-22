import 'dart:convert';

import 'package:foodtogo_merchants/models/dto/login_request_dto.dart';
import 'package:foodtogo_merchants/models/dto/login_response_dto.dart';
import 'package:foodtogo_merchants/settings/secrets.dart';
import 'package:http/http.dart' as http;

class UserServices {
  Future<void> login(LoginRequestDTO loginRequestDTO) async {
    final url = Uri.http('${Secrets.FoodToGoAPILink}', 'api/UserAPI/login');

    final jsonData = json.encode({
      "userName": loginRequestDTO.username,
      "password": loginRequestDTO.password,
      "loginFromApp": loginRequestDTO.loginFromApp,
    });

    print(jsonData);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonData,
    );

    print(response.body);
    print(response.statusCode);
    // return LoginResponseDTO();
  }
}
