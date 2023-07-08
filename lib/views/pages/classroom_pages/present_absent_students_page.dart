import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/attendance_controller.dart';
import '../../../helper/constants.dart';
import '../../../helper/functions.dart';
import '../../widgets/custom_button.dart';

class PresentAbsentStudentsPage extends StatelessWidget {
  const PresentAbsentStudentsPage({super.key, this.isPresentDetails = true});

  final bool isPresentDetails;

  @override
  Widget build(BuildContext context) {
    final height = Get.height;
    final width = Get.width;
    final colorScheme = Get.theme.colorScheme;
    final textTheme = Get.textTheme;

    final attendanceController = Get.find<AttendanceController>()..filterSearchResult('', isPresentDetails);
    final studentsData = attendanceController.filteredStudents;
    final totalStudents = attendanceController.classroomData.cRs.length + attendanceController.classroomData.students.length;
    final searchController = TextEditingController();

    return Scaffold(
      body: Obx(
        () {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search by ID or Name',
                  labelStyle: Get.textTheme.bodyMedium,
                  isDense: true,
                  alignLabelWithHint: true,
                ),
                onChanged: (value) => attendanceController.filterSearchResult(value, isPresentDetails),
              ),
              verticalGap(height * percentGapSmall),
              Text(
                '${studentsData.length}/$totalStudents students',
                style:
                    textTheme.bodyMedium!.copyWith(color: isPresentDetails ? colorScheme.primary : colorScheme.error),
              ),
              verticalGap(height * percentGapMedium),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: studentsData.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        _buildUsersList(studentsData[index]),
                        if (studentsData.length > 1)
                          const Divider(thickness: 0.3),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildUsersList(Map<String, dynamic> student) {
    final height = Get.height;
    final width = Get.width;
    final textTheme = Get.textTheme;
    final colorScheme = Get.theme.colorScheme;

    String picUrl =
        'https://firebasestorage.googleapis.com/v0/b/visoattend.appspot.com/o/profile_pics%2Fdefault_profile.jpg?alt=media&token=0ff37477-4ac1-41df-8522-73a5eacceee7';

    return GestureDetector(
      onTap: () {
        final attendanceController = Get.find<AttendanceController>();
        final attendance = attendanceController.selectedAttendance;
        attendanceController.selectedAttendanceStatus =
            attendance.studentsData[student['authUid']] ?? 'Absent';

        _handleUpdateAttendanceStatus(student);
      },
      child: Container(
        color: colorScheme.surface,
        child: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(picUrl),
                ),
              ),
            ),
            horizontalGap(width * percentGapLarge),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'],
                  style: textTheme.bodyMedium!,
                ),
                Text(
                  student['userId'],
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleUpdateAttendanceStatus(Map<String, dynamic> student) {
    final height = Get.height;
    final width = Get.width;
    final textTheme = Get.theme.textTheme;
    final colorScheme = Get.theme.colorScheme;

    final attendanceController = Get.find<AttendanceController>();

    Get.bottomSheet(
      backgroundColor: colorScheme.surface,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(height * percentGapMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${student['name']}',
              style: textTheme.titleLarge,
            ),
            Text(
              '${student['userId']}',
              style: textTheme.titleSmall,
            ),
            verticalGap(height * percentGapMedium),
            Text(
              'Change Attendance',
              style: textTheme.bodySmall,
            ),
            Obx(() {
              return Column(
                children: [
                  RadioListTile.adaptive(
                    contentPadding: const EdgeInsets.all(0),
                    value: 'Present',
                    groupValue: attendanceController.selectedAttendanceStatus,
                    onChanged: (value) {
                      attendanceController.selectedAttendanceStatus = value!;
                    },
                    title: Text(
                      'Present',
                      style: textTheme.bodyLarge!
                          .copyWith(color: colorScheme.primary),
                    ),
                  ),
                  RadioListTile.adaptive(
                    contentPadding: const EdgeInsets.all(0),
                    value: 'Absent',
                    groupValue: attendanceController.selectedAttendanceStatus,
                    onChanged: (value) {
                      attendanceController.selectedAttendanceStatus = value!;
                    },
                    title: Text(
                      'Absent',
                      style: textTheme.bodyLarge!
                          .copyWith(color: colorScheme.error),
                    ),
                    activeColor: colorScheme.error,
                  ),
                ],
              );
            }),
            verticalGap(height * percentGapMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  height: height * 0.05,
                  width: width * 0.4,
                  backgroundColor: colorScheme.onSurface,
                  textColor: colorScheme.surface,
                  text: 'Cancel',
                  onPressed: () {
                    Get.back();
                  },
                ),
                CustomButton(
                  height: height * 0.05,
                  width: width * 0.4,
                  text: 'Confirm',
                  onPressed: () async {
                    await attendanceController.changeStudentAttendanceStatus(
                      student: student,
                    );
                    Get.back();
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
