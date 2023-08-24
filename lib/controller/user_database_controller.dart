import 'package:get/get.dart';
import 'package:visoattend/services/encryption_service.dart';

import '../../controller/cloud_firestore_controller.dart';
import '../../helper/functions.dart';
import '../../models/user_model.dart';

import 'auth_controller.dart';
import 'camera_service_controller.dart';
import 'face_detector_controller.dart';
import 'recognition_controller.dart';

class UserDatabaseController extends GetxController {
  final _isFront = false.obs;

  bool get isFront => _isFront.value;
  final _isRight = false.obs;

  bool get isRight => _isRight.value;
  final _isLeft = false.obs;

  bool get isLeft => _isLeft.value;

  void resetValues() {
    _isFront(false);
    _isRight(false);
    _isLeft(false);
  }

  Future<bool> registerRetrainUserToFirestore(UserModel user,
      {bool retrainModel = false}) async {
    final cameraServiceController = Get.find<CameraServiceController>();
    final faceDetectorController = Get.find<FaceDetectorController>();
    final recognitionController = Get.find<RecognitionController>();
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    final authController = Get.find<AuthController>();

    final faceAngle = faceDetectorController.faces[0].headEulerAngleY!;
    final emb =
        await recognitionController.performRecognitionOnIsolateFirestore(
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
      loadingDialog('Registering...');
      //Stopping camera service
      cameraServiceController.isBusy = true;
      await cameraServiceController.cameraController.stopImageStream();
      cameraServiceController.isStopped = true;

      if (retrainModel) {
        await cloudFirestoreController.updateUserData(user);
      } else {
        final userCredential =
            await authController.createUserWithEmailAndPassword(
                email: user.email, password: authController.tempPassword);
        if (userCredential != null) {
          user.authUid = userCredential.user!.uid;
          await cloudFirestoreController.addUserDataToFirestore(user);
          final encryptedPass = EncryptionService().encryptWithAES(
            user.authUid,
            authController.tempPassword,
          );
          await cloudFirestoreController.updateUserSingleData(
            user: user,
            data: {'password': encryptedPass},
          );
          authController.tempPassword = '';
          cloudFirestoreController.initialize();
        }
      }
      hideLoadingDialog();
      resetValues();
      return true;
    }
    return false;
  }
}
