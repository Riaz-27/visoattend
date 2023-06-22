import 'dart:developer';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../models/recognition_model.dart';
import '../models/user_model.dart';
import '../services/recognition_service.dart';
import '../services/recognition_isolate.dart';
import '../models/entities/isar_user.dart';
import '../services/image_converter.dart';

class RecognitionController extends GetxController {
  final _performedRecognition = false.obs;

  bool get performedRecognition => _performedRecognition.value;

  final threshold = 0.9;
  final recognitionService = RecognitionService();

  final _recognitionResults = <int, RecognitionModel>{}.obs;

  Map<int, RecognitionModel> get recognitionResults => _recognitionResults;

  @override
  void onInit() {
    recognitionService.initialize();
    super.onInit();
  }

  @override
  void onClose() {
    recognitionService.dispose();
    super.onClose();
  }

  dynamic performFaceRecognition({
    required CameraImage cameraImage,
    required List<Face> faces,
    required CameraLensDirection cameraLensDirection,
    bool isRegistration = false,
    List<IsarUser>? users,
  }) async {
    _performedRecognition(false);
    img.Image image;
    //convert CameraImage to Image and rotate it so that our frame will be in a portrait
    image = convertYUV420ToImage(cameraImage);
    image = img.copyRotate(
        image, cameraLensDirection == CameraLensDirection.front ? 270 : 90);

    List<double> emb = [];
    List<dynamic> recognitionResults = [];

    for (Face face in faces) {
      Rect faceRect = face.boundingBox;
      //crop face
      final faceImage = img.copyCrop(
          image,
          faceRect.left.toInt(),
          faceRect.top.toInt(),
          faceRect.width.toInt(),
          faceRect.height.toInt());
      emb = await recognitionService.runModel(faceImage);

      if (!isRegistration) {
        if (users == null) {
          print('Users data not found');
          return;
        }
        final recognitionResult = recognitionService.findNearest(emb, users);
        recognitionResult[2] = faceRect;
        if (recognitionResult[1] > threshold) {
          recognitionResult[0] = 'Uk';
        }
        print('The result : $recognitionResult');
        recognitionResults.add(recognitionResult);
      }
    }
    _performedRecognition(true);

    if (isRegistration) {
      return emb;
    } else {
      return recognitionResults;
    }
  }

  dynamic performRecognitionOnIsolate({
    required CameraImage cameraImage,
    required List<Face> faces,
    required CameraLensDirection cameraLensDirection,
    bool isRegistration = false,
    List<IsarUser>? users,
  }) async {
    _performedRecognition(false);
    final interpreterAddress = recognitionService.interpreterAddress;

    final result = await recognitionIsolate(
        interpreterAddress: interpreterAddress,
        cameraImage: cameraImage,
        faces: faces,
        isRegistration: isRegistration,
        users: users,
        cameraLensDirection: cameraLensDirection);
    _performedRecognition(true);
    return result;
  }

  Future<dynamic> performRecognitionOnIsolateFirestore({
    required CameraImage cameraImage,
    required List<Face> faces,
    required CameraLensDirection cameraLensDirection,
    bool isRegistration = false,
    List<UserModel>? users,
  }) async {
    final interpreterAddress = recognitionService.interpreterAddress;
    final pres = DateTime.now().millisecondsSinceEpoch;
    final result = await recognitionIsolateForFirestore(
        interpreterAddress: interpreterAddress,
        cameraImage: cameraImage,
        faces: faces,
        isRegistration: isRegistration,
        users: users,
        cameraLensDirection: cameraLensDirection);
    _performedRecognition(true);
    _recognitionResults.value = result;
    final pre = DateTime.now().millisecondsSinceEpoch;
    log('Total Time: ${pre - pres}');
    return result;
  }
}
