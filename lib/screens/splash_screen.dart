import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/dto/merchant_dto.dart';
import 'package:foodtogo_merchants/providers/merchants_provider.dart';
import 'package:foodtogo_merchants/screens/login_screen.dart';
import 'package:foodtogo_merchants/screens/tabs_screen.dart';
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

  _login() async {
    //delay for animation
    await _delay(3);
    //loading data
    var userServices = UserServices();
    await userServices.checkLocalLoginAuthorized();
    List<MerchantDTO>? merchantList;
    if (UserServices.isAuthorized) {
      merchantList = await userServices.getMerchantList();
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TabsScreen(),
          ),
        );
      }
    } else {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      }
    }
    if (merchantList != null) {
      ref.read(merchantProvider.notifier).updateMerchants(merchantList);
    }
    // inspect(merchantList);
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
    _login();
  }

  @override
  void dispose() {
    _textAnimationController.dispose();
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
