import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/providers/merchants_provider.dart';

class MerchantsList extends ConsumerStatefulWidget {
  const MerchantsList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MechantWidgetState();
  }
}

class _MechantWidgetState extends ConsumerState<MerchantsList> {
  @override
  Widget build(BuildContext context) {
    final merchantList = ref.watch(merchantProvider);
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

    if (merchantList.isNotEmpty) {
      content = ListView.builder(
        itemCount: merchantList.length,
        itemBuilder: (context, index) => Text(merchantList[index].name),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: content,
    );
  }
}
