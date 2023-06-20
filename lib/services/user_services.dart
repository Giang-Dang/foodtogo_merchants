import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:foodtogo_merchants/models/dto/api_response_dto.dart';
import 'package:foodtogo_merchants/models/dto/login_request_dto.dart';
import 'package:foodtogo_merchants/models/dto/login_response_dto.dart';
import 'package:foodtogo_merchants/models/dto/register_request_dto.dart';
import 'package:foodtogo_merchants/models/dto/user_dto.dart';
import 'package:foodtogo_merchants/models/dto/update_dto/user_update_dto.dart';
import 'package:foodtogo_merchants/settings/secrets.dart';
import 'package:http/http.dart' as http;

const kTokenKeyName = 'loginToken';
const kUserIdKeyName = 'userId';

class UserServices {
  static bool isAuthorized = false;
  static String jwtToken = "";
  static String strUserId = "";

  Future<UserDTO?> get(int userId) async {
    final apiUrl = 'api/UserAPI/$userId';
    final url = Uri.http(Secrets.kFoodToGoAPILink, apiUrl, {
      'id': userId.toString(),
    });

    final resonseJson = await http.get(url, headers: {
      'Authorization': 'Bearer $jwtToken',
    });

    if (resonseJson.statusCode == HttpStatus.ok) {
      final responseObject = json.decode(resonseJson.body);

      var userDTO = UserDTO(
        id: responseObject['result']['id'],
        username: responseObject['result']['username'],
        role: responseObject['result']['role'],
        phoneNumber: responseObject['result']['phoneNumber'],
        email: responseObject['result']['email'],
      );

      return userDTO;
    }
    return null;
  }

  Future<bool> update(int userId, UserUpdateDTO updateDTO) async {
    final apiUrl = 'api/UserAPI/${userId.toString()}';
    final url = Uri.http(Secrets.kFoodToGoAPILink, apiUrl);

    final jsonData = json.encode({
      "id": updateDTO.id,
      "phoneNumber": updateDTO.phoneNumber,
      "email": updateDTO.email,
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

  Future<LoginResponseDTO> login(LoginRequestDTO loginRequestDTO) async {
    const loginAPISubUrl = 'api/UserAPI/login';
    final url = Uri.http(Secrets.kFoodToGoAPILink, loginAPISubUrl);

    final jsonData = json.encode({
      "userName": loginRequestDTO.username,
      "password": loginRequestDTO.password,
      "loginFromApp": loginRequestDTO.loginFromApp,
    });

    final responseJson = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonData,
    );

    final responseObject = json.decode(responseJson.body);

    LoginResponseDTO loginResponseDTO;

    if (responseObject['isSuccess'] as bool) {
      loginResponseDTO = LoginResponseDTO(
        isSuccess: responseObject['isSuccess'],
        errorMessage: "",
        user: UserDTO(
          id: responseObject['result']['user']['id'],
          username: responseObject['result']['user']['username'],
          role: responseObject['result']['user']['role'],
          phoneNumber: responseObject['result']['user']['phoneNumber'],
          email: responseObject['result']['user']['email'],
        ),
      );

      saveLoginInfo(responseObject['result']['token'] as String,
          responseObject['result']['user']['id'].toString());
      //set static values
      isAuthorized = true;
      jwtToken = responseObject['result']['token'] as String;
      strUserId = responseObject['result']['user']['id'].toString();
    } else {
      loginResponseDTO = LoginResponseDTO(
        isSuccess: responseObject['isSuccess'],
        errorMessage: responseObject['errorMessages'][0],
      );
    }
    return loginResponseDTO;
  }

  Future<void> checkLocalLoginAuthorized() async {
    jwtToken = await getLoginToken() ?? "";
    strUserId = await getStoredUserId() ?? "";
    // print('jwtToken $jwtToken');
    // print('strUserId $strUserId');
    if (jwtToken == "" || strUserId == "") {
      isAuthorized = false;
      jwtToken = "";
      strUserId = "";
      return;
    }

    final merchantAPIByUserIdLink = 'api/MerchantAPI/byuser/$strUserId';
    final url = Uri.http(Secrets.kFoodToGoAPILink, merchantAPIByUserIdLink);

    final responseJson = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (responseJson.statusCode == HttpStatus.ok) {
      isAuthorized = true;
      return;
    }

    isAuthorized = false;
    jwtToken = "";
    strUserId = "";
    return;
  }

  Future<APIResponseDTO> register(RegisterRequestDTO registerRequestDTO) async {
    const registerAPISubUrl = 'api/UserAPI/register';
    final url = Uri.http(Secrets.kFoodToGoAPILink, registerAPISubUrl);

    final jsonData = json.encode({
      "userName": registerRequestDTO.username,
      "password": registerRequestDTO.password,
      "phoneNumber": registerRequestDTO.phoneNumber,
      "email": registerRequestDTO.email,
    });

    final responseJson = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonData,
    );

    final responseObject = json.decode(responseJson.body);
    return APIResponseDTO(
      statusCode: responseObject['statusCode'],
      isSuccess: responseObject['isSuccess'],
      errorMessages: [],
      result: responseObject['result'],
    );
  }

  FlutterSecureStorage getSecureStorage() {
    AndroidOptions getAndroidOptions() => const AndroidOptions(
          encryptedSharedPreferences: true,
        );
    final storage = FlutterSecureStorage(aOptions: getAndroidOptions());
    return storage;
  }

  Future<void> saveLoginInfo(String token, String strUserId) async {
    final storage = getSecureStorage();
    await storage.delete(key: kTokenKeyName);
    await storage.delete(key: kUserIdKeyName);
    await storage.write(key: kTokenKeyName, value: token);
    await storage.write(key: kUserIdKeyName, value: strUserId);
  }

  Future<void> deleteStoredLoginInfo() async {
    final storage = getSecureStorage();
    await storage.delete(key: kTokenKeyName);
    await storage.delete(key: kUserIdKeyName);
  }

  Future<String?> getLoginToken() async {
    final storage = getSecureStorage();
    return await storage.read(key: kTokenKeyName);
  }

  Future<String?> getStoredUserId() async {
    final storage = getSecureStorage();
    return await storage.read(key: kUserIdKeyName);
  }

  bool isValidUsername(String? username) {
    RegExp validCharacters = RegExp(r'^[a-zA-Z0-9_]+$');
    if (username == null) {
      return false;
    }
    return username.length >= 4 &&
        username.length <= 30 &&
        validCharacters.hasMatch(username);
  }

  bool isValidEmail(String? email) {
    RegExp validRegex = RegExp(
        r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z]{2,})+');
    if (email == null) {
      return false;
    }
    return validRegex.hasMatch(email);
  }

  bool isValidPhoneNumber(String? phoneNumber) {
    // Regular expression pattern to match valid phone numbers
    String pattern =
        r'^(0|\+84)(3[2-9]|5[689]|7[06-9]|8[1-6]|9[0-46-9])[0-9]{7}$|^(0|\+84)(2[0-9]{1}|[3-9]{1})[0-9]{8}$';
    RegExp regExp = RegExp(pattern);

    if (phoneNumber == null) {
      return false;
    }
    // Check if the phone number matches the pattern
    if (regExp.hasMatch(phoneNumber)) {
      return true;
    } else {
      return false;
    }
  }
}
