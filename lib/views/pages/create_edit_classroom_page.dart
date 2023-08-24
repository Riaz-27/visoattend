import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controller/attendance_controller.dart';
import '../../controller/classroom_controller.dart';
import '../../controller/cloud_firestore_controller.dart';
import '../../controller/navigation_controller.dart';
import '../../helper/constants.dart';
import '../../helper/functions.dart';
import '../../views/pages/detailed_home_page.dart';

class CreateEditClassroomPage extends StatelessWidget {
  const CreateEditClassroomPage({
    super.key,
    this.isEdit = false,
    this.userRole = 'Teacher',
  });

  final bool isEdit;
  final String userRole;

  @override
  Widget build(BuildContext context) {
    final departmentOptions = [
      'Qur\'anic Sciences and Islamic Studies',
      'Da\'wah and Islamic Studies',
      'Science of Hadith and Islamic Studies',
      'Computer Science and Engineering',
      'Computer and Communication Engineering',
      'Electrical and Electronic Engineering',
      'Electronic and Telecommunication Engineering',
      'Civil Engineering',
      'Pharmacy',
      'Business Administration',
      'Economics & Banking',
      'Department of Law',
      'English Language and Literature',
      'Arabic Language and Literature',
      'Library and Information Science',
      'Shariah and Islamic Studies',
      'Institute of Foreign Language',
      'Center for General Education',
      'Morality Development Program',
    ];

    final classroom = Get.find<AttendanceController>().classroomData;
    final courseCodeController = TextEditingController();
    final courseTitleController = TextEditingController();
    final sectionController = TextEditingController();
    final sessionController = TextEditingController();
    final departmentController = TextEditingController();
    final roomNoController =
        List.generate(7, (index) => TextEditingController());
    final classCountController =
        List.generate(7, (index) => TextEditingController());

    final classroomController = Get.find<ClassroomController>();
    final currentUser = Get.find<CloudFirestoreController>().currentUser;
    final currentUserRole = Get.find<AttendanceController>().currentUserRole;

    if (isEdit) {
      classroomController.detailsExpanded = false;

      courseTitleController.text = classroom.courseTitle;
      courseCodeController.text = classroom.courseCode;
      sectionController.text = classroom.section;
      sessionController.text = classroom.session;
      departmentController.text = classroom.department;
      final weekDays = classroomController.weekDays;
      for (int i = 0; i < weekDays.length; i++) {
        final dbWeekStartTime = classroom.weekTimes[weekDays[i]]['startTime'];
        final dbWeekEndTime = classroom.weekTimes[weekDays[i]]['endTime'];
        final dbWeekRoomNo = classroom.weekTimes[weekDays[i]]['room'];
        String dbClassCount =
            classroom.weekTimes[weekDays[i]]['classCount'] ?? '';
        dbClassCount = dbClassCount == '' ? '1' : dbClassCount;
        if (dbWeekStartTime != 'Off Day') {
          //getting the database time and setting the variables
          classroomController.selectedStartTimes[i] = dbWeekStartTime;
          classroomController.selectedEndTimes[i] = dbWeekEndTime;
          classroomController.selectedWeekTimes[weekDays[i]]['startTime'] =
              dbWeekStartTime;
          classroomController.selectedWeekTimes[weekDays[i]]['endTime'] =
              dbWeekEndTime;
          classroomController.selectedWeeks[i] = true;

          //getting the database room no and class count and setting the variables
          classroomController.selectedWeekTimes[weekDays[i]]['room'] =
              dbWeekRoomNo;
          roomNoController[i].text = dbWeekRoomNo;

          classroomController.selectedWeekTimes[weekDays[i]]['classCount'] =
              dbClassCount;
          classCountController[i].text = dbClassCount;
        }
      }
    }

    final collapsedTitle = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          courseTitleController.text,
          style: textTheme.bodyMedium!.copyWith(color: textColorDefault),
        ),
        Text(
          courseCodeController.text,
          style: textTheme.bodySmall!.copyWith(color: textColorLight),
        ),
      ],
    );
    final expandedTitle =
        Text(isEdit ? 'Change classroom details' : 'Set classroom details');

    return WillPopScope(
      onWillPop: () async {
        return !(Get.isDialogOpen ?? false);
      },
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: Text(
            isEdit ? 'Edit Classroom' : 'Create Classroom',
            style: textTheme.bodyLarge!.copyWith(color: textColorDefault),
          ),
          actions: [
            classroom.isArchived
                ? const SizedBox()
                : GestureDetector(
                    onTap: () async {
                      if (classroom.isArchived) return;

                      final courseCode = courseCodeController.text.trim();
                      final courseTitle = courseTitleController.text.trim();
                      if (courseTitle.isEmpty || courseCode.isEmpty) {
                        errorDialog(
                          title: 'Missing Required Field',
                          msg: 'Course Title and Course Code must be provided.',
                        );
                        return;
                      }
                      if (isEdit) {
                        loadingDialog('Saving...');
                        classroom.courseCode = courseCodeController.text.trim();
                        classroom.courseTitle =
                            courseTitleController.text.trim();
                        classroom.session = sessionController.text.trim();
                        classroom.section = sectionController.text.trim();
                        classroom.department = departmentController.text.trim();
                        classroom.weekTimes =
                            classroomController.selectedWeekTimes;
                        await classroomController.updateClassroom(classroom);
                        hideLoadingDialog();
                        Get.back();
                      } else if (!isEdit) {
                        loadingDialog('Please wait...');
                        await classroomController.createNewClassroom(
                          courseCode: courseCode,
                          courseTitle: courseTitle,
                          section: sectionController.text.trim(),
                          session: sessionController.text.trim(),
                          department: departmentController.text.trim(),
                        );
                        hideLoadingDialog();
                        Get.back();
                        Get.back();
                        Get.find<NavigationController>().selectedHomeIndex = 1;
                      }
                    },
                    child: Container(
                      margin: isEdit && currentUserRole == 'Teacher'
                          ? EdgeInsets.zero
                          : EdgeInsets.symmetric(
                              horizontal: deviceWidth * percentGapLarge),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: colorScheme.secondaryContainer,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: kSmall,
                          vertical: kVerySmall,
                        ),
                        child: Text(
                          isEdit ? 'Save' : 'Create',
                          style: textTheme.bodySmall!.copyWith(
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
            if (isEdit &&
                currentUser.authUid == classroom.teachers[0]['authUid'])
              PopupMenuButton(
                position: PopupMenuPosition.under,
                tooltip: 'Classroom Options',
                itemBuilder: (BuildContext context) => [
                  if (classroom.isArchived) ...[
                    const PopupMenuItem(
                      value: 'restore',
                      child: Text('Restore'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                  if (!classroom.isArchived)
                    const PopupMenuItem(
                      value: 'archive',
                      child: Text('Archive Classroom'),
                    ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'archive':
                      _handleClassArchiveRestore(context, archive: true);
                      break;
                    case 'restore':
                      _handleClassArchiveRestore(context, archive: false);
                      break;
                    case 'delete':
                      _handleClassDelete(
                        context,
                        courseTitle: courseTitleController.text,
                      );
                      break;
                  }
                },
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: deviceHeight * percentGapSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Classroom Details',
                  style: textTheme.bodySmall!.copyWith(
                    color: textColorLight,
                  ),
                ),
                verticalGap(deviceHeight * percentGapSmall),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: colorScheme.surfaceVariant.withOpacity(0.6),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTileTheme(
                    contentPadding: EdgeInsets.zero,
                    minVerticalPadding: 0,
                    dense: true,
                    child: Theme(
                      data: Get.theme.copyWith(
                        dividerColor: Colors.transparent,
                        splashColor: Colors.transparent,
                      ),
                      child: Obx(() {
                        final classroomController =
                            Get.find<ClassroomController>();
                        Widget title = classroomController.detailsExpanded
                            ? expandedTitle
                            : collapsedTitle;
                        return ExpansionTile(
                          initiallyExpanded: !isEdit,
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: EdgeInsets.zero,
                          title: title,
                          onExpansionChanged: (value) =>
                              classroomController.detailsExpanded = value,
                          children: [
                            TextField(
                              enabled:
                                  isEdit && userRole == 'CR' ? false : true,
                              readOnly: classroom.isArchived,
                              controller: courseTitleController,
                              style: textTheme.bodyMedium!.copyWith(
                                color: textColorDefault,
                              ),
                              decoration: InputDecoration(
                                labelText:
                                    'Course Title (e.g. Project / Thesis) *',
                                labelStyle: textTheme.bodyMedium!.copyWith(
                                  color: textColorDefault,
                                ),
                                alignLabelWithHint: true,
                                isDense: true,
                              ),
                            ),
                            verticalGap(deviceHeight * percentGapVerySmall),
                            TextField(
                              enabled:
                                  isEdit && userRole == 'CR' ? false : true,
                              readOnly: classroom.isArchived,
                              controller: courseCodeController,
                              style: textTheme.bodyMedium!.copyWith(
                                color: textColorDefault,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Course Code (e.g. CSE-4800) *',
                                labelStyle: textTheme.bodyMedium!.copyWith(
                                  color: textColorDefault,
                                ),
                                isDense: true,
                                alignLabelWithHint: true,
                              ),
                            ),
                            verticalGap(deviceHeight * percentGapVerySmall),
                            TextField(
                              readOnly: classroom.isArchived,
                              controller: sectionController,
                              style: textTheme.bodyMedium!.copyWith(
                                color: textColorDefault,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Section (e.g. 8BM)',
                                labelStyle: textTheme.bodyMedium!.copyWith(
                                  color: textColorDefault,
                                ),
                                isDense: true,
                                alignLabelWithHint: true,
                              ),
                            ),
                            verticalGap(deviceHeight * percentGapVerySmall),
                            TextField(
                              readOnly: classroom.isArchived,
                              controller: sessionController,
                              style: textTheme.bodyMedium!.copyWith(
                                color: textColorDefault,
                              ),
                              decoration: InputDecoration(
                                labelText:
                                    'Session (e.g. Spring-2022, Batch-47)',
                                labelStyle: textTheme.bodyMedium!.copyWith(
                                  color: textColorDefault,
                                ),
                                isDense: true,
                                alignLabelWithHint: true,
                              ),
                            ),
                            verticalGap(deviceHeight * percentGapVerySmall),
                            Autocomplete<String>(
                              optionsBuilder: (textEditingValue) {
                                if (textEditingValue.text == '') {
                                  return const Iterable<String>.empty();
                                }
                                return departmentOptions.where((opt) => opt
                                    .toLowerCase()
                                    .contains(
                                        textEditingValue.text.toLowerCase()));
                              },
                              onSelected: (value) {
                                departmentController.text = value;
                              },
                              fieldViewBuilder: (context, fieldController,
                                  focusNode, onSubmitted) {
                                fieldController.text =
                                    departmentController.text;
                                return TextField(
                                  readOnly: classroom.isArchived,
                                  controller: fieldController,
                                  style: textTheme.bodyMedium!.copyWith(
                                    color: textColorDefault,
                                  ),
                                  focusNode: focusNode,
                                  onChanged: (value) =>
                                      departmentController.text = value,
                                  decoration: InputDecoration(
                                    labelText: 'Department',
                                    labelStyle: textTheme.bodyMedium!.copyWith(
                                      color: textColorDefault,
                                    ),
                                    isDense: true,
                                    alignLabelWithHint: true,
                                  ),
                                );
                              },
                              optionsViewBuilder:
                                  (context, onSelected, optionsData) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          top: deviceHeight *
                                              percentGapVerySmall),
                                      width: deviceWidth * 0.85,
                                      decoration: BoxDecoration(
                                          color: colorScheme.surfaceVariant
                                              .withOpacity(0.7),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                              color: colorScheme.onBackground)),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 10),
                                        itemCount: optionsData.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final option =
                                              optionsData.elementAt(index);
                                          return GestureDetector(
                                            onTap: () => onSelected(option),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                verticalGap(10),
                                                Text(
                                                  option,
                                                  style: textTheme.bodyMedium!
                                                      .copyWith(
                                                    color: textColorDefault,
                                                  ),
                                                ),
                                                verticalGap(10),
                                                if (index <
                                                    optionsData.length - 1)
                                                  const Divider(
                                                      height: 0,
                                                      thickness: 0.5),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            // TextField(
                            //   controller: departmentController,
                            //   style: textTheme.bodyMedium,
                            //   decoration: InputDecoration(
                            //     labelText: 'Department',
                            //     labelStyle: Get.textTheme.bodyMedium,
                            //     isDense: true,
                            //     alignLabelWithHint: true,
                            //   ),
                            // ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                verticalGap(deviceHeight * percentGapMedium),
                Text(
                  'Weekly class schedule',
                  style: textTheme.bodySmall!.copyWith(
                    color: textColorLight,
                  ),
                ),
                verticalGap(deviceHeight * percentGapSmall),
                Flexible(
                  child: ListView.builder(
                    padding: classroom.isArchived
                        ? const EdgeInsets.only(bottom: 80)
                        : EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      return _buildWeekTimeList(
                        context,
                        index,
                        roomNoController,
                        classCountController,
                      );
                    },
                  ),
                ),
                verticalGap(deviceHeight * percentGapSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _handleClassArchiveRestore(BuildContext context, {required bool archive}) {
  final classroomController = Get.find<ClassroomController>();
  final classroom = Get.find<AttendanceController>().classroomData;
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          archive ? 'Archive Classroom' : 'Restore Classroom',
          style: textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: textColorDefault,
          ),
        ),
        content: SizedBox(
          width: deviceWidth,
          child: Text(
            'Do you really want to ${archive ? 'archive' : 'restore'} this classroom?',
            style: textTheme.bodyMedium!.copyWith(color: textColorDefault),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              loadingDialog('Please wait...');
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              await classroomController
                  .archiveRestoreClassroom(classroom, archive)
                  .then(
                    (_) => Get.find<CloudFirestoreController>()
                        .initialize()
                        .then(
                            (_) => Get.offAll(() => const DetailedHomePage())),
                  );
              hideLoadingDialog();
            },
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  );
}

void _handleClassDelete(
  BuildContext context, {
  required String courseTitle,
}) {
  final deleteController = TextEditingController();
  final classroomController = Get.find<ClassroomController>();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Delete Classroom',
          style: textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: textColorDefault,
          ),
        ),
        content: SizedBox(
          width: deviceWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Remember This process cannot be undone!!!\nThis process might take some time depending on the classroom size.',
                style: textTheme.bodyMedium!.copyWith(color: colorScheme.error),
              ),
              verticalGap(deviceHeight * percentGapSmall),
              Text(
                'Enter the Course Title to confirm',
                style: textTheme.bodyMedium!.copyWith(color: textColorDefault),
              ),
              verticalGap(deviceHeight * percentGapSmall),
              TextField(
                controller: deleteController,
                decoration: InputDecoration(
                  hintText: courseTitle,
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
              if (courseTitle == deleteController.text) {
                loadingDialog('Deleting...');
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                await classroomController.deleteClassroom().then(
                      (_) => Get.find<CloudFirestoreController>()
                          .initialize()
                          .then((_) =>
                              Get.offAll(() => const DetailedHomePage())),
                    );
                hideLoadingDialog();
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  );
}

Future<void> _selectTime(BuildContext context, int index,
    {bool isEndTime = false}) async {
  final classroomController = Get.find<ClassroomController>();
  final weekDay = classroomController.weekDays[index];
  final weekStartTimes = List.generate(7, (index) => TimeOfDay.now());
  final weekEndTimes = List.generate(7, (index) => TimeOfDay.now());
  TimeOfDay initialTime = TimeOfDay.now();
  if (isEndTime && classroomController.selectedEndTimes[index] != 'Off Day') {
    final selectedTime =
        DateTime.parse(classroomController.selectedEndTimes[index]);
    initialTime = TimeOfDay.fromDateTime(selectedTime);
  } else if (!isEndTime &&
      classroomController.selectedStartTimes[index] != 'Off Day') {
    final selectedTime =
        DateTime.parse(classroomController.selectedStartTimes[index]);
    initialTime = TimeOfDay.fromDateTime(selectedTime);
  }

  final TimeOfDay? picked = await showTimePicker(
    helpText: isEndTime ? 'Select End Time' : 'Select Start Time',
    context: context,
    initialTime: initialTime,
  );

  if (picked != null) {
    final dateTime = DateTime.now().copyWith(
      hour: picked.hour,
      minute: picked.minute,
    );
    if (isEndTime) {
      weekEndTimes[index] = picked;
      if (classroomController.selectedStartTimes[index] == 'Off Day') {
        final reducedDateTime = dateTime.add(const Duration(minutes: -50));
        weekStartTimes[index] = TimeOfDay.fromDateTime(reducedDateTime);
        classroomController.selectedStartTimes[index] =
            reducedDateTime.toString();
      } else {
        weekStartTimes[index] = TimeOfDay.fromDateTime(
            DateTime.parse(classroomController.selectedStartTimes[index]));
      }
      classroomController.selectedEndTimes[index] = dateTime.toString();
    } else {
      weekStartTimes[index] = picked;
      if (classroomController.selectedEndTimes[index] == 'Off Day') {
        final addedDateTime = dateTime.add(const Duration(minutes: 50));
        weekEndTimes[index] = TimeOfDay.fromDateTime(addedDateTime);
        classroomController.selectedEndTimes[index] = addedDateTime.toString();
      } else {
        weekEndTimes[index] = TimeOfDay.fromDateTime(
            DateTime.parse(classroomController.selectedEndTimes[index]));
      }
      classroomController.selectedStartTimes[index] = dateTime.toString();
    }

    final timeDifference =
        (weekEndTimes[index].hour * 60 + weekEndTimes[index].minute) -
            (weekStartTimes[index].hour * 60 + weekStartTimes[index].minute);
    if (timeDifference < 0) {
      classroomController.selectedStartTimes[index] = DateTime.now()
          .copyWith(
            hour: weekEndTimes[index].hour,
            minute: weekEndTimes[index].minute,
          )
          .toString();
      classroomController.selectedEndTimes[index] = DateTime.now()
          .copyWith(
            hour: weekStartTimes[index].hour,
            minute: weekStartTimes[index].minute,
          )
          .toString();
    }

    classroomController.selectedWeekTimes[weekDay]['startTime'] =
        classroomController.selectedStartTimes[index];
    classroomController.selectedWeekTimes[weekDay]['endTime'] =
        classroomController.selectedEndTimes[index];
  } else if (!isEndTime &&
      classroomController.selectedStartTimes[index] == 'Off Day') {
    classroomController.selectedWeeks[index] = false;
  }
}

Widget _buildWeekTimeList(
  BuildContext context,
  int index,
  List<TextEditingController> roomNoController,
  List<TextEditingController> classCountController,
) {
  final classroomController = Get.find<ClassroomController>();

  final classroom = Get.find<AttendanceController>().classroomData;

  final weekName = classroomController.weekDays[index];

  final expansionController = ExpansionTileController();
  return Obx(() {
    final isSelected = classroomController.selectedWeeks[index];
    final selectedStartTime = classroomController.selectedStartTimes[index];
    final selectedEndTime = classroomController.selectedEndTimes[index];
    final startTimeString = selectedStartTime == 'Off Day'
        ? 'Off Day'
        : DateFormat.jm().format(DateTime.parse(selectedStartTime));
    final endTimeString = selectedEndTime == 'Off Day'
        ? 'Off Day'
        : DateFormat.jm().format(DateTime.parse(selectedEndTime));

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: colorScheme.surfaceVariant.withOpacity(0.6)),
      child: Theme(
        data: Get.theme.copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          controller: expansionController,
          onExpansionChanged: (value) async {
            if (!classroomController.selectedWeeks[index] && value) {
              if (classroom.isArchived) {
                expansionController.collapse();
                return;
              }
              classroomController.selectedWeeks[index] = value;
              classroomController.selectedWeekTimes[weekName]['startTime'] =
                  'Off Day';
              classroomController.selectedWeekTimes[weekName]['endTime'] =
                  'Off Day';
              classroomController.selectedStartTimes[index] = 'Off Day';
              classroomController.selectedEndTimes[index] = 'Off Day';
              if (value) {
                await _selectTime(context, index);
                if (!classroomController.selectedWeeks[index]) {
                  expansionController.collapse();
                }
              }
            }
          },
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                weekName,
                style: classroomController.selectedWeeks[index]
                    ? textTheme.bodyMedium!.copyWith(color: textColorDefault)
                    : textTheme.bodyMedium!.copyWith(color: textColorLight),
              ),
              Text(
                startTimeString == 'Off Day'
                    ? 'No class'
                    : '$startTimeString - $endTimeString',
                style: textTheme.labelSmall!.copyWith(color: textColorLight),
              ),
            ],
          ),
          trailing: SizedBox(
            height: 35,
            child: FittedBox(
              fit: BoxFit.fill,
              child: Switch.adaptive(
                value: classroomController.selectedWeeks[index],
                onChanged: (value) async {
                  if (classroom.isArchived) {
                    value = false;
                    return;
                  }
                  classroomController.selectedWeeks[index] = value;
                  classroomController.selectedWeekTimes[weekName]['startTime'] =
                      'Off Day';
                  classroomController.selectedWeekTimes[weekName]['endTime'] =
                      'Off Day';
                  classroomController.selectedStartTimes[index] = 'Off Day';
                  classroomController.selectedEndTimes[index] = 'Off Day';
                  if (value) {
                    expansionController.expand();
                    await _selectTime(context, index);
                    if (classroomController.selectedStartTimes[index] ==
                        'Off Day') {
                      expansionController.collapse();
                    }
                  } else {
                    expansionController.collapse();
                  }
                },
              ),
            ),
          ),
          children: [
            verticalGap(deviceHeight * percentGapVerySmall),
            Row(
              children: [
                horizontalGap(deviceWidth * 0.05),
                Flexible(
                  flex: 1,
                  child: TextField(
                    readOnly: classroom.isArchived,
                    keyboardType: TextInputType.none,
                    onTap:
                        isSelected ? () => _selectTime(context, index) : null,
                    controller: TextEditingController(text: startTimeString),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(8),
                      isDense: true,
                      labelText: 'From',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    textAlign: TextAlign.center,
                    style: textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColorDefault,
                    ),
                  ),
                ),
                horizontalGap(deviceWidth * percentGapSmall),
                const Text('-'),
                horizontalGap(deviceWidth * percentGapSmall),
                Flexible(
                  flex: 1,
                  child: TextField(
                    readOnly: classroom.isArchived,
                    keyboardType: TextInputType.none,
                    onTap: isSelected
                        ? () => _selectTime(context, index, isEndTime: true)
                        : null,
                    controller: TextEditingController(text: endTimeString),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(8),
                      isDense: true,
                      labelText: 'To',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    textAlign: TextAlign.center,
                    style: textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColorDefault,
                    ),
                  ),
                ),
                horizontalGap(deviceWidth * 0.05),
              ],
            ),
            verticalGap(deviceHeight * percentGapSmall),
            Row(
              children: [
                horizontalGap(deviceWidth * 0.05),
                Flexible(
                  flex: 1,
                  child: TextField(
                    readOnly: classroom.isArchived,
                    enabled: isSelected,
                    controller: roomNoController[index],
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(8),
                      isDense: true,
                      labelText: 'Room No',
                      labelStyle: textTheme.labelMedium!.copyWith(
                        color: textColorDefault,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    textAlign: TextAlign.start,
                    style: textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColorDefault,
                    ),
                    onChanged: (value) {
                      classroomController.selectedWeekTimes[weekName]['room'] =
                          roomNoController[index].text.trim();
                    },
                  ),
                ),
                horizontalGap(deviceWidth * percentGapSmall),
                const Text(' '),
                horizontalGap(deviceWidth * percentGapSmall),
                Flexible(
                  flex: 1,
                  child: TextField(
                    readOnly: classroom.isArchived,
                    enabled: isSelected,
                    controller: classCountController[index],
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(8),
                      isDense: true,
                      labelText: 'Class Count',
                      labelStyle: textTheme.labelMedium!.copyWith(
                        color: textColorDefault,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.start,
                    style: textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColorDefault,
                    ),
                    onChanged: (value) {
                      if (value == '' || value == '0') {
                        classroomController.selectedWeekTimes[weekName]
                            ['classCount'] = '1';
                      } else {
                        classroomController.selectedWeekTimes[weekName]
                                ['classCount'] =
                            classCountController[index].text.trim();
                      }
                    },
                  ),
                ),
                horizontalGap(deviceWidth * 0.05),
              ],
            ),
            verticalGap(deviceHeight * percentGapSmall),
          ],
        ),
      ),
    );
  });
}

// Widget _buildWeekTimeList(
//   BuildContext context,
//   int index,
//   List<TextEditingController> roomNoController,
// ) {
//   final classroomController = Get.find<ClassroomController>();
//
//   final height = Get.height;
//   final width = Get.width;
//
//   final weekName = classroomController.weekDays[index];
//   return Obx(() {
//     final isSelected = classroomController.selectedWeeks[index];
//     final selectedStartTime = classroomController.selectedStartTimes[index];
//     final selectedEndTime = classroomController.selectedEndTimes[index];
//     final startTimeString = selectedStartTime == 'Off Day'
//         ? 'Off Day'
//         : DateFormat.jm().format(DateTime.parse(selectedStartTime));
//     final endTimeString = selectedEndTime == 'Off Day'
//         ? 'Off Day'
//         : DateFormat.jm().format(DateTime.parse(selectedEndTime));
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 15),
//       padding:
//       const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(15),
//           color: colorScheme.surfaceVariant.withOpacity(0.6)),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(weekName),
//               const Spacer(),
//               SizedBox(
//                 height: 40,
//                 child: FittedBox(
//                   fit: BoxFit.fill,
//                   child: Switch.adaptive(
//                     value: classroomController.selectedWeeks[index],
//                     onChanged: (value) {
//                       classroomController.selectedWeeks[index] = value;
//                       classroomController.selectedWeekTimes[weekName]
//                           ['startTime'] = 'Off Day';
//                       classroomController.selectedWeekTimes[weekName]['endTime'] =
//                           'Off Day';
//                       classroomController.selectedStartTimes[index] = 'Off Day';
//                       classroomController.selectedEndTimes[index] = 'Off Day';
//                       if (value) {
//                         _selectTime(context, index);
//                       }
//                     },
//                   ),
//                 ),
//               ),
//               // Obx(() {
//               //   return ElevatedButton(
//               //     onPressed:
//               //         classroomController.selectedWeeks[index]
//               //             ? () => selectTime(index)
//               //             : null,
//               //     child: const Icon(Icons.access_time),
//               //   );
//               // }),
//             ],
//           ),
//           isSelected
//               ? Column(
//                   children: [
//                     Row(
//                       children: [
//                         horizontalGap(width * 0.05),
//                         Flexible(
//                           flex: 1,
//                           child: TextField(
//                             keyboardType: TextInputType.none,
//                             onTap: isSelected
//                                 ? () => _selectTime(context, index)
//                                 : null,
//                             controller:
//                                 TextEditingController(text: startTimeString),
//                             decoration: InputDecoration(
//                               contentPadding: const EdgeInsets.all(8),
//                               isDense: true,
//                               labelText: 'From',
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             textAlign: TextAlign.center,
//                             style: Get.textTheme.labelMedium!
//                                 .copyWith(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         horizontalGap(width * percentGapSmall),
//                         const Text('-'),
//                         horizontalGap(width * percentGapSmall),
//                         Flexible(
//                           flex: 1,
//                           child: TextField(
//                             keyboardType: TextInputType.none,
//                             onTap: isSelected
//                                 ? () =>
//                                     _selectTime(context, index, isEndTime: true)
//                                 : null,
//                             controller:
//                                 TextEditingController(text: endTimeString),
//                             decoration: InputDecoration(
//                               contentPadding: const EdgeInsets.all(8),
//                               isDense: true,
//                               labelText: 'To',
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             textAlign: TextAlign.center,
//                             style: Get.textTheme.labelMedium!
//                                 .copyWith(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         horizontalGap(width * 0.05),
//                       ],
//                     ),
//                     verticalGap(height * percentGapSmall),
//                     Row(
//                       children: [
//                         horizontalGap(width * 0.05),
//                         Flexible(
//                           flex: 1,
//                           child: TextField(
//                             readOnly: !isSelected,
//                             enabled: isSelected,
//                             controller: roomNoController[index],
//                             decoration: InputDecoration(
//                               contentPadding: const EdgeInsets.all(8),
//                               isDense: true,
//                               labelText: 'Room No',
//                               labelStyle: Get.textTheme.labelMedium,
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             textAlign: TextAlign.start,
//                             style: Get.textTheme.labelMedium!
//                                 .copyWith(fontWeight: FontWeight.bold),
//                             onChanged: (value) {
//                               classroomController.selectedWeekTimes[weekName]
//                                   ['room'] = roomNoController[index].text.trim();
//                             },
//                           ),
//                         ),
//                         horizontalGap(width * percentGapSmall),
//                         const Text(' '),
//                         horizontalGap(width * percentGapSmall),
//                         Flexible(
//                           flex: 1,
//                           child: TextField(
//                             readOnly: !isSelected,
//                             enabled: isSelected,
//                             controller: roomNoController[index],
//                             decoration: InputDecoration(
//                               contentPadding: const EdgeInsets.all(8),
//                               isDense: true,
//                               labelText: 'Class Count',
//                               labelStyle: Get.textTheme.labelMedium,
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             textAlign: TextAlign.start,
//                             style: Get.textTheme.labelMedium!
//                                 .copyWith(fontWeight: FontWeight.bold),
//                             onChanged: (value) {
//                               classroomController.selectedWeekTimes[weekName]
//                                   ['room'] = roomNoController[index].text.trim();
//                             },
//                           ),
//                         ),
//                         horizontalGap(width * 0.05),
//                       ],
//                     ),
//                   ],
//                 )
//               : const SizedBox(),
//         ],
//       ),
//     );
//   });
// }
