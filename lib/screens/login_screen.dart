import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:foodtogo_merchants/models/dto/login_request_dto.dart';
import 'package:foodtogo_merchants/models/enum/login_from_app.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final UserServices _userServices = UserServices();

  late bool _isPasswordObscured;

  bool _login() {
    var loginRequestDTO = LoginRequestDTO(
      username: _usernameController.text,
      password: _passwordController.text,
      loginFromApp: LoginFromApp.Merchant.name,
    );
    _userServices.login(loginRequestDTO);
    return true;
  }

  @override
  void initState() {
    super.initState();
    _isPasswordObscured = true;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(40, 60, 40, 0),
      child: Form(
        child: Column(
          children: [
            Text(
              'Log In',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: KColors.kPrimaryColor,
                    fontSize: 30,
                  ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person,
                  size: 30,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    maxLength: 20,
                    decoration: const InputDecoration(
                      label: Text('Enter your username.'),
                    ),
                    controller: _usernameController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock,
                  size: 30,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    obscureText: _isPasswordObscured,
                    decoration: InputDecoration(
                      label: const Text('Enter your password.'),
                      suffixIcon: IconButton(
                        icon: _isPasswordObscured
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isPasswordObscured = !_isPasswordObscured;
                          });
                        },
                      ),
                    ),
                    controller: _passwordController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: KColors.kLightTextColor,
                    ),
                children: [
                  const TextSpan(text: 'Click '),
                  TextSpan(
                    text: ' here ',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        print('navigate to register page');
                      },
                  ),
                  const TextSpan(text: ' to register.'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
