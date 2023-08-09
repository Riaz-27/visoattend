import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controller/attendance_controller.dart';
import '../../../helper/functions.dart';
import '../../../views/widgets/custom_button.dart';
import '../../../controller/cloud_firestore_controller.dart';
import '../../../controller/leave_request_controller.dart';
import '../../../helper/constants.dart';
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
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.loadLeaveRequestData();
        },
        child: Padding(
          padding: EdgeInsets.only(
            right: deviceHeight * percentGapSmall,
            left: deviceHeight * percentGapSmall,
          ),
          child: Obx(
            () {
              return controller.classroomLeaveRequests.isEmpty
                  ? const Center(
                      child: Text('No leave request application found'),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: attendanceController.classroomData.isArchived
                          ? const EdgeInsets.only(bottom: 80)
                          : EdgeInsets.zero,
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
                            context,
                            leaveRequestIndex: index,
                            user: user,
                          ),
                        );
                      },
                    );
            },
          ),
        ),
      ),
      floatingActionButton: Obx(
        () {
          return attendanceController.currentUserRole != 'Teacher' &&
                  !attendanceController.classroomData.isArchived
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

  Widget _buildLeaveRequestList(BuildContext context,
      {required int leaveRequestIndex, required UserModel user}) {
    final attendanceController = Get.find<AttendanceController>();
    final isTeacher = attendanceController.currentUserRole == 'Teacher';
    final classroomId = attendanceController.classroomData.classroomId;

    final leaveRequest = controller.classroomLeaveRequests[leaveRequestIndex];

    final fromDateTime = DateTime.parse(leaveRequest.fromDate);
    final toDateTime = DateTime.parse(leaveRequest.toDate);
    final dateDifference = toDateTime
        .add(const Duration(milliseconds: 1))
        .difference(fromDateTime);
    String durationDay = dateDifference.inDays > 1
        ? '${dateDifference.inDays} days'
        : '${dateDifference.inDays} day';
    final leaveRequestDateTime = DateTime.parse(leaveRequest.dateTime);
    final now = DateTime.now();
    final isToday = leaveRequestDateTime.day == now.day &&
        leaveRequestDateTime.month == now.month &&
        leaveRequestDateTime.year == now.year;

    final dateString = isToday
        ? 'Today'
        : DateFormat('dd MMMM, y').format(leaveRequestDateTime);
    final timeString = DateFormat('hh:mm a').format(leaveRequestDateTime);

    return InkWell(
      customBorder:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onLongPress: () {
        if (isTeacher ||
            leaveRequest.applicationStatus[classroomId] == 'Pending') {
          _handleDeleteLeaveRequest(context, leaveRequestIndex);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: deviceHeight * percentGapSmall,
          horizontal: deviceWidth * percentGapLarge,
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
                horizontalGap(deviceWidth * percentGapSmall),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColorDefault,
                      ),
                    ),
                    verticalGap(deviceHeight * percentGapVerySmall),
                    Text(
                      user.userId,
                      style: textTheme.bodySmall!.copyWith(
                        color: textColorLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            verticalGap(deviceHeight * percentGapSmall),
            Row(
              children: [
                Icon(
                  Icons.date_range_rounded,
                  size: 18,
                  color: colorScheme.secondary,
                ),
                horizontalGap(deviceWidth * percentGapSmall),
                Text(
                  DateFormat('dd MMMM y').format(fromDateTime),
                  style: textTheme.labelMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColorDefault,
                  ),
                ),
                horizontalGap(deviceWidth * percentGapSmall),
                Text(
                  'to',
                  style: textTheme.labelMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColorDefault,
                  ),
                ),
                horizontalGap(deviceWidth * percentGapSmall),
                Text(
                  DateFormat('dd MMMM y').format(toDateTime),
                  style: textTheme.labelMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColorDefault,
                  ),
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
                    style: textTheme.labelMedium!.copyWith(
                      color: textColorDefault,
                    ),
                  ),
                ),
              ],
            ),
            verticalGap(deviceHeight * percentGapVerySmall),
            Row(
              children: [
                Icon(
                  Icons.subtitles,
                  size: 18,
                  color: colorScheme.secondary,
                ),
                horizontalGap(deviceWidth * percentGapSmall),
                Text(
                  leaveRequest.reason,
                  style: textTheme.labelMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColorDefault,
                  ),
                ),
              ],
            ),
            verticalGap(deviceHeight * percentGapVerySmall),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                horizontalGap(deviceWidth * percentGapSmall + 18),
                Expanded(
                  child: Text(
                    leaveRequest.description,
                    style: textTheme.labelMedium!.copyWith(
                      color: textColorDefault,
                    ),
                  ),
                ),
              ],
            ),
            verticalGap(deviceHeight * percentGapSmall),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$dateString at $timeString',
                    style: textTheme.labelMedium!.copyWith(
                      color: textColorLight,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            verticalGap(deviceHeight * percentGapVerySmall),
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
                            width: deviceWidth * 0.3,
                            height: 35,
                            backgroundColor:
                                colorScheme.primary.withOpacity(0.6),
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
                            width: deviceWidth * 0.3,
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
      ),
    );
  }

  void _handleDeleteLeaveRequest(context, leaveRequestIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete Leave Request',
            style: textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: textColorDefault,
            ),
          ),
          content: SizedBox(
            width: deviceWidth,
            child: Text(
              'Do you really want to delete this request?',
              style: textTheme.bodyMedium!.copyWith(
                color: textColorDefault,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await controller.deleteClassroomLeaveRequest(
                  leaveRequestIndex: leaveRequestIndex,
                );
                Get.back();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
