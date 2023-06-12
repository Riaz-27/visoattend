import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visoattend/views/pages/create_classroom_page.dart';

import '../../controller/cloud_firestore_controller.dart';
import '../../views/pages/classroom_page.dart';
import '../../views/widgets/custom_text_form_field.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                      Obx(
                        () {
                          final userName = Get.find<CloudFirestoreController>().currentUsername;
                          return Text(
                            'Welcome, $userName',
                            style: const TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                      ),
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
                child: ListView.builder(
                  itemCount: 3, // Replace with your desired number of classes
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () => Get.to(() => const ClassroomPage()),
                      child: _buildCustomCard(),
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

  Widget _buildCustomCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.grey[200], // Replace with your desired color
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Classname',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Date',
                  style: TextStyle(fontSize: 14.0),
                ),
              ],
            ),
            Spacer(),
            Column(
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
