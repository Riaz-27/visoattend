import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClassroomDatabaseController extends GetxController {
  final List<String> _weekDays = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday'
  ];
  List<String> get weekDays => _weekDays;

  final _weekTimes =
      List.generate(7, (index) => TimeOfDay.now()).obs;
  List<TimeOfDay> get weekTimes => _weekTimes;

  final _selectedWeeks = List.generate(7, (index) => false).obs;
  List<bool> get selectedWeeks => _selectedWeeks;


}
