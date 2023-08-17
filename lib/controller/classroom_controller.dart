import 'package:get/get.dart';


import '../models/classroom_model.dart';
import '../models/user_model.dart';
import 'cloud_firestore_controller.dart';
import 'leave_request_controller.dart';

import 'attendance_controller.dart';

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
    'Saturday': {
      'startTime': 'Off Day',
      'endTime': 'Off Day',
      'room': '',
      'classCount': '1',
    },
    'Sunday': {
      'startTime': 'Off Day',
      'endTime': 'Off Day',
      'room': '',
      'classCount': '1',
    },
    'Monday': {
      'startTime': 'Off Day',
      'endTime': 'Off Day',
      'room': '',
      'classCount': '1',
    },
    'Tuesday': {
      'startTime': 'Off Day',
      'endTime': 'Off Day',
      'room': '',
      'classCount': '1',
    },
    'Wednesday': {
      'startTime': 'Off Day',
      'endTime': 'Off Day',
      'room': '',
      'classCount': '1',
    },
    'Thursday': {
      'startTime': 'Off Day',
      'endTime': 'Off Day',
      'room': '',
      'classCount': '1',
    },
    'Friday': {
      'startTime': 'Off Day',
      'endTime': 'Off Day',
      'room': '',
      'classCount': '1',
    },
  };

  Map<String, dynamic> get selectedWeekTimes => _selectedWeekTimes;

  final _selectedStartTimes = List.generate(7, (index) => 'Off Day').obs;

  List<String> get selectedStartTimes => _selectedStartTimes;

  final _selectedEndTimes = List.generate(7, (index) => 'Off Day').obs;

  List<String> get selectedEndTimes => _selectedEndTimes;

  final _selectedWeeks = List.generate(7, (index) => false).obs;

  List<bool> get selectedWeeks => _selectedWeeks;

  final _detailsExpanded = true.obs;

  bool get detailsExpanded => _detailsExpanded.value;

  set detailsExpanded(bool value) => _detailsExpanded.value = value;

  Future<void> createNewClassroom({
    required courseCode,
    required courseTitle,
    required section,
    required session,
    required department,
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
      department: department,
      leaveRequestIds: [],
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
    await cloudFirestoreController
        .getUserClassrooms()
        .then((_) => cloudFirestoreController.filterClassesOfToday());
  }

  Future<void> updateClassroom(ClassroomModel classroom) async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    await cloudFirestoreController.updateClassroom(classroom);
    cloudFirestoreController.filterClassesOfToday();
  }

  Future<void> archiveRestoreClassroom(
      ClassroomModel classroom, bool archive) async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    await cloudFirestoreController.archiveRestoreClassroom(classroom, archive);
  }

  Future<void> deleteClassroom() async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    final attendanceController = Get.find<AttendanceController>();
    final classroom = attendanceController.classroomData;
    final attendances = attendanceController.attendances;
    final classroomUsers = attendanceController.teachersData.toList() +
        attendanceController.cRsData.toList() +
        attendanceController.studentsData.toList();
    final leaveRequests =
        Get.find<LeaveRequestController>().classroomLeaveRequests;

    await cloudFirestoreController.deleteClassroom(
      classroom: classroom,
      attendances: attendances,
      leaveRequests: leaveRequests,
      classroomUsers: classroomUsers,
    );
  }

  Future<void> leaveClassroom(ClassroomModel classroom) async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    await cloudFirestoreController.leaveClassroom(classroom);
  }

  Future<void> removeStudentFromClassroom(ClassroomModel classroom, UserModel studentData) async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    await cloudFirestoreController.removeUserFromClassroom(classroom, studentData);
  }
}
