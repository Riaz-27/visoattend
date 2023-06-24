import 'package:get/get.dart';
import 'package:visoattend/controller/attendance_controller.dart';
import 'package:visoattend/controller/auth_controller.dart';
import 'package:visoattend/controller/profile_pic_controller.dart';

import '../controller/camera_service_controller.dart';
import '../controller/face_detector_controller.dart';
import '../controller/recognition_controller.dart';
import '../controller/user_database_controller.dart';
import 'controller/classroom_controller.dart';
import 'controller/cloud_firestore_controller.dart';

class GlobalBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController());
    Get.lazyPut(() => CameraServiceController(), fenix: true);
    Get.lazyPut(() => FaceDetectorController(), fenix: true);
    Get.lazyPut(() => RecognitionController(), fenix: true);
    Get.lazyPut(() => UserDatabaseController(), fenix: true);
    Get.lazyPut(() => CloudFirestoreController(), fenix: true);
    Get.lazyPut(() => ClassroomController(), fenix: true);
    Get.lazyPut(() => AttendanceController(), fenix: true);
    Get.lazyPut(() => ProfilePicController(), fenix: true);
  }
}
