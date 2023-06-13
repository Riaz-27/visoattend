import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visoattend/models/classroom_model.dart';
import 'package:visoattend/views/pages/create_classroom_page.dart';

import '../../controller/cloud_firestore_controller.dart';
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
                            cloudFirestoreController.currentUsername;
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
                child: StreamBuilder<List<ClassroomModel>>(
                    stream: cloudFirestoreController.getUserClassrooms,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Loading...');
                      }
                      if (snapshot.hasData) {
                        print('UPDATING STREAM: ${snapshot.data!.length}');
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            final classroom = snapshot.data![index];
                            return GestureDetector(
                              onTap: () => Get.to(() => const ClassroomPage()),
                              child: _buildCustomCard(
                                classname:
                                    '${classroom.courseCode} - ${classroom.courseTitle}',
                              ),
                            );
                          },
                        );
                      }
                      return const Text('No Classroom data found.');
                    }),
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
    required String classname,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.grey[200], // Replace with your desired color
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classname,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Date',
                  style: TextStyle(fontSize: 14.0),
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
                onPressed: () {
                  //TODO
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
