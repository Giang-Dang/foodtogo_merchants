import 'package:flutter/material.dart';
import 'package:foodtogo_merchants/models/dto/update_dto/user_update_dto.dart';
import 'package:foodtogo_merchants/models/dto/user_dto.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';

class ChangeAccountInfoScreen extends StatefulWidget {
  const ChangeAccountInfoScreen({
    Key? key,
    required this.userDTO,
  }) : super(key: key);

  final UserDTO userDTO;
  @override
  State<ChangeAccountInfoScreen> createState() =>
      _ChangeAccountInfoScreenState();
}

class _ChangeAccountInfoScreenState extends State<ChangeAccountInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  UserDTO? _user;

  _showAlertDialog(String title, String message, void Function() onOkPressed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                onOkPressed();
              },
            ),
          ],
        );
      },
    );
  }

  bool _isValidEmail(String? email) {
    RegExp validRegex = RegExp(
        r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z]{2,})+');
    if (email == null) {
      return false;
    }
    return validRegex.hasMatch(email);
  }

  bool _isValidPhoneNumber(String? phoneNumber) {
    // Regular expression pattern to match valid phone numbers
    String pattern =
        r'^(0|\+84)(3[2-9]|5[689]|7[06-9]|8[1-6]|9[0-46-9])[0-9]{7}$|^(0|\+84)(2[0-9]{1}|[3-9]{1})[0-9]{8}$';
    RegExp regExp = RegExp(pattern);

    if (phoneNumber == null) {
      return false;
    }
    // Check if the phone number matches the pattern
    if (regExp.hasMatch(phoneNumber)) {
      return true;
    } else {
      return false;
    }
  }

  _onSavePressed() async {
    if (_formKey.currentState!.validate()) {
      final userServices = UserServices();
      final userUpdateDTO = UserUpdateDTO(
        id: _user!.id,
        phoneNumber: _phoneNumberController.text,
        email: _emailController.text,
      );

      final isSuccess = await userServices.update(_user!.id, userUpdateDTO);

      if (!isSuccess) {
        _showAlertDialog(
          'Sorry',
          'Unable to update your merchant at the moment. Please try again at a later time.',
          () {
            Navigator.of(context).pop();
          },
        );
      }

      _showAlertDialog(
        'Success',
        'We have successfully updated your merchant.',
        () {
          Navigator.pop(context);
          Navigator.pop(context, userUpdateDTO);
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _user = widget.userDTO;
    _phoneNumberController.text = _user!.phoneNumber;
    _emailController.text = _user!.email;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: KColors.kPrimaryColor,
        foregroundColor: KColors.kOnBackgroundColor,
        title: const Text('FoodToGo - Merchants'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 80,
              color: KColors.kPrimaryColor,
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(
                'Edit your profile',
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: KColors.kOnBackgroundColor,
                      fontSize: 34,
                    ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(35, 15, 40, 30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 27,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Enter your new phone number'),
                            ),
                            keyboardType: TextInputType.phone,
                            controller: _phoneNumberController,
                            validator: (value) {
                              if (_isValidPhoneNumber(value)) {
                                return null;
                              }
                              return 'Please enter a valid phone number.';
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.email,
                          size: 27,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Enter your new email'),
                            ),
                            controller: _emailController,
                            validator: (value) {
                              if (_isValidEmail(value)) {
                                return null;
                              }
                              return 'Please enter a valid email.';
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        _onSavePressed();
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
