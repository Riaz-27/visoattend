import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:visoattend/models/attendance_model.dart';

import '../../../controller/attendance_controller.dart';
import '../../../controller/cloud_firestore_controller.dart';
import '../../../helper/constants.dart';
import '../../../helper/functions.dart';
import '../../../models/classroom_model.dart';
import '../attendance_record_page.dart';

class ClassroomPage extends GetView<AttendanceController> {
  const ClassroomPage({super.key, required this.classroomData});

  final ClassroomModel classroomData;

  @override
  Widget build(BuildContext context) {
    final height = Get.height;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: height * percentGapSmall,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _topView(context: context, classroom: classroomData),
              verticalGap(height * percentGapSmall),
              Text(
                "Attendance History",
                style: Get.textTheme.titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              verticalGap(height * percentGapSmall),
              Flexible(
                child: Obx(() {
                  return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: controller.attendances.length,
                    itemBuilder: (context, index) {
                      return _buildAttendanceListView(
                          attendance: controller.attendances[index]);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Obx(() {
        return controller.currentUserRole == 'Teacher'
            ? FloatingActionButton.extended(
                onPressed: () {
                  if (controller.studentsData.isEmpty) {
                    return;
                  }
                  Get.to(() => const AttendanceRecordPage());
                },
                label: const Text('Take Attendance'),
                icon: const Icon(
                  Icons.add,
                  size: 18,
                ),
                extendedPadding: const EdgeInsets.symmetric(
                  horizontal: kSmall,
                ),
                extendedIconLabelSpacing: 0,
                extendedTextStyle: Get.textTheme.labelMedium,
              )
            : const SizedBox();
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildAttendanceListView({required AttendanceModel attendance}) {
    final height = Get.height;
    final width = Get.width;
    final dateTime = DateTime.fromMillisecondsSinceEpoch(attendance.dateTime);

    final currentUser = Get.find<CloudFirestoreController>().currentUser;
    final presentStatus = attendance.studentsData[currentUser.authUid];
    final userRole = controller.currentUserRole;
    final color = presentStatus == 'Absent'
        ? Get.theme.colorScheme.error
        : Get.theme.colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(bottom: height * percentGapSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Get.theme.colorScheme.surfaceVariant.withAlpha(100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kSmall),
        child: Row(
          children: [
            Text(
              dateTime.day.toString(),
              style: Get.textTheme.displaySmall!
                  .copyWith(color: Get.theme.colorScheme.onBackground),
            ),
            horizontalGap(width * percentGapSmall),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMMM y').format(dateTime),
                  style: Get.textTheme.titleSmall,
                ),
                Text(
                  DateFormat.jm().format(dateTime),
                  style: Get.textTheme.bodySmall,
                ),
              ],
            ),
            const Spacer(),
            if (userRole == 'Student')
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    presentStatus ?? '',
                    style: Get.textTheme.titleSmall!.copyWith(color: color),
                  ),
                  Text(
                    'by ${attendance.takenBy['name']}',
                    style: Get.textTheme.bodySmall,
                  ),
                ],
              ),
            if (userRole != 'Student') const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _topView({
    required BuildContext context,
    required ClassroomModel classroom,
  }) {
    final height = Get.height;
    final width = Get.width;

    return Container(
      height: height * 0.28,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Get.theme.colorScheme.surfaceVariant.withAlpha(100),
      ),
      padding: const EdgeInsets.all(kSmall),
      child: Row(
        children: [
          horizontalGap(width * percentGapVerySmall),
          Obx(() {
            // Calculation Missed class
            final missedClasses = controller.currentUserMissedClasses;
            final totalClasses = controller.attendances.length;
            final percent = (totalClasses - missedClasses) / totalClasses;
            String status = 'Collegiate';
            Color color = Get.theme.colorScheme.primary;
            if (percent < 0.6) {
              color = Get.theme.colorScheme.error;
              status = 'Dis-Collegiate';
            } else if (percent < 0.7) {
              color = Colors.orange;
              status = 'Non-Collegiate';
            }

            return Column(
              children: [
                verticalGap(height * percentGapSmall),
                CircularPercentIndicator(
                  radius: height * 0.08,
                  lineWidth: 12,
                  percent: totalClasses > 0 ? percent : 0,
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: color,
                  backgroundColor:
                      Get.theme.colorScheme.onBackground.withAlpha(15),
                  animation: true,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        totalClasses > 0
                            ? '${(percent * 100).toStringAsFixed(0)}%'
                            : 'N/A',
                        style: Get.textTheme.titleLarge,
                      ),
                      Text(
                        status,
                        style: Get.textTheme.labelSmall!.copyWith(color: color),
                      ),
                    ],
                  ),
                ),
                verticalGap(height * percentGapSmall),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircularPercentIndicator(
                      radius: height * 0.023,
                      lineWidth: 7,
                      percent:
                          totalClasses > 0 ? missedClasses / totalClasses : 0,
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: Get.theme.colorScheme.error,
                      backgroundColor:
                          Get.theme.colorScheme.onBackground.withAlpha(15),
                      animation: true,
                      center: Text(
                        missedClasses.toString(),
                        style: Get.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: missedClasses > 0
                              ? Get.theme.colorScheme.error
                              : Get.theme.colorScheme.onBackground,
                        ),
                      ),
                    ),
                    horizontalGap(width * percentGapSmall),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        verticalGap(height * percentGapVerySmall),
                        Text(
                          'Missed Classes',
                          style: Get.textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Get.theme.colorScheme.error,
                          ),
                        ),
                        Text(
                          'Out of $totalClasses classes',
                          style: Get.textTheme.bodySmall!,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          }),
          horizontalGap(width * 0.05),
          Expanded(
            child: Obx(() {
              //finding class schedule
              String? scheduleText = "Today's class";
              DateTime nextDate = DateTime.now();
              String startTime = classroom
                  .weekTimes[DateFormat('EEEE').format(nextDate)]['startTime'];
              String endTime = classroom
                  .weekTimes[DateFormat('EEEE').format(nextDate)]['endTime'];
              String roomNo = classroom
                  .weekTimes[DateFormat('EEEE').format(nextDate)]['room'];

              if (startTime == 'Off Day' ||
                  (endTime != 'Off Day' &&
                      DateTime.parse(endTime)
                          .copyWith(
                              day: nextDate.day,
                              month: nextDate.month,
                              year: nextDate.year)
                          .isBefore(DateTime.now()))) {
                scheduleText = 'Next class';
                for (int i = 1; i <= 7; i++) {
                  nextDate = DateTime.now().add(Duration(days: i));
                  startTime =
                      classroom.weekTimes[DateFormat('EEEE').format(nextDate)]
                          ['startTime'];
                  endTime =
                      classroom.weekTimes[DateFormat('EEEE').format(nextDate)]
                          ['endTime'];
                  roomNo = classroom
                      .weekTimes[DateFormat('EEEE').format(nextDate)]['room'];
                  if (startTime != 'Off Day') {
                    break;
                  }
                  if (i == 7) {
                    scheduleText = null;
                  }
                }
              }
              if (scheduleText != null) {
                if (scheduleText.contains('Next')) {
                  scheduleText +=
                      ' - ${DateFormat('E, d MMMM').format(nextDate)}';
                }
                startTime = DateFormat.jm().format(DateTime.parse(startTime));
                endTime = DateFormat.jm().format(DateTime.parse(endTime));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  controller.currentUserRole == 'Teacher'
                      ? GestureDetector(
                          onTap: () async {
                            await Clipboard.setData(
                                    ClipboardData(text: classroom.classroomId))
                                .then((value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                    "Classroom ID copied to clipboard",
                                  ),
                                ),
                              );
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Copy Code',
                                style: Get.textTheme.bodySmall,
                              ),
                              horizontalGap(width * percentGapVerySmall),
                              Icon(
                                Icons.copy_rounded,
                                size: 18,
                                color: Get.textTheme.bodySmall!.color,
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          height: height * percentGapSmall,
                        ),
                  verticalGap(height * percentGapVerySmall),
                  Text(
                    classroom.courseTitle,
                    style: Get.textTheme.labelMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  verticalGap(height * percentGapVerySmall),
                  Row(
                    children: [
                      Text(
                        'Code: ',
                        style: Get.textTheme.labelSmall!.copyWith(
                          color:
                              Get.theme.colorScheme.onBackground.withAlpha(150),
                        ),
                      ),
                      Text(
                        classroom.courseCode,
                        style: Get.textTheme.labelMedium,
                      ),
                    ],
                  ),
                  verticalGap(height * percentGapVerySmall),
                  Row(
                    children: [
                      Text(
                        classroom.section.isEmpty ? '' : 'Section: ',
                        style: Get.textTheme.labelSmall!.copyWith(
                          color:
                              Get.theme.colorScheme.onBackground.withAlpha(150),
                        ),
                      ),
                      Text(
                        classroom.section,
                        style: Get.textTheme.labelMedium,
                      ),
                    ],
                  ),
                  verticalGap(height * percentGapSmall),
                  Text(
                    scheduleText ?? 'Schedule not set yet',
                    style: Get.textTheme.labelSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Get.theme.colorScheme.onBackground.withAlpha(150),
                    ),
                  ),
                  verticalGap(height * percentGapVerySmall),
                  Row(
                    children: [
                      if (roomNo != '') ...[
                        const Icon(
                          Icons.location_pin,
                          size: 14,
                        ),
                        Text(
                          'Room No: ',
                          style: Get.textTheme.labelSmall!.copyWith(
                              color: Get.theme.colorScheme.onBackground
                                  .withAlpha(150)),
                        ),
                        Text(
                          roomNo,
                          style: Get.textTheme.labelMedium,
                        ),
                      ],
                    ],
                  ),
                  verticalGap(height * 0.015),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (scheduleText != null) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From',
                              style: Get.textTheme.labelSmall!.copyWith(
                                color: Get.theme.colorScheme.onBackground
                                    .withAlpha(150),
                              ),
                            ),
                            verticalGap(height * percentGapVerySmall),
                            Text(
                              startTime,
                              style: Get.textTheme.labelMedium,
                            ),
                          ],
                        ),
                        horizontalGap(width * 0.08),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'To',
                              style: Get.textTheme.labelSmall!.copyWith(
                                color: Get.theme.colorScheme.onBackground
                                    .withAlpha(150),
                              ),
                            ),
                            verticalGap(height * percentGapVerySmall),
                            Text(
                              endTime,
                              style: Get.textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ]
                    ],
                  )
                ],
              );
            }),
          )
        ],
      ),
    );
  }
}
