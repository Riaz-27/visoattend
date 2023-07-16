import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visoattend/controller/attendance_controller.dart';

import 'apply_leave_page.dart';

class LeaveRequestPage extends GetView<AttendanceController> {
  const LeaveRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Obx(
        () {
          return controller.currentUserRole != 'Teacher'
              ? FloatingActionButton(
                  onPressed: () => Get.to(() => const ApplyLeavePage()),
                  child: const Icon(Icons.add),
                )
              : const SizedBox();
        },
      ),
    );
  }
}
