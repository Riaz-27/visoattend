import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:visoattend/views/widgets/shimmer_loading.dart';

import '../../helper/functions.dart';
import '../../models/classroom_model.dart';
import '../../controller/cloud_firestore_controller.dart';
import '../../helper/constants.dart';

import 'detailed_classroom_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();

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
              child: Obx(
                () {
                  return cloudFirestoreController.isHomeLoading
                      ? _loadingWidget()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            verticalGap(height * percentGapSmall),
                            // Running Class UI
                            Obx(() {
                              final classTimes =
                                  cloudFirestoreController.timeLeftToStart;
                              final isRunning = classTimes.isNotEmpty
                                  ? classTimes.first < 1
                                      ? true
                                      : false
                                  : false;
                              return (!cloudFirestoreController.isHoliday &&
                                      classroomList.isNotEmpty)
                                  ? Text(
                                      isRunning
                                          ? "Running Class"
                                          : "Next Class",
                                      style: textTheme.titleSmall!.copyWith(
                                          fontWeight: FontWeight.bold),
                                    )
                                  : const SizedBox();
                            }),
                            verticalGap(height * percentGapSmall),
                            GestureDetector(
                              onTap: () {
                                if (classroomList.isNotEmpty) {
                                  Get.to(
                                    () => DetailedClassroomPage(
                                        classroomData: classroomList.first),
                                  );
                                }
                              },
                              child: _topView(
                                  context: context,
                                  classroomList: classroomList),
                            ),
                            verticalGap(height * percentGapMedium),
                            Obx(() {
                              String nextDateString = '';
                              if (classroomList.isEmpty &&
                                  cloudFirestoreController
                                      .classesOfNextDay.isEmpty) {
                                return const SizedBox();
                              }
                              if (classroomList.isEmpty) {
                                final nextDate =
                                    cloudFirestoreController.nextClassDate;
                                final nextDateTime = DateTime.parse(nextDate);
                                final tomorrowDate =
                                    DateTime.now().add(const Duration(days: 1));
                                if (nextDateTime.day == tomorrowDate.day) {
                                  nextDateString = 'Tomorrow';
                                } else {
                                  nextDateString = DateFormat('EEE, dd MMMM')
                                      .format(nextDateTime);
                                }
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Next Class',
                                      style: textTheme.titleSmall!.copyWith(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    Text(
                                      nextDateString,
                                      style: textTheme.bodySmall!.copyWith(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                );
                              }
                              return Text(
                                "Later Today",
                                style: textTheme.titleSmall!
                                    .copyWith(fontWeight: FontWeight.bold),
                              );
                            }),
                            verticalGap(height * percentGapSmall),
                            if (classroomList.isNotEmpty)
                              Flexible(
                                child: Obx(
                                  () {
                                    if (classroomList.length == 1) {
                                      return const Text(
                                          'No more classes today!');
                                    }
                                    return ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: classroomList.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        if (index == 0) {
                                          return const SizedBox();
                                        }
                                        return GestureDetector(
                                          onTap: () => Get.to(
                                            () => DetailedClassroomPage(
                                              classroomData:
                                                  classroomList[index],
                                            ),
                                          ),
                                          child: _buildCustomCard(
                                            classroom: classroomList[index],
                                            index: index,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            if (cloudFirestoreController
                                .classesOfNextDay.isNotEmpty)
                              Flexible(
                                child: Obx(() {
                                  final nextClassList =
                                      cloudFirestoreController.classesOfNextDay;
                                  return ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: nextClassList.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () => Get.to(
                                          () => DetailedClassroomPage(
                                            classroomData: nextClassList[index],
                                          ),
                                        ),
                                        child: _buildNextClassCard(
                                            classroom: nextClassList[index]),
                                      );
                                    },
                                  );
                                }),
                              ),
                          ],
                        );
                },
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
    final weekday = DateFormat('EEEE').format(DateTime.now());
    final weekStartTime = classroom.weekTimes[weekday]['startTime'];
    final weekEndTime = classroom.weekTimes[weekday]['endTime'];
    final startTime = DateFormat.jm().format(DateTime.parse(weekStartTime));
    final endTime = DateFormat.jm().format(DateTime.parse(weekEndTime));
    final roomNo = classroom.weekTimes[weekday]['room'];
    final classSession = classroom.session.split(',').first;

    return Container(
      margin: EdgeInsets.only(bottom: height * percentGapSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: colorScheme.surfaceVariant.withAlpha(100),
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
                  // Row(
                  //   children: [
                  //     // Text(
                  //     //   '$startTime - $endTime',
                  //     //   style: textTheme.bodySmall,
                  //     // ),
                  //     const Spacer(),
                  //     Obx(() {
                  //       final timeLeft = Get.find<CloudFirestoreController>()
                  //           .timeLeftToStart[index];
                  //       final timeLeftHour = (timeLeft / 60).floor();
                  //       final timeLeftMin = timeLeft % 60;
                  //       String timeLeftText = '';
                  //       Color textColor = Colors.green;
                  //       if (timeLeftHour > 0) {
                  //         timeLeftText += '${timeLeftHour}h ';
                  //       }
                  //       timeLeftText += '${timeLeftMin}m Left';
                  //       if (timeLeftHour == 0 && timeLeftMin <= 5) {
                  //         textColor = Colors.red;
                  //       } else if (timeLeftHour == 0 && timeLeftMin <= 15) {
                  //         textColor = Colors.orange;
                  //       }
                  //       return Text(
                  //         timeLeftText,
                  //         style: textTheme.bodySmall!.copyWith(
                  //           fontWeight: FontWeight.bold,
                  //           color: textColor,
                  //         ),
                  //       );
                  //     }),
                  //   ],
                  // ),
                  // verticalGap(height * percentGapVerySmall),
                  Row(
                    children: [
                      Text(
                        classroom.courseTitle,
                        style: textTheme.titleSmall!
                            .copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Obx(() {
                        final cloudFirestoreController =
                            Get.find<CloudFirestoreController>();
                        if(cloudFirestoreController.timeLeftToStart.isEmpty){
                          return const SizedBox();
                        }
                        final timeLeft =
                            cloudFirestoreController.timeLeftToStart[index];
                        final timeLeftHour = (timeLeft / 60).floor();
                        final timeLeftMin = timeLeft % 60;
                        String timeLeftText = '';
                        Color textColor = Colors.green;
                        if (timeLeftHour > 0) {
                          timeLeftText += '${timeLeftHour}h ';
                        }
                        timeLeftText += '${timeLeftMin}m left';
                        if (timeLeftHour == 0 && timeLeftMin <= 5) {
                          textColor = Colors.red;
                        } else if (timeLeftHour == 0 && timeLeftMin <= 15) {
                          textColor = Colors.orange;
                        }
                        return Expanded(
                          child: Text(
                            timeLeftText,
                            style: textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        );
                      }),
                    ],
                  ),
                  verticalGap(height * percentGapVerySmall),
                  // Text(
                  //   classroom.courseCode,
                  //   style: textTheme.titleSmall!.copyWith(
                  //     color: colorScheme.onBackground.withAlpha(150),
                  //   ),
                  // ),
                  Text(
                    '$startTime - $endTime',
                    style: Get.textTheme.titleSmall!.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.8),
                      letterSpacing: 0.4,
                    ),
                  ),
                  Wrap(
                    children: [
                      _customClassroomTag(text: classroom.courseCode),
                      if (roomNo != '') _customClassroomTag(text: roomNo),
                      if (classroom.section != '')
                        _customClassroomTag(text: classroom.section),
                      if (classSession != '')
                        _customClassroomTag(text: classSession),
                    ],
                  ),
                ],
              ),
            ),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.end,
            //   children: [
            //     Obx(() {
            //       final timeLeft = Get.find<CloudFirestoreController>()
            //           .timeLeftToStart[index];
            //       final timeLeftHour = (timeLeft / 60).floor();
            //       final timeLeftMin = timeLeft % 60;
            //       String timeLeftText = '';
            //       Color textColor = Colors.green;
            //       if (timeLeftHour > 0) {
            //         timeLeftText += '${timeLeftHour}h ';
            //       }
            //       timeLeftText += '${timeLeftMin}m Left';
            //       if (timeLeftHour == 0 && timeLeftMin <= 5) {
            //         textColor = Colors.red;
            //       } else if (timeLeftHour == 0 && timeLeftMin <= 15) {
            //         textColor = Colors.orange;
            //       }
            //       return Text(
            //         timeLeftText,
            //         style: textTheme.titleSmall!.copyWith(
            //           fontWeight: FontWeight.bold,
            //           color: textColor,
            //         ),
            //       );
            //     }),
            //     verticalGap(height * percentGapVerySmall),
            //     Text(
            //       '$startTime - $endTime',
            //       style: textTheme.titleSmall!
            //           .copyWith(color: colorScheme.onBackground.withAlpha(150)),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextClassCard({
    required ClassroomModel classroom,
  }) {
    final nextDate = Get.find<CloudFirestoreController>().nextClassDate;
    final nextDateTime = DateTime.parse(nextDate);
    final nextWeekDay = DateFormat('EEEE').format(nextDateTime);

    final weekStartTime = classroom.weekTimes[nextWeekDay]['startTime'];
    final weekEndTime = classroom.weekTimes[nextWeekDay]['endTime'];
    final roomNo = classroom.weekTimes[nextWeekDay]['room'];
    final classSession = classroom.session.split(',').first;

    final startTime = DateFormat.jm().format(DateTime.parse(weekStartTime));
    final endTime = DateFormat.jm().format(DateTime.parse(weekEndTime));

    return Container(
      margin: EdgeInsets.only(bottom: height * percentGapSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: colorScheme.surfaceVariant.withAlpha(100),
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
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     Text(
                  //       '$startTime - $endTime',
                  //       style: textTheme.bodySmall,
                  //       textAlign: TextAlign.right,
                  //     ),
                  //   ],
                  // ),
                  // verticalGap(height * percentGapVerySmall),
                  Text(
                    classroom.courseTitle,
                    style: textTheme.titleSmall!
                        .copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  verticalGap(height * percentGapVerySmall),
                  Text(
                    '$startTime - $endTime',
                    style: Get.textTheme.titleSmall!.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.8),
                      letterSpacing: 0.4,
                    ),
                  ),
                  Wrap(
                    children: [
                      _customClassroomTag(text: classroom.courseCode),
                      if (roomNo != '') _customClassroomTag(text: roomNo),
                      if (classroom.section != '')
                        _customClassroomTag(text: classroom.section),
                      if (classSession != '')
                        _customClassroomTag(text: classSession),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customClassroomTag(
      {Color? bgColor, Color? textColor, required String text}) {
    return Container(
      margin: EdgeInsets.only(top: height * percentGapSmall, right: 10),
      padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: bgColor ?? colorScheme.surfaceVariant.withOpacity(0.7),
      ),
      child: Text(
        text,
        style: textTheme.labelMedium!.copyWith(
            color: textColor ?? colorScheme.onSurface.withOpacity(0.8),
            fontWeight: FontWeight.bold),
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
      double percent = totalClasses > 0
          ? (totalClasses - missedClasses) / totalClasses
          : 0.0;
      String percentText =
          totalClasses > 0 ? '${(percent * 100).toStringAsFixed(0)}%' : 'N/A';
      String status = 'Collegiate';
      Color color = colorScheme.primary;
      if (percent < 0.6) {
        color = colorScheme.error;
        status = 'Dis-Collegiate';
      } else if (percent < 0.7) {
        color = Colors.orange;
        status = 'Non-Collegiate';
      }
      if (isTeacher) {
        percentText = totalClasses.toString();
        percent = 1.0;
        status = 'classes taken';
        color = colorScheme.onSurfaceVariant;
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

      String timeLeftText = '';
      double timePercent = 0;
      if (timeLeftToStart.isNotEmpty) {
        if (timeLeftToStart.first > 0) {
          timeLeftText = 'Starts in: ';
          final timeLeft = timeLeftToStart.first;
          final timeLeftHour = timeLeft ~/ 60;
          final timeLeftMin = timeLeft % 60;
          if (timeLeftHour > 0) {
            timeLeftText += '${timeLeftHour}h ';
          }
          timeLeftText += '${timeLeftMin}m';
        } else {
          if (timeLeftToEnd.first < 0) {
            timeLeftText = 'Time left: ';
            final timeLeft = timeLeftToEnd.first * -1;
            final timeLeftHour = (timeLeft ~/ 60);
            final timeLeftMin = timeLeft % 60;
            if (timeLeftHour > 0) {
              timeLeftText += '${timeLeftHour}h ';
            }
            timeLeftText += '${timeLeftMin}m';

            final totalTime = (timeLeftToStart.first + timeLeftToEnd.first);
            timePercent = (timeLeftToStart.first / totalTime);
          }
        }
      }

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: colorScheme.surfaceVariant.withAlpha(100),
        ),
        padding: EdgeInsets.only(
          top: 3,
          bottom: 15,
          left: height * percentGapSmall,
          right: height * percentGapSmall,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                horizontalGap(width * percentGapVerySmall),
                if (!cloudFirestoreController.isHoliday &&
                    classroomList.isNotEmpty)
                  Column(
                    children: [
                      verticalGap(height * percentGapSmall),
                      CircularPercentIndicator(
                        radius: height * 0.07,
                        lineWidth: 11,
                        percent: percent,
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: color,
                        backgroundColor: colorScheme.onBackground.withAlpha(15),
                        animation: true,
                        center: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              percentText,
                              style: textTheme.titleLarge,
                            ),
                            Text(
                              status,
                              style:
                                  textTheme.labelSmall!.copyWith(color: color),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                horizontalGap(width * 0.05),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      verticalGap(height * percentGapSmall),
                      Text(
                        cloudFirestoreController.isHoliday
                            ? 'Looks like its a Holiday!'
                            : classroomList.isEmpty
                                ? 'No more classes today'
                                : classroom.courseTitle,
                        style: textTheme.labelMedium!
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
                            style: textTheme.labelMedium,
                          ),
                          if (classroomList.isNotEmpty) ...[
                            horizontalGap(width * percentGapSmall),
                            Text(
                              'Section: ',
                              style: textTheme.labelSmall!.copyWith(
                                  color:
                                      colorScheme.onBackground.withAlpha(150)),
                            ),
                            Text(
                              classroom.section,
                              style: textTheme.labelMedium,
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
                                style: textTheme.labelSmall!.copyWith(
                                    color: colorScheme.onBackground
                                        .withAlpha(150)),
                              ),
                              Text(
                                roomNo,
                                style: textTheme.labelMedium,
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
                                  style: textTheme.labelSmall!.copyWith(
                                    color:
                                        colorScheme.onBackground.withAlpha(150),
                                  ),
                                ),
                                verticalGap(height * percentGapVerySmall),
                                Text(
                                  startTime,
                                  style: textTheme.labelMedium,
                                ),
                                // Text(
                                //   startTimeLeftText,
                                //   style: textTheme.labelMedium!.copyWith(
                                //     color: startTextColor,
                                //   ),
                                // ),
                              ],
                            ),
                            horizontalGap(height * percentGapLarge),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ends at',
                                  style: textTheme.labelSmall!.copyWith(
                                    color:
                                        colorScheme.onBackground.withAlpha(150),
                                  ),
                                ),
                                verticalGap(height * percentGapVerySmall),
                                Text(
                                  endTime,
                                  style: textTheme.labelMedium,
                                ),
                                // Text(
                                //   endTimeLeftText,
                                //   style: textTheme.labelMedium!.copyWith(
                                //     color: endTextColor,
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
            if (!cloudFirestoreController.isHoliday &&
                classroomList.isNotEmpty) ...[
              verticalGap(height * percentGapSmall),
              Text(
                timeLeftText,
                style: textTheme.bodySmall!,
              ),
              verticalGap(height * percentGapVerySmall),
              LinearPercentIndicator(
                padding: EdgeInsets.zero,
                animateFromLastPercent: true,
                animation: true,
                lineHeight: 6,
                barRadius: const Radius.circular(3),
                percent: timePercent,
                progressColor: colorScheme.primary,
                backgroundColor: colorScheme.onBackground.withOpacity(0.1),
              ),
              verticalGap(height * percentGapVerySmall),
            ],
          ],
        ),
      );
    });
  }

  Widget _loadingWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        verticalGap(height * percentGapSmall),
        _loadingTopView(),
        verticalGap(height * percentGapMedium),
        Flexible(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 3,
            itemBuilder: (BuildContext context, int index) {
              return _loadBuildCustomCard();
            },
          ),
        ),
      ],
    );
  }

  Widget _loadingTopView() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: loadColor.withOpacity(0.04),
      ),
      padding: EdgeInsets.only(
        top: 3,
        bottom: 15,
        left: height * percentGapSmall,
        right: height * percentGapSmall,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              horizontalGap(width * percentGapVerySmall),
              Column(
                children: [
                  verticalGap(height * percentGapSmall),
                  ShimmerLoading(
                    height: height * 0.12,
                    width: height * 0.12,
                    radius: 100,
                  )
                ],
              ),
              horizontalGap(width * 0.05),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    verticalGap(height * percentGapSmall),
                    ShimmerLoading(width: width * 0.5, color: loadColorLight),
                    verticalGap(height * percentGapVerySmall),
                    ShimmerLoading(
                      width: width * 0.3,
                      height: 12,
                      color: loadColorLight,
                    ),
                    verticalGap(height * percentGapSmall),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerLoading(
                              width: width * 0.16,
                              height: 10,
                            ),
                            verticalGap(height * percentGapVerySmall),
                            ShimmerLoading(
                              width: width * 0.16,
                              height: 12,
                              color: loadColorLight,
                            ),
                          ],
                        ),
                        horizontalGap(height * percentGapLarge),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerLoading(
                              width: width * 0.16,
                              height: 10,
                            ),
                            verticalGap(height * percentGapVerySmall),
                            ShimmerLoading(
                              width: width * 0.16,
                              height: 12,
                              color: loadColorLight,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalGap(height * percentGapSmall),
          ShimmerLoading(height: 10, width: width * 0.2),
          verticalGap(height * percentGapVerySmall),
          ShimmerLoading(
            height: 6,
            width: width,
            radius: 100,
          ),
          verticalGap(height * percentGapVerySmall),
        ],
      ),
    );
  }

  Widget _loadBuildCustomCard() {
    return Container(
      margin: EdgeInsets.only(bottom: height * percentGapSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: loadColor.withOpacity(0.04),
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
                  ShimmerLoading(width: width * 0.5, color: loadColorLight),
                  verticalGap(height * percentGapVerySmall),
                  ShimmerLoading(
                    width: width * 0.3,
                    height: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
