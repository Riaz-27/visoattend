import 'package:get/get.dart';
import 'package:visoattend/models/leave_request_model.dart';
import 'package:visoattend/models/user_model.dart';

import '../models/classroom_model.dart';
import 'cloud_firestore_controller.dart';
import 'attendance_controller.dart';

class LeaveRequestController extends GetxController {
  final _selectedClassrooms = <ClassroomModel>[].obs;

  List<ClassroomModel> get selectedClassrooms => _selectedClassrooms;

  final _availableClassrooms = <ClassroomModel>[].obs;

  List<ClassroomModel> get availableClassrooms => _availableClassrooms;

  final _classroomLeaveRequests = <LeaveRequestModel>[].obs;

  List<LeaveRequestModel> get classroomLeaveRequests => _classroomLeaveRequests;

  final _activeLeaveRequests = <LeaveRequestModel>[].obs;

  List<LeaveRequestModel> get activeLeaveRequests => _activeLeaveRequests;

  final _pendingLeaveRequestsCount = 0.obs;

  int get pendingLeaveRequestsCount => _pendingLeaveRequestsCount.value;

  final _leaveRequestsUser = <String, UserModel>{}.obs;

  Map<String, UserModel> get leaveRequestsUser => _leaveRequestsUser;

  void setValues({bool isSelectedClass = false}) {
    final attendanceController = Get.find<AttendanceController>();
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    final currentUser = cloudFirestoreController.currentUser;
    _availableClassrooms.clear();
    _selectedClassrooms.clear();

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

    leaveRequest.leaveRequestId =
        await cloudFirestoreController.saveLeaveRequest(leaveRequest);
    if (leaveRequest.leaveRequestId == '') {
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
    await cloudFirestoreController
        .updateLeaveRequestApplicationStatus(leaveRequest);

    _classroomLeaveRequests.add(leaveRequest);
  }

  Future<void> getAndFilterClassroomLeaveRequests() async {
    final attendanceController = Get.find<AttendanceController>();
    final cloudFirestoreController = Get.find<CloudFirestoreController>();

    final userRole = attendanceController.currentUserRole;
    final isTeacherOrCR = userRole != 'Student';
    final currentClass = attendanceController.classroomData;
    final leaveRequestList = currentClass.leaveRequestIds;

    _classroomLeaveRequests.value = await cloudFirestoreController
        .getClassroomLeaveRequests(leaveRequestList);

    // Filtering result
    final classroomStudents = attendanceController.cRsData.toList() +
        attendanceController.studentsData.toList();

    _leaveRequestsUser.clear();
    _activeLeaveRequests.clear();
    if (isTeacherOrCR) {
      for (LeaveRequestModel request in _classroomLeaveRequests) {
        _leaveRequestsUser[request.leaveRequestId] = classroomStudents
            .firstWhere((student) => student.authUid == request.userAuthUid);

        // Getting active requests
        final now = DateTime.now();
        final fromDateTime = DateTime.parse(request.fromDate);
        final toDateTime = DateTime.parse(request.toDate);
        if (request.applicationStatus[currentClass.classroomId] == 'Approved' &&
            now.isAfter(fromDateTime) &&
            now.isBefore(toDateTime)) {
          _activeLeaveRequests.add(request);
        }
      }
    }
    if (userRole != 'Teacher') {
      _classroomLeaveRequests.removeWhere((request) =>
          request.userAuthUid != cloudFirestoreController.currentUser.authUid);
    }

    _classroomLeaveRequests.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    _pendingLeaveRequestsCount.value = _classroomLeaveRequests
        .where((request) =>
            request.applicationStatus[currentClass.classroomId] == 'Pending')
        .toList()
        .length;
  }

  Future<void> changeApplicationStatus({
    required int leaveRequestIndex,
    required String status,
  }) async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    final attendanceController = Get.find<AttendanceController>();

    final currentClassroom = attendanceController.classroomData;
    final leaveRequest = _classroomLeaveRequests[leaveRequestIndex];

    leaveRequest.applicationStatus[currentClassroom.classroomId] = status;
    _classroomLeaveRequests[leaveRequestIndex] = leaveRequest;

    await cloudFirestoreController
        .updateLeaveRequestApplicationStatus(leaveRequest);

    _pendingLeaveRequestsCount.value--;
  }

  Future<void> deleteClassroomLeaveRequest(
      {required int leaveRequestIndex}) async {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    final attendanceController = Get.find<AttendanceController>();

    final currentClassroom = attendanceController.classroomData;
    final leaveRequest = _classroomLeaveRequests[leaveRequestIndex];

    _classroomLeaveRequests.remove(leaveRequest);
    await cloudFirestoreController.deleteClassroomLeaveRequest(
      classroom: currentClassroom,
      leaveRequest: leaveRequest,
    );

    if (leaveRequest.applicationStatus[currentClassroom.classroomId] ==
        'Pending') {
      _pendingLeaveRequestsCount.value--;
    }
  }
}
