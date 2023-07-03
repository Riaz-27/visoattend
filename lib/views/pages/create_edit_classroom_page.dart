import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visoattend/controller/classroom_controller.dart';
import 'package:visoattend/helper/constants.dart';
import 'package:visoattend/helper/functions.dart';

import '../../models/classroom_model.dart';

class CreateEditClassroomPage extends StatelessWidget {
  const CreateEditClassroomPage({
    super.key,
    this.isEdit = false,
    this.classroom,
    this.userRole = 'Teacher',
  });

  final bool isEdit;
  final ClassroomModel? classroom;
  final String userRole;

  @override
  Widget build(BuildContext context) {
    final courseCodeController = TextEditingController();
    final courseTitleController = TextEditingController();
    final sectionController = TextEditingController();
    final sessionController = TextEditingController();
    final roomNoController =
        List.generate(7, (index) => TextEditingController());

    final classroomController = Get.find<ClassroomController>();

    final height = Get.height;
    final width = Get.width;

    if (isEdit && classroom != null) {
      courseTitleController.text = classroom!.courseTitle;
      courseCodeController.text = classroom!.courseCode;
      sectionController.text = classroom!.section;
      sessionController.text = classroom!.session;
      final weekDays = classroomController.weekDays;
      for (int i = 0; i < weekDays.length; i++) {
        final dbWeekStartTime = classroom!.weekTimes[weekDays[i]]['startTime'];
        final dbWeekEndTime = classroom!.weekTimes[weekDays[i]]['endTime'];
        final dbWeekRoomNo = classroom!.weekTimes[weekDays[i]]['room'];
        if (dbWeekStartTime != 'Off Day') {
          //getting the database time and setting the variables
          classroomController.selectedStartTimes[i] = dbWeekStartTime;
          classroomController.selectedEndTimes[i] = dbWeekEndTime;
          classroomController.selectedWeekTimes[weekDays[i]]['startTime'] =
              dbWeekStartTime;
          classroomController.selectedWeekTimes[weekDays[i]]['endTime'] =
              dbWeekEndTime;
          classroomController.selectedWeeks[i] = true;

          //getting the database room no and setting the variables
          classroomController.selectedWeekTimes[weekDays[i]]['room'] =
              dbWeekRoomNo;
          roomNoController[i].text = dbWeekRoomNo;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          isEdit ? 'Edit Classroom' : 'Create Classroom',
          style: Get.textTheme.bodyLarge,
        ),
        actions: [
          if (isEdit)
            Padding(
              padding: const EdgeInsets.only(right: kSmall),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Get.theme.colorScheme.error,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(kSmall),
                  child: Text(
                    'Delete',
                    style: Get.textTheme.bodySmall!.copyWith(
                      color: Get.theme.colorScheme.onError,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: height * percentGapSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              readOnly: userRole == 'Teacher' ? false : true,
              controller: courseCodeController,
              decoration: InputDecoration(
                labelText: 'Course Code (e.g. CSE-4800) *',
                labelStyle: Get.textTheme.bodyMedium,
                isDense: true,
                alignLabelWithHint: true,
              ),
            ),
            verticalGap(height * percentGapVerySmall),
            TextField(
              readOnly: userRole == 'Teacher' ? false : true,
              controller: courseTitleController,
              decoration: InputDecoration(
                labelText: 'Course Title (e.g. Project / Thesis) *',
                labelStyle: Get.textTheme.bodyMedium,
                alignLabelWithHint: true,
                isDense: true,
              ),
            ),
            verticalGap(height * percentGapVerySmall),
            TextField(
              controller: sectionController,
              decoration: InputDecoration(
                labelText: 'Section (e.g. 8BM)',
                labelStyle: Get.textTheme.bodyMedium,
                isDense: true,
                alignLabelWithHint: true,
              ),
            ),
            verticalGap(height * percentGapVerySmall),
            TextField(
              controller: sessionController,
              decoration: InputDecoration(
                labelText: 'Session (e.g. Spring-2022)',
                labelStyle: Get.textTheme.bodyMedium,
                isDense: true,
                alignLabelWithHint: true,
              ),
            ),
            verticalGap(height * percentGapMedium),
            Text(
              'Set Week Times',
              style: Get.textTheme.titleMedium,
            ),
            verticalGap(height * percentGapVerySmall),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 7,
                itemBuilder: (context, index) {
                  return _buildWeekTimeList(context, index, roomNoController);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: height * percentGapSmall),
              child: ElevatedButton(
                onPressed: () async {
                  final courseCode = courseCodeController.text.trim();
                  final courseTitle = courseTitleController.text.trim();
                  if(courseTitle.isEmpty || courseTitle.isEmpty){
                    return;
                  }
                  if (isEdit && classroom != null) {
                    classroom!.courseCode = courseCodeController.text.trim();
                    classroom!.courseTitle = courseTitleController.text.trim();
                    classroom!.session = sessionController.text.trim();
                    classroom!.section = sectionController.text.trim();
                    classroom!.weekTimes = classroomController.selectedWeekTimes;
                    await classroomController.updateClassroom(classroom!);
                  } else if (!isEdit) {
                    await classroomController.createNewClassroom(
                      courseCode: courseCode,
                      courseTitle: courseTitle,
                      section: sectionController.text.trim(),
                      session: sessionController.text.trim(),
                    );
                  }
                  Get.back();
                },
                child: const Text('Confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _selectTime(BuildContext context, int index,
    {bool isEndTime = false}) async {
  final classroomController = Get.find<ClassroomController>();
  final weekDay = classroomController.weekDays[index];
  final weekStartTimes = List.generate(7, (index) => TimeOfDay.now());
  final weekEndTimes = List.generate(7, (index) => TimeOfDay.now());
  final TimeOfDay? picked = await showTimePicker(
    helpText: isEndTime ? 'Select End Time' : 'Select Start Time',
    context: context,
    initialTime: isEndTime ? weekEndTimes[index] : weekStartTimes[index],
  );

  if (picked != null) {
    final dateTime = DateTime.now().copyWith(
      hour: picked.hour,
      minute: picked.minute,
    );
    if (isEndTime) {
      weekEndTimes[index] = picked;
      if (classroomController.selectedStartTimes[index] == 'Off Day') {
        final reducedDateTime = dateTime.add(const Duration(minutes: -40));
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
        final addedDateTime = dateTime.add(const Duration(minutes: 40));
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
  } else {
    classroomController.selectedWeeks[index] = false;
  }
}

Widget _buildWeekTimeList(
  BuildContext context,
  int index,
  List<TextEditingController> roomNoController,
) {
  final classroomController = Get.find<ClassroomController>();

  final height = Get.height;
  final width = Get.width;

  final weekName = classroomController.weekDays[index];
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: classroomController.selectedWeeks[index],
              onChanged: (value) {
                classroomController.selectedWeeks[index] = value ?? false;
                classroomController.selectedWeekTimes[weekName]['startTime'] =
                    'Off Day';
                classroomController.selectedWeekTimes[weekName]['endTime'] =
                    'Off Day';
                classroomController.selectedWeekTimes[weekName]['room'] = '';
                classroomController.selectedStartTimes[index] = 'Off Day';
                classroomController.selectedEndTimes[index] = 'Off Day';
                if (value != null && value) {
                  _selectTime(context, index);
                }
              },
            ),
            Text(weekName),
            horizontalGap(width * percentGapSmall),
            // Obx(() {
            //   return ElevatedButton(
            //     onPressed:
            //         classroomController.selectedWeeks[index]
            //             ? () => selectTime(index)
            //             : null,
            //     child: const Icon(Icons.access_time),
            //   );
            // }),
          ],
        ),
        isSelected
            ? Row(
                children: [
                  horizontalGap(width * 0.05),
                  Flexible(
                    flex: 1,
                    child: TextField(
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
                      style: Get.textTheme.labelMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  horizontalGap(width * percentGapSmall),
                  const Text('-'),
                  horizontalGap(width * percentGapSmall),
                  Flexible(
                    flex: 1,
                    child: TextField(
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
                      style: Get.textTheme.labelMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  horizontalGap(width * percentGapLarge),
                  Flexible(
                    flex: 2,
                    child: TextField(
                      readOnly: !isSelected,
                      enabled: isSelected,
                      controller: roomNoController[index],
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(8),
                        isDense: true,
                        labelText: 'Room No',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      textAlign: TextAlign.start,
                      style: Get.textTheme.labelMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                      onChanged: (value) {
                        classroomController.selectedWeekTimes[weekName]
                            ['room'] = roomNoController[index].text.trim();
                      },
                    ),
                  ),
                ],
              )
            : const SizedBox(),
      ],
    );
  });
}
