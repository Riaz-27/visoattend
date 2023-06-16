import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visoattend/models/classroom_model.dart';
import 'package:visoattend/views/pages/create_classroom_page.dart';

import '../../controller/classroom_controller.dart';
import '../../controller/cloud_firestore_controller.dart';
import '../../views/pages/classroom_page.dart';
import '../../views/widgets/custom_text_form_field.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 30, right: 16, left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                          style: const TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                      Text(
                        '${DateTime.now().day} ${_getMonthInLetter(DateTime.now().month)} ${DateTime.now().year}',
                        style: const TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Today\'s Classes',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: Obx(
                  () {
                    final classroomList = cloudFirestoreController.classrooms;
                    if(classroomList.isEmpty){
                      return const Text('No Classroom Found');
                    }
                    print('Found Classrooms: ${classroomList.length}');
                    return ListView.builder(
                      itemCount: classroomList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () => Get.to(() => ClassroomPage(classroomData: classroomList[index])),
                          child: _buildCustomCard(index: index),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 10),
        child: FloatingActionButton(
          onPressed: () {
            Get.bottomSheet(
              backgroundColor: Colors.white,
              enableDrag: true,
              Padding(
                padding: const EdgeInsets.all(10.0),
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
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(() => const CreateClassroomPage());
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
    required int index,
  }) {
    final classData = Get.find<CloudFirestoreController>().classrooms[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classData.courseTitle,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  classData.courseCode,
                  style: const TextStyle(fontSize: 14.0),
                ),
              ],
            ),
            const Spacer(),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Class Time',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Time Left',
                  style: TextStyle(fontSize: 14.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthInLetter(int month) {
    final months = [
      '', // To align with month indexing starting from 1
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
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
                hintText: 'Enter Class Id',
              ),
            ),
            // const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Get.put(ClassroomController());
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
}
