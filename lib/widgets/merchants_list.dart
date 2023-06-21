import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/merchant.dart';
import 'package:foodtogo_merchants/services/merchant_services.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/widgets/merchant_list_item.dart';

class MerchantsList extends ConsumerStatefulWidget {
  const MerchantsList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MechantWidgetState();
  }
}

class _MechantWidgetState extends ConsumerState<MerchantsList> {
  List<Merchant> _merchantList = [];

  Timer? _initTimer;

  _getMerchantList() async {
    final merchantServices = MerchantServices();

    final merchantList = await merchantServices.getAll(
        searchUserId: int.tryParse(UserServices.strUserId));
    
    if (mounted) {
      setState(() {
        _merchantList = merchantList;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _getMerchantList();
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
    Widget content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'You do not have any merchant.',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 18,
                ),
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            "Try to create one by clicking '+' button.",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 14,
                ),
          ),
        ],
      ),
    );

    if (_merchantList.isNotEmpty) {
      content = Container(
        color: KColors.kBackgroundColor,
        child: ListView.builder(
          itemCount: _merchantList.length,
          itemBuilder: (context, index) =>
              MerchantListItem(merchant: _merchantList[index]),
        ),
      );
    }
    return content;
  }
}
