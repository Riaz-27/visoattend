import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visoattend/controller/navigation_controller.dart';
import 'package:visoattend/helper/constants.dart';
import 'package:visoattend/views/pages/classroom_pages/leave_request_page.dart';
import 'package:visoattend/views/pages/classroom_pages/people_page.dart';
import 'package:visoattend/views/pages/create_edit_classroom_page.dart';

import '../../controller/attendance_controller.dart';
import '../../models/classroom_model.dart';
import 'classroom_pages/classroom_page.dart';

class DetailedClassroomPage extends GetView<NavigationController> {
  const DetailedClassroomPage({super.key, required this.classroomData});

  final ClassroomModel classroomData;

  @override
  Widget build(BuildContext context) {
    final attendanceController = Get.find<AttendanceController>();
    attendanceController
        .updateValues(classroomData)
        .then((_) => attendanceController.getStudentsData());

    final navigationPages = [
      ClassroomPage(classroomData: classroomData),
      PeoplePage(classroom: classroomData),
      const LeaveRequestPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          classroomData.courseTitle,
          style: Get.textTheme.bodyLarge,
        ),
        forceMaterialTransparency: true,
        actions: [
            Obx(
              () {
                return attendanceController.currentUserRole != 'Student'?  IconButton(
                  onPressed: () {
                    Get.to(() => CreateEditClassroomPage(
                          isEdit: true,
                          classroom: classroomData,
                        ));
                  },
                  icon: const Icon(Icons.settings),
                ) : const SizedBox();
              }
            )
        ],
      ),
      body: Obx(() {
        return navigationPages[controller.selectedIndex];
      }),
      bottomNavigationBar: Obx(() {
        return NavigationBar(
          selectedIndex: controller.selectedIndex,
          onDestinationSelected: (index) => controller.changeIndex(index),
          height: 65,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.class_outlined),
              selectedIcon: Icon(Icons.class_rounded),
              label: 'Classroom',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_alt_outlined),
              selectedIcon: Icon(Icons.people_alt),
              label: 'People',
            ),
            NavigationDestination(
              icon: Icon(Icons.mail_outline_rounded),
              selectedIcon: Icon(Icons.mail),
              label: 'Leave Request',
            ),
          ],
        );
      }),
    );
  }
}
