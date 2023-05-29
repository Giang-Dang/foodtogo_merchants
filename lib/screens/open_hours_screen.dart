import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:foodtogo_merchants/models/enum/days_of_week.dart';
import 'package:foodtogo_merchants/models/merchant.dart';
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

  _saveOpenHours() async {}

  @override
  Widget build(BuildContext context) {
    final merchant = widget.merchant;

    return Scaffold(
      appBar: AppBar(
        title: Text(merchant.name),
      ),
      body: Container(
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
                  getOpenHoursData: _getOpenHoursData,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _saveOpenHours();
                },
                child: const Text('Save open hours'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
