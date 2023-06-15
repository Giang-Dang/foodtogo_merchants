import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/dto/update_dto/order_update_dto.dart';
import 'package:foodtogo_merchants/models/enum/order_status.dart';
import 'package:foodtogo_merchants/models/enum/user_type.dart';
import 'package:foodtogo_merchants/models/order.dart';
import 'package:foodtogo_merchants/models/order_detail.dart';
import 'package:foodtogo_merchants/providers/orders_list_provider.dart';
import 'package:foodtogo_merchants/screens/rating_user_screen.dart';
import 'package:foodtogo_merchants/services/order_detail_services.dart';
import 'package:foodtogo_merchants/services/order_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/widgets/rating_button.dart';
import 'package:intl/intl.dart';

final dateFormatter = DateFormat.yMMMMd();

class OrderDetailsScreen extends ConsumerStatefulWidget {
  const OrderDetailsScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  final Order order;

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  final OrderDetailServices _orderDetailServices = OrderDetailServices();
  final OrderServices _orderServices = OrderServices();

  List<OrderDetail>? _orderDetailsList;
  Timer? _initTimer;

  _getOrderDetailsList() async {
    final orderDetailsList =
        await _orderDetailServices.getAll(searchOrderId: widget.order.id);

    if (orderDetailsList != null) {
      if (mounted) {
        setState(() {
          _orderDetailsList = orderDetailsList;
        });
      }
    }
  }

