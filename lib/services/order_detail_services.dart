import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:foodtogo_merchants/models/dto/order_details_dto.dart';
import 'package:foodtogo_merchants/models/order_detail.dart';
import 'package:foodtogo_merchants/services/menu_item_services.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/secrets.dart';
import 'package:http/http.dart' as http;

class OrderDetailServices {
  static const _apiUrl = 'api/OrderDetailAPI';

  Future<List<OrderDetail>?> getAll({
    int? searchOrderId,
    int? searchItemId,
    int pageSize = 0,
    int pageNumber = 1,
  }) async {
    final MenuItemServices menuItemServices = MenuItemServices();

    final orderDetailDTOsList = await getAllDTOs(
      searchItemId: searchItemId,
      searchOrderId: searchOrderId,
      pageSize: pageSize,
      pageNumber: pageNumber,
    );

    if (orderDetailDTOsList != null) {
      List<OrderDetail> resultList = [];

      for (var dto in orderDetailDTOsList) {
        var menuItem = await menuItemServices.get(dto.menuItemId);
        if (menuItem == null) {
          log('OrderDetailServices.getAll() menuItem == null');
          return null;
        }
        var orderDetail = OrderDetail(
          id: dto.id,
          orderId: dto.orderId,
          menuItem: menuItem,
          quantity: dto.quantity,
          unitPrice: dto.unitPrice,
          specialInstruction: dto.specialInstruction,
        );

        resultList.add(orderDetail);
      }

      return resultList;
    }

    log('OrderDetailServices.getAll() orderDetailDTOsList == null');
  }

  Future<List<OrderDetailDTO>?> getAllDTOs({
    int? searchOrderId,
    int? searchItemId,
    int pageSize = 0,
    int pageNumber = 1,
  }) async {
    final jwtToken = UserServices.jwtToken;

    final queryParams = <String, String>{};
    queryParams.addAll({
      'pageSize': pageSize.toString(),
      'pageNumber': pageNumber.toString(),
    });
    if (searchOrderId != null) {
      queryParams['searchOrderId'] = searchOrderId.toString();
    }
    if (searchItemId != null) {
      queryParams['searchItemId'] = searchItemId.toString();
    }

    final url = Uri.http(Secrets.FoodToGoAPILink, _apiUrl, queryParams);

    final responseJson = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwtToken',
      },
    );

    if (responseJson.statusCode == HttpStatus.ok) {
      final responseData = json.decode(responseJson.body);
      final orderDetailDTOsList = (responseData['result'] as List)
          .map((json) => OrderDetailDTO.fromJson(json))
          .toList();

      return orderDetailDTOsList;
    }

    log('OrderDetailServices.getAllDTOs()');
    return null;
  }
}
