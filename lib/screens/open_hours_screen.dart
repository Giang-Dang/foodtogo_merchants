import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:foodtogo_merchants/models/dto/create_dto/normal_open_hours_create_dto.dart';
import 'package:foodtogo_merchants/models/dto/update_dto/normal_open_hours_update_dto.dart';
import 'package:foodtogo_merchants/models/enum/days_of_week.dart';
import 'package:foodtogo_merchants/models/merchant.dart';
import 'package:foodtogo_merchants/services/normal_open_hours_services.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/widgets/open_hour_selector.dart';

class OpenHoursScreen extends StatefulWidget {
  const OpenHoursScreen({
    Key? key,
    required this.merchant,
  }) : super(key: key);

  final Merchant merchant;

  @override
  State<OpenHoursScreen> createState() => _OpenHoursScreenState();
}

class _OpenHoursScreenState extends State<OpenHoursScreen> {
  final List<TimeOfDay> _openingTime =
      List.filled(7, const TimeOfDay(hour: 6, minute: 0));

  final List<TimeOfDay> _closingTime =
      List.filled(7, const TimeOfDay(hour: 17, minute: 0));

  final List<bool> _isOpenInDay = List.filled(7, false);

  bool _isLoaded = false;
  Timer? _initTimer;

  _getOpenHoursData({
    required DaysOfWeek dayOfWeek,
    required bool isOpen,
    TimeOfDay? openingTime,
    TimeOfDay? closingTime,
  }) {
    _isOpenInDay[dayOfWeek.index] = isOpen;

    if (isOpen) {
      if (openingTime != null && closingTime != null) {
        _openingTime[dayOfWeek.index] = openingTime;
        _closingTime[dayOfWeek.index] = closingTime;
        return;
      }
      log('_OpenHoursScreenState._getOpenHoursData() isOpen == true && openingTime == null && closingTime == null');
    }

    return;
  }

  _onSavePressed() async {
    final result = await _saveOpenHours();

    if (result) {
      _showAlertDialog('Update Successed',
          'We have successfully updated your opening times.', () {
        if (context.mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      });
    } else {
      _showAlertDialog('Update Failed',
          'Unable to update your opening times at the moment. Please try again at a later time.',
          () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });
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

  Future<bool> _saveOpenHours() async {
    final NormalOpenHoursServices normalOpenHoursServices =
        NormalOpenHoursServices();
    final List<bool> isExistList = List.filled(7, false);
    final List<int> indexList = List.filled(7, 0);

    for (var i = 0; i < isExistList.length; i++) {
      var response = await normalOpenHoursServices.getAll(
        searchMerchantId: widget.merchant.merchantId,
        searchDayOfWeek: i,
      ); //always return 1 instance

      if (response == null) {
        log('_saveOpenHours() getAll = null');
        inspect(response);
        return false;
      }

      isExistList[i] = response.isNotEmpty;
      if (response.isNotEmpty) {
        indexList[i] = response.first.id;
      }
    }

    for (var i = 0; i < DaysOfWeek.values.length; i++) {
      if (!_isOpenInDay[i]) {
        continue;
      }

      final now = DateTime.now();
      DateTime openDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _openingTime[i].hour,
        _openingTime[i].minute,
      );

      DateTime closeDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _closingTime[i].hour,
        _closingTime[i].minute,
      );

      if (isExistList[i]) {
        var updateDTO = NormalOpenHoursUpdateDTO(
            id: indexList[i],
            merchantId: widget.merchant.merchantId,
            dayOfWeek: i,
            sessionNo: 1,
            openTime: openDateTime,
            closeTime: closeDateTime);
        var response =
            await normalOpenHoursServices.update(indexList[i], updateDTO);

        if (!response) {
          log('_saveOpenHours() update fail');
          inspect(response);
          return false;
        }
      } else {
        var createDTO = NormalOpenHoursCreateDTO(
            id: 0,
            merchantId: widget.merchant.merchantId,
            dayOfWeek: i,
            sessionNo: 1,
            openTime: openDateTime,
            closeTime: closeDateTime);

        var response = await normalOpenHoursServices.create(createDTO);

        if (response == null) {
          log('_saveOpenHours() create fail');
          inspect(response);
          return false;
        }
      }
    }
    return true;
  }

  _loadOpenHoursData() async {
    if (mounted) {
      setState(() {
        _isLoaded = false;
      });
    }

    final NormalOpenHoursServices normalOpenHoursServices =
        NormalOpenHoursServices();

    final merchantOpenHours = await normalOpenHoursServices.getAll(
        searchMerchantId: widget.merchant.merchantId);

    if (merchantOpenHours == null) {
      log('_loadOpenHoursData() merchantOpenHours == null');
      return;
    }

    for (var i = 0; i < DaysOfWeek.values.length; i++) {
      final dayOpenHours =
          merchantOpenHours.where((e) => e.dayOfWeek == i).toList();

      if (dayOpenHours.isEmpty) {
        continue;
      } else {
        _isOpenInDay[i] = true;
        final dayOpeningTime = dayOpenHours.first.openTime;
        final dayClosingTime = dayOpenHours.first.closeTime;
        _openingTime[i] =
            TimeOfDay(hour: dayOpeningTime.hour, minute: dayOpeningTime.minute);
        _closingTime[i] =
            TimeOfDay(hour: dayClosingTime.hour, minute: dayClosingTime.minute);
      }
    }

    if (mounted) {
      setState(() {
        _isLoaded = true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _loadOpenHoursData();
      _initTimer?.cancel();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _initTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final merchant = widget.merchant;

    Widget content = const Center(
      child: CircularProgressIndicator(),
    );

    if (_isLoaded) {
      content = Container(
        color: KColors.kBackgroundColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              for (var value in DaysOfWeek.values)
                OpenHourSelector(
                  openingTime: _openingTime[value.index],
                  closingTime: _closingTime[value.index],
                  dayOfWeek: value,
                  isOpen: _isOpenInDay[value.index],
                  getOpenHoursData: _getOpenHoursData,
                ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _onSavePressed();
                },
                child: const Text('Save open hours'),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(merchant.name),
        ),
        body: content);
  }
}
