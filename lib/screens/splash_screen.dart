import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/merchant.dart';
import 'package:foodtogo_merchants/models/promotion.dart';
import 'package:foodtogo_merchants/providers/merchants_list_provider.dart';
import 'package:foodtogo_merchants/providers/promotions_list_provider.dart';
import 'package:foodtogo_merchants/screens/login_screen.dart';
import 'package:foodtogo_merchants/screens/tabs_screen.dart';
import 'package:foodtogo_merchants/services/merchant_services.dart';
import 'package:foodtogo_merchants/services/promotion_services.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _textAnimationController;
  late Animation<double> _textAnimation;
  Timer? _loginTimer;

  _login() async {
    //delay for animation
    await _delay(1);
    //loading data
    final userServices = UserServices();
    final merchantServices = MerchantServices();
    final promotionServices = PromotionServices();

    await userServices.checkLocalLoginAuthorized();
    List<Merchant>? merchantList;
    List<Promotion>? promotionsList;
    if (UserServices.isAuthorized) {
      merchantList = await merchantServices.getAllMerchantsFromUser();
      promotionsList =
          await promotionServices.getAll(int.parse(UserServices.strUserId));

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TabsScreen(),
          ),
        );
      }
    } else {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    }
    if (merchantList != null) {
      ref.watch(merchantsListProvider.notifier).updateMerchants(merchantList);
    }
    if (promotionsList != null) {
      ref.watch(promotionsListProvider.notifier).update(promotionsList);
    }
  }

  _delay(int seconds) async {
    await Future.delayed(Duration(seconds: seconds));
  }

  @override
  void initState() {
    super.initState();
    //animation
    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _textAnimation =
        Tween(begin: 0.0, end: 1.0).animate(_textAnimationController);

    //login
    _loginTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) {
        _login();
        _loginTimer?.cancel();
      },
    );
  }

  @override
  void dispose() {
    _textAnimationController.dispose();
    _loginTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodToGo - Merchants'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Welcome',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: KColors.kPrimaryColor,
                    fontSize: 35,
                  ),
            ),
            const SizedBox(height: 80),
            Image.asset(
              'assets/images/pizza_loading.gif',
              height: 80,
              width: 80,
            ),
            const SizedBox(height: 15),
            AnimatedBuilder(
              animation: _textAnimation,
              builder: (context, child) {
                if (_textAnimation.value < 0.25) {
                  return SizedBox(
                    width: 90,
                    child: Text(
                      'Loading',
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 20,
                          ),
                    ),
                  );
                } else if (_textAnimation.value >= 0.25 &&
                    _textAnimation.value < 0.5) {
                  return SizedBox(
                    width: 90,
                    child: Text(
                      'Loading.',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 20,
                          ),
                    ),
                  );
                } else if (_textAnimation.value >= 0.5 &&
                    _textAnimation.value < 0.75) {
                  return SizedBox(
                    width: 90,
                    child: Text(
                      'Loading..',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 20,
                          ),
                    ),
                  );
                } else {
                  return SizedBox(
                    width: 90,
                    child: Text(
                      'Loading...',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 20,
                          ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 60)
          ],
        ),
      ),
    );
  }
}
