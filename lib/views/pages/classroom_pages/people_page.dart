import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:visoattend/controller/cloud_firestore_controller.dart';
import 'package:visoattend/controller/navigation_controller.dart';
import 'package:visoattend/helper/constants.dart';
import 'package:visoattend/services/report_generate_service.dart';
import 'package:visoattend/views/widgets/custom_button.dart';

import '../../../controller/attendance_controller.dart';
import '../../../controller/profile_pic_controller.dart';
import '../../../helper/functions.dart';
import '../../../models/classroom_model.dart';

class PeoplePage extends GetView<AttendanceController> {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final classroom = controller.classroomData;
    final height = Get.height;
    final width = Get.width;
    final colorScheme = Get.theme.colorScheme;
    final textTheme = Get.textTheme;

    final currentUserRole = controller.currentUserRole;

    final studentsList = classroom.students
      ..sort((a, b) => a['userId'].compareTo(b['userId']));

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * percentGapMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Teachers',
                style:
                    textTheme.titleMedium!.copyWith(color: colorScheme.primary),
              ),
              Divider(
                thickness: 1,
                color: colorScheme.primary,
              ),
              verticalGap(height * percentGapSmall),
              Flexible(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: classroom.teachers.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        _buildUsersList(
                          classroom.teachers[index],
                          userRole: 'Teacher',
                          forTeacher: true,
                        ),
                        if (classroom.teachers.length > 1)
                          const Divider(
                            thickness: 0.3,
                          )
                      ],
                    );
                  },
                ),
              ),
              verticalGap(height * percentGapMedium),
              if (classroom.cRs.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CRs',
                      style: textTheme.titleMedium!
                          .copyWith(color: colorScheme.primary),
                    ),
                    Text(
                      '${classroom.cRs.length} Students',
                      style: textTheme.titleSmall!
                          .copyWith(color: colorScheme.primary),
                    ),
                  ],
                ),
                Divider(
                  thickness: 1,
                  color: colorScheme.primary,
                ),
                verticalGap(height * percentGapSmall),
                Flexible(
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: classroom.cRs.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          _buildUsersList(
                            classroom.cRs[index],
                            userRole: 'CR',
                          ),
                          if (classroom.cRs.length > 1)
                            const Divider(
                              thickness: 0.3,
                            )
                        ],
                      );
                    },
                  ),
                ),
                verticalGap(height * percentGapMedium),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentUserRole == 'Teacher' ? 'Students' : 'Classmates',
                    style: textTheme.titleMedium!
                        .copyWith(color: colorScheme.primary),
                  ),
                  Text(
                    '${classroom.students.length} Students',
                    style: textTheme.titleSmall!
                        .copyWith(color: colorScheme.primary),
                  ),
                ],
              ),
              Divider(
                thickness: 1,
                color: colorScheme.primary,
              ),
              verticalGap(height * percentGapSmall),
              Flexible(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: studentsList.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        _buildUsersList(
                          studentsList[index],
                          userRole: 'Student',
                        ),
                        if (studentsList.length > 1)
                          const Divider(
                            thickness: 0.3,
                          )
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList(
    Map<String, dynamic> user, {
    required String userRole,
    bool forTeacher = false,
  }) {
    final classroom = controller.classroomData;
    final height = Get.height;
    final width = Get.width;
    final textTheme = Get.textTheme;
    final colorScheme = Get.theme.colorScheme;

    String picUrl =
        'https://firebasestorage.googleapis.com/v0/b/visoattend.appspot.com/o/profile_pics%2Fdefault_profile.jpg?alt=media&token=0ff37477-4ac1-41df-8522-73a5eacceee7';

    final isTeacher = controller.currentUserRole == 'Teacher';

    final currentUserAuthUid =
        Get.find<CloudFirestoreController>().currentUser.authUid;

    return InkWell(
      onTap: () {
        if (!isTeacher ||
            currentUserAuthUid == user['authUid'] ||
            user['authUid'] == classroom.teachers.first['authUid']) {
          return;
        }
        Get.find<CloudFirestoreController>().selectedUserRole = userRole;
        _handleUserPrivilege(user, userRole);
      },
      child: Container(
        color: colorScheme.surface,
        child: Obx(() {
          final percent = controller.getUserAttendancePercent(user['authUid']);
          Color color = colorScheme.primary;
          String status = 'Collegiate';
          if (percent < 0.6) {
            color = colorScheme.error;
            status = 'Dis-Collegiate';
          } else if (percent < 0.7) {
            color = Colors.orange;
            status = 'Non-Collegiate';
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              isTeacher
                  ? CircularPercentIndicator(
                      radius: 22,
                      lineWidth: 5,
                      percent: forTeacher
                          ? 0
                          : percent == 0
                              ? 1
                              : percent,
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: color,
                      backgroundColor: colorScheme.onBackground.withAlpha(15),
                      animation: true,
                      center: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(picUrl),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(picUrl),
                        ),
                      ),
                    ),
              horizontalGap(width * percentGapLarge),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'],
                    style: textTheme.bodyMedium!,
                  ),
                  Text(
                    user['userId'],
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
              const Spacer(),
              if (isTeacher && !forTeacher) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(percent * 100).toStringAsFixed(0)}%',
                      style: textTheme.labelSmall!
                          .copyWith(fontWeight: FontWeight.bold, color: color),
                    ),
                    Text(
                      status,
                      style: textTheme.labelSmall,
                    ),
                  ],
                )
              ]
            ],
          );
        }),
      ),
    );
  }

  void _handleUserPrivilege(Map<String, dynamic> user, String userRole) {
    final height = Get.height;
    final width = Get.width;
    final textTheme = Get.theme.textTheme;
    final colorScheme = Get.theme.colorScheme;

    final cloudFirestoreController = Get.find<CloudFirestoreController>();

    Get.bottomSheet(
      backgroundColor: colorScheme.surface,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(height * percentGapMedium),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${user['name']}',
              style: textTheme.titleLarge,
            ),
            Text(
              '${user['userId']}',
              style: textTheme.titleSmall,
            ),
            verticalGap(height * percentGapMedium),
            Text(
              'Set Role',
              style: textTheme.bodySmall,
            ),
            Obx(() {
              return Column(
                children: [
                  RadioListTile.adaptive(
                    contentPadding: const EdgeInsets.all(0),
                    value: 'Teacher',
                    groupValue: cloudFirestoreController.selectedUserRole,
                    onChanged: (value) {
                      cloudFirestoreController.selectedUserRole = value!;
                    },
                    title: const Text('Teacher'),
                  ),
                  RadioListTile.adaptive(
                    contentPadding: const EdgeInsets.all(0),
                    value: 'CR',
                    groupValue: cloudFirestoreController.selectedUserRole,
                    onChanged: (value) {
                      cloudFirestoreController.selectedUserRole = value!;
                    },
                    title: const Text('CR'),
                  ),
                  RadioListTile.adaptive(
                    contentPadding: const EdgeInsets.all(0),
                    value: 'Student',
                    groupValue: cloudFirestoreController.selectedUserRole,
                    onChanged: (value) {
                      cloudFirestoreController.selectedUserRole = value!;
                    },
                    title: const Text('Student'),
                  ),
                ],
              );
            }),
            verticalGap(height * percentGapMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  height: height * 0.05,
                  width: width * 0.4,
                  backgroundColor: colorScheme.onSurface,
                  textColor: colorScheme.surface,
                  text: 'Cancel',
                  onPressed: () {
                    Get.back();
                  },
                ),
                CustomButton(
                  height: height * 0.05,
                  width: width * 0.4,
                  text: 'Confirm',
                  onPressed: () async {
                    await cloudFirestoreController.changeUserRole(
                      user: user,
                      classroom: controller.classroomData,
                      currentRole: userRole,
                    );
                    Get.back();
                    Get.find<NavigationController>().changeIndex(0);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
