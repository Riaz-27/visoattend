import 'package:get/get.dart';

import '../models/attendance_model.dart';
import '../models/classroom_model.dart';
import '../models/user_model.dart';
import 'cloud_firestore_controller.dart';

class AttendanceController extends GetxController {
  final _attendances = <AttendanceModel>[].obs;
  List<AttendanceModel> get attendances => _attendances;

  final _classroomData = ClassroomModel.empty().obs;
  ClassroomModel get classroomData => _classroomData.value;

  List<UserModel> studentsData = [];

  void updateValues(ClassroomModel classroom) async{
    _classroomData.value = classroom;
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    _attendances.value = await cloudFirestoreController.getClassroomAttendances(classroom.classroomId);
  }

  void getStudentsData() async {
    List<String> allStudentsUid = [];
    for(var student in classroomData.students+classroomData.cRs){
      allStudentsUid.add(student['id']);
    }
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    studentsData = await cloudFirestoreController.getStudentsOfClassroom(allStudentsUid);
  }


//   void recordStudentAttendance({
//
// }) async {
//     final pres = DateTime.now().millisecondsSinceEpoch;
//     final cameraImage = cameraServiceController.cameraImage;
//     final faces = faceDetectorController.faces;
//     final camDirection =
//         cameraServiceController.cameraLensDirection;
//     final users =
//     await userDatabaseController.getAllIsarUsers();
//     recognitionResults =
//     await recognitionController.performRecognitionOnIsolate(
//       cameraImage: cameraImage,
//       faces: faces,
//       cameraLensDirection: camDirection,
//       users: users,
//     );
//     final pre = DateTime.now().millisecondsSinceEpoch - pres;
//     print('Time total: $pre ms');
//   }
}