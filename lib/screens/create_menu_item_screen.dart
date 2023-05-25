import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/dto/create_dto/menu_item_create_dto.dart';
import 'package:foodtogo_merchants/models/dto/menu_item_type_dto.dart';
import 'package:foodtogo_merchants/models/merchant.dart';
import 'package:foodtogo_merchants/providers/menu_item_list_provider.dart';
import 'package:foodtogo_merchants/services/menu_item_services.dart';
import 'package:foodtogo_merchants/services/menu_item_type_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/widgets/image_input.dart';

class CreateMenuItemScreen extends ConsumerStatefulWidget {
  const CreateMenuItemScreen({
    Key? key,
    required this.merchant,
  }) : super(key: key);

  final Merchant merchant;

  @override
  ConsumerState<CreateMenuItemScreen> createState() =>
      _CreateMenuItemScreenState();
}

class _CreateMenuItemScreenState extends ConsumerState<CreateMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  File? _selectedImage;
  List<MenuItemTypeDTO>? _typesList;
  int _dropdownValue = 1;

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

  bool _isValidDishName(String? username) {
    if (username == null) {
      return false;
    }
    return username.length >= 4 && username.length <= 50;
  }

  _loadTypes() async {
    final menuItemTypeServices = MenuItemTypeServices();

    final typesList = await menuItemTypeServices.getAll();

    setState(() {
      _typesList = typesList;
    });
  }

  _onCreatePressed(Merchant merchant, File? image) async {
    if (_formKey.currentState!.validate()) {
      if (image == null) {
        _showAlertDialog(
          'Alert',
          'Please take a picture for your dish.',
          () {
            Navigator.of(context).pop();
          },
        );
        return;
      }
      final menuItemServices = MenuItemServices();

      final createDTO = MenuItemCreateDTO(
        id: 0,
        merchantId: merchant.merchantId,
        itemTypeId: _dropdownValue,
        name: _nameController.text,
        description: _descriptionController.text,
        unitPrice: double.parse(_priceController.text),
      );

      setState(() {
        _isCreating = true;
      });

      bool isCreateSuccess = await menuItemServices.create(createDTO, image);

      var menuItemsList =
          await menuItemServices.getAllMenuItems(merchant.merchantId);

      setState(() {
        _isCreating = false;
      });

      if (!isCreateSuccess || menuItemsList == null) {
        _showAlertDialog(
          'Sorry',
          'Unable to create your dish at the moment. Please try again at a later time.',
          () {
            Navigator.of(context).pop();
          },
        );

        setState(() {
          _selectedImage = null;
        });
        return;
      }

      ref
          .watch(menuItemsListProvider.notifier)
          .updateMenuItemsList(menuItemsList);

      _showAlertDialog(
        'Success',
        'We have successfully created your dish.',
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
    _loadTypes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _merchant = widget.merchant;

    Widget waitingContain = const Center(
      child: CircularProgressIndicator(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodToGo - Merchants'),
      ),
      body: _typesList == null
          ? waitingContain
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(35, 15, 40, 30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Create New Dish',
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
                          Icons.fastfood,
                          size: 27,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Enter your dish name'),
                            ),
                            controller: _nameController,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  !_isValidDishName(value)) {
                                return 'The name of your dish is invalid.';
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
                          Icons.attach_money,
                          size: 27,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              label: Text('Enter a price for your dish'),
                            ),
                            controller: _priceController,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  double.parse(value) < 0) {
                                return 'Please enter a valid price for your dish.';
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
                          Icons.format_list_bulleted,
                          size: 27,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: DropdownButtonFormField(
                            value: _dropdownValue,
                            items: _typesList!
                                .map<DropdownMenuItem<int>>(
                                    (e) => DropdownMenuItem(
                                          value: e.id,
                                          child: Text(e.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium),
                                        ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _dropdownValue = value ?? 0;
                              });
                            },
                            decoration: const InputDecoration(
                              label: Text('Choose your dish type'),
                            ),
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a dish type';
                              }
                              return null;
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
                          Icons.description,
                          size: 27,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextFormField(
                            minLines: 1,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              label: Text('Enter your dish description'),
                            ),
                            controller: _descriptionController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'The description of your dish is invalid.';
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
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        if (_selectedImage != null) {
                          _onCreatePressed(_merchant, _selectedImage);
                        }
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
