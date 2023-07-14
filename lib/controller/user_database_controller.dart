import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:visoattend/controller/cloud_firestore_controller.dart';
import 'package:visoattend/controller/profile_pic_controller.dart';
import 'package:visoattend/models/user_model.dart';

import '../services/isar_service.dart';
import '../models/entities/isar_user.dart';
import 'auth_controller.dart';
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

  void resetValues(){
    _isFront(false);
    _isRight(false);
    _isLeft(false);
  }

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

  Future<bool> registerRetrainUserToFirestore(UserModel user, {bool retrainModel = false}) async {
    final cameraServiceController = Get.find<CameraServiceController>();
    final faceDetectorController = Get.find<FaceDetectorController>();
    final recognitionController = Get.find<RecognitionController>();
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    final authController = Get.find<AuthController>();
    final profilePicController = Get.find<ProfilePicController>();

    // await faceDetectorController.doFaceDetectionOnFrame(
    //   cameraServiceController.cameraImage,
    //   cameraServiceController.cameraRotation!,
    // );
    final faceAngle = faceDetectorController.faces[0].headEulerAngleY!;
    final emb = await recognitionController.performRecognitionOnIsolateFirestore(
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
      //Stopping camera service
      cameraServiceController.isBusy = true;
      await cameraServiceController.cameraController.stopImageStream();
      cameraServiceController.isStopped = true;

      if(retrainModel){
        await cloudFirestoreController.updateUserData(user);
      } else {
        final userCredential =
            await authController.createUserWithEmailAndPassword(
                email: user.email, password: authController.tempPassword);
        if (userCredential != null) {
          user.authUid = userCredential.user!.uid;
          await cloudFirestoreController.addUserDataToFirestore(user);
          authController.tempPassword = '';
          cloudFirestoreController.initialize();
        }
      }
      return true;
    }
    return false;
  }
}
