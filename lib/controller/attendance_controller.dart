import 'package:get/get.dart';
import 'package:visoattend/controller/user_database_controller.dart';

import '../models/attendance_model.dart';
import '../models/classroom_model.dart';
import '../models/recognition_model.dart';
import '../models/user_model.dart';
import 'camera_service_controller.dart';
import 'cloud_firestore_controller.dart';
import 'face_detector_controller.dart';
import 'recognition_controller.dart';

class AttendanceController extends GetxController {
  final _attendances = <AttendanceModel>[].obs;

  List<AttendanceModel> get attendances => _attendances;

  final _classroomData = ClassroomModel.empty().obs;

  ClassroomModel get classroomData => _classroomData.value;

  List<UserModel> studentsData = [];
  final _currentUserRole = 'Student'.obs;

  String get currentUserRole => _currentUserRole.value;

  final _currentUserMissedClasses = 0.obs;
  int get currentUserMissedClasses => _currentUserMissedClasses.value;

  Map<int, RecognitionModel> totalRecognized = {};

  Map<String, RecognitionModel> matchedStudents = {}; // String is user.authUid

  @override
  onInit(){
    ever(_attendances, (_) => calculateMissedClass());
    super.onInit();
  }

  Future<void> updateValues(ClassroomModel classroom) async {
    _classroomData.value = classroom;
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    _attendances.value = await cloudFirestoreController
        .getClassroomAttendances(classroom.classroomId);
    _currentUserRole.value =
        cloudFirestoreController.currentUser.classrooms[classroom.classroomId];

    print(
        'The current user is : ${cloudFirestoreController.currentUser.authUid}');
    print('The current user is : $currentUserRole');
  }

  Future<void> getStudentsData() async {
    List<String> allStudentsUid = [];
    for (var student in classroomData.students + classroomData.cRs) {
      allStudentsUid.add(student['authUid']);
    }
    if (allStudentsUid.isEmpty) {
      print('No Students in this class');
      return;
    }
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    studentsData =
        await cloudFirestoreController.getStudentsOfClassroom(allStudentsUid);
  }

  Future<void> setMatchedStudents() async {
    totalRecognized.forEach((key, value) {
      if (value.userOrNot is UserModel) {
        final authUid = value.userOrNot.authUid;
        matchedStudents[authUid] = value;
      }
    });
  }

  Future<void> saveDataToFirestore({int counts = 1}) async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    final currentUser = cloudFirestoreController.currentUser;
    final takenBy = {
      'authUid': currentUser.authUid,
      'name': currentUser.name,
      'userId': currentUser.userId,
    };
    AttendanceModel attendanceData = AttendanceModel(
      dateTime: DateTime.now().millisecondsSinceEpoch,
      counts: counts,
      studentsData: {},
      takenBy: takenBy,
    );
    for (var student in studentsData) {
      attendanceData.studentsData[student.authUid] = 'Absent';
      if (matchedStudents.containsKey(student.authUid)) {
        attendanceData.studentsData[student.authUid] = 'Present';
      }
    }

    await cloudFirestoreController
        .saveAttendanceData(classroomData.classroomId, attendanceData)
        .then((_) => _attendances.add(attendanceData));
  }

  void calculateMissedClass(){
    final userAuthUid = Get.find<CloudFirestoreController>().currentUser.authUid;
    _currentUserMissedClasses.value =0;
    for(AttendanceModel attendance in _attendances){
      if(attendance.studentsData[userAuthUid] == 'Absent'){
        _currentUserMissedClasses.value++;
      }
    }
  }


}
