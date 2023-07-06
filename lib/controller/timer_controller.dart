import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visoattend/controller/cloud_firestore_controller.dart';

class TimerController extends FullLifeCycleController with FullLifeCycleMixin {
  @override
  void onDetached() {
    cancelTimer();
  }

  @override
  void onInactive() {
    cancelTimer();
  }

  @override
  void onPaused() {
    cancelTimer();
  }

  @override
  void onResumed() {
    startTimer();
  }

  /// Timer for classroom start end related data
  Timer? _classTimer;
  bool _isInitialized = false;

  void startTimer() {
    if (!_isInitialized) {
      final cloudFirestoreController = Get.find<CloudFirestoreController>();
      _classTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        final now = DateTime.now();
        if (now.second == 1) {
          cloudFirestoreController.updateTimeLeft();
        }
      });
      _isInitialized = true;
    }
  }

  void cancelTimer() {
    if (_isInitialized) {
      _classTimer!.cancel();
      _isInitialized = false;
    }
  }

  /// Timer for handling open attendance
  Timer? _attendanceTimer;

  final _timeLeft = 0.obs;

  int get timeLeft => _timeLeft.value;

  set timeLeft(int val) => _timeLeft.value = val;

  void startAttendanceTimer() {
    _attendanceTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _timeLeft.value--;
      if(_timeLeft.value == 0){
        _attendanceTimer!.cancel();
      }
    });
  }
}
