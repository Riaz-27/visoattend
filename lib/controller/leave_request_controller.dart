import 'package:get/get.dart';
import 'package:visoattend/models/leave_request_model.dart';

import '../models/classroom_model.dart';
import 'cloud_firestore_controller.dart';
import 'attendance_controller.dart';

class LeaveRequestController extends GetxController {
  final _selectedClassrooms = <ClassroomModel>[].obs;

  List<ClassroomModel> get selectedClassrooms => _selectedClassrooms;

  final _availableClassrooms = <ClassroomModel>[].obs;

  List<ClassroomModel> get availableClassrooms => _availableClassrooms;

  void setValues({bool isSelectedClass = false}) {
    final attendanceController = Get.find<AttendanceController>();
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    final currentUser = cloudFirestoreController.currentUser;

    _availableClassrooms.value = cloudFirestoreController.classrooms.toList();

    if (isSelectedClass) {
      final selectedClass = attendanceController.classroomData;
      _selectedClassrooms.add(selectedClass);
      _availableClassrooms
          .removeWhere((classroom) => classroom == selectedClass);
    }

    final classroomsResult = _availableClassrooms.toList();

    for (ClassroomModel classroom in classroomsResult) {
      for (var teacher in classroom.teachers) {
        if (teacher['authUid'] == currentUser.authUid) {
          _availableClassrooms.remove(classroom);
          break;
        }
      }
    }
  }

  Future<void> saveLeaveRequestData(LeaveRequestModel leaveRequest) async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();

    leaveRequest.leaveRequestId = await cloudFirestoreController.saveLeaveRequest(leaveRequest);
    if(leaveRequest.leaveRequestId == ''){
      print('Error');
      return;
    }
    for (ClassroomModel classroom in _selectedClassrooms) {
      leaveRequest.applicationStatus[classroom.classroomId] = 'Pending';
      await cloudFirestoreController.addLeaveRequestInClassroom(
        classroom,
        leaveRequest.leaveRequestId,
      );
    }
    await cloudFirestoreController.updateLeaveRequestApplicationStatus(leaveRequest);
  }
}
