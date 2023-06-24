import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visoattend/controller/classroom_controller.dart';
import 'package:visoattend/helper/constants.dart';
import 'package:visoattend/helper/functions.dart';

class CreateClassroomPage extends StatelessWidget {
  const CreateClassroomPage({super.key});

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
            .selectedWeekTimes[classroomController.weekDays[index]] = dateTime.toString();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Classroom'),
      ),
      body: Padding(
        padding: EdgeInsets.all(height * percentGapSmall),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: courseCodeController,
              decoration: const InputDecoration(
                hintText: 'Course Code (e.g. CSE-4800)',
              ),
            ),
            verticalGap(height * percentGapVerySmall),
            TextField(
              controller: courseTitleController,
              decoration: const InputDecoration(
                hintText: 'Course Title (e.g. Project / Thesis)',
              ),
            ),
            verticalGap(height * percentGapVerySmall),
            TextField(
              controller: sectionController,
              decoration: const InputDecoration(
                hintText: 'Section (e.g. 8BM)',
              ),
            ),
            verticalGap(height * percentGapVerySmall),
            TextField(
              controller: sessionController,
              decoration: const InputDecoration(
                hintText: 'Session (e.g. Spring-2022)',
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
                            classroomController.selectedWeekTimes[weekName] =
                                'Off Day';
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
                          final selectedTime =
                              classroomController.selectedWeekTimes[weekName];
                          final timeString = selectedTime == 'Off Day' ? 'Off Day' : DateFormat.jm().format(DateTime.parse(selectedTime));
                          return TextField(
                            readOnly: !isSelected,
                            onTap: isSelected ? () => selectTime(index) : null,
                            controller:
                                TextEditingController(text: timeString),
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
                await classroomController.createNewClassroom(
                  courseCode: courseCodeController.text.trim(),
                  courseTitle: courseTitleController.text.trim(),
                  section: sectionController.text.trim(),
                  session: sessionController.text.trim(),
                );
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
