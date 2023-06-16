import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:image/image.dart' as img;

class FaceDetectorController extends GetxController {
  late FaceDetector _faceDetector;

  List<Face> _faces = [];
  List<Face> get faces => _faces;

  final _faceDetected = false.obs;
  bool get faceDetected => _faceDetected.value;

  @override
  void onInit() {
    _initialize();
    super.onInit();
  }

  @override
  void onClose() {
    _close();
    super.onClose();
  }

  void _initialize() {
    final options =
    FaceDetectorOptions(performanceMode: FaceDetectorMode.fast, enableTracking: true);
    _faceDetector = FaceDetector(options: options);
  }

  Future<void> doFaceDetectionOnFrame(CameraImage image, InputImageRotation rotation) async {
    _faceDetected(false);
    //convert frame into InputImage format
    var frameImg = _getInputImage(image, rotation);

    //Faces Detection
    _faces = await _faceDetector.processImage(frameImg);
    print('Total Face found: ${_faces.length}');
    if(_faces.length>1){
      _faceDetected(true);
    }
  }

  //converting image to InputImage
  InputImage _getInputImage(CameraImage image, InputImageRotation rotation) {
    print('The Rotation of Image : $rotation');

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize =
    Size(image.width.toDouble(), image.height.toDouble());
    // final camera = description;
    // final imageRotation =
    // InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    // if (imageRotation == null) return;

    final inputImageFormat =
    InputImageFormatValue.fromRawValue(image.format.raw);
    // if (inputImageFormat == null) return null;

    final planeData = image.planes.map(
          (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: rotation,
      inputImageFormat: inputImageFormat!,
      planeData: planeData,
    );

    final inputImage =
    InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

    return inputImage;
  }



  _close() async {
    await _faceDetector.close();
  }

}