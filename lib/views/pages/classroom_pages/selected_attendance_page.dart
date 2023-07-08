import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visoattend/controller/attendance_controller.dart';
import 'package:visoattend/models/attendance_model.dart';
import 'package:visoattend/views/pages/classroom_pages/present_absent_students_page.dart';

import '../../../controller/navigation_controller.dart';
import '../../../helper/constants.dart';

class SelectedAttendancePage extends GetView<NavigationController> {
  const SelectedAttendancePage({super.key, required this.attendance});

  final AttendanceModel attendance;

  @override
  Widget build(BuildContext context) {
    final width = Get.width;
    final colorScheme = Get.theme.colorScheme;
    final textTheme = Get.theme.textTheme;

    final attendanceController = Get.find<AttendanceController>();

    attendanceController.selectedAttendance = attendance;
    final attendanceDateTime =
        DateTime.fromMillisecondsSinceEpoch(attendance.dateTime);

    final classroomData = attendanceController.classroomData;

    final navigationPages = [
      const PresentAbsentStudentsPage(),
      const PresentAbsentStudentsPage(isPresentDetails: false),
    ];

    return WillPopScope(
      onWillPop: () async {
        controller.changeAttendanceIndex(0);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('d MMMM, y').format(attendanceDateTime),
                style: Get.textTheme.bodyMedium,
              ),
              Text(
                DateFormat.jm().format(attendanceDateTime),
                style: Get.textTheme.bodySmall,
              ),
            ],
          ),
          forceMaterialTransparency: true,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * percentGapMedium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(classroomData.courseTitle, style: textTheme.bodySmall),
                  Text(' (${classroomData.courseCode})',
                      style: textTheme.bodySmall),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(classroomData.section, style: textTheme.bodySmall),
                  Text(' (${classroomData.session})',
                      style: textTheme.bodySmall),
                ],
              ),
              Expanded(
                child: Obx(() {
                  return navigationPages[controller.selectedAttendanceIndex];
                }),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Obx(() {
          return NavigationBar(
            selectedIndex: controller.selectedAttendanceIndex,
            onDestinationSelected: (index) =>
                controller.changeAttendanceIndex(index),
            height: 65,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.check_circle_outline),
                selectedIcon: Icon(Icons.check_circle),
                label: 'Present',
              ),
              NavigationDestination(
                icon: Icon(Icons.do_disturb_on_outlined),
                selectedIcon: Icon(Icons.do_disturb_on),
                label: 'Absent',
              ),
            ],
          );
        }),
      ),
    );
  }
}
