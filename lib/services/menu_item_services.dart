import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:foodtogo_merchants/models/dto/create_dto/menu_item_create_dto.dart';
import 'package:foodtogo_merchants/models/dto/create_dto/menu_item_image_create_dto.dart';
import 'package:foodtogo_merchants/models/dto/update_dto/menu_item_image_update_dto.dart';
import 'package:foodtogo_merchants/models/dto/update_dto/menu_item_update_dto.dart';
import 'package:foodtogo_merchants/models/menu_item.dart';
import 'package:foodtogo_merchants/services/file_services.dart';
import 'package:foodtogo_merchants/services/menu_item_image_services.dart';
import 'package:foodtogo_merchants/services/menu_item_type_services.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/secrets.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class MenuItemServices {
  static const apiUrl = 'api/MenuItemAPI';

  Future<List<MenuItem>?> getAllMenuItems(int merchantId) async {
    final menuItemTypeServices = MenuItemTypeServices();
    final menuItemImageServices = MenuItemImageServices();

    final url = Uri.http(
      Secrets.FoodToGoAPILink,
      apiUrl,
      {
        'searchMerchanId': '$merchantId',
      },
    );

    final jwtToken = UserServices.jwtToken;

    final responseJson = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    final reponseData = jsonDecode(responseJson.body);

    final menuItemDTOList = (reponseData['result'] as List);

    if (menuItemDTOList.isEmpty) {
      return null;
    }

    List<MenuItem> menuItemList = [];

    for (var item in menuItemDTOList) {
      var itemId = item['id'];
      var itemTypeId = item['itemTypeId'];
      var menuType = await menuItemTypeServices.get(itemTypeId);
      var menuItemImage = await menuItemImageServices.getByMenuItem(itemId);

      var menuItem = MenuItem(
        id: itemId,
        merchantId: item['merchantId'],
        itemType: menuType.name,
        name: item['name'],
        description: item['description'],
        unitPrice: item['unitPrice'],
        imagePath: menuItemImage.path,
      );
      menuItemList.add(menuItem);
    }

    return menuItemList;
  }

  Future<bool> create(MenuItemCreateDTO createDTO, File image) async {
    final url = Uri.http(Secrets.FoodToGoAPILink, apiUrl);
    final jwtToken = UserServices.jwtToken;

    final jsonData = json.encode({
      "id": createDTO.id,
      "merchantId": createDTO.merchantId,
      "itemTypeId": createDTO.itemTypeId,
      "name": createDTO.name,
      "description": createDTO.description,
      "unitPrice": createDTO.unitPrice,
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

    int menuItemId = 0;
    bool isUploadImageSuccess = false;

    if (responseObject['isSuccess'] as bool) {
      menuItemId = responseObject['result']['id'];
      isUploadImageSuccess = await uploadMenuItemImage(image, menuItemId);
    }

    if (responseJson.statusCode == HttpStatus.created && isUploadImageSuccess) {
      return true;
    }
    return false;
  }

  Future<bool> update(
    int id,
    MenuItemUpdateDTO updateDTO,
    File? image,
  ) async {
    final url = Uri.http(Secrets.FoodToGoAPILink, '$apiUrl/$id');
    final jwtToken = UserServices.jwtToken;

    final jsonData = json.encode({
      "id": id,
      "merchantId": updateDTO.merchantId,
      "itemTypeId": updateDTO.itemTypeId,
      "name": updateDTO.name,
      "description": updateDTO.description,
      "unitPrice": updateDTO.unitPrice,
    });

    final responseJson = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonData,
    );
    if (responseJson.statusCode != HttpStatus.ok) {
      return false;
    }

    bool isUploadImageSuccess = true;
    if (image != null) {
      final responseObject = json.decode(responseJson.body);

      if (responseObject['isSuccess'] as bool) {
        final menuItemImageServices = MenuItemImageServices();
        final menuItemImage = await menuItemImageServices.getByMenuItem(id);
        isUploadImageSuccess = await uploadMenuItemImage(
          image,
          id,
          imageId: menuItemImage.id,
        );
      }
    }

    return isUploadImageSuccess;
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

  Future<bool> uploadMenuItemImage(File image, int menuItemId,
      {int imageId = 0}) async {
    final fileServices = FileServices();
    final menuItemImageServices = MenuItemImageServices();
    //rename image to correct format
    final menuItemIdStr = menuItemId.toString().padLeft(7, '0');
    final datetime = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final fileExtention = path.extension(image.path);
    final newName = 'MenuItemImage_${menuItemIdStr}_$datetime$fileExtention';
    final renamedImage = await fileServices.renameFile(image, newName);

    final responsePath = await fileServices.uploadImage(renamedImage);
    final createDTO = MenuItemImageCreateDTO(
      id: imageId, //in case of updating
      menuItemId: menuItemId,
      path: responsePath,
    );

    if (imageId == 0) {
      await menuItemImageServices.create(createDTO);
    } else {
      //update
      final updateDTO = MenuItemImageUpdateDTO(
        id: imageId,
        menuItemId: createDTO.menuItemId,
        path: createDTO.path,
      );
      await menuItemImageServices.update(updateDTO, imageId);
    }

    return true;
  }
}
