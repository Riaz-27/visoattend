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
    'Saturday': {'time': 'Off Day', 'room': ''},
    'Sunday': {'time': 'Off Day', 'room': ''},
    'Monday': {'time': 'Off Day', 'room': ''},
    'Tuesday': {'time': 'Off Day', 'room': ''},
    'Wednesday': {'time': 'Off Day', 'room': ''},
    'Thursday': {'time': 'Off Day', 'room': ''},
    'Friday': {'time': 'Off Day', 'room': ''},
  }.obs;

  Map<String, dynamic> get selectedWeekTimes => _selectedWeekTimes;

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
      cloudFirestoreController.filterClassesOfToday();
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
    cloudFirestoreController.filterClassesOfToday();
  }
}
