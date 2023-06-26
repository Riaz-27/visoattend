import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:visoattend/controller/auth_controller.dart';
import 'package:visoattend/models/attendance_model.dart';
import 'package:visoattend/views/pages/auth_page.dart';

import '../../controller/attendance_controller.dart';
import '../../controller/cloud_firestore_controller.dart';
import '../../helper/constants.dart';
import '../../helper/functions.dart';
import '../../models/classroom_model.dart';
import 'attendance_record_page.dart';

class ClassroomPage extends GetView<AttendanceController> {
  const ClassroomPage({super.key, required this.classroomData});

  final ClassroomModel classroomData;

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    controller
        .updateValues(classroomData)
        .then((_) => controller.getStudentsData());

    final height = Get.height;
    final width = Get.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          classroomData.courseTitle,
          style: Get.textTheme.bodyLarge,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await authController.signOut();
              Get.offAll(() => const AuthPage());
            },
            icon: const Icon(Icons.logout_rounded),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: height * percentGapSmall,
          right: height * percentGapSmall,
          left: height * percentGapSmall,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topView(context: context, classroom: classroomData),
            verticalGap(height * percentGapMedium),
            Text(
              "Attendance History",
              style: Get.textTheme.titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            verticalGap(height * percentGapMedium),
            Expanded(
              child: Obx(() {
                return ListView.builder(
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
      floatingActionButton: Obx(() {
        return controller.currentUserRole == 'Teacher'
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                ),
                onPressed: () {
                  if (controller.studentsData.isEmpty) {
                    return;
                  }
                  Get.to(() => const AttendanceRecordPage());
                },
                child: const Text('Take Attendance'),
              )
            : const SizedBox();
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
        color: Get.theme.colorScheme.surfaceVariant.withAlpha(150),
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
        color: Get.theme.colorScheme.surfaceVariant.withAlpha(150),
      ),
      padding: const EdgeInsets.all(kSmall),
      child: Row(
        children: [
          horizontalGap(width * percentGapSmall),
          Obx(
             () {
               final missedClasses = controller.currentUserMissedClasses;
               final totalClasses = controller.attendances.length;
               final percent = (totalClasses-missedClasses)/totalClasses;
               String status = 'Collegiate';
               Color color = Get.theme.colorScheme.primary;
               if(percent<0.6){
                 color = Get.theme.colorScheme.error;
                 status = 'Dis-Collegiate';
               } else if(percent < 0.7){
                 color = Colors.orange;
                 status = 'Non-Collegiate';
               }
              return Column(
                children: [
                  verticalGap(height * percentGapSmall),
                  CircularPercentIndicator(
                      radius: height * 0.08,
                      lineWidth: 12,
                      percent: totalClasses>0? percent : 0,
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: color,
                      backgroundColor: Get.theme.colorScheme.onBackground.withAlpha(15),
                      animation: true,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text( totalClasses>0?
                            '${(percent*100).toStringAsFixed(0)}%':'N/A',
                            style: Get.textTheme.titleLarge,
                          ),
                          Text(
                            status,
                            style: Get.textTheme.labelSmall!
                                .copyWith(color: color),
                          ),
                        ],
                      ),
                   ),
                  verticalGap(height * percentGapSmall),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircularPercentIndicator(
                        radius: height * 0.025,
                        lineWidth: 5,
                        percent: totalClasses>0?missedClasses/totalClasses:0,
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: Get.theme.colorScheme.error,
                        backgroundColor: Get.theme.colorScheme.onBackground.withAlpha(15),
                        animation: true,
                        center: Text(
                          missedClasses.toString(),
                          style: Get.textTheme.titleMedium,
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
            }
          ),
          horizontalGap(width * 0.05),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  return controller.currentUserRole == 'Teacher'
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
                      : const SizedBox();
                }),
                verticalGap(height * percentGapVerySmall),
                Text(
                  classroom.courseTitle,
                  style: Get.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                verticalGap(height * percentGapVerySmall),
                Text(
                  classroom.courseCode,
                  style: Get.textTheme.bodySmall,
                ),
                verticalGap(height * percentGapVerySmall),
                Text(
                  classroom.section,
                  style: Get.textTheme.bodySmall,
                ),
                verticalGap(height * percentGapVerySmall),
                Text(
                  'startTime',
                  style: Get.textTheme.bodySmall,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
