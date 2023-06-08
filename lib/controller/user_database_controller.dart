import 'package:get/get.dart';
import 'package:isar/isar.dart';

import '../services/isar_service.dart';
import '../models/entities/isar_user.dart';
import 'camera_service_controller.dart';
import 'face_detector_controller.dart';
import 'recognition_controller.dart';

class UserDatabaseController extends GetxController {

  final isarService = IsarService();

  final _isFront = false.obs;

  bool get isFront => _isFront.value;
  final _isRight = false.obs;

  bool get isRight => _isRight.value;
  final _isLeft = false.obs;

  bool get isLeft => _isLeft.value;

  Future<bool> saveUser(IsarUser newUser) async {
    final isar = await isarService.db;
    final alreadyExist = await checkUser(newUser.userId);
    if (alreadyExist) {
      print('User Already Exists.');
      return false;
    } else {
      await isar.writeTxn<int>(() => isar.isarUsers.put(newUser));
      return true;
    }
  }

  Future<bool> checkUser(String userId) async {
    final isar = await isarService.db;
    return await isar.isarUsers.filter().userIdEqualTo(userId).count() > 0
        ? true
        : false;
  }

  Future<IsarUser?> verifyUser(String userId, String password) async {
    final isar = await isarService.db;
    final user = await isar.isarUsers
        .filter()
        .userIdEqualTo(userId)
        .and()
        .passwordEqualTo(password)
        .findFirst();
    return user;
  }

  Future<List<IsarUser>> getAllIsarUsers() async {
    final isar = await isarService.db;
    return isar.isarUsers.where().findAll();
  }

  Future<void> registerNewUserToDatabase(IsarUser user) async {
    final cameraServiceController = Get.find<CameraServiceController>();
    final faceDetectorController = Get.find<FaceDetectorController>();
    final recognitionController = Get.find<RecognitionController>();
    await faceDetectorController.doFaceDetectionOnFrame(
      cameraServiceController.cameraImage,
      cameraServiceController.cameraRotation!,
    );
    final faceAngle = faceDetectorController.faces[0].headEulerAngleY!;
    final emb = await recognitionController.performRecognitionOnIsolate(
      cameraImage: cameraServiceController.cameraImage,
      faces: faceDetectorController.faces,
      cameraLensDirection: cameraServiceController.cameraLensDirection,
      isRegistration: true,
    );

    if (faceAngle > -10 && faceAngle < 10) {
      user.faceDataFront = emb;
      _isFront(true);
    } else if (faceAngle < -15 && faceAngle > -35) {
      user.faceDataLeft = emb;
      _isLeft(true);
    } else if (faceAngle > 15 && faceAngle < 35) {
      user.faceDataRight = emb;
      _isRight(true);
    }

    if (_isFront.value && _isLeft.value && _isRight.value) {
      saveUser(user);
    }
  }
}
