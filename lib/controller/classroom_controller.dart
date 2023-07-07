import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visoattend/controller/cloud_firestore_controller.dart';
import 'package:visoattend/models/classroom_model.dart';

class ClassroomController extends GetxController {
  final List<String> _weekDays = [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday'
  ];

  List<String> get weekDays => _weekDays;

  final _selectedWeekTimes = {
    'Saturday': {'startTime': 'Off Day','endTime': 'Off Day', 'room': ''},
    'Sunday': {'startTime': 'Off Day','endTime': 'Off Day', 'room': ''},
    'Monday': {'startTime': 'Off Day','endTime': 'Off Day', 'room': ''},
    'Tuesday': {'startTime': 'Off Day','endTime': 'Off Day', 'room': ''},
    'Wednesday': {'startTime': 'Off Day','endTime': 'Off Day', 'room': ''},
    'Thursday': {'startTime': 'Off Day','endTime': 'Off Day', 'room': ''},
    'Friday': {'startTime': 'Off Day','endTime': 'Off Day', 'room': ''},
  };

  Map<String, dynamic> get selectedWeekTimes => _selectedWeekTimes;

  final _selectedStartTimes = List.generate(7, (index) => 'Off Day').obs;

  List<String> get selectedStartTimes => _selectedStartTimes;

  final _selectedEndTimes = List.generate(7, (index) => 'Off Day').obs;

  List<String> get selectedEndTimes => _selectedEndTimes;


  final _selectedWeeks = List.generate(7, (index) => false).obs;

  List<bool> get selectedWeeks => _selectedWeeks;

  Future<void> createNewClassroom({
    required courseCode,
    required courseTitle,
    required section,
    required session,
  }) async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    final currentUser = cloudFirestoreController.currentUser;
    final teacher = {
      'name': currentUser.name,
      'userId': currentUser.userId,
      'authUid': currentUser.authUid,
    };
    final classroom = ClassroomModel(
      isArchived: false,
      openAttendance: 'off',
      classroomId: 'null',
      courseCode: courseCode,
      courseTitle: courseTitle,
      section: section,
      session: session,
      weekTimes: _selectedWeekTimes,
      teachers: [teacher],
      cRs: [],
      students: [],
    );

    final classroomId =
        await cloudFirestoreController.createClassroom(classroom);
    if (classroomId != null) {
      await cloudFirestoreController
          .updateUserClassroom({classroomId: 'Teacher'});
      await cloudFirestoreController.initialize();
    }
  }

  Future<void> joinClassroom(String classroomId) async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    if (cloudFirestoreController.isUserAlreadyInThisClassroom(classroomId)) {
      print('User Already in this class');
      return;
    }
    await cloudFirestoreController.joinClassroom(classroomId);
    await cloudFirestoreController
        .updateUserClassroom({classroomId: 'Student'});
    await cloudFirestoreController.initialize();
  }

  Future<void> updateClassroom(ClassroomModel classroom) async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    await cloudFirestoreController.updateClassroom(classroom);
    int index = cloudFirestoreController.classrooms.indexWhere(
      (dbClassroom) => classroom.classroomId == dbClassroom.classroomId,
    );
    cloudFirestoreController.classrooms[index] = classroom;
    cloudFirestoreController.filterClassesOfToday();
  }

  Future<void> archiveClassroom(ClassroomModel classroom) async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    cloudFirestoreController.archiveClassroom(classroom);
  }

  Future<void> leaveClassroom(ClassroomModel classroom) async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    cloudFirestoreController.leaveClassroom(classroom);
  }
}
