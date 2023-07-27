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
    if (!isRegistration) {
      _recognitionResults.value = result;
    }
    final pre = DateTime.now().millisecondsSinceEpoch;
    log('Total Time: ${pre - pres}');
    return result;
  }
}
