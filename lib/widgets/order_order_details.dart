import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodtogo_merchants/models/order.dart';
import 'package:foodtogo_merchants/models/order_detail.dart';
import 'package:foodtogo_merchants/services/order_detail_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';

class OrderOrderDetails extends StatefulWidget {
  const OrderOrderDetails({
    Key? key,
    required this.order,
  }) : super(key: key);

  final Order order;

  @override
  State<OrderOrderDetails> createState() => _OrderOrderDetailsState();
}

class _OrderOrderDetailsState extends State<OrderOrderDetails> {
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

    return Column(
      children: [
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
      ],
    );
  }
}
