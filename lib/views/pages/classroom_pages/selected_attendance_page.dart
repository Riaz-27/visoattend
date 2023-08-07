import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visoattend/controller/cloud_firestore_controller.dart';

import '../../../controller/attendance_controller.dart';
import '../../../helper/constants.dart';
import '../../../helper/functions.dart';
import '../../../models/attendance_model.dart';
import '../../../models/user_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class SelectedAttendancePage extends GetView<AttendanceController> {
  const SelectedAttendancePage({super.key, required this.attendance});

  final AttendanceModel attendance;

  @override
  Widget build(BuildContext context) {
    final height = Get.height;
    final width = Get.width;
    final textTheme = Get.textTheme;

    controller.selectedAttendance = attendance;
    final studentsData = controller.filteredStudents;
    final totalStudents = controller.allStudents.length;
    final classroomData = controller.classroomData;

    final searchController = TextEditingController();

    print(attendance.attendanceId.toString());

    return WillPopScope(
      onWillPop: () async {
        controller.selectedCategory = '';
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: Obx(
            () {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('d MMMM, y').format(controller.selectedDateTime),
                    style: Get.textTheme.bodyMedium,
                  ),
                  Row(
                    children: [
                      Text(
                        DateFormat.jm().format(controller.selectedDateTime),
                        style: Get.textTheme.bodySmall,
                      ),
                      Text(
                        ' | ${classroomData.courseCode}',
                        style: Get.textTheme.bodySmall,
                      ),
                      Text(
                        ' | ${classroomData.section}',
                        style: Get.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              );
            }
          ),
          actions: [
            Obx(() {
              final currentUserRole = controller.currentUserRole;
              final currentUser =
                  Get.find<CloudFirestoreController>().currentUser;
              return (currentUserRole == 'Teacher' ||
                      (currentUserRole == 'CR' &&
                          attendance.takenBy['authUid'] == currentUser.authUid))
                  ? PopupMenuButton(
                      position: PopupMenuPosition.under,
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            _handleEditAttendance(context);
                            break;
                          case 'delete':
                            _handleDeleteAttendance(context);
                            break;
                        }
                      },
                    )
                  : const SizedBox();
            }),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * percentGapMedium),
          child: Obx(() {
            final studentsText = controller.selectedCategory == ''
                ? '$totalStudents Students'
                : '${studentsData.length}/$totalStudents Students';
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  controller: searchController,
                  style: textTheme.labelLarge,
                  hintText: 'Search by ID or Name',
                  onChanged: (value) {
                    controller.selectedCategory = '';
                    controller.filterSearchResult(value);
                  },
                ),
                verticalGap(height * percentGapVerySmall),
                _buildFilterChip(),
                verticalGap(height * percentGapVerySmall),
                Text(
                  studentsText,
                  style: textTheme.bodySmall,
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
          }),
        ),
      ),
    );
  }

  Widget _buildFilterChip() {
    final width = Get.width;
    final colorScheme = Get.theme.colorScheme;
    final textTheme = Get.theme.textTheme;
    final selectedCategory = controller.selectedCategory;

    final chipCategories = ['Present', 'Absent'];
    return Row(
      children: chipCategories
          .map(
            (category) => Row(
              children: [
                FilterChip(
                  showCheckmark: false,
                  selectedColor: category == 'Present'
                      ? colorScheme.primary.withOpacity(0.7)
                      : colorScheme.error.withOpacity(0.7),
                  backgroundColor: category == 'Present'
                      ? colorScheme.secondaryContainer.withOpacity(0.8)
                      : colorScheme.errorContainer.withOpacity(0.8),
                  side: BorderSide.none,
                  label: Text(
                    category,
                    style: textTheme.labelMedium!.copyWith(
                        color: selectedCategory == category
                            ? Colors.white
                            : colorScheme.onBackground),
                  ),
                  selected: selectedCategory == category,
                  onSelected: (selected) {
                    if (selected) {
                      controller.selectedCategory = category;
                    } else {
                      controller.selectedCategory = '';
                    }
                    controller.selectedCategoryResult();
                  },
                ),
                horizontalGap(width * percentGapMedium),
              ],
            ),
          )
          .toList(),
    );
  }

  Widget _buildUsersList(UserModel student) {
    final height = Get.height;
    final width = Get.width;
    final textTheme = Get.textTheme;
    final colorScheme = Get.theme.colorScheme;

    final attendance = controller.selectedAttendance;
    final studentStatus = attendance.studentsData[student.authUid] ?? 'Absent';
    final classroomData = controller.classroomData;
    return GestureDetector(
      onTap: () {
        if (classroomData.isArchived) return;

        controller.selectedAttendanceStatus = studentStatus;

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
                  image: NetworkImage(student.profilePic),
                ),
              ),
            ),
            horizontalGap(width * percentGapLarge),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: textTheme.bodyMedium!,
                ),
                Text(
                  student.userId,
                  style: textTheme.bodySmall,
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: studentStatus[0] == 'P'
                    ? colorScheme.primary
                    : colorScheme.error,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _handleUpdateAttendanceStatus(UserModel student) {
    final height = Get.height;
    final width = Get.width;
    final textTheme = Get.theme.textTheme;
    final colorScheme = Get.theme.colorScheme;

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
              student.name,
              style: textTheme.titleLarge,
            ),
            Text(
              student.userId,
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
                    groupValue: controller.selectedAttendanceStatus,
                    onChanged: (value) {
                      controller.selectedAttendanceStatus = value!;
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
                    groupValue: controller.selectedAttendanceStatus,
                    onChanged: (value) {
                      controller.selectedAttendanceStatus = value!;
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
                    await controller.changeStudentAttendanceStatus(
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

  void _handleEditAttendance(BuildContext context) {
    controller.selectedDateTime =
        DateTime.fromMillisecondsSinceEpoch(attendance.dateTime);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Edit Attendance',
            style: Get.textTheme.titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: Get.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Change date and time of classroom',
                  style: Get.textTheme.bodyMedium,
                ),
                verticalGap(height * percentGapSmall),
                Obx(() {
                  return Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date', style: textTheme.bodySmall),
                          verticalGap(height * percentGapVerySmall),
                          _customInkWellButton(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: controller.selectedDateTime,
                                firstDate: DateTime.now()
                                    .add(const Duration(days: -365)),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                controller.selectedDateTime =
                                    controller.selectedDateTime.copyWith(
                                  day: picked.day,
                                  month: picked.month,
                                  year: picked.year,
                                );
                              }
                            },
                            text: DateFormat('dd MMMM, y')
                                .format(controller.selectedDateTime),
                          ),
                        ],
                      ),
                      horizontalGap(width * percentGapLarge),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Time', style: textTheme.bodySmall),
                          verticalGap(height * percentGapVerySmall),
                          _customInkWellButton(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                    controller.selectedDateTime),
                              );
                              if (picked != null) {
                                controller.selectedDateTime =
                                    controller.selectedDateTime.copyWith(
                                  hour: picked.hour,
                                  minute: picked.minute,
                                );
                              }
                            },
                            text: DateFormat('hh:mm a')
                                .format(controller.selectedDateTime),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.selectedDateTime =
                    DateTime.fromMillisecondsSinceEpoch(attendance.dateTime);
                Get.back();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                attendance.dateTime =
                    controller.selectedDateTime.millisecondsSinceEpoch;
                await controller.updateAttendanceDateTime(attendance);
                Get.back();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _customInkWellButton({Function()? onTap, required String text}) {
    return InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: colorScheme.surfaceTint.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text),
      ),
    );
  }

  void _handleDeleteAttendance(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete Attendance',
            style: Get.textTheme.titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: Get.width,
            child: Text(
              'Do you really want to delete this attendance data?',
              style: Get.textTheme.bodyMedium,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await controller.deleteAttendance(attendance);
                Get.back();
                Get.back();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
