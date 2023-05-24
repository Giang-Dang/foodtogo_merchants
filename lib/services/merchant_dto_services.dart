import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:foodtogo_merchants/models/dto/merchant_dto.dart';
import 'package:foodtogo_merchants/models/dto/update_dto/merchant_update_dto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'package:foodtogo_merchants/models/dto/create_dto/mechant_profile_image_create_dto.dart';
import 'package:foodtogo_merchants/models/dto/create_dto/merchant_create_dto.dart';
import 'package:foodtogo_merchants/services/file_services.dart';
import 'package:foodtogo_merchants/services/merchant_profile_image_services.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/secrets.dart';

class MerchantDTOServices {
  static const apiUrl = 'api/MerchantAPI';

  Future<List<MerchantDTO>> getAll() async {
    final url = Uri.http(Secrets.FoodToGoAPILink, apiUrl);
    final jwtToken = UserServices.jwtToken;

    final responseJson = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    final reponseData = jsonDecode(responseJson.body);
    final merchants = (reponseData['result'] as List)
        .map((merchantJson) => MerchantDTO.fromJson(merchantJson))
        .toList();
    return merchants;
  }

  Future<bool> create(MerchantCreateDTO createDTO, File image) async {
    final url = Uri.http(Secrets.FoodToGoAPILink, apiUrl);
    final jwtToken = UserServices.jwtToken;

    final jsonData = json.encode({
      "merchantId": 0,
      "userId": createDTO.userId,
      "name": createDTO.name,
      "address": createDTO.address,
      "phoneNumber": createDTO.phoneNumber,
      "geoLatitude": createDTO.geoLatitude,
      "geoLongitude": createDTO.geoLongitude,
    });

    final responseJson = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonData,
    );

    final responseObject = json.decode(responseJson.body);

    int merchantId = 0;
    bool isUploadImageSuccess = false;

    inspect(responseJson);
    inspect(responseObject);
    if (responseObject['isSuccess'] as bool) {
      merchantId = responseObject['result']['merchantId'];
      isUploadImageSuccess = await uploadProfileImage(image, merchantId);
    }

    if (responseJson.statusCode == HttpStatus.created && isUploadImageSuccess) {
      return true;
    }
    return false;
  }

  Future<bool> update(
    MerchantUpdateDTO updateDTO,
    int id,
  ) async {
    final url = Uri.http(Secrets.FoodToGoAPILink, '$apiUrl/$id');
    final jwtToken = UserServices.jwtToken;

    final jsonData = json.encode({
      "merchantId": id,
      "userId": updateDTO.userId,
      "name": updateDTO.name,
      "address": updateDTO.address,
      "phoneNumber": updateDTO.phoneNumber,
      "geoLatitude": updateDTO.geoLatitude,
      "geoLongitude": updateDTO.geoLongitude,
    });

    final responseJson = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonData,
    );

    inspect(responseJson);

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

  Future<int> getMerchantId(String name) async {
    final url = Uri.http(Secrets.FoodToGoAPILink, '$apiUrl/idbyname/$name');
    final jwtToken = UserServices.jwtToken;

    final responseJson = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (responseJson.statusCode != HttpStatus.ok) {
      return 0;
    }
    final responseObject = json.decode(responseJson.body);
    return responseObject['MerchantId'];
  }

  Future<bool> uploadProfileImage(File image, int merchantId) async {
    // try {
    final fileServices = FileServices();
    final merchantProfileImageServices = MerchantProfileImageServices();
    //rename image to correct format
    final merchantIdStr = merchantId.toString().padLeft(7, '0');
    final datetime = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final fileExtention = path.extension(image.path);
    final newName =
        'MerchantProfileImage_${merchantIdStr}_$datetime$fileExtention';
    final renamedImage = await fileServices.renameFile(image, newName);

    final responsePath = await fileServices.uploadImage(renamedImage);
    final createDTO = MerchantProfileImageCreateDTO(
      merchantId: merchantId,
      path: responsePath,
    );
    await merchantProfileImageServices.create(createDTO);
    // } catch (e) {
    //   return false;
    // }

    return true;
  }
}
