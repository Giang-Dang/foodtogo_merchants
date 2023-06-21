import 'package:flutter/material.dart';
import 'package:foodtogo_merchants/models/enum/promotion_status.dart';
import 'package:foodtogo_merchants/models/promotion.dart';
import 'package:foodtogo_merchants/screens/promotion_details_screen.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';

class PromotionListItem extends StatelessWidget {
  const PromotionListItem({
    Key? key,
    required this.promotion,
  }) : super(key: key);

  final Promotion promotion;

  PromotionStatus _getPromotionStatus(Promotion promotion) {
    final now = DateTime.now();
    if (promotion.startDate.isBefore(now) && promotion.endDate.isAfter(now)) {
      return PromotionStatus.active;
    }
    if (promotion.endDate.year == now.year &&
        promotion.endDate.month == now.month &&
        promotion.endDate.day == now.day) {
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

  _onTapListTile(BuildContext context, Promotion promotion) async {
    if (context.mounted) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PromotionDetailsScreen(promotion: promotion),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final promotionStatus = _getPromotionStatus(promotion);
    final titleColor = _getTitleColor(promotionStatus);

    return Container(
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
            _onTapListTile(context, promotion);
          },
          title: Text(
            _getPrefixString(promotionStatus) + promotion.name,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: titleColor,
                ),
          ),
          subtitle: Text(
            promotion.description,
            overflow: TextOverflow.ellipsis,
          ),
          isThreeLine: false,
        ),
      ),
    );
  }
}
