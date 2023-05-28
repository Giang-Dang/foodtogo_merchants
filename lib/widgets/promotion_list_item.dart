import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:foodtogo_merchants/models/enum/promotion_status.dart';
import 'package:foodtogo_merchants/models/promotion.dart';
import 'package:foodtogo_merchants/screens/promotion_details_screen.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';

class PromotionListItem extends StatefulWidget {
  const PromotionListItem({
    Key? key,
    required this.promotion,
  }) : super(key: key);

  final Promotion promotion;

  @override
  State<PromotionListItem> createState() => _PromotionListItemState();
}

class _PromotionListItemState extends State<PromotionListItem> {
  final jwtToken = UserServices.jwtToken;
  Promotion? _promotion;

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

  Color _getTitleColor(PromotionStatus promotionStatus) {
    if (promotionStatus == PromotionStatus.active) {
      return KColors.kSuccessColor;
    }
    if (promotionStatus == PromotionStatus.notyet) {
      return KColors.kDanger;
    }
    if (promotionStatus == PromotionStatus.passed) {
      return KColors.kLightTextColor;
    }
    return KColors.kLightTextColor;
  }

  String _getPrefixString(PromotionStatus promotionStatus) {
    if (promotionStatus == PromotionStatus.active) {
      return '[Ongoing] ';
    }
    if (promotionStatus == PromotionStatus.notyet) {
      return '[Not yet] ';
    }
    if (promotionStatus == PromotionStatus.passed) {
      return '[Passed] ';
    }
    return '[Passed] ';
  }

  _onTapListTile(Promotion promotion) async {
    if (context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PromotionDetailsScreen(promotion: promotion),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _promotion = widget.promotion;

    Widget content = const ListTile(
      leading: CircularProgressIndicator(),
      title: Text('Loading...'),
    );

    if (_promotion != null) {
      final promotionStatus = _getPromotionStatus(_promotion!);
      final titleColor = _getTitleColor(promotionStatus);

      content = Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: KColors.kOnBackgroundColor,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: ListTile(
            onTap: () {
              _onTapListTile(_promotion!);
            },
            title: Text(
              _getPrefixString(promotionStatus) + _promotion!.name,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: titleColor,
                  ),
            ),
            subtitle: Text(
              _promotion!.description,
              overflow: TextOverflow.ellipsis,
            ),
            isThreeLine: false,
          ),
        ),
      );
    }

    return content;
  }
}
