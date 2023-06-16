import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visoattend/controller/auth_controller.dart';
import 'package:visoattend/models/attendance_model.dart';

import '../../controller/attendance_controller.dart';
import '../../controller/cloud_firestore_controller.dart';
import '../../models/classroom_model.dart';
import 'attendance_record_page.dart';

class ClassroomPage extends GetView<AttendanceController> {
  const ClassroomPage({super.key, required this.classroomData});

  final ClassroomModel classroomData;

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    controller.updateValues(classroomData);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classroom'),
        actions: [
          IconButton(
            onPressed: () async {
              await authController.signOut();
            },
            icon: const Icon(Icons.logout_rounded),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Center(
                    child: Text(
                      'Card View',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
            ),
          ),
          Expanded(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Obx(() {
                return ListView.builder(
                  itemCount: controller.attendances.length,
                  itemBuilder: (context, index) {
                    return _buildAttendanceListView(
                        data: controller.attendances[index]);
                  },
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        ),
        onPressed: () {
          Get.to(() => const AttendanceRecordPage());
        },
        child: const Text('Take Attendance'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAttendanceListView({required AttendanceModel data}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: const ListTile(
        title: Text('attendance'),
      ),
    );
  }
}
