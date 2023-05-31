import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/dto/menu_item_type_dto.dart';
import 'package:foodtogo_merchants/models/dto/update_dto/menu_item_update_dto.dart';
import 'package:foodtogo_merchants/models/menu_item.dart';
import 'package:foodtogo_merchants/providers/menu_item_list_provider.dart';
import 'package:foodtogo_merchants/services/file_services.dart';
import 'package:foodtogo_merchants/services/menu_item_services.dart';
import 'package:foodtogo_merchants/services/menu_item_type_services.dart';
import 'package:foodtogo_merchants/services/user_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/settings/secrets.dart';
import 'package:foodtogo_merchants/widgets/image_input.dart';
import 'package:transparent_image/transparent_image.dart';

class EditMenuItemScreen extends ConsumerStatefulWidget {
  const EditMenuItemScreen({
    Key? key,
    required this.menuItem,
  }) : super(key: key);

  final MenuItem menuItem;

  @override
  ConsumerState<EditMenuItemScreen> createState() =>
      _CreateMenuItemScreenState();
}

class _CreateMenuItemScreenState extends ConsumerState<EditMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  File? _selectedImage;
  List<MenuItemTypeDTO>? _typesList;
  int _dropdownValue = 1;

  bool _isEditing = false;

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

  _setDefaultValues() async {
    final menuItemTypeServices = MenuItemTypeServices();
    final menuItem = widget.menuItem;
    _nameController.text = menuItem.name;
    _priceController.text = menuItem.unitPrice.toString();
    _descriptionController.text = menuItem.description;
    final menuItemTypes = await menuItemTypeServices.getAll();
    setState(() {
      _dropdownValue =
          menuItemTypes.firstWhere((e) => e.name == menuItem.itemType).id;
    });
  }

  _onEditPressed(MenuItem menuItem, File? image) async {
    if (_formKey.currentState!.validate()) {
      final fileServices = FileServices();
      final menuItemServices = MenuItemServices();

      image ??= await fileServices.getImage(menuItem.imagePath);

      final updateDTO = MenuItemUpdateDTO(
        id: menuItem.id,
        merchantId: menuItem.merchantId,
        itemTypeId: _dropdownValue,
        name: _nameController.text,
        description: _descriptionController.text,
        unitPrice: double.parse(_priceController.text),
      );

      setState(() {
        _isEditing = true;
      });

      bool isEditSuccess =
          await menuItemServices.update(menuItem.id, updateDTO, image);

      var menuItemsList =
          await menuItemServices.getAllMenuItems(menuItem.merchantId);

      setState(() {
        _isEditing = false;
      });

      if (!isEditSuccess || menuItemsList == null) {
        _showAlertDialog(
          'Sorry',
          'Unable to update your dish at the moment. Please try again at a later time.',
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
        'We have successfully updated your dish.',
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
    _setDefaultValues();
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
    final menuItem = widget.menuItem;
    final jwtToken = UserServices.jwtToken;
    final imageUrl =
        Uri.http(Secrets.kFoodToGoAPILink, menuItem.imagePath).toString();

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
                      'Edit Your Dish',
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
                    const SizedBox(height: 20),
                    const SizedBox(
                        width: double.infinity,
                        child: Text('Current Dish Picture:')),
                    const SizedBox(height: 5),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                        width: 1,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
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
                        width: double.infinity,
                        child: Text('New Dish Picture:')),
                    const SizedBox(height: 5),
                    ImageInput(
                      onPickImage: (image) {
                        _selectedImage = image;
                      },
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        _onEditPressed(menuItem, _selectedImage);
                      },
                      child: _isEditing
                          ? const CircularProgressIndicator()
                          : const Text('Edit dish'),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
    );
  }
}