  _showAlertDialog(String title, String message, void Function() onOkPressed) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  onOkPressed();
                },
              ),
            ],
          );
        },
      );
    }
  }

  _navigateToRatingScreen(
      {required UserType fromUserType,
      required UserType toUserType,
      required Order order}) {
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RatingUserScreen(
              order: order, fromUserType: fromUserType, toUserType: toUserType),
        ),
      );
    }
  }

  _isAbleToCancel(Order order) {
    if (order.status == OrderStatus.Placed.name.toLowerCase()) {
      return true;
    }
    if (order.status == OrderStatus.Getting.name.toLowerCase()) {
      return true;
    }
    if (order.status == OrderStatus.DriverAtMerchant.name.toLowerCase()) {
      return true;
    }
    return false;
  }

  _showCancellationBottomSheet(
    BuildContext context,
    Order order,
  ) async {
    final TextEditingController controller = TextEditingController();
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 1.0,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Please enter a cancellation reason:',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: KColors.kPrimaryColor),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  minLines: 2,
                  maxLines: 5,
                  decoration:
                      const InputDecoration(hintText: 'Cancellation reason'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (controller.text == '') {
                      _showAlertDialog('Invalid Reason',
                          'The reason field cannot be left empty!', () {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      });
                      return;
                    }
                    // Return the cancellation reason
                    String? reason = controller.text;

                    await _onCancelPress(order, reason);
                  },
                  child: const Text('Cancel Order'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _onCancelPress(Order order, String reason) async {
    final updateDTO = OrderUpdateDTO(
      id: order.id,
      merchantId: order.merchant.merchantId,
      shipperId: order.shipper.userId,
      customerId: order.customer.customerId,
      promotionId: order.promotion == null ? null : order.promotion!.id,
      placedTime: order.placedTime,
      eta: order.eta,
      deliveryCompletionTime: order.deliveryCompletionTime,
      orderPrice: order.orderPrice,
      shippingFee: order.shippingFee,
      appFee: order.appFee,
      promotionDiscount: order.promotionDiscount,
      status: OrderStatus.Cancelled.name.toLowerCase(),
      cancelledBy: UserType.Merchant.name.toLowerCase(),
      cancellationReason: reason,
    );

    bool isSuccess = await _orderServices.update(order.id, updateDTO);

    final orderList =
        await _orderServices.getAll(merchantId: order.merchant.merchantId);

    isSuccess &= (orderList != null);

    if (isSuccess) {
      _showAlertDialog('Cancelled', 'The order has been cancelled', () {
        final orderListFromProvider = ref.read(ordersListProvider);
        if (orderList != orderListFromProvider) {
          ref.watch(ordersListProvider.notifier).updateOrdersList(orderList!);
        }
        if (context.mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      });
    } else {
      _showAlertDialog('Cancellation failed',
          'Unable to cancel this order at the moment. Please try again later.',
          () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //get order details
    _initTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      _getOrderDetailsList();
      _initTimer?.cancel();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _initTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final OrderServices orderServices = OrderServices();
    final orderStatusInfo =
        orderServices.getOrderStatusInfo(widget.order.status);

    final totalPrice = widget.order.orderPrice +
        widget.order.appFee +
        widget.order.shippingFee -
        widget.order.promotionDiscount;

    final isCancelled =
        widget.order.status == OrderStatus.Cancelled.name.toLowerCase();

    final isAbleToCancel = _isAbleToCancel(widget.order);

    Widget orderDetailsContent = const SizedBox(
        height: 30,
        width: 30,
        child: CircularProgressIndicator(color: KColors.kPrimaryColor));

    if (_orderDetailsList != null) {
      orderDetailsContent = Column(
        children: [
          ..._orderDetailsList!
              .map((e) => Material(
                    borderRadius: BorderRadius.circular(10.0),
                    child: ListTile(
                      title: Text(e.menuItem.name),
                      subtitle: Text(e.specialInstruction.toString()),
                      trailing: Transform.translate(
                        offset: const Offset(0, 24),
                        child: Text('Quantity: ${e.quantity}',
                            style: const TextStyle(fontSize: 13)),
                      ),
                      onTap: () {},
                      isThreeLine: true,
                    ),
                  ))
              .toList(),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.order.merchant.name,
          style: const TextStyle(color: KColors.kPrimaryColor),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        width: double.infinity,
        color: KColors.kPrimaryColor.withOpacity(0.5),
        child: ListView(
          children: [
            //Order status

            Text(
              'Status',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: KColors.kLightTextColor,
                    fontSize: 22,
                  ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: KColors.kOnBackgroundColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      orderStatusInfo,
                      style: TextStyle(
                          color:
                              orderServices.getOrderColor(widget.order.status),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (isCancelled)
                    ListTile(
                      title: const Text('Cancelled By:'),
                      subtitle: Text(widget.order.cancelledBy.toString()),
                    ),
                  if (isCancelled)
                    ListTile(
                      title: const Text('Reason:'),
                      subtitle:
                          Text(widget.order.cancellationReason ?? 'Unknown'),
                    ),
                ],
              ),
            ),
            //Customer
            const SizedBox(height: 20),
            Text(
              'Customer',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: KColors.kLightTextColor,
                    fontSize: 22,
                  ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: KColors.kOnBackgroundColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.order.customer.lastName} ${widget.order.customer.middleName} ${widget.order.customer.firstName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        RatingBarIndicator(
                          rating: widget.order.customer.rating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 20.0,
                          direction: Axis.horizontal,
                        ),
                      ],
                    ),
                    trailing: Transform.translate(
                      offset: const Offset(10, 2),
                      child: RatingButton(
                        onButtonPressed: () {
                          _navigateToRatingScreen(
                              fromUserType: UserType.Merchant,
                              toUserType: UserType.Customer,
                              order: widget.order);
                        },
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: Text(widget.order.customer.phoneNumber),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(widget.order.customer.email),
                  ),
                  ListTile(
                    leading: const Icon(Icons.check_circle),
                    title: Text(
                        '${widget.order.customer.successOrderCount} order(s) / ${widget.order.customer.cancelledOrderCount + widget.order.customer.successOrderCount} order(s)'),
                  ),
                ],
              ),
            ),
            //Shipper
            const SizedBox(height: 20),
            Text(
              'Shipper',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: KColors.kLightTextColor,
                    fontSize: 22,
                  ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: KColors.kOnBackgroundColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.order.shipper.lastName} ${widget.order.shipper.middleName} ${widget.order.shipper.firstName}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        RatingBarIndicator(
                          rating: widget.order.shipper.rating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 20.0,
                          direction: Axis.horizontal,
                        ),
                      ],
                    ),
                    trailing: Transform.translate(
                      offset: const Offset(10, 2),
                      child: RatingButton(
                        onButtonPressed: () {
                          _navigateToRatingScreen(
                              fromUserType: UserType.Merchant,
                              toUserType: UserType.Shipper,
                              order: widget.order);
                        },
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.two_wheeler),
                    title: Text(
                      widget.order.shipper.vehicleNumberPlate,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(widget.order.shipper.vehicleType),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: Text(widget.order.shipper.phoneNumber),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(widget.order.shipper.email),
                  ),
                  ListTile(
                    leading: const Icon(Icons.check_circle),
                    title: Text(
                        '${widget.order.shipper.successOrderCount} order(s) / ${widget.order.shipper.cancelledOrderCount + widget.order.shipper.successOrderCount} order(s)'),
                  ),
                ],
              ),
            ),
            //Order details
            const SizedBox(height: 20),
            Text(
              'Order Details',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: KColors.kLightTextColor,
                    fontSize: 22,
                  ),
            ),
            const SizedBox(height: 10),
            Container(
              height: _orderDetailsList == null ? 80 : null,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: KColors.kOnBackgroundColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: orderDetailsContent,
            ),
            //Order info
            const SizedBox(height: 20),
            Text(
              'Order Info',
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: KColors.kLightTextColor,
                    fontSize: 22,
                  ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: KColors.kOnBackgroundColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal Price:'),
                        Text(widget.order.orderPrice.toStringAsFixed(1)),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('App Fee:'),
                        Text(widget.order.appFee.toStringAsFixed(1)),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Shipping Fee:'),
                        Text(widget.order.shippingFee.toStringAsFixed(1)),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Promotion Discount:'),
                        Text(
                            '-${widget.order.promotionDiscount.toStringAsFixed(1)}'),
                      ],
                    ),
                  ),
                  const Divider(thickness: 1.0, color: KColors.kTextColor),
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Price:'),
                        Text(totalPrice.toStringAsFixed(1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (isAbleToCancel) const SizedBox(height: 10),
            if (isAbleToCancel) const SizedBox(height: 20),
            if (isAbleToCancel)
              ElevatedButton(
                  onPressed: () {
                    _showCancellationBottomSheet(context, widget.order);
                  },
                  child: const Text('Cancel Order')),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
