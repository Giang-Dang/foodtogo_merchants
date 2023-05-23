import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodtogo_merchants/models/place_location.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/widgets/location_input.dart';

class MerchantRegisterScreen extends StatefulWidget {
  const MerchantRegisterScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MerchantRegisterScreenState();
  }
}

class _MerchantRegisterScreenState extends State<MerchantRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  File? _selectedImage;
  PlaceLocation? _selectedLocation;

  bool _isValidUsername(String? username) {
    if (username == null) {
      return false;
    }
    return username.length >= 4 && username.length <= 50;
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
          key: _formKey,
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
                        label: Text('Enter your username'),
                      ),
                      controller: _nameController,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            _isValidUsername(value)) {
                          return 'Invalid username. Usernames must be between 4 and 20 characters long and can only contain letters, numbers, and underscores.';
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
              LocationInput(
                onSelectLocation: (location) {
                  _selectedLocation = location;
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Create'),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
