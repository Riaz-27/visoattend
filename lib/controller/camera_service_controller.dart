import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:synchronized/synchronized.dart';

// import 'recognition_controller.dart';
// import 'user_database_controller.dart';
// import '../services/recognition_service.dart';

import 'face_detector_controller.dart';

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
  bool _isBusy = false;

  bool get isInitialized => _isInitialized.value;

  Future<void> _checkCameras() async {
    _cameras = await availableCameras();
    _cameraLensDirection = CameraLensDirection.back;
    _cameraDescription = _cameras[0];
  }

  Future<void> _initialize() async {
    final faceDetectorController = Get.find<FaceDetectorController>();
    // final recognitionController = Get.find<RecognitionController>();
    // final userDatabaseController = Get.find<UserDatabaseController>();
    _cameraController = CameraController(
      _cameraDescription,
      ResolutionPreset.max,
      enableAudio: false,
    );
    await _cameraController.initialize().then((_) {
      _cameraRotation = InputImageRotationValue.fromRawValue(
          _cameraDescription.sensorOrientation);
      var lock = Lock();
      _cameraController.startImageStream((image) async {
        if (!_isBusy) {
          _isBusy = true;
          _cameraImage = image;
          await lock.synchronized(() async {
            await faceDetectorController.doFaceDetectionOnFrame(
                _cameraImage, _cameraRotation!);
          });
          // await lock.synchronized(() async {
          //   final cameraImage = _cameraImage;
          //   final faces = faceDetectorController.faces;
          //   final camDirection =
          //       _cameraLensDirection;
          //   final users = await userDatabaseController.getAllUsers();
          //   await recognitionController.performRecognitionOnIsolate(
          //     cameraImage: cameraImage,
          //     faces: faces,
          //     cameraLensDirection: camDirection,
          //     users: users,
          //   );
          // });
          _isBusy = false;
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
    _cameraController.stopImageStream();
    _cameraController.dispose();
    super.onClose();
  }

  Size getImageSize() {
    assert(_isInitialized.value == true, 'Camera not initialized');
    assert(_cameraController.value.previewSize != null, 'Preview size is null');
    return Size(
      _cameraController.value.previewSize!.height,
      _cameraController.value.previewSize!.width,
    );
  }

  Future<void> toggleCameraDirection() async {
    _isInitialized(false);
    if (_cameraLensDirection == CameraLensDirection.back) {
      _cameraLensDirection = CameraLensDirection.front;
      _cameraDescription = _cameras[1];
    } else {
      _cameraLensDirection = CameraLensDirection.back;
      _cameraDescription = _cameras[0];
    }
    await _cameraController.stopImageStream();
    await _initialize();
    _isInitialized(true);
  }

// InputImageRotation rotationIntToImageRotation(int rotation) {
//   switch (rotation) {
//     case 90:
//       return InputImageRotation.rotation90deg;
//     case 180:
//       return InputImageRotation.rotation180deg;
//     case 270:
//       return InputImageRotation.rotation270deg;
//     default:
//       return InputImageRotation.rotation0deg;
//   }
// }
}
