import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:foodtogo_merchants/models/dto/create_dto/mechant_profile_image_create_dto.dart';
import 'package:foodtogo_merchants/models/dto/merchant_profile_image_dto.dart';
import 'package:foodtogo_merchants/models/dto/update_dto/merchant_profile_image_update_dto.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/secrets.dart';
import 'package:http/http.dart' as http;

class MerchantProfileImageServices {
  static const apiUrl = 'api/MerchantProfileImageAPI';

  Future<MerchantProfileImageDTO?> getByMerchantId(int merchantId) async {
    final newApiUrl = '$apiUrl/bymerchant/$merchantId';
    final url = Uri.http(Secrets.FoodToGoAPILink, newApiUrl);
    final jwtToken = UserServices.jwtToken;

    final responseJson = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (responseJson.statusCode != HttpStatus.ok) {
      return null;
    }

    final responseData = json.decode(responseJson.body);

    return MerchantProfileImageDTO(
      id: responseData['result']['id'],
      merchantId: responseData['result']['merchantId'],
      path: responseData['result']['path'],
    );
  }

  Future<bool> create(MerchantProfileImageCreateDTO createDTO) async {
    final url = Uri.http(Secrets.FoodToGoAPILink, apiUrl);
    final jwtToken = UserServices.jwtToken;

    final jsonData = json.encode({
      "id": createDTO.id,
      "merchantId": createDTO.merchantId,
      "path": createDTO.path,
    });

    final responseJson = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonData,
    );

    if (responseJson.statusCode == HttpStatus.created) {
      return true;
    }
    return false;
  }

  Future<bool> update(
    MerchantProfileImageUpdateDTO updateDTO,
    int id,
  ) async {
    final url = Uri.http(Secrets.FoodToGoAPILink, '$apiUrl/$id');
    final jwtToken = UserServices.jwtToken;

    final jsonData = json.encode({
      "id": id,
      "merchantId": updateDTO.merchantId,
      "path": updateDTO.path,
    });

    final responseJson = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonData,
    );

    if (responseJson.statusCode == HttpStatus.ok) {
      return true;
    }
    return false;
  }

  Future<bool> delete(int id) async {
    final url = Uri.http(Secrets.FoodToGoAPILink, '$apiUrl/$id');
    final jwtToken = UserServices.jwtToken;

    final responseJson = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (responseJson.statusCode == HttpStatus.noContent) {
      return true;
    }
    return false;
  }
}
