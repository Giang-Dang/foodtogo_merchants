import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodtogo_merchants/models/customer.dart';
import 'package:foodtogo_merchants/models/dto/order_dto.dart';
import 'package:foodtogo_merchants/models/dto/update_dto/order_update_dto.dart';
import 'package:foodtogo_merchants/models/enum/order_status.dart';
import 'package:foodtogo_merchants/models/merchant.dart';
import 'package:foodtogo_merchants/models/order.dart';
import 'package:foodtogo_merchants/models/promotion.dart';
import 'package:foodtogo_merchants/models/shipper.dart';
import 'package:foodtogo_merchants/services/customer_services.dart';
import 'package:foodtogo_merchants/services/merchant_services.dart';
import 'package:foodtogo_merchants/services/promotion_services.dart';
import 'package:foodtogo_merchants/services/shipper_services.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/settings/secrets.dart';
import 'package:http/http.dart' as http;

class OrderServices {
  static const _apiUrl = 'api/OrderAPI';

  Future<List<Order>?> getAll({
    int merchantId = 0,
    int customerId = 0,
    int shipperId = 0,
    int promotionId = 0,
    String? searchStatus,
    DateTime? searchPlacedDate,
    int pageSize = 0,
    int pageNumber = 1,
  }) async {
    final orderDTOList = await getAllDTO(
      merchantId: merchantId,
      customerId: customerId,
      shipperId: shipperId,
      promotionId: promotionId,
      searchStatus: searchStatus,
      searchPlacedDate: searchPlacedDate,
      pageSize: pageSize,
      pageNumber: pageNumber,
    );

    if (orderDTOList == null) {
      return null;
    }

    List<Order> ordersList = [];

    for (var orderDTO in orderDTOList) {
      var order = await getFromDTO(orderDTO);
      if (order == null) {
        return null;
      }
      ordersList.add(order);
    }

    return ordersList;
  }

  Future<List<OrderDTO>?> getAllDTO({
    int merchantId = 0,
    int customerId = 0,
    int shipperId = 0,
    int promotionId = 0,
    String? searchStatus,
    DateTime? searchPlacedDate,
    int pageSize = 0,
    int pageNumber = 1,
  }) async {
    final jwtToken = UserServices.jwtToken;

    final queryParams = <String, String>{};
    queryParams.addAll({
      'searchCustomerId': customerId.toString(),
      'searchMerchantId': merchantId.toString(),
      'searchShipperId': shipperId.toString(),
      'searchPromotionId': promotionId.toString(),
      'pageSize': pageSize.toString(),
      'pageNumber': pageNumber.toString(),
    });
    if (searchStatus != null) {
      queryParams['searchStatus'] = searchStatus;
    }
    if (searchPlacedDate != null) {
      queryParams['searchPlacedDate'] = searchPlacedDate.toString();
    }

    final url = Uri.http(Secrets.FoodToGoAPILink, _apiUrl, queryParams);

    final responseJson = await http.get(url, headers: {
      'Authorization': 'Bearer $jwtToken',
    });

    if (responseJson.statusCode == HttpStatus.ok) {
      final responseData = json.decode(responseJson.body);

      final ordersList = (responseData['result'] as List)
          .map((json) => OrderDTO.fromJson(json))
          .toList();

      return ordersList;
    }

    return null;
  }

  Future<Order?> getFromDTO(OrderDTO orderDTO) async {
    final MerchantServices merchantServices = MerchantServices();
    final CustomerServices customerServices = CustomerServices();
    final ShipperServices shipperServices = ShipperServices();
    final PromotionServices promotionServices = PromotionServices();

    final Merchant? merchant = await merchantServices.get(orderDTO.merchantId);
    final Customer? customer = await customerServices.get(orderDTO.customerId);
    final Shipper? shipper = await shipperServices.get(orderDTO.shipperId);
    Promotion? promotion;
    if (orderDTO.promotionId != null) {
      promotion = await promotionServices.get(orderDTO.promotionId!);
    }

    if (merchant == null || customer == null || shipper == null) {
      return null;
    }

    Order order = Order(
      id: orderDTO.id,
      merchant: merchant,
      shipper: shipper,
      customer: customer,
      promotion: promotion,
      placedTime: orderDTO.placedTime,
      eta: orderDTO.eta,
      deliveryCompletionTime: orderDTO.deliveryCompletionTime,
      orderPrice: orderDTO.orderPrice,
      shippingFee: orderDTO.shippingFee,
      appFee: orderDTO.appFee,
      promotionDiscount: orderDTO.promotionDiscount,
      status: orderDTO.status,
      cancelledBy: orderDTO.cancelledBy,
      cancellationReason: orderDTO.cancellationReason,
    );

    return order;
  }

