import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/enum/promotion_status.dart';
import 'package:foodtogo_merchants/models/merchant.dart';
import 'package:foodtogo_merchants/models/promotion.dart';
import 'package:foodtogo_merchants/providers/promotions_list_provider.dart';
import 'package:foodtogo_merchants/services/promotion_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/widgets/promotion_list_item.dart';

class PromotionList extends ConsumerStatefulWidget {
  const PromotionList({
    Key? key,
    required this.merchant,
  }) : super(key: key);

  final Merchant merchant;

  @override
  ConsumerState<PromotionList> createState() => _PromotionListState();
}

class _PromotionListState extends ConsumerState<PromotionList> {
  List<Promotion> _promotionsList = [];
  Timer? _initTimer;

  _updatePromotionsList() async {
    final promotionServices = PromotionServices();
    final promotionsList =
        await promotionServices.getAll(widget.merchant.merchantId);
    if (mounted) {
      setState(() {
        _promotionsList = promotionsList ?? [];
      });
    }
  }

  PromotionStatus _getPromotionStatus(Promotion promotion) {
    final now = DateTime.now();
    if (promotion.startDate.isBefore(now) && promotion.endDate.isAfter(now)) {
      return PromotionStatus.active;
    }
    if (promotion.startDate.isAfter(now)) {
      return PromotionStatus.notyet;
    }
    return PromotionStatus.passed;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _updatePromotionsList();
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
    _promotionsList.sort((a, b) {
      return _getPromotionStatus(a).index - _getPromotionStatus(b).index;
    });

    if (widget.merchant.isDeleted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'This merchant has been deleted.',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: 18,
                  ),
            ),
          ],
        ),
      );
    }

    Widget content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'You do not have any promotion.',
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

    if (_promotionsList.isNotEmpty) {
      content = Container(
        color: KColors.kBackgroundColor,
        child: ListView.builder(
          itemCount: _promotionsList.length,
          itemBuilder: (context, index) =>
              PromotionListItem(promotion: _promotionsList[index]),
        ),
      );
    }
    return content;
  }
}
