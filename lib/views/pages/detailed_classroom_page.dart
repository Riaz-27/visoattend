import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/classroom_controller.dart';
import '../../controller/navigation_controller.dart';
import '../../helper/constants.dart';
import '../../helper/functions.dart';
import '../../views/pages/classroom_pages/leave_request_page.dart';
import '../../views/pages/classroom_pages/people_page.dart';
import '../../views/pages/create_edit_classroom_page.dart';
import '../../controller/attendance_controller.dart';
import '../../controller/leave_request_controller.dart';
import '../../models/classroom_model.dart';
import 'classroom_pages/classroom_page.dart';

class DetailedClassroomPage extends GetView<NavigationController> {
  const DetailedClassroomPage({super.key, required this.classroomData});

  final ClassroomModel classroomData;

  @override
  Widget build(BuildContext context) {
    final attendanceController = Get.find<AttendanceController>();
    // final leaveRequestController = Get.find<LeaveRequestController>();
    // attendanceController.updateValues(classroomData).then((_) =>
    //     attendanceController.getUsersData().then((_) =>
    //         leaveRequestController.getAndFilterClassroomLeaveRequests()));
    loadData();

    final navigationPages = [
      const ClassroomPage(),
      const PeoplePage(),
      const LeaveRequestPage(),
    ];

    return WillPopScope(
      onWillPop: () async {
        if (controller.selectedIndex == 0) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          return true;
        } else {
          controller.changeIndex(0);
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            classroomData.courseTitle,
            style: textTheme.bodyLarge!.copyWith(color: textColorDefault),
          ),
          forceMaterialTransparency: true,
          actions: [
            Obx(() {
              final userRole = attendanceController.currentUserRole;
              if (userRole == '') {
                return const SizedBox();
              }
              if (userRole == 'Student') {
                return PopupMenuButton(
                  position: PopupMenuPosition.under,
                  tooltip: 'Classroom Options',
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'unenroll',
                      child: Text('Unenroll'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'unenroll') {
                      _handleLeaveClass(context);
                    }
                  },
                );
              } else {
                return IconButton(
                  onPressed: () {
                    Get.to(
                      () => CreateEditClassroomPage(
                        isEdit: true,
                        userRole: userRole,
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings),
                );
              }
            })
          ],
        ),
        body: Obx(() {
          return navigationPages[controller.selectedIndex];
        }),
        bottomNavigationBar: Obx(() {
          final leaveRequestController = Get.find<LeaveRequestController>();
          return NavigationBar(
            selectedIndex: controller.selectedIndex,
            onDestinationSelected: (index) => controller.changeIndex(index),
            height: 65,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.class_outlined),
                selectedIcon: Icon(Icons.class_rounded),
                label: 'Classroom',
              ),
              const NavigationDestination(
                icon: Icon(Icons.people_alt_outlined),
                selectedIcon: Icon(Icons.people_alt),
                label: 'People',
              ),
              NavigationDestination(
                icon: Obx(() {
                  final pendingCount =
                      leaveRequestController.pendingLeaveRequestsCount;
                  return Badge(
                    isLabelVisible: pendingCount > 0,
                    label: Text(pendingCount.toString()),
                    child: const Icon(Icons.mail_outline_rounded),
                  );
                }),
                selectedIcon: const Icon(Icons.mail),
                label: 'Leave Request',
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> loadData() async {
    final attendanceController = Get.find<AttendanceController>();
    final leaveRequestController = Get.find<LeaveRequestController>();

    attendanceController.isAttendanceLoading = true;
    await attendanceController.loadDataOfClassroom(classroomData);
    await leaveRequestController.loadLeaveRequestData();
    attendanceController.isAttendanceLoading = false;
  }

  void _handleLeaveClass(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Leave Classroom',
              style: textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: textColorDefault,
              ),
            ),
            content: SizedBox(
              width: deviceWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Do you really want to unroll from this classroom?',
                    style: textTheme.bodyMedium!.copyWith(
                      color: textColorDefault,
                    ),
                  ),
                  verticalGap(20),
                  Text(
                    'Course Title',
                    style: textTheme.labelSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColorDefault,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      classroomData.courseTitle,
                      style: textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColorLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await Get.find<ClassroomController>()
                      .leaveClassroom(classroomData);
                  Get.back();
                  Get.back();
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        });
  }
}
