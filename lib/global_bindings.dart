import 'package:get/get.dart';

import '../controller/camera_service_controller.dart';
import '../controller/face_detector_controller.dart';
import '../controller/recognition_controller.dart';
import '../controller/user_database_controller.dart';

class GlobalBinding implements Bindings {

  @override
  void dependencies() {
    Get.lazyPut(() => CameraServiceController());
    Get.lazyPut(() => FaceDetectorController());
    Get.lazyPut(() => RecognitionController());
    Get.lazyPut(() => UserDatabaseController());
  }

}