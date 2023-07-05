import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:visoattend/controller/attendance_controller.dart';
import 'package:visoattend/controller/timer_controller.dart';

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
    if (!cloudFirestoreController.isInitialized) {
      cloudFirestoreController.initialize();
    }
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
                top: height * percentGapLarge,
                right: height * percentGapSmall,
                left: height * percentGapSmall,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            final userName =
                                cloudFirestoreController.currentUser.name;
                            return Text(
                              'Welcome, $userName',
                              style: Get.textTheme.titleMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            );
                          }),
                          verticalGap(height * percentGapVerySmall),
                          Text(
                            DateFormat('EEE, d MMMM y').format(DateTime.now()),
                            style: Get.textTheme.bodySmall!.copyWith(
                                color: Get.theme.colorScheme.onBackground
                                    .withAlpha(150)),
                          ),
                        ],
                      ),

                      ///Temporary button
                      IconButton(
                        onPressed: () async {
                          await Get.find<AuthController>().signOut();
                          cloudFirestoreController.isInitialized = false;
                          Get.offAll(() => const AuthPage());
                        },
                        icon: const Icon(Icons.logout_rounded),
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.blueGrey,
                        child: Obx(() {
                          final picUrl =
                              Get.find<ProfilePicController>().profilePicUrl;
                          return picUrl == ''
                              ? const Icon(Icons.people_rounded)
                              : Image.network(
                                  picUrl,
                                  fit: BoxFit.cover,
                                );
                        }),
                      ),
                    ],
                  ),
                  verticalGap(height * percentGapMedium),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Later Today",
                        style: Get.textTheme.titleSmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () => Get.to(() => const AllClassroomPage()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: kSmall, vertical: kVerySmall),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Get.theme.colorScheme.secondaryContainer),
                          child: Text(
                            "All Classes",
                            style: Get.textTheme.bodySmall!.copyWith(
                                color: Get.theme.colorScheme.secondary,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 10),
        child: FloatingActionButton(
          onPressed: () {
            Get.bottomSheet(
              backgroundColor: Colors.white,
              enableDrag: true,
              Padding(
                padding: const EdgeInsets.all(kSmall),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          _handleJoinClass();
                        },
                        child: const Text('Join Class'),
                      ),
                    ),
                    verticalGap(height * percentGapSmall),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(() => const CreateEditClassroomPage());
                          //
                        },
                        child: const Text('Create Class'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
        borderRadius: BorderRadius.circular(10),
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

  void _handleJoinClass() {
    final TextEditingController classroomIdController = TextEditingController();
    Get.bottomSheet(
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 100,
              width: double.infinity,
              child: CustomTextFormField(
                controller: classroomIdController,
                labelText: 'Enter Class Id',
              ),
            ),
            // const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final classroomDatabaseController =
                      Get.find<ClassroomController>();
                  await classroomDatabaseController
                      .joinClassroom(classroomIdController.text);
                },
                child: const Text('Join'),
              ),
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

    return Container(
      height: height * 0.23,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Get.theme.colorScheme.surfaceVariant.withAlpha(100),
      ),
      padding: const EdgeInsets.all(kSmall),
      child: Row(
        children: [
          horizontalGap(width * percentGapSmall),
          Obx(() {
            final totalClasses = cloudFirestoreController.homeClassAttendances;
            final missedClasses = cloudFirestoreController.homeMissedClasses;
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

            return CircularPercentIndicator(
              radius: height * 0.08,
              lineWidth: 12,
              percent: totalClasses > 0 ? percent : 0,
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: color,
              backgroundColor: Get.theme.colorScheme.onBackground.withAlpha(15),
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
            );
          }),
          horizontalGap(width * 0.05),
          Expanded(
            child: Obx(() {
              final classroom = classroomList.isNotEmpty
                  ? classroomList[0]
                  : ClassroomModel.empty();
              final startTime = classroomList.isEmpty
                  ? ''
                  : DateFormat.jm().format(DateTime.parse(classroom
                          .weekTimes[DateFormat('EEEE').format(DateTime.now())]
                      ['startTime']));
              final endTime = classroomList.isEmpty
                  ? ''
                  : DateFormat.jm().format(DateTime.parse(classroom
                          .weekTimes[DateFormat('EEEE').format(DateTime.now())]
                      ['endTime']));
              final roomNo = classroomList.isEmpty
                  ? ''
                  : classroom
                          .weekTimes[DateFormat('EEEE').format(DateTime.now())]
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
                    final timeLeftHour = (timeLeft / 60).floor();
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
              return Column(
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
                        if(roomNo != '') ...[
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
                        horizontalGap(width * 0.12),
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
              );
            }),
          )
        ],
      ),
    );
  }
}
