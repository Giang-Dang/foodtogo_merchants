import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/dto/update_dto/user_update_dto.dart';
import 'package:foodtogo_merchants/models/dto/user_dto.dart';
import 'package:foodtogo_merchants/screens/change_account_info_screen.dart';
import 'package:foodtogo_merchants/screens/login_screen.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';

class Me extends ConsumerStatefulWidget {
  const Me({Key? key}) : super(key: key);

  @override
  ConsumerState<Me> createState() => _MeState();
}

class _MeState extends ConsumerState<Me> {
  UserDTO? _user;

  _loadUserInfo() async {
    final userServices = UserServices();
    int userId = int.parse(UserServices.strUserId);
    var userDTO = await userServices.get(userId);

    if (userDTO == null) {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
      return;
    }

    setState(() {
      _user = userDTO;
    });
  }

  _onTapChangeUserInfoPressed() async {
    if (_user != null) {
      UserUpdateDTO? userUpdateDTO = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChangeAccountInfoScreen(
            userDTO: _user!,
          ),
        ),
      );
      if (userUpdateDTO != null) {
        setState(() {
          _user = UserDTO(
            id: _user!.id,
            username: _user!.username,
            role: _user!.role,
            phoneNumber: userUpdateDTO.phoneNumber,
            email: userUpdateDTO.email,
          );
        });
      }
    }
  }

  _logout() {
    final userServices = UserServices();

    userServices.deleteStoredLoginInfo();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    Widget contain = const Center(
      child: CircularProgressIndicator(),
    );

    if (_user != null) {
      contain = Container(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
        width: double.infinity,
        color: KColors.kBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi,',
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: KColors.kTextColor,
                        fontSize: 34,
                      ),
                ),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: KColors.kLightTextColor,
                        ),
                    children: [
                      TextSpan(
                        text: _user!.username,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: KColors.kPrimaryColor,
                              fontSize: 30,
                            ),
                      ),
                      TextSpan(
                        text: ' !',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: KColors.kTextColor,
                              fontSize: 34,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: ListView(
                  children: [
                    Text(
                      'About you:',
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: KColors.kLightTextColor,
                            fontSize: 22,
                          ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: KColors.kOnBackgroundColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.phone),
                            title: Text(_user!.phoneNumber),
                          ),
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: Text(_user!.email),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Account:',
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: KColors.kLightTextColor,
                            fontSize: 22,
                          ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        children: [
                          Material(
                            elevation: 3,
                            borderRadius: BorderRadius.circular(10.0),
                            color: KColors.kOnBackgroundColor,
                            child: ListTile(
                              leading: const Icon(
                                Icons.phone,
                                color: KColors.kPrimaryColor,
                              ),
                              title: const Text('Change your account info'),
                              onTap: () {
                                _onTapChangeUserInfoPressed();
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Material(
                            elevation: 3,
                            borderRadius: BorderRadius.circular(10.0),
                            child: ListTile(
                              leading: const Icon(
                                Icons.logout,
                                color: KColors.kPrimaryColor,
                              ),
                              title: const Text(
                                'Log out',
                                style: TextStyle(color: KColors.kPrimaryColor),
                              ),
                              onTap: _logout,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    return contain;
  }
}
