import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visoattend/controller/classroom_controller.dart';
import 'package:visoattend/controller/navigation_controller.dart';
import 'package:visoattend/helper/functions.dart';
import 'package:visoattend/views/pages/classroom_pages/leave_request_page.dart';
import 'package:visoattend/views/pages/classroom_pages/people_page.dart';
import 'package:visoattend/views/pages/create_edit_classroom_page.dart';

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
    final leaveRequestController = Get.find<LeaveRequestController>();
    attendanceController.updateValues(classroomData).then((_) =>
        attendanceController.getUsersData().then((_) =>
            leaveRequestController.getAndFilterClassroomLeaveRequests()));

    final navigationPages = [
      const ClassroomPage(),
      const PeoplePage(),
      const LeaveRequestPage(),
    ];

    return WillPopScope(
      onWillPop: () async {
        if (controller.selectedIndex == 0) {
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
            style: Get.textTheme.bodyLarge,
          ),
          forceMaterialTransparency: true,
          actions: [
            Obx(() {
              final userRole = attendanceController.currentUserRole;
              if (userRole == '') {
                return const SizedBox();
              }
              if (userRole == 'Student') {
                return IconButton(
                  onPressed: () {
                    _handleLeaveClass(context);
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                  ),
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
                icon: Obx(
                  () {
                    final pendingCount = leaveRequestController.pendingLeaveRequestsCount;
                    return Badge(
                      isLabelVisible: pendingCount > 0,
                      label: Text(pendingCount.toString()),
                      child: const Icon(Icons.mail_outline_rounded),
                    );
                  }
                ),
                selectedIcon: const Icon(Icons.mail),
                label: 'Leave Request',
              ),
            ],
          );
        }),
      ),
    );
  }

  void _handleLeaveClass(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Leave Classroom',
              style: Get.textTheme.titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            content: SizedBox(
              width: Get.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Do you really want to leave this classroom?',
                    style: Get.textTheme.bodyMedium,
                  ),
                  verticalGap(20),
                  Text(
                    'Course Title',
                    style: Get.textTheme.labelSmall!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Flexible(
                    child: Text(
                      classroomData.courseTitle,
                      style: Get.textTheme.bodySmall!
                          .copyWith(fontWeight: FontWeight.bold),
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
