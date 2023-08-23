import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/attendance_controller.dart';
import '../models/attendance_model.dart';
import 'constants.dart';

/// For UI

Widget verticalGap(double height) => SizedBox(height: height);

Widget horizontalGap(double width) => SizedBox(width: width);

void loadingDialog([String? msg]) {
  Get.dialog(
    barrierDismissible: false,
    Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 8),
            Text(
              msg ?? '',
              style: textTheme.titleSmall!.copyWith(
                color: textColorDefault,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void errorDialog({required String title, required String msg}) {
  Get.dialog(
    barrierDismissible: false,
    AlertDialog(
      title: Text(
        title,
        style: textTheme.titleMedium!.copyWith(color: textColorDefault),
      ),
      content: Text(
        msg,
        style: textTheme.bodyMedium!.copyWith(color: textColorDefault),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Ok'),
        ),
      ],
    ),
  );
}

void hideLoadingDialog() {
  if (Get.isDialogOpen ?? false) Get.back();
}

void handleEditAttendance(BuildContext context, AttendanceModel attendance) {
  final attendanceController = Get.find<AttendanceController>();
  attendanceController.selectedDateTime =
      DateTime.fromMillisecondsSinceEpoch(attendance.dateTime);
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Edit Attendance',
          style: textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: textColorDefault,
          ),
        ),
        content: SizedBox(
          width: deviceWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change date and time of classroom',
                style: textTheme.bodyMedium!.copyWith(
                  color: textColorDefault,
                ),
              ),
              verticalGap(deviceHeight * percentGapSmall),
              Obx(() {
                return Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: textTheme.bodySmall!
                              .copyWith(color: textColorLight),
                        ),
                        verticalGap(deviceHeight * percentGapVerySmall),
                        _customInkWellButton(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  attendanceController.selectedDateTime,
                              firstDate: DateTime.now()
                                  .add(const Duration(days: -365)),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              attendanceController.selectedDateTime =
                                  attendanceController.selectedDateTime
                                      .copyWith(
                                day: picked.day,
                                month: picked.month,
                                year: picked.year,
                              );
                            }
                          },
                          text: DateFormat('dd MMMM, y')
                              .format(attendanceController.selectedDateTime),
                        ),
                      ],
                    ),
                    horizontalGap(deviceWidth * percentGapLarge),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time',
                          style: textTheme.bodySmall!.copyWith(
                            color: textColorLight,
                          ),
                        ),
                        verticalGap(deviceHeight * percentGapVerySmall),
                        _customInkWellButton(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                  attendanceController.selectedDateTime),
                            );
                            if (picked != null) {
                              attendanceController.selectedDateTime =
                                  attendanceController.selectedDateTime
                                      .copyWith(
                                hour: picked.hour,
                                minute: picked.minute,
                              );
                            }
                          },
                          text: DateFormat('hh:mm a')
                              .format(attendanceController.selectedDateTime),
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
              attendanceController.selectedDateTime =
                  DateTime.fromMillisecondsSinceEpoch(attendance.dateTime);
              Get.back();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              attendance.dateTime =
                  attendanceController.selectedDateTime.millisecondsSinceEpoch;
              await attendanceController.updateAttendanceDateTime(attendance);
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

void handleDeleteAttendance(BuildContext context, AttendanceModel attendance,
    {bool selected = false}) {
  final attendanceController = Get.find<AttendanceController>();
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Delete Attendance',
          style: textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: textColorDefault,
          ),
        ),
        content: SizedBox(
          width: deviceWidth,
          child: Text(
            'Do you really want to delete this attendance data?',
            style: textTheme.bodyMedium!.copyWith(color: textColorDefault),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await attendanceController.deleteAttendance(attendance);
              Get.back();
              if (selected) Get.back();
            },
            child: Text(
              'Yes',
              style: textTheme.bodyMedium!.copyWith(color: colorScheme.error),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
        ],
      );
    },
  );
}