  Future<bool> update(int id, OrderUpdateDTO updateDTO) async {
    final newApiUrl = '$_apiUrl/$id';
    final jwtToken = UserServices.jwtToken;

    final url = Uri.http(Secrets.FoodToGoAPILink, newApiUrl);

    final requestJson = json.encode(updateDTO.toJson());

    final responseJson = await http.put(url,
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
        body: requestJson);

    if (responseJson.statusCode != HttpStatus.ok) {
      log('OrderServices.update() responseJson.statusCode != HttpStatus.ok');
      inspect(responseJson);

      return false;
    }

    return true;
  }

  Color getOrderColor(String orderStatus) {
    if (orderStatus == OrderStatus.Placed.name.toLowerCase()) {
      return KColors.kLightTextColor;
    }
    if (orderStatus == OrderStatus.Getting.name.toLowerCase()) {
      return KColors.kBlue;
    }
    if (orderStatus == OrderStatus.DriverAtMerchant.name.toLowerCase()) {
      return KColors.kSuccessColor;
    }
    if (orderStatus == OrderStatus.Delivering.name.toLowerCase()) {
      return KColors.kBlue;
    }
    if (orderStatus == OrderStatus.DriverAtDeliveryPoint.name.toLowerCase()) {
      return KColors.kSuccessColor;
    }
    if (orderStatus == OrderStatus.Completed.name.toLowerCase()) {
      return KColors.kSuccessColor;
    }
    if (orderStatus == OrderStatus.Cancelled.name.toLowerCase()) {
      return KColors.kDanger;
    }
    return KColors.kTextColor;
  }

  String getOrderStatusInfo(String orderStatus) {
    if (orderStatus == OrderStatus.Placed.name.toLowerCase()) {
      return 'Order is placed';
    }
    if (orderStatus == OrderStatus.Getting.name.toLowerCase()) {
      return 'shipper is picking up the package.';
    }
    if (orderStatus == OrderStatus.DriverAtMerchant.name.toLowerCase()) {
      return 'Shipper is at the merchant';
    }
    if (orderStatus == OrderStatus.Delivering.name.toLowerCase()) {
      return 'Shipper is delivering the package.';
    }
    if (orderStatus == OrderStatus.DriverAtDeliveryPoint.name.toLowerCase()) {
      return 'Shipper is at the delivery point';
    }
    if (orderStatus == OrderStatus.Completed.name.toLowerCase()) {
      return 'Order has been completed';
    }
    if (orderStatus == OrderStatus.Cancelled.name.toLowerCase()) {
      return 'Order has been cancelled';
    }
    return 'NA';
  }

  int getOrderStatusIndex(String orderStatus) {
    for (var value in OrderStatus.values) {
      if (orderStatus == value.name.toLowerCase()) {
        return value.index;
      }
    }
    log('OrderServices.getOrderStatusIndex() -1');
    return -1;
  }

  // Icon getOrderIcon(String orderStatus) {
  //   if (orderStatus == OrderStatus.Placed.name.toLowerCase()) {
  //     return Icons.sprint;
  //   }
  //   if (orderStatus == OrderStatus.Getting.name.toLowerCase()) {
  //     return Icons.sprint;
  //   }
  //   if (orderStatus == OrderStatus.DriverAtMerchant.name.toLowerCase()) {
  //     return KColors.kSuccessColor;
  //   }
  //   if (orderStatus == OrderStatus.Delivering.name.toLowerCase()) {
  //     return KColors.kBlue;
  //   }
  //   if (orderStatus == OrderStatus.DriverAtDeliveryPoint.name.toLowerCase()) {
  //     return KColors.kSuccessColor;
  //   }
  //   if (orderStatus == OrderStatus.Completed.name.toLowerCase()) {
  //     return KColors.kSuccessColor;
  //   }
  //   if (orderStatus == OrderStatus.Cancelled.name.toLowerCase()) {
  //     return KColors.kDanger;
  //   }
  //   return KColors.kTextColor;
  // }
}
