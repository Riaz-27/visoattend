import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:visoattend/services/generate_excel_service.dart';

import '../../../controller/timer_controller.dart';
import '../../../models/attendance_model.dart';
import '../../../views/pages/classroom_pages/selected_attendance_page.dart';
import '../../../views/widgets/shimmer_loading.dart';
import '../../../controller/attendance_controller.dart';
import '../../../controller/cloud_firestore_controller.dart';
import '../../../helper/constants.dart';
import '../../../helper/functions.dart';
import '../../../services/generate_pdf_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../attendance_record_page.dart';

class ClassroomPage extends GetView<AttendanceController> {
  const ClassroomPage({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          final attendanceController = Get.find<AttendanceController>();
          await attendanceController
              .updateValues(attendanceController.classroomData);
          await attendanceController.getUsersData();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: height * percentGapSmall,
          ),
          child: SingleChildScrollView(
            child: Obx(() {
              return controller.isAttendanceLoading
                  ? _loadWidget()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _topView(context: context),
                        verticalGap(height * percentGapSmall),
                        Obx(() {
                          return Text(
                            'Attendances (${controller.filteredAttendances.length})',
                            style: Get.textTheme.bodySmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          );
                        }),
                        verticalGap(height * percentGapVerySmall),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: width * 0.4,
                              height: 28,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                    color: Get.theme.colorScheme.outline),
                              ),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: CustomTextField(
                                      controller: searchController,
                                      style: Get.theme.textTheme.bodySmall,
                                      disableBorder: true,
                                      hintText: 'All Times',
                                      onChanged: (value) {
                                        controller.filterAttendances(value);
                                      },
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final firstDate = controller
                                              .attendances.isEmpty
                                          ? DateTime.now()
                                          : DateTime.fromMillisecondsSinceEpoch(
                                              controller
                                                  .attendances.last.dateTime);

                                      final pickedDate = await showDatePicker(
                                        selectableDayPredicate: (dateTime) =>
                                            true,
                                        context: context,
                                        initialDate: selectedDate,
                                        firstDate: firstDate,
                                        lastDate: DateTime.now(),
                                      );
                                      selectedDate =
                                          pickedDate ?? DateTime.now();
                                      final dateText = pickedDate != null
                                          ? DateFormat('dd MMMM y')
                                              .format(pickedDate)
                                          : '';
                                      searchController.text = dateText;
                                      controller.filterAttendances(dateText);
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      height: 28,
                                      width: 40,
                                      child: const Icon(
                                        Icons.date_range,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Obx(() {
                              return controller.currentUserRole == 'Teacher' ||
                                      (controller.currentUserRole == 'CR' &&
                                          controller.classroomData
                                                  .openAttendance !=
                                              'off')
                                  ? GestureDetector(
                                      onTap: _generateReport,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: kSmall,
                                            vertical: kVerySmall),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            color: Get.theme.colorScheme
                                                .secondaryContainer),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.file_download_outlined,
                                              size: 16,
                                              color: Get
                                                  .theme.colorScheme.secondary,
                                            ),
                                            Text(
                                              "Report",
                                              style: Get.textTheme.bodySmall!
                                                  .copyWith(
                                                      color: Get
                                                          .theme
                                                          .colorScheme
                                                          .secondary,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : const SizedBox();
                            }),
                          ],
                        ),
                        verticalGap(height * percentGapSmall),
                        Flexible(
                          child: Obx(() {
                            return ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: controller.classroomData.isArchived
                                  ? const EdgeInsets.only(bottom: 80)
                                  : EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: controller.filteredAttendances.length,
                              itemBuilder: (context, index) {
                                return _buildAttendanceListView(
                                    attendance:
                                        controller.filteredAttendances[index]);
                              },
                            );
                          }),
                        ),
                      ],
                    );
            }),
          ),
        ),
      ),
      floatingActionButton: Obx(() {
        return controller.classroomData.isArchived ||
                controller.isAttendanceLoading
            ? const SizedBox()
            : _bottomFloatingButton(context);
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _generateReport() async {
    Get.bottomSheet(
      backgroundColor: colorScheme.surface,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(15),
          topLeft: Radius.circular(15),
        ),
      ),
      Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: kSmall, vertical: kMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              height: height * 0.055,
              backgroundColor: colorScheme.secondaryContainer,
              textColor: colorScheme.onSecondaryContainer,
              text: 'Generate PDF Report',
              onPressed: () async {
                Get.back();
                final classroomData = controller.classroomData;
                final attendances = controller.attendances;
                final reportGenerateService = GeneratePdfService(
                  classroomData: classroomData,
                  attendances: attendances,
                );
                final pdfData = await reportGenerateService.generateReport(
                    department: classroomData.department);
                final dateTimeNow =
                    DateFormat('ddMMy_hhmmss').format(DateTime.now());

                reportGenerateService.savePdfFile(
                    '${classroomData.courseCode}_$dateTimeNow', pdfData);
              },
            ),
            verticalGap(height * percentGapSmall),
            CustomButton(
              height: height * 0.055,
              backgroundColor: colorScheme.secondaryContainer,
              textColor: colorScheme.onSecondaryContainer,
              text: 'Generate Excel Report',
              onPressed: () async {
                Get.back();
                final excelService = GenerateExcelService();
                final dateTimeNow =
                DateFormat('ddMMy_hhmmss').format(DateTime.now());
                await excelService.generateReport('${controller.classroomData.courseCode}_$dateTimeNow');

                // excelService.saveExcelFile(
                //     '${controller.classroomData.courseCode}_$dateTimeNow', excelData);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceListView({required AttendanceModel attendance}) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(attendance.dateTime);
    final isToday = DateFormat('dMy').format(dateTime) ==
        DateFormat('dMy').format(DateTime.now());

    final currentUser = Get.find<CloudFirestoreController>().currentUser;
    final presentStatus = attendance.studentsData[currentUser.authUid];
    final userRole = controller.currentUserRole;
    final color = presentStatus == 'Absent' || presentStatus == null
        ? Get.theme.colorScheme.error
        : Get.theme.colorScheme.primary;
    final classroomData = controller.classroomData;
    int presentStudents = 0;
    int totalStudents = 0;
    if (userRole == 'Teacher') {
      for (var student in classroomData.cRs + classroomData.students) {
        if (attendance.studentsData[student['authUid']] == 'Present') {
          presentStudents++;
        }
        totalStudents++;
      }
    }
    final takenBy = (controller.teachersData.toList() +
            controller.cRsData.toList() +
            controller.studentsData.toList())
        .firstWhere((user) => attendance.takenBy['authUid'] == user.authUid);

    return GestureDetector(
      onTap: () {
        final openAttendance = controller.classroomData.openAttendance;
        if (userRole == 'Teacher' ||
            (userRole == 'CR' && openAttendance == 'always') ||
            (userRole == 'CR' &&
                isToday &&
                openAttendance != 'off' &&
                openAttendance != 'always')) {
          Get.to(() => SelectedAttendancePage(attendance: attendance));
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: height * percentGapSmall),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Get.theme.colorScheme.surfaceVariant.withAlpha(100),
        ),
        child: Padding(
          padding: const EdgeInsets.all(kSmall),
          child: Row(
            children: [
              Text(
                DateFormat('dd').format(dateTime),
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
              if (userRole == 'Student' || userRole == 'CR')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      presentStatus ?? 'Missing',
                      style: Get.textTheme.titleSmall!.copyWith(color: color),
                    ),
                    Text(
                      'by ${takenBy.name}',
                      style: Get.textTheme.bodySmall,
                    ),
                  ],
                ),
              if (userRole == 'Teacher')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'by ${takenBy.authUid == currentUser.authUid ? 'you' : takenBy.name}',
                      style: Get.textTheme.titleSmall,
                    ),
                    Text(
                      '$presentStudents/$totalStudents presents',
                      style: Get.textTheme.bodySmall,
                    ),
                  ],
                ),
              Obx(() {
                final openAttendance = controller.classroomData.openAttendance;
                if (userRole == 'Teacher' ||
                    (userRole == 'CR' && openAttendance == 'always') ||
                    (userRole == 'CR' &&
                        isToday &&
                        openAttendance != 'off' &&
                        openAttendance != 'always')) {
                  return const Icon(Icons.chevron_right);
                }
                return const SizedBox();
              })
            ],
          ),
        ),
      ),
    );
  }

  Widget _topView({
    required BuildContext context,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Get.theme.colorScheme.surfaceVariant.withOpacity(0.4),
      ),
      padding: const EdgeInsets.all(kSmall),
      child: Row(
        children: [
          horizontalGap(width * percentGapVerySmall),
          Obx(() {
            final currentUserRole =
                Get.find<AttendanceController>().currentUserRole;
            final isTeacher = currentUserRole == 'Teacher';
            // Calculation Missed class
            final missedClasses = controller.currentUserMissedClasses;
            final totalClasses = controller.attendances.length;
            final percent = totalClasses > 0
                ? (totalClasses - missedClasses) / totalClasses
                : 0.0;
            String percentText = totalClasses > 0
                ? '${(percent * 100).toStringAsFixed(0)}%'
                : 'N/A';
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
              color = Get.theme.colorScheme.onSurfaceVariant;
              percentText = totalClasses.toString();
              status = 'Total classes';
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                verticalGap(height * percentGapSmall),
                CircularPercentIndicator(
                  radius: height * 0.08,
                  lineWidth: 12,
                  percent: isTeacher ? 1 : percent,
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: color,
                  backgroundColor:
                      Get.theme.colorScheme.onBackground.withAlpha(15),
                  animation: true,
                  animateFromLastPercent: true,
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
                verticalGap(height * percentGapSmall),
                if (!isTeacher)
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
              final classroom = controller.classroomData;
              if (classroom.classroomId == '') {
                return const SizedBox();
              }
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
                  controller.currentUserRole == 'Teacher' &&
                          !classroom.isArchived
                      ? GestureDetector(
                          onTap: () async {
                            await Clipboard.setData(
                                    ClipboardData(text: classroom.classroomId))
                                .then((value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  content: const Text(
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

  Widget _bottomFloatingButton(BuildContext context) {
    final height = Get.height;
    final timerController = Get.find<TimerController>();

    return Obx(() {
      final classroomData = controller.classroomData;
      final isClassEmpty =
          classroomData.students.length + classroomData.cRs.length == 0;
      final userRole = controller.currentUserRole;
      if (isClassEmpty) {
        return const SizedBox();
      }
      if (userRole == 'Teacher') {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20, right: 10),
          child: FloatingActionButton(
            onPressed: () {
              Get.bottomSheet(
                backgroundColor: Get.theme.colorScheme.surface,
                enableDrag: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: kSmall, vertical: kMedium),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomButton(
                        height: height * 0.055,
                        backgroundColor:
                            Get.theme.colorScheme.secondaryContainer,
                        textColor: Get.theme.colorScheme.onSecondaryContainer,
                        text: 'Take Attendance',
                        onPressed: () {
                          Get.back();
                          Get.to(() => const AttendanceRecordPage());
                        },
                        onLongPressed: () async {
                          await controller.saveDataToFirestore().then((_) {
                            Get.back();
                            Fluttertoast.showToast(
                                msg: 'Created empty attendance');
                          });
                        },
                      ),
                      verticalGap(height * percentGapSmall),
                      Obx(() {
                        final openAttendance =
                            controller.classroomData.openAttendance;
                        String buttonText = 'Open Attendance';
                        final timeLeft = timerController.timeLeft;
                        print('time LEFT: $timeLeft');
                        if (openAttendance == 'always') {
                          buttonText = 'Close Attendance';
                        } else if (openAttendance != 'off') {
                          if (timeLeft > 0) {
                            buttonText = 'Close Attendance';
                            final timeMin = timeLeft ~/ 60;
                            final timeSec = timeLeft % 60;
                            if (timeMin > 0) {
                              buttonText += ' (${timeMin}m ${timeSec}s)';
                            } else {
                              buttonText += ' (${timeSec}s)';
                            }
                          } else {
                            buttonText = 'Open Attendance';
                            controller.closeAttendance();
                          }
                        }
                        return CustomButton(
                          height: height * 0.055,
                          backgroundColor:
                              Get.theme.colorScheme.secondaryContainer,
                          textColor: Get.theme.colorScheme.onSecondaryContainer,
                          text: buttonText,
                          onPressed: () async {
                            if (buttonText[0] == 'O') {
                              await controller.openAttendance('30');
                            } else {
                              await controller.closeAttendance();
                            }
                          },
                          onLongPressed: () async {
                            if (buttonText[0] == 'O') {
                              _openAttendanceTime(context);
                            }
                          },
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      }
      final openAttendance = controller.classroomData.openAttendance;
      if (userRole == 'CR' && openAttendance != 'off') {
        String timeText = 'Take Attendance';
        if (openAttendance != 'always') {
          controller.checkOpenCloseAttendance(openAttendance);
          final timeLeft = timerController.timeLeft;
          final timeMin = timeLeft ~/ 60;
          final timeSec = timeLeft % 60;
          if (timeMin > 0) {
            timeText += ' (${timeMin}m ${timeSec}s)';
          } else {
            timeText += ' (${timeSec}s)';
          }
        }
        return InkWell(
          onTap: () {
            Get.to(() => const AttendanceRecordPage());
          },
          onLongPress: () async {
            await controller.saveDataToFirestore().then((_) {
              Fluttertoast.showToast(msg: 'Created empty attendance');
            });
          },
          child: FloatingActionButton.extended(
            onPressed: () {},
            label: Text(timeText),
          ),
        );
      } else if (userRole == 'CR' && openAttendance == 'off') {
        timerController.cancelAttendanceTimer();
      }

      return const SizedBox();
    });
  }

  void _openAttendanceTime(BuildContext context) async {
    final textController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Open Attendance',
            style: Get.textTheme.titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: Get.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Allow class CR to take attendance.\nEnter duration in minute.',
                  style: Get.textTheme.bodyMedium,
                ),
                verticalGap(Get.height * percentGapSmall),
                TextField(
                  controller: textController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    hintText: 'Always',
                    isDense: true,
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await controller.openAttendance(textController.text);
                Get.back();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  /// For Initial loading view
  Widget _loadWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _loadTopView(),
        verticalGap(height * percentGapSmall),
        Flexible(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 4,
            itemBuilder: (context, index) {
              return _loadAttendanceListView();
            },
          ),
        ),
      ],
    );
  }

  Widget _loadTopView() {
    return Container(
      // height: height * 0.28,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: loadColor.withOpacity(0.04),
      ),
      padding: const EdgeInsets.all(kSmall),
      child: Row(
        children: [
          horizontalGap(width * percentGapVerySmall),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              verticalGap(height * percentGapSmall),
              ShimmerLoading(
                width: height * 0.14,
                height: height * 0.14,
                radius: 100,
              ),
              verticalGap(height * percentGapSmall),
            ],
          ),
          horizontalGap(width * 0.05),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalGap(height * percentGapSmall),
                ShimmerLoading(width: width * 0.5, color: loadColorLight),
                verticalGap(height * percentGapVerySmall),
                ShimmerLoading(width: width * 0.25, height: 10),
                verticalGap(height * percentGapVerySmall),
                ShimmerLoading(width: width * 0.15, height: 10),
                verticalGap(height * percentGapMedium),
                ShimmerLoading(width: width * 0.3, height: 10),
                verticalGap(height * 0.015),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(width: width * 0.15, height: 12),
                    horizontalGap(width * 0.08),
                    ShimmerLoading(width: width * 0.15, height: 12),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _loadAttendanceListView() {
    return Container(
      margin: EdgeInsets.only(bottom: height * percentGapSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: loadColor.withOpacity(0.04),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kSmall),
        child: Row(
          children: [
            ShimmerLoading(
              width: width * 0.1,
              height: 40,
              color: loadColorLight,
            ),
            horizontalGap(width * percentGapSmall),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  width: width * 0.3,
                  height: 12,
                  color: loadColorLight,
                ),
                verticalGap(height * percentGapVerySmall),
                ShimmerLoading(width: width * 0.2, height: 10),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ShimmerLoading(
                  width: width * 0.15,
                  height: 12,
                  color: loadColorLight,
                ),
                verticalGap(height * percentGapVerySmall),
                ShimmerLoading(width: width * 0.25, height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
