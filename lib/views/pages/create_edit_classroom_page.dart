import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visoattend/controller/classroom_controller.dart';
import 'package:visoattend/helper/constants.dart';
import 'package:visoattend/helper/functions.dart';

import '../../models/classroom_model.dart';

class CreateEditClassroomPage extends StatelessWidget {
  const CreateEditClassroomPage(
      {super.key,
      this.isEdit = false,
      this.classroom,
      this.userRole = 'Teacher'});

  final bool isEdit;
  final ClassroomModel? classroom;
  final String userRole;

  @override
  Widget build(BuildContext context) {
    final courseCodeController = TextEditingController();
    final courseTitleController = TextEditingController();
    final sectionController = TextEditingController();
    final sessionController = TextEditingController();

    final classroomController = Get.find<ClassroomController>();

    final weekTimes = List.generate(7, (index) => TimeOfDay.now());
    final height = Get.height;
    final width = Get.width;

    Future<void> selectTime(int index) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: weekTimes[index],
      );

      if (picked != null) {
        final dateTime = DateTime.now().copyWith(
          hour: picked.hour,
          minute: picked.minute,
        );
        print(dateTime);
        weekTimes[index] = picked;
        classroomController
                .selectedWeekTimes[classroomController.weekDays[index]]
            ['time'] = dateTime.toString();
      }
    }

    if (isEdit && classroom != null) {
      courseTitleController.text = classroom!.courseTitle;
      courseCodeController.text = classroom!.courseCode;
      sectionController.text = classroom!.section;
      sessionController.text = classroom!.session;
      final weekDays = classroomController.weekDays;
      for (int i = 0; i < weekDays.length; i++) {
        final databaseWeekTime = classroom!.weekTimes[weekDays[i]]['time'];
        if (databaseWeekTime != 'Off Day') {
          classroomController.selectedWeekTimes[weekDays[i]]['time'] =
              databaseWeekTime;
          classroomController.selectedWeeks[i] = true;
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
                labelText: 'Course Code (e.g. CSE-4800)',
                labelStyle: Get.textTheme.bodyMedium,
              ),
            ),
            verticalGap(height * percentGapVerySmall),
            TextField(
              readOnly: userRole == 'Teacher' ? false : true,
              controller: courseTitleController,
              decoration: InputDecoration(
                labelText: 'Course Title (e.g. Project / Thesis)',
                labelStyle: Get.textTheme.bodyMedium,
              ),
            ),
            verticalGap(height * percentGapVerySmall),
            TextField(
              controller: sectionController,
              decoration: InputDecoration(
                labelText: 'Section (e.g. 8BM)',
                labelStyle: Get.textTheme.bodyMedium,
              ),
            ),
            verticalGap(height * percentGapVerySmall),
            TextField(
              controller: sessionController,
              decoration: InputDecoration(
                labelText: 'Session (e.g. Spring-2022)',
                labelStyle: Get.textTheme.bodyMedium,
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
                itemCount: 7,
                itemBuilder: (context, index) {
                  final weekName = classroomController.weekDays[index];
                  return Row(
                    children: [
                      Obx(() {
                        return Checkbox(
                          value: classroomController.selectedWeeks[index],
                          onChanged: (value) {
                            classroomController.selectedWeeks[index] =
                                value ?? false;
                            classroomController.selectedWeekTimes[weekName]
                                ['time'] = 'Off Day';
                            if (value != null && value) {
                              selectTime(index);
                            }
                          },
                        );
                      }),
                      Expanded(
                        child: Text(weekName),
                      ),
                      horizontalGap(width * percentGapVerySmall),
                      Expanded(
                        flex: 1,
                        child: Obx(() {
                          final isSelected =
                              classroomController.selectedWeeks[index];
                          final selectedTime = classroomController
                              .selectedWeekTimes[weekName]['time'];
                          final timeString = selectedTime == 'Off Day'
                              ? 'Off Day'
                              : DateFormat.jm()
                                  .format(DateTime.parse(selectedTime!));
                          return TextField(
                            readOnly: !isSelected,
                            onTap: isSelected ? () => selectTime(index) : null,
                            controller: TextEditingController(text: timeString),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.access_time),
                            ),
                          );
                        }),
                      ),
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
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (isEdit && classroom != null) {

                } else if (!isEdit) {
                  await classroomController.createNewClassroom(
                    courseCode: courseCodeController.text.trim(),
                    courseTitle: courseTitleController.text.trim(),
                    section: sectionController.text.trim(),
                    session: sessionController.text.trim(),
                  );
                }
                Get.back();
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
