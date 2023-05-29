import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodtogo_merchants/models/order.dart';
import 'package:foodtogo_merchants/models/order_detail.dart';
import 'package:foodtogo_merchants/services/order_detail_services.dart';
import 'package:foodtogo_merchants/services/order_services.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:intl/intl.dart';

final dateFormatter = DateFormat.yMMMMd();

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  final Order order;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  List<OrderDetail>? _orderDetailsList;
  Timer? _initTimer;

  _getOrderDetailsList() async {
    final OrderDetailServices orderDetailServices = OrderDetailServices();
    final orderDetailsList =
        await orderDetailServices.getAll(searchOrderId: widget.order.id);

    if (orderDetailsList != null) {
      if (mounted) {
        setState(() {
          _orderDetailsList = orderDetailsList;
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                    title: const Text('Order Price:'),
                    subtitle: Text(widget.order.orderPrice.toStringAsFixed(1)),
                  ),
                  ListTile(
                    title: const Text('App Fee:'),
                    subtitle: Text(widget.order.appFee.toStringAsFixed(1)),
                  ),
                  ListTile(
                    title: const Text('Promotion Discount:'),
                    subtitle: Text(
                        '-${widget.order.promotionDiscount.toStringAsFixed(1)}'),
                  ),
                  ListTile(
                    title: const Text('Shipping Fee:'),
                    subtitle: Text(widget.order.shippingFee.toStringAsFixed(1)),
                  ),
                  const Divider(thickness: 1.0, color: KColors.kTextColor),
                  ListTile(
                    title: const Text('Total Price:'),
                    subtitle: Text(totalPrice.toStringAsFixed(1)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
