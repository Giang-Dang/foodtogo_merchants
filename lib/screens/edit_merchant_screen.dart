import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/dto/update_dto/merchant_profile_image_update_dto.dart';
import 'package:foodtogo_merchants/models/dto/update_dto/merchant_update_dto.dart';
import 'package:foodtogo_merchants/models/merchant.dart';
import 'package:foodtogo_merchants/models/place_location.dart';
import 'package:foodtogo_merchants/providers/merchants_list_provider.dart';
import 'package:foodtogo_merchants/services/file_services.dart';
import 'package:foodtogo_merchants/services/merchant_profile_image_services.dart';
import 'package:foodtogo_merchants/services/merchant_services.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/settings/secrets.dart';
import 'package:foodtogo_merchants/widgets/image_input.dart';
import 'package:foodtogo_merchants/widgets/location_input.dart';
import 'package:path/path.dart' as path;
import 'package:transparent_image/transparent_image.dart';

class EditMerchantScreen extends ConsumerStatefulWidget {
  const EditMerchantScreen({
    Key? key,
    required this.merchant,
  }) : super(key: key);

  final Merchant merchant;

  @override
  ConsumerState<EditMerchantScreen> createState() => _EditMerchantScreenState();
}

class _EditMerchantScreenState extends ConsumerState<EditMerchantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  File? _selectedImage;
  PlaceLocation? _selectedLocation;

  bool _isUpdating = false;

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

  _initialUpdate(Merchant merchant) async {
    final FileServices fileServices = FileServices();
    final imageFile = await fileServices.getImage(merchant.imagePath);
    if (mounted) {
      setState(() {
        _selectedImage = imageFile;
        _selectedLocation = PlaceLocation(
            latitude: merchant.geoLatitude,
            longitude: merchant.geoLongitude,
            address: merchant.address);
      });
    }
  }

  _onEditPressed(Merchant merchant) async {
    if (_formKey.currentState!.validate()) {
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
      final merchantProfileImageServices = MerchantProfileImageServices();

      final userId = int.parse((await userServices.getStoredUserId())!);
      final updateDTO = MerchantUpdateDTO(
        merchantId: merchant.merchantId,
        userId: userId,
        name: _nameController.text,
        address: _selectedLocation!.address,
        phoneNumber: _phoneNumberController.text,
        geoLatitude: _selectedLocation!.latitude,
        geoLongitude: _selectedLocation!.longitude,
        isDeleted: false,
      );

      if (mounted) {
        setState(() {
          _isUpdating = true;
        });
      }

      bool isUpdateSuccess =
          await merchantServices.update(updateDTO, merchant.merchantId);

      final originalImageDTO = await merchantProfileImageServices
          .getByMerchantId(merchant.merchantId);

      if (path.basename(_selectedImage!.path) !=
          path.basename(originalImageDTO!.path)) {
        final fileServices = FileServices();
        final newFilePath = await fileServices.uploadImage(_selectedImage!);

        final updateDTO = MerchantProfileImageUpdateDTO(
            id: originalImageDTO.id,
            merchantId: originalImageDTO.merchantId,
            path: newFilePath);

        final isSuccessUpdateImagePath = await merchantProfileImageServices
            .update(updateDTO, originalImageDTO.id);

        if (!isSuccessUpdateImagePath) {
          log('_EditMerchantScreenState._onEditPressed() isSuccessUpdateImagePath == false');
          isUpdateSuccess = false;
        }
      }

      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }

      if (!isUpdateSuccess) {
        _showAlertDialog(
          'Sorry',
          'Unable to update your merchant at the moment. Please try again at a later time.',
          () {
            Navigator.of(context).pop();
          },
        );

        _initialUpdate(merchant);

        return;
      }

      final merchantsList = await merchantServices.getAllMerchantsFromUser();

      if (mounted) {
        ref
            .watch(merchantsListProvider.notifier)
            .updateMerchants(merchantsList);
      }

      _showAlertDialog(
        'Success',
        'We have successfully updated your merchant.',
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
    _nameController.text = widget.merchant.name;
    _phoneNumberController.text = widget.merchant.phoneNumber;
    _initialUpdate(widget.merchant);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jwtToken = UserServices.jwtToken;
    final imageUrl =
        Uri.http(Secrets.kFoodToGoAPILink, widget.merchant.imagePath)
            .toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.merchant.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(35, 15, 40, 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Edit Your Merchant',
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
              const Divider(thickness: 1.0, color: KColors.kPrimaryColor),
              const SizedBox(height: 10),
              const SizedBox(
                  width: double.infinity, child: Text('Current Dish Picture:')),
              const SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                  width: 1,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                )),
                height: 170,
                width: double.infinity,
                alignment: Alignment.center,
                child: FadeInImage(
                  placeholder: MemoryImage(kTransparentImage),
                  image: NetworkImage(imageUrl, headers: {
                    'Authorization': 'Bearer $jwtToken',
                  }),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(
                  width: double.infinity, child: Text('New Dish Picture:')),
              const SizedBox(height: 5),
              ImageInput(
                onPickImage: (image) {
                  _selectedImage = image;
                },
              ),
              const SizedBox(height: 10),
              const Divider(thickness: 1.0, color: KColors.kPrimaryColor),
              const SizedBox(height: 10),
              const SizedBox(
                  width: double.infinity, child: Text('Current Location:')),
              const SizedBox(height: 10),
              SizedBox(
                  width: double.infinity,
                  child: Text(
                    widget.merchant.address,
                    style: const TextStyle(color: KColors.kLightTextColor),
                  )),
              const SizedBox(height: 10),
              LocationInput(
                onSelectLocation: (location) {
                  _selectedLocation = location;
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _onEditPressed(widget.merchant);
                },
                child: _isUpdating
                    ? const CircularProgressIndicator()
                    : const Text('Edit'),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
