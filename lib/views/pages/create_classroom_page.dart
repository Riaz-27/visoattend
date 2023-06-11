import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visoattend/controller/classroom_database_controller.dart';

class CreateClassroomPage extends StatelessWidget {
  const CreateClassroomPage({super.key});

  @override
  Widget build(BuildContext context) {
    final courseCodeController = TextEditingController();
    final courseTitleController = TextEditingController();
    final sectionController = TextEditingController();

    final classroomDatabaseController = Get.find<ClassroomDatabaseController>();

    Future<void> selectTime(int index) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: classroomDatabaseController.weekTimes[index],
      );

      if (picked != null &&
          picked != classroomDatabaseController.weekTimes[index]) {
        classroomDatabaseController.weekTimes[index] = picked;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Classroom'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: courseCodeController,
              decoration: const InputDecoration(
                hintText: 'Course Code',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: courseTitleController,
              decoration: const InputDecoration(
                hintText: 'Course Title',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: sectionController,
              decoration: const InputDecoration(
                hintText: 'Section',
              ),
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Set Week Times',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: 7,
                itemBuilder: (context, index) {
                  final weekName = classroomDatabaseController.weekDays[index];

                  return Row(
                    children: [
                      Obx(() {
                        return Checkbox(
                          value:
                              classroomDatabaseController.selectedWeeks[index],
                          onChanged: (value) {
                            classroomDatabaseController.selectedWeeks[index] =
                                value ?? false;
                          },
                        );
                      }),
                      Expanded(
                        child: Text(weekName),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        flex: 1,
                        child: Obx(() {
                          final selectedTime = DateFormat.jm().format(
                            DateTime(
                                2023,
                                1,
                                6 + index,
                                classroomDatabaseController
                                    .weekTimes[index].hour,
                                classroomDatabaseController
                                    .weekTimes[index].minute),
                          );
                          final isSelected = classroomDatabaseController
                              .selectedWeeks[index];
                          return TextField(
                            readOnly: !isSelected,
                            onTap:
                            isSelected
                                    ? () => selectTime(index)
                                    : null,
                            controller:
                                TextEditingController(text: isSelected? selectedTime : 'Off Day'),
                            decoration: const InputDecoration(
                              hintText: 'Select Time',
                            ),
                          );
                        }),
                      ),
                      const SizedBox(width: 8.0),
                      Obx(() {
                        return ElevatedButton(
                          onPressed:
                              classroomDatabaseController.selectedWeeks[index]
                                  ? () => selectTime(index)
                                  : null,
                          child: const Icon(Icons.access_time),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // TODO: Handle confirm button press
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
