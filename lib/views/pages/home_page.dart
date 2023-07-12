import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:visoattend/controller/attendance_controller.dart';
import 'package:visoattend/controller/timer_controller.dart';
import 'package:visoattend/views/widgets/custom_button.dart';

import '../../controller/profile_pic_controller.dart';
import '../../helper/functions.dart';
import '../../models/classroom_model.dart';
import '../../views/pages/create_edit_classroom_page.dart';
import '../../controller/auth_controller.dart';
import '../../controller/classroom_controller.dart';
import '../../controller/cloud_firestore_controller.dart';
import '../../helper/constants.dart';
import 'classroom_pages/classroom_page.dart';
import '../../views/widgets/custom_text_form_field.dart';
import 'all_classroom_page.dart';
import 'auth_page.dart';
import 'detailed_classroom_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final height = Get.height;
    final width = Get.width;
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    // if (!cloudFirestoreController.isInitialized) {
    //   cloudFirestoreController.initialize();
    // }
    final classroomList = cloudFirestoreController.classesOfToday;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await cloudFirestoreController.initialize();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(
                right: height * percentGapSmall,
                left: height * percentGapSmall,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [

                  verticalGap(height * percentGapSmall),
                  // Running Class UI
                  Obx(() {
                    final classTimes = cloudFirestoreController.timeLeftToStart;
                    final isRunning = classTimes.isNotEmpty
                        ? classTimes.first < 1
                            ? true
                            : false
                        : false;
                    return Text(
                      isRunning ? "Running Class" : "Next Class",
                      style: Get.textTheme.titleSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    );
                  }),
                  verticalGap(height * percentGapSmall),
                  GestureDetector(
                    onTap: () {
                      if (classroomList.isNotEmpty) {
                        Get.to(() => DetailedClassroomPage(
                            classroomData: classroomList.first));
                      }
                    },
                    child: _topView(
                        context: context, classroomList: classroomList),
                  ),
                  verticalGap(height * percentGapMedium),
                  Text(
                    "Later Today",
                    style: Get.textTheme.titleSmall!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  verticalGap(height * percentGapSmall),
                  Flexible(
                    child: Obx(
                      () {
                        if (classroomList.length == 1) {
                          return const Text('No more classes today!');
                        }
                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: classroomList.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == 0) {
                              return const SizedBox();
                            }
                            return GestureDetector(
                              // onTap: () => Get.to(() => ClassroomPage(
                              //     classroomData: classroomList[index])),
                              onTap: () => Get.to(() => DetailedClassroomPage(
                                    classroomData: classroomList[index],
                                  )),
                              child: _buildCustomCard(
                                  classroom: classroomList[index],
                                  index: index),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomCard({
    required ClassroomModel classroom,
    required int index,
  }) {
    final height = Get.height;

    final weekTime = classroom
        .weekTimes[DateFormat('EEEE').format(DateTime.now())]['startTime'];
    final startTime = DateFormat.jm().format(DateTime.parse(weekTime));

    return Container(
      margin: EdgeInsets.only(bottom: height * percentGapSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Get.theme.colorScheme.surfaceVariant.withAlpha(100),
      ),
      child: Padding(
        padding: EdgeInsets.all(height * percentGapSmall),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classroom.courseTitle,
                    style: Get.textTheme.titleSmall!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  verticalGap(height * percentGapVerySmall),
                  Text(
                    classroom.courseCode,
                    style: Get.textTheme.titleSmall!.copyWith(
                      color: Get.theme.colorScheme.onBackground.withAlpha(150),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Obx(() {
                  final timeLeft = Get.find<CloudFirestoreController>()
                      .timeLeftToStart[index];
                  final timeLeftHour = (timeLeft / 60).floor();
                  final timeLeftMin = timeLeft % 60;
                  String timeLeftText = '';
                  Color textColor = Colors.green;
                  if (timeLeftHour > 0) {
                    timeLeftText += '${timeLeftHour}h ';
                  }
                  timeLeftText += '${timeLeftMin}m Left';
                  if (timeLeftHour == 0 && timeLeftMin <= 5) {
                    textColor = Colors.red;
                  } else if (timeLeftHour == 0 && timeLeftMin <= 15) {
                    textColor = Colors.orange;
                  }
                  return Text(
                    timeLeftText,
                    style: Get.textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  );
                }),
                verticalGap(height * percentGapVerySmall),
                Text(
                  startTime,
                  style: Get.textTheme.titleSmall!.copyWith(
                      color: Get.theme.colorScheme.onBackground.withAlpha(150)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _topView({
    required BuildContext context,
    required List<ClassroomModel> classroomList,
  }) {
    final height = Get.height;
    final width = Get.width;

    final cloudFirestoreController = Get.find<CloudFirestoreController>();

    return Obx(() {
      /// Data for circular percent indication
      final isTeacher = cloudFirestoreController.homeClassUserRole == 'Teacher';
      //Home class missing information
      final totalClasses = cloudFirestoreController.homeClassAttendances;
      final missedClasses = cloudFirestoreController.homeMissedClasses;
      final percent = totalClasses > 0
          ? (totalClasses - missedClasses) / totalClasses
          : 0.0;
      String percentText =
          totalClasses > 0 ? '${(percent * 100).toStringAsFixed(0)}%' : 'N/A';
      String status = 'Collegiate';
      Color color = Get.theme.colorScheme.primary;
      if (percent < 0.6) {
        color = Get.theme.colorScheme.error;
        status = 'Dis-Collegiate';
      } else if (percent < 0.7) {
        color = Colors.orange;
        status = 'Non-Collegiate';
      }
      if (isTeacher) {
        percentText = totalClasses.toString();
        status = 'classes taken';
        color = Get.theme.colorScheme.secondary;
      }

      /// data for Home class details
      final classroom =
          classroomList.isNotEmpty ? classroomList[0] : ClassroomModel.empty();
      final startTime = classroomList.isEmpty
          ? ''
          : DateFormat.jm().format(DateTime.parse(
              classroom.weekTimes[DateFormat('EEEE').format(DateTime.now())]
                  ['startTime']));
      final endTime = classroomList.isEmpty
          ? ''
          : DateFormat.jm().format(DateTime.parse(
              classroom.weekTimes[DateFormat('EEEE').format(DateTime.now())]
                  ['endTime']));
      final roomNo = classroomList.isEmpty
          ? ''
          : classroom.weekTimes[DateFormat('EEEE').format(DateTime.now())]
              ['room'];
      final timeLeftToStart = cloudFirestoreController.timeLeftToStart;
      final timeLeftToEnd = cloudFirestoreController.timeLeftToEnd;
      final isRunning = timeLeftToStart.isNotEmpty
          ? timeLeftToStart.first < 1
              ? true
              : false
          : false;
      print(timeLeftToStart);
      print(timeLeftToEnd);
      String startTimeLeftText = '';
      String endTimeLeftText = 'Not Started';
      Color startTextColor = Get.theme.colorScheme.primary;
      Color endTextColor = Get.theme.colorScheme.primary;
      if (timeLeftToStart.isNotEmpty) {
        if (timeLeftToStart.first > 0) {
          final timeLeft = timeLeftToStart.first;
          final timeLeftHour = (timeLeft / 60).floor();
          final timeLeftMin = timeLeft % 60;
          if (timeLeftHour > 0) {
            startTimeLeftText += '${timeLeftHour}h ';
          }
          startTimeLeftText += '${timeLeftMin}m Left';
          if (timeLeftHour == 0 && timeLeftMin <= 5) {
            startTextColor = Get.theme.colorScheme.error;
          } else if (timeLeftHour == 0 && timeLeftMin <= 15) {
            startTextColor = Colors.orange;
          }
        } else {
          startTimeLeftText = 'Running';
          startTextColor = Get.theme.colorScheme.primary;
          endTimeLeftText = '';
          if (timeLeftToEnd.first < 0) {
            final timeLeft = timeLeftToEnd.first * -1;
            final timeLeftHour = (timeLeft ~/ 60);
            final timeLeftMin = timeLeft % 60;
            if (timeLeftHour > 0) {
              endTimeLeftText += '${timeLeftHour}h ';
            }
            endTimeLeftText += '${timeLeftMin}m Left';
            if (timeLeftHour == 0 && timeLeftMin <= 5) {
              endTextColor = Get.theme.colorScheme.error;
            } else if (timeLeftHour == 0 && timeLeftMin <= 15) {
              endTextColor = Colors.orange;
            }
          }
        }
      }
      return Container(
        height: height * 0.23,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Get.theme.colorScheme.surfaceVariant.withAlpha(100),
        ),
        padding: const EdgeInsets.all(kSmall),
        child: Row(
          children: [
            horizontalGap(width * percentGapSmall),
            if (!cloudFirestoreController.isHoliday && classroomList.isNotEmpty)
              CircularPercentIndicator(
                radius: height * 0.07,
                lineWidth: 12,
                percent: percent,
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: color,
                backgroundColor:
                    Get.theme.colorScheme.onBackground.withAlpha(15),
                animation: true,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      percentText,
                      style: Get.textTheme.titleLarge,
                    ),
                    Text(
                      status,
                      style: Get.textTheme.labelSmall!.copyWith(color: color),
                    ),
                  ],
                ),
              ),
            horizontalGap(width * 0.05),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  verticalGap(height * percentGapSmall),
                  Text(
                    cloudFirestoreController.isHoliday
                        ? 'Looks like its a Holiday!'
                        : classroomList.isEmpty
                            ? 'No more classes today'
                            : classroom.courseTitle,
                    style: Get.textTheme.labelMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  verticalGap(height * percentGapVerySmall),
                  Row(
                    children: [
                      Text(
                        cloudFirestoreController.isHoliday
                            ? 'Enjoy your Holiday!'
                            : classroom.courseCode,
                        style: Get.textTheme.labelMedium,
                      ),
                      if (classroomList.isNotEmpty) ...[
                        horizontalGap(width * percentGapSmall),
                        Text(
                          'Section: ',
                          style: Get.textTheme.labelSmall!.copyWith(
                              color: Get.theme.colorScheme.onBackground
                                  .withAlpha(150)),
                        ),
                        Text(
                          classroom.section,
                          style: Get.textTheme.labelMedium,
                        ),
                      ]
                    ],
                  ),
                  if (classroomList.isNotEmpty) ...[
                    verticalGap(height * percentGapSmall),
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
                        ]
                      ],
                    ),
                    verticalGap(height * percentGapSmall),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isRunning ? 'Started' : 'Starts at',
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
                            Text(
                              startTimeLeftText,
                              style: Get.textTheme.labelMedium!.copyWith(
                                color: startTextColor,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ends at',
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
                            Text(
                              endTimeLeftText,
                              style: Get.textTheme.labelMedium!.copyWith(
                                color: endTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ]
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
