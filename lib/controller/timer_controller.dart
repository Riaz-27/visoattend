import 'dart:async';

import 'package:get/get.dart';

import '../controller/cloud_firestore_controller.dart';

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
  bool _isATInitialized = false;

  final _timeLeft = (-1).obs;

  int get timeLeft => _timeLeft.value;

  set timeLeft(int val) => _timeLeft.value = val;

  void startAttendanceTimer(int dbTimeLeft) {
    if (!_isATInitialized && dbTimeLeft > 0) {
      _timeLeft.value = dbTimeLeft;
      _attendanceTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        // print('Open Timer : ${timeLeft~/60} : ${timeLeft%60}');
        _timeLeft.value--;
        if (_timeLeft.value == 0) {
          cancelAttendanceTimer();
        }
      });
      _isATInitialized = true;
    }
  }

  void cancelAttendanceTimer() {
    if(_isATInitialized){
      _attendanceTimer!.cancel();
      _timeLeft(-1);
      _isATInitialized = false;
    }
  }

  ///reset password timer controller
  Timer? _resetPassTimer;
  bool _isResetPassTimerInitialized = false;

  final _resetPassTimeLeft = 60.obs;
  int get resetPassTimeLeft => _resetPassTimeLeft.value;

  void startResetPassTimer() {
    _isResetPassTimerInitialized = true;
    _resetPassTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _resetPassTimeLeft.value--;
      if(_resetPassTimeLeft.value == 0) cancelResetPassTimer();
    });
  }

  void cancelResetPassTimer() {
    if(_isResetPassTimerInitialized){
      _resetPassTimer!.cancel();
      _resetPassTimeLeft.value = 60;
      _isResetPassTimerInitialized = false;
    }
  }

}
