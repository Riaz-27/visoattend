import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visoattend/controller/attendance_controller.dart';
import 'package:visoattend/helper/functions.dart';
import 'package:visoattend/views/widgets/custom_button.dart';

import '../../../controller/cloud_firestore_controller.dart';
import '../../../controller/leave_request_controller.dart';
import '../../../helper/constants.dart';
import '../../../models/leave_request_model.dart';
import '../../../models/user_model.dart';
import 'apply_leave_page.dart';

class LeaveRequestPage extends GetView<LeaveRequestController> {
  const LeaveRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final attendanceController = Get.find<AttendanceController>();
    final cloudFirestoreController = Get.find<CloudFirestoreController>();

    final isTeacher = attendanceController.currentUserRole == 'Teacher';

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          right: height * percentGapSmall,
          left: height * percentGapSmall,
        ),
        child: Obx(
          () {
            return controller.classroomLeaveRequests.isEmpty
                ? const Center(
                    child: Text('No leave request application found'),
                  )
                : ListView.builder(
                    itemCount: controller.classroomLeaveRequests.length,
                    itemBuilder: (context, index) {
                      final leaveRequest =
                          controller.classroomLeaveRequests[index];
                      final user = isTeacher
                          ? controller
                              .leaveRequestsUser[leaveRequest.leaveRequestId]!
                          : cloudFirestoreController.currentUser;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: _buildLeaveRequestList(
                            leaveRequestIndex: index, user: user),
                      );
                    },
                  );
          },
        ),
      ),
      floatingActionButton: Obx(
        () {
          return attendanceController.currentUserRole != 'Teacher'
              ? FloatingActionButton(
                  onPressed: () =>
                      Get.to(() => const ApplyLeavePage(isSelectedClass: true)),
                  child: const Icon(Icons.add),
                )
              : const SizedBox();
        },
      ),
    );
  }

  Widget _buildLeaveRequestList(
      {required int leaveRequestIndex, required UserModel user}) {
    final attendanceController = Get.find<AttendanceController>();

    final leaveRequest = controller.classroomLeaveRequests[leaveRequestIndex];

    final fromDateTime = DateTime.parse(leaveRequest.fromDate);
    final toDateTime = DateTime.parse(leaveRequest.toDate);
    final dateDifference = toDateTime.add(const Duration(milliseconds: 1)).difference(fromDateTime);
    String durationDay = dateDifference.inDays > 1
        ? '${dateDifference.inDays} days'
        : '${dateDifference.inDays} day';


    return Container(
      padding: EdgeInsets.symmetric(
        vertical: height * percentGapSmall,
        horizontal: width * percentGapLarge,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surfaceVariant.withOpacity(0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final status = leaveRequest.applicationStatus[
                attendanceController.classroomData.classroomId];
            Color color = colorScheme.primary;
            IconData icon = Icons.check_rounded;
            Color iconColor = colorScheme.primaryContainer;
            if (status == 'Declined') {
              color = colorScheme.error;
              iconColor = colorScheme.error.withOpacity(0.7);
              icon = Icons.clear_rounded;
            }
            return status != 'Pending'
                ? Row(
                    children: [
                      Text(
                        status,
                        style: textTheme.labelMedium!.copyWith(color: color),
                      ),
                      const Spacer(),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.circle_rounded,
                            size: 25,
                            color: iconColor,
                          ),
                          Icon(
                            icon,
                            size: 15,
                            color: colorScheme.surface,
                          ),
                        ],
                      ),
                    ],
                  )
                : const SizedBox();
          }),
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.outline.withOpacity(0.4),
                      image: const DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/default_profile.jpg'),
                      ),
                    ),
                  ),
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.outline.withOpacity(0.4),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(user.profilePic),
                      ),
                    ),
                  ),
                ],
              ),
              horizontalGap(width * percentGapSmall),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: textTheme.bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  verticalGap(height * percentGapVerySmall),
                  Text(
                    user.userId,
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
              const Spacer(),
              // Column(
              //   crossAxisAlignment: CrossAxisAlignment.end,
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     Text(
              //       'on 19 Jul 2023',
              //       style: textTheme.labelSmall,
              //     ),
              //     verticalGap(height * percentGapVerySmall),
              //     Text(
              //       'at 01:38am',
              //       style: textTheme.labelSmall,
              //     ),
              //   ],
              // ),
            ],
          ),
          verticalGap(height * percentGapSmall),
          Row(
            children: [
              Icon(
                Icons.date_range_rounded,
                size: 18,
                color: colorScheme.secondary,
              ),
              horizontalGap(width * percentGapSmall),
              Text(
                DateFormat('dd MMMM y').format(fromDateTime),
                style: textTheme.labelMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              horizontalGap(width * percentGapSmall),
              Text(
                'to',
                style: textTheme.labelMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              horizontalGap(width * percentGapSmall),
              Text(
                DateFormat('dd MMMM y').format(toDateTime),
                style: textTheme.labelMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: colorScheme.surfaceVariant.withOpacity(0.7),
                ),
                child: Text(
                  durationDay,
                  style: textTheme.labelMedium,
                ),
              ),
            ],
          ),
          verticalGap(height * percentGapVerySmall),
          Row(
            children: [
              Icon(
                Icons.subtitles,
                size: 18,
                color: colorScheme.secondary,
              ),
              horizontalGap(width * percentGapSmall),
              Text(
                leaveRequest.reason,
                style: textTheme.labelMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          verticalGap(height * percentGapVerySmall),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              horizontalGap(width * percentGapSmall + 18),
              Expanded(
                child: Text(
                  leaveRequest.description,
                  style: textTheme.labelMedium,
                ),
              ),
            ],
          ),
          verticalGap(height * percentGapSmall),
          Obx(
            () {
              final currentClass = attendanceController.classroomData;
              return attendanceController.currentUserRole == 'Teacher' &&
                      leaveRequest
                              .applicationStatus[currentClass.classroomId] ==
                          'Pending'
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomButton(
                          text: 'Approve',
                          textStyle: textTheme.bodyMedium!
                              .copyWith(color: colorScheme.surface),
                          width: width * 0.3,
                          height: 35,
                          backgroundColor: colorScheme.primary.withOpacity(0.6),
                          onPressed: () async {
                            await controller.changeApplicationStatus(
                                leaveRequestIndex: leaveRequestIndex,
                                status: 'Approved');
                            await attendanceController
                                .updateAttendanceOnApprove(leaveRequest);
                          },
                        ),
                        CustomButton(
                          text: 'Decline',
                          textColor: colorScheme.error,
                          textStyle: textTheme.bodyMedium!
                              .copyWith(color: colorScheme.surface),
                          width: width * 0.3,
                          backgroundColor:
                              colorScheme.onSurface.withOpacity(0.8),
                          height: 35,
                          onPressed: () async {
                            await controller.changeApplicationStatus(
                                leaveRequestIndex: leaveRequestIndex,
                                status: 'Declined');
                          },
                        ),
                      ],
                    )
                  : const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
