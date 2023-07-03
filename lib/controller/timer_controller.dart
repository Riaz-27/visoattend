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

  // @override
  // void onInit() {
  //   startTimer();
  //   super.onInit();
  // }

  Timer? _myTimer;
  bool _isInitialized = false;

  void startTimer() {
    if (!_isInitialized) {
      final cloudFirestoreController = Get.find<CloudFirestoreController>();
      _myTimer = Timer.periodic(const Duration(seconds: 1), (_) {
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
      _myTimer!.cancel();
      _isInitialized = false;
    }
  }
}
