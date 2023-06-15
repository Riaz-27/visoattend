import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visoattend/controller/cloud_firestore_controller.dart';
import 'package:visoattend/models/classroom_model.dart';

class ClassroomDatabaseController extends GetxController {
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

  final _selectedWeekTimes = List.generate(7, (index) => 'Off Day').obs;

  List<String> get selectedWeekTimes => _selectedWeekTimes;

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
      cloudFirestoreController.updateUserClassroom(
        {
          'id': classroomId,
          'role': 'teacher',
        },
      );
      cloudFirestoreController.classrooms.add(classroom);
    }
  }

  Future<void> joinClassroom(String classroomId) async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    if (cloudFirestoreController.isUserAlreadyInThisClassroom(classroomId)) {
      print('User Already in this class');
      return;
    }
    await cloudFirestoreController.joinClassroom(classroomId);
    await cloudFirestoreController.updateUserClassroom(
      {
        'id': classroomId,
        'role': 'student',
      },
    );
  }
}
