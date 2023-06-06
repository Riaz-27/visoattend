import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraService {
  late List<CameraDescription> _cameras;

  late CameraController _cameraController;

  CameraController get cameraController => _cameraController;

  InputImageRotation? _cameraRotation;

  InputImageRotation? get cameraRotation => _cameraRotation;

  late CameraImage _cameraImage;

  CameraImage get cameraImage => _cameraImage;

  late CameraDescription cameraDescription;

  bool isInitialized = false;

  late CameraLensDirection cameraLensDirection;

  Future<void> initialize() async {
    _cameras = await availableCameras();
    cameraLensDirection = CameraLensDirection.back;
    cameraDescription = _cameras[0];
    _cameraController = CameraController(
        cameraDescription, ResolutionPreset.max,
        enableAudio: false);
    _cameraController.initialize().then((_) {
      isInitialized = true;
      _cameraRotation = InputImageRotationValue.fromRawValue(
          cameraDescription.sensorOrientation);
      _cameraController.startImageStream((image) => _cameraImage = image);
    });
  }

  void toggleCameraDirection() async {
    await _cameraController.stopImageStream();
    if (cameraLensDirection == CameraLensDirection.back) {
      cameraLensDirection = CameraLensDirection.front;
      cameraDescription = _cameras[1];
    } else {
      cameraLensDirection = CameraLensDirection.back;
      cameraDescription = _cameras[0];
    }
    await initialize();
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

  Size getImageSize() {
    assert(_cameraController.value.previewSize != null, 'Preview size is null');
    return Size(
      _cameraController.value.previewSize!.height,
      _cameraController.value.previewSize!.width,
    );
  }

  dispose() async {
    await _cameraController.stopImageStream();
    await _cameraController.dispose();
  }
}
