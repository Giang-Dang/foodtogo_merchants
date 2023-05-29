import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:foodtogo_merchants/models/enum/days_of_week.dart';
import 'package:foodtogo_merchants/settings/kcolors.dart';
import 'package:foodtogo_merchants/util/material_color_creator.dart';

class OpenHourSelector extends StatefulWidget {
  const OpenHourSelector(
      {Key? key,
      required this.openingTime,
      required this.closingTime,
      required this.dayOfWeek,
      required this.getOpenHoursData})
      : super(key: key);

  final TimeOfDay openingTime;
  final TimeOfDay closingTime;
  final DaysOfWeek dayOfWeek;
  final Function({
    required DaysOfWeek dayOfWeek,
    required bool isOpen,
    TimeOfDay? openingTime,
    TimeOfDay? closingTime,
  }) getOpenHoursData;

  @override
  State<OpenHourSelector> createState() => _OpenHourSelectorState();
}

class _OpenHourSelectorState extends State<OpenHourSelector> {
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;
  bool _switchValue = false;

  @override
  Widget build(BuildContext context) {
    openingTime ??= widget.openingTime;
    closingTime ??= widget.closingTime;
    final dayOfWeek = widget.dayOfWeek;

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: _switchValue
            ? KColors.kSuccessColor.withOpacity(0.2)
            : KColors.kPrimaryColor.withOpacity(0.2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '  ${dayOfWeek.name}',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: KColors.kTextColor),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: _switchValue,
                  onChanged: (value) {
                    if (mounted) {
                      setState(() {
                        _switchValue = value;
                      });
                    }

                    widget.getOpenHoursData(
                      isOpen: true,
                      dayOfWeek: dayOfWeek,
                      openingTime: openingTime,
                      closingTime: closingTime,
                    );
                  },
                  activeColor: KColors.kOnBackgroundColor,
                  activeTrackColor: KColors.kAppleGreen,
                  inactiveThumbColor: KColors.kLightTextColor,
                ),
              ),
            ],
          ),
          if (_switchValue)
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final TimeOfDay? newTime = await showTimePicker(
                        context: context,
                        initialTime: openingTime!,
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.fromSwatch(
                                    primarySwatch: MaterialColorCreator
                                        .createMaterialColor(
                              KColors.kPrimaryColor,
                            ))),
                            child: child!,
                          );
                        },
                      );

                      if (newTime != null) {
                        if (mounted) {
                          setState(() {
                            openingTime = newTime;
                          });
                        }

                        widget.getOpenHoursData(
                          isOpen: true,
                          dayOfWeek: dayOfWeek,
                          openingTime: openingTime,
                          closingTime: closingTime,
                        );
                      }
                    },
                    child: InputDecorator(
                      decoration:
                          const InputDecoration(labelText: 'Opening Time'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(openingTime!.format(context)),
                          Icon(Icons.arrow_drop_down,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey.shade700
                                  : Colors.white70),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final TimeOfDay? newTime = await showTimePicker(
                        context: context,
                        initialTime: closingTime!,
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.fromSwatch(
                                    primarySwatch: MaterialColorCreator
                                        .createMaterialColor(
                              KColors.kPrimaryColor,
                            ))),
                            child: child!,
                          );
                        },
                      );
                      if (newTime != null) {
                        if (mounted) {
                          setState(() {
                            closingTime = newTime;
                          });
                        }

                        widget.getOpenHoursData(
                          isOpen: true,
                          dayOfWeek: dayOfWeek,
                          openingTime: openingTime,
                          closingTime: closingTime,
                        );
                      }
                    },
                    child: InputDecorator(
                      decoration:
                          const InputDecoration(labelText: 'Closing Time'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(closingTime!.format(context)),
                          Icon(Icons.arrow_drop_down,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.grey.shade700
                                  : Colors.white70),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
