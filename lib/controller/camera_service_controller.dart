import 'dart:developer' as dev;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:synchronized/synchronized.dart';

import '../../models/user_model.dart';
import 'attendance_controller.dart';
import 'face_detector_controller.dart';
import 'recognition_controller.dart';

class CameraServiceController extends GetxController {
  late CameraController _cameraController;

  CameraController get cameraController => _cameraController;

  InputImageRotation? _cameraRotation;

  InputImageRotation? get cameraRotation => _cameraRotation;

  late CameraImage _cameraImage;

  CameraImage get cameraImage => _cameraImage;

  late CameraLensDirection _cameraLensDirection;

  CameraLensDirection get cameraLensDirection => _cameraLensDirection;

  late List<CameraDescription> _cameras;
  late CameraDescription _cameraDescription;

  final _isInitialized = false.obs;

  bool get isInitialized => _isInitialized.value;

  bool isBusy = false;
  bool isStopped = false;
  bool isSignUp = false;

  Future<void> _checkCameras() async {
    _cameras = await availableCameras();
    _cameraLensDirection =
        isSignUp ? CameraLensDirection.front : CameraLensDirection.back;
    _cameraDescription = isSignUp ? _cameras[1] : _cameras[0];
  }

  Future<void> _initialize() async {
    final faceDetectorController = Get.find<FaceDetectorController>();
    final recognitionController = Get.find<RecognitionController>();
    final attendanceController = Get.find<AttendanceController>();
    _cameraController = CameraController(
      _cameraDescription,
      ResolutionPreset.max,
      enableAudio: false,
    );
    await _cameraController.initialize().then((_) {
      // _cameraRotation = InputImageRotationValue.fromRawValue(
      //     _cameraDescription.sensorOrientation);
      _cameraRotation =
          rotationIntToImageRotation(_cameraDescription.sensorOrientation);

      dev.log('Camera rotation: $_cameraRotation');

      // attendanceController.totalRecognized.clear();

      _cameraController.startImageStream((image) async {
        if (!isBusy) {
          isBusy = true;
          _cameraImage = image;
          // await lock.synchronized(() async {
          await faceDetectorController.doFaceDetectionOnFrame(
              _cameraImage, _cameraRotation!);
          if (!isSignUp) {
            final totalStudents = attendanceController.cRsData.toList() +
                attendanceController.studentsData.toList();
            await recognitionController
                .performRecognitionOnIsolateFirestore(
              cameraImage: cameraImage,
              faces: faceDetectorController.faces,
              cameraLensDirection: cameraLensDirection,
              users: totalStudents,
            )
                .then((_) {
              recognitionController.recognitionResults.forEach((key, value) {
                if (attendanceController.totalRecognized.containsKey(key)) {
                  if (value.userOrNot is UserModel) {
                    attendanceController.totalRecognized[key] = value;
                  }
                } else {
                  attendanceController.totalRecognized[key] = value;
                }
              });
              // attendanceController.totalRecognized.addAll();
              isBusy = false;
            });
          } else {
            isBusy = false;
          }
          isBusy = false;
        }
      });
    });
    _isInitialized(true);
  }

  void _init() async {
    await _checkCameras();
    await _initialize();
  }

  @override
  void onInit() {
    _init();
    super.onInit();
  }

  @override
  void onClose() {
    if (!isStopped) {
      _cameraController.stopImageStream();
    }
    _cameraController.dispose();
    super.onClose();
  }

  Size getImageSize() {
    if (!_isInitialized.value) {
      return Size.zero;
    }
    return Size(
      _cameraController.value.previewSize!.height,
      _cameraController.value.previewSize!.width,
    );
  }

  Future<void> toggleCameraDirection() async {
    _isInitialized.value = false;
    await _cameraController.stopImageStream();
    await _cameraController.dispose();
    if (_cameraLensDirection == CameraLensDirection.back) {
      _cameraLensDirection = CameraLensDirection.front;
      _cameraDescription = _cameras[1];
    } else {
      _cameraLensDirection = CameraLensDirection.back;
      _cameraDescription = _cameras[0];
    }
    await _initialize();
  }

  InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }
}
