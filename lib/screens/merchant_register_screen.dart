import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/dto/create_dto/merchant_create_dto.dart';
import 'package:foodtogo_merchants/models/place_location.dart';
import 'package:foodtogo_merchants/providers/merchants_list_provider.dart';
import 'package:foodtogo_merchants/services/merchant_services.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/widgets/image_input.dart';
import 'package:foodtogo_merchants/widgets/location_input.dart';

class MerchantRegisterScreen extends ConsumerStatefulWidget {
  const MerchantRegisterScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MerchantRegisterScreenState();
  }
}

class _MerchantRegisterScreenState
    extends ConsumerState<MerchantRegisterScreen> {
  final _formMerchantRegisterKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  File? _selectedImage;
  PlaceLocation? _selectedLocation;

  bool _isCreating = false;

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

  bool _isValidMerchantName(String? username) {
    if (username == null) {
      return false;
    }
    return username.length >= 4 && username.length <= 50;
  }

  _onCreatePressed() async {
    if (_formMerchantRegisterKey.currentState!.validate()) {
      if (_selectedImage == null || _selectedLocation == null) {
        _showAlertDialog(
          'Alert',
          'Please select a location and a profile picture for the merchant',
          () {
            Navigator.of(context).pop();
          },
        );
        return;
      }

      final userServices = UserServices();
      final merchantServices = MerchantServices();
      final userId = int.parse((await userServices.getStoredUserId())!);
      final createDTO = MerchantCreateDTO(
        merchantId: 0,
        userId: userId,
        name: _nameController.text,
        address: _selectedLocation!.address,
        phoneNumber: _phoneNumberController.text,
        geoLatitude: _selectedLocation!.latitude,
        geoLongitude: _selectedLocation!.longitude,
      );

      setState(() {
        _isCreating = true;
      });

      bool isCreateSuccess =
          await merchantServices.create(createDTO, _selectedImage!);

      setState(() {
        _isCreating = false;
      });

      if (!isCreateSuccess) {
        _showAlertDialog(
          'Sorry',
          'Unable to create your merchant at the moment. Please try again at a later time.',
          () {
            Navigator.of(context).pop();
          },
        );
        setState(() {
          _selectedImage = null;
          _selectedLocation = null;
        });
        return;
      }

      final merchantsList = await merchantServices.getAllMerchantsFromUser();

      ref.watch(merchantsListProvider.notifier).updateMerchants(merchantsList);

      _showAlertDialog(
        'Success',
        'We have successfully created your merchant.',
        () {
          Navigator.pop(context);
          Navigator.pop(context);
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
    _nameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodToGo - Merchants'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(35, 15, 40, 30),
        child: Form(
          key: _formMerchantRegisterKey,
          child: Column(
            children: [
              Text(
                'Create New Merchant',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: KColors.kPrimaryColor,
                      fontSize: 30,
                    ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person,
                    size: 27,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Enter your merchant name'),
                      ),
                      controller: _nameController,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !_isValidMerchantName(value)) {
                          return 'The merchant name is invalid.';
                        }
                        return null;
                      },
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
                    Icons.phone,
                    size: 27,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        label: Text('Enter your phone number'),
                      ),
                      controller: _phoneNumberController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ImageInput(
                onPickImage: (image) {
                  _selectedImage = image;
                },
              ),
              const SizedBox(height: 10),
              LocationInput(
                onSelectLocation: (location) {
                  _selectedLocation = location;
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _onCreatePressed();
                },
                child: _isCreating
                    ? const CircularProgressIndicator()
                    : const Text('Create'),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
