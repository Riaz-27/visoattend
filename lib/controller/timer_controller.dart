import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TimerController extends FullLifeCycleController with FullLifeCycleMixin {
  @override
  void onDetached() {
    myTimer.cancel();
  }

  @override
  void onInactive() {
    myTimer.cancel();
  }

  @override
  void onPaused() {
    myTimer.cancel();
  }

  @override
  void onResumed() {
    startTimer();
  }

  @override
  void onInit() {
    startTimer();
    super.onInit();
  }

  late Timer myTimer;

  void startTimer() {
    myTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      print('Timer : ${DateFormat('h:m:s').format(DateTime.now())}');
    });
  }

}