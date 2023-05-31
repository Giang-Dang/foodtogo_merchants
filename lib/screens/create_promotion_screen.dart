import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_merchants/models/dto/create_dto/promotion_create_dto.dart';
import 'package:foodtogo_merchants/models/merchant.dart';
import 'package:foodtogo_merchants/providers/promotions_list_provider.dart';
import 'package:foodtogo_merchants/services/promotion_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:intl/intl.dart';

final dateFormatter = DateFormat.yMd();

class CreatePromotionScreen extends ConsumerStatefulWidget {
  const CreatePromotionScreen({
    Key? key,
    required this.merchant,
  }) : super(key: key);

  final Merchant merchant;

  @override
  ConsumerState<CreatePromotionScreen> createState() =>
      _CreatePromotionScreenState();
}

class _CreatePromotionScreenState extends ConsumerState<CreatePromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountPercentageController = TextEditingController();
  final _discountAmountController = TextEditingController();
  final _quantityController = TextEditingController();

  DateTime? _pickedStartDate;
  DateTime? _pickedEndDate;

  bool _isCreating = false;

  _onCreatePressed(int merchantId) async {
    if (_formKey.currentState!.validate()) {
      bool isConfirmCreation = false;
      await _showConfirmCreationDialog(
          title: 'You Will NOT Be Able to EDIT or DELETE a Created Promotion',
          message: 'Please Verify Your Promotion Information.',
          onOkPressed: () {
            isConfirmCreation = true;
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          onCancelPressed: () {
            isConfirmCreation = false;
            if (context.mounted) {
              Navigator.of(context).pop();
            }
            return;
          });

      if (!isConfirmCreation) {
        return;
      }

      if (mounted) {
        setState(() {
          _isCreating = true;
        });
      }

      final createDTO = PromotionCreateDTO(
        id: 0,
        discountCreatorMerchantId: merchantId,
        name: _nameController.text,
        description: _descriptionController.text,
        discountPercentage: int.parse(_discountPercentageController.text),
        discountAmount: double.parse(_discountAmountController.text),
        startDate: _pickedStartDate!,
        endDate: _pickedEndDate!,
        quantity: int.parse(_quantityController.text),
        quantityLeft: int.parse(_quantityController.text),
      );

      final PromotionServices promotionServices = PromotionServices();

      bool isCreateSuccess = await promotionServices.create(createDTO);

      setState(() {
        _isCreating = false;
      });

      if (!isCreateSuccess) {
        _showAlertDialog(
          'Sorry',
          'Unable to create your dish at the moment. Please try again at a later time.',
          () {
            Navigator.of(context).pop();
          },
        );
        return;
      }

      final promotionsList =
          await promotionServices.getAll(createDTO.discountCreatorMerchantId);
      ref.watch(promotionsListProvider.notifier).update(promotionsList!);

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

  _showConfirmCreationDialog({
    required String title,
    required String message,
    required void Function() onOkPressed,
    required void Function() onCancelPressed,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                onOkPressed();
              },
            ),
            TextButton(
              child: const Text('I wanna edit something.'),
              onPressed: () {
                onCancelPressed();
              },
            ),
          ],
        );
      },
    );
  }

  _showStartDatePicker() async {
    final now = DateTime.now();
    final lastDate = DateTime(now.year + 1, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _pickedEndDate ?? now,
      firstDate: now,
      lastDate: _pickedEndDate ?? lastDate,
    );
    if (mounted) {
      setState(() {
        _pickedStartDate = pickedDate;
      });
    }
  }

  _showEndDatePicker() async {
    final now = DateTime.now();
    final lastDate = DateTime(now.year + 1, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _pickedStartDate ?? now,
      firstDate: _pickedStartDate ?? now,
      lastDate: lastDate,
    );
    if (mounted) {
      setState(() {
        _pickedEndDate = pickedDate;
      });
    }
  }

  bool _isValidName(String? name) {
    if (name == null) {
      return false;
    }
    return name.length >= 4 && name.length <= 50;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _discountAmountController.dispose();
    _discountPercentageController.dispose();
    _quantityController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final merchant = widget.merchant;

    return Scaffold(
      appBar: AppBar(
        title: Text(merchant.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(35, 15, 40, 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Create New Promotion',
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
                        label: Text('Enter your promotion name'),
                      ),
                      controller: _nameController,
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !_isValidName(value)) {
                          return 'The name of your promotion is invalid.';
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
                        label: Text('Enter your promotion description'),
                      ),
                      controller: _descriptionController,
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
                    Icons.percent,
                    size: 27,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text('Enter your discount percentage'),
                        suffixText: '%',
                      ),
                      controller: _discountPercentageController,
                      validator: (value) {
                        if (value == null || value == '') {
                          return 'Invalid discount percentage.';
                        }
                        if (int.parse(value) < 0 || int.parse(value) > 100) {
                          return 'Invalid discount percentage.';
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
                    Icons.payments,
                    size: 27,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text('Enter your discount amount'),
                      ),
                      controller: _discountAmountController,
                      validator: (value) {
                        if (value == null || value == '') {
                          return 'Invalid discount amount.';
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
                    Icons.payments,
                    size: 27,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text('Enter promotion quantity'),
                      ),
                      controller: _quantityController,
                      validator: (value) {
                        if (value == null) {
                          return 'Invalid quantity.';
                        }
                        final quantity = int.tryParse(value);
                        if (quantity == null) {
                          return 'Invalid quantity.';
                        }
                        if (quantity <= 0) {
                          return 'Invalid quantity.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Start Date: '),
                  IconButton(
                      onPressed: () {
                        _showStartDatePicker();
                      },
                      icon: const Icon(Icons.calendar_month)),
                  Text(_pickedStartDate == null
                      ? 'Please pick a date.'
                      : dateFormatter.format(_pickedStartDate!)),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Text('End Date: '),
                  IconButton(
                      onPressed: () {
                        _showEndDatePicker();
                      },
                      icon: const Icon(Icons.calendar_month)),
                  Text(_pickedEndDate == null
                      ? 'Please pick a date.'
                      : dateFormatter.format(_pickedEndDate!)),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _onCreatePressed(merchant.merchantId);
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
