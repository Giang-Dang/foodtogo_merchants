import 'package:flutter/widgets.dart';
import 'package:foodtogo_merchants/models/merchant.dart';

class MerchantWidget extends StatefulWidget {
  const MerchantWidget({
    Key? key,
    required this.merchant,
  }) : super(key: key);

  final Merchant merchant;

  @override
  State<MerchantWidget> createState() => _MerchantWidgetState();
}

class _MerchantWidgetState extends State<MerchantWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
