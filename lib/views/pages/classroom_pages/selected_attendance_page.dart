import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controller/cloud_firestore_controller.dart';
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
    controller.selectedAttendance = attendance;
    final studentsData = controller.filteredStudents;
    final totalStudents = controller.allStudents.length;
    final classroomData = controller.classroomData;

    final searchController = TextEditingController();

    return WillPopScope(
      onWillPop: () async {
        if(Get.isDialogOpen ?? false) return false;
        controller.selectedCategory = '';
        controller.updateValues(controller.classroomData);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('d MMMM, y').format(controller.selectedDateTime),
                  style: textTheme.bodyMedium!.copyWith(
                    color: textColorDefault,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      DateFormat.jm().format(controller.selectedDateTime),
                      style: textTheme.bodySmall!.copyWith(
                        color: textColorLight,
                      ),
                    ),
                    Text(
                      ' | ${classroomData.courseCode}',
                      style: textTheme.bodySmall!.copyWith(
                        color: textColorLight,
                      ),
                    ),
                    Text(
                      ' | ${classroomData.section}',
                      style: textTheme.bodySmall!.copyWith(
                        color: textColorLight,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
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
                            handleEditAttendance(context, attendance);
                            break;
                          case 'delete':
                            handleDeleteAttendance(context, attendance,
                                selected: true);
                            break;
                        }
                      },
                    )
                  : const SizedBox();
            }),
          ],
        ),
        body: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: deviceWidth * percentGapMedium),
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
                  style: textTheme.labelLarge!.copyWith(
                    color: textColorDefault,
                  ),
                  hintText: 'Search by ID or Name',
                  onChanged: (value) {
                    controller.selectedCategory = '';
                    controller.filterSearchResult(value);
                  },
                ),
                verticalGap(deviceHeight * percentGapVerySmall),
                _buildFilterChip(),
                verticalGap(deviceHeight * percentGapVerySmall),
                Text(
                  studentsText,
                  style: textTheme.bodySmall!.copyWith(color: textColorLight),
                ),
                verticalGap(deviceHeight * percentGapMedium),
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
    final selectedCategory = controller.selectedCategory;

    final chipCategories = ['Present', 'Absent', 'Taken Leave'];
    return Row(
      children: chipCategories.map((category) {
        Color selectColor = colorScheme.primary;
        Color backgroundColor = colorScheme.secondaryContainer;
        if (category == 'Absent') {
          selectColor = colorScheme.error;
          backgroundColor = colorScheme.errorContainer;
        } else if (category.contains('Leave')) {
          selectColor = Colors.amber.shade700;
          backgroundColor = Colors.amber.shade100;
        }
        return Row(
          children: [
            FilterChip(
              showCheckmark: false,
              selectedColor: selectColor.withOpacity(0.7),
              backgroundColor: backgroundColor.withOpacity(0.8),
              side: BorderSide.none,
              label: Text(
                category,
                style: textTheme.labelMedium!.copyWith(
                  color: selectedCategory == category
                      ? Colors.white
                      : colorScheme.onBackground,
                ),
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
            horizontalGap(deviceWidth * percentGapMedium),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildUsersList(UserModel student) {
    final attendance = controller.selectedAttendance;
    final studentStatus =
        attendance.studentsData[student.authUid] as String? ?? 'Absent';
    final classroomData = controller.classroomData;
    Color color = colorScheme.primary;
    if (studentStatus.contains('Leave')) {
      color = Colors.amber;
    } else if (studentStatus == 'Absent') {
      color = colorScheme.error;
    }
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
            horizontalGap(deviceWidth * percentGapLarge),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style:
                      textTheme.bodyMedium!.copyWith(color: textColorDefault),
                ),
                Text(
                  student.userId,
                  style: textTheme.bodySmall!.copyWith(color: textColorLight),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: color,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _handleUpdateAttendanceStatus(UserModel student) {
    final studentStatus = controller
            .selectedAttendance.studentsData[student.authUid] as String? ??
        'Absent';
    // Color color = colorScheme.primary;
    // if (studentStatus.contains('Leave')) {
    //   color = Colors.amber;
    // } else if (studentStatus == 'Absent') {
    //   color = colorScheme.error;
    // }

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
        padding: EdgeInsets.all(deviceHeight * percentGapMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              student.name,
              style: textTheme.titleLarge!.copyWith(color: textColorDefault),
            ),
            Text(
              student.userId,
              style: textTheme.titleSmall!.copyWith(color: textColorDefault),
            ),
            verticalGap(deviceHeight * percentGapMedium),
            Text(
              'Change Attendance',
              style: textTheme.bodySmall!.copyWith(color: textColorLight),
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
                    value: 'Present(Leave)',
                    groupValue: controller.selectedAttendanceStatus,
                    onChanged: (value) {
                      controller.selectedAttendanceStatus = value!;
                    },
                    title: Text(
                      'Taken Leave',
                      style: textTheme.bodyLarge!
                          .copyWith(color: Colors.orangeAccent),
                    ),
                    activeColor: Colors.orangeAccent,
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
            verticalGap(deviceHeight * percentGapMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  height: deviceHeight * 0.05,
                  width: deviceWidth * 0.4,
                  backgroundColor: colorScheme.onSurface,
                  textColor: colorScheme.surface,
                  text: 'Cancel',
                  onPressed: () {
                    Get.back();
                  },
                ),
                CustomButton(
                  height: deviceHeight * 0.05,
                  width: deviceWidth * 0.4,
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

// void _handleEditAttendance(BuildContext context) {
//   controller.selectedDateTime =
//       DateTime.fromMillisecondsSinceEpoch(attendance.dateTime);
//   showDialog(
//     barrierDismissible: false,
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: Text(
//           'Edit Attendance',
//           style: textTheme.titleMedium!.copyWith(
//             fontWeight: FontWeight.bold,
//             color: textColorDefault,
//           ),
//         ),
//         content: SizedBox(
//           width: deviceWidth,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Change date and time of classroom',
//                 style: textTheme.bodyMedium!.copyWith(
//                   color: textColorDefault,
//                 ),
//               ),
//               verticalGap(deviceHeight * percentGapSmall),
//               Obx(() {
//                 return Row(
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Date',
//                           style: textTheme.bodySmall!
//                               .copyWith(color: textColorLight),
//                         ),
//                         verticalGap(deviceHeight * percentGapVerySmall),
//                         _customInkWellButton(
//                           onTap: () async {
//                             final picked = await showDatePicker(
//                               context: context,
//                               initialDate: controller.selectedDateTime,
//                               firstDate: DateTime.now()
//                                   .add(const Duration(days: -365)),
//                               lastDate: DateTime.now()
//                                   .add(const Duration(days: 365)),
//                             );
//                             if (picked != null) {
//                               controller.selectedDateTime =
//                                   controller.selectedDateTime.copyWith(
//                                 day: picked.day,
//                                 month: picked.month,
//                                 year: picked.year,
//                               );
//                             }
//                           },
//                           text: DateFormat('dd MMMM, y')
//                               .format(controller.selectedDateTime),
//                         ),
//                       ],
//                     ),
//                     horizontalGap(deviceWidth * percentGapLarge),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Time',
//                           style: textTheme.bodySmall!.copyWith(
//                             color: textColorLight,
//                           ),
//                         ),
//                         verticalGap(deviceHeight * percentGapVerySmall),
//                         _customInkWellButton(
//                           onTap: () async {
//                             final picked = await showTimePicker(
//                               context: context,
//                               initialTime: TimeOfDay.fromDateTime(
//                                   controller.selectedDateTime),
//                             );
//                             if (picked != null) {
//                               controller.selectedDateTime =
//                                   controller.selectedDateTime.copyWith(
//                                 hour: picked.hour,
//                                 minute: picked.minute,
//                               );
//                             }
//                           },
//                           text: DateFormat('hh:mm a')
//                               .format(controller.selectedDateTime),
//                         ),
//                       ],
//                     ),
//                   ],
//                 );
//               }),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               controller.selectedDateTime =
//                   DateTime.fromMillisecondsSinceEpoch(attendance.dateTime);
//               Get.back();
//             },
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               attendance.dateTime =
//                   controller.selectedDateTime.millisecondsSinceEpoch;
//               await controller.updateAttendanceDateTime(attendance);
//               Get.back();
//             },
//             child: const Text('Save'),
//           ),
//         ],
//       );
//     },
//   );
// }
//
// Widget _customInkWellButton({Function()? onTap, required String text}) {
//   return InkWell(
//     customBorder: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(10),
//     ),
//     onTap: onTap,
//     child: Container(
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//       decoration: BoxDecoration(
//         color: colorScheme.surfaceTint.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Text(text),
//     ),
//   );
// }
//
// void _handleDeleteAttendance(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: Text(
//           'Delete Attendance',
//           style: textTheme.titleMedium!.copyWith(
//             fontWeight: FontWeight.bold,
//             color: textColorDefault,
//           ),
//         ),
//         content: SizedBox(
//           width: deviceWidth,
//           child: Text(
//             'Do you really want to delete this attendance data?',
//             style: textTheme.bodyMedium!.copyWith(color: textColorDefault),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('No'),
//           ),
//           TextButton(
//             onPressed: () async {
//               await controller.deleteAttendance(attendance);
//               Get.back();
//               Get.back();
//             },
//             child: const Text('Yes'),
//           ),
//         ],
//       );
//     },
//   );
// }
}
