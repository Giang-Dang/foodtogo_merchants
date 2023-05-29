import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/dto/merchant_dto.dart';
import 'package:foodtogo_merchants/models/merchant.dart';
import 'package:foodtogo_merchants/providers/merchants_list_provider.dart';
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
  late List<Merchant> _merchantsList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _merchantsList = ref.watch(merchantsListProvider);
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

    if (_merchantsList.isNotEmpty) {
      content = Container(
        color: KColors.kBackgroundColor,
        child: ListView.builder(
          itemCount: _merchantsList.length,
          itemBuilder: (context, index) =>
              MerchantListItem(merchant: _merchantsList[index]),
        ),
      );
    }
    return content;
  }
}
