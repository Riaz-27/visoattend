import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controller/cloud_firestore_controller.dart';
import '../../../controller/navigation_controller.dart';
import '../../../helper/constants.dart';
import '../../../views/widgets/custom_button.dart';
import '../../../controller/attendance_controller.dart';
import '../../../helper/functions.dart';
import '../../../models/user_model.dart';

class PeoplePage extends GetView<AttendanceController> {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final classroom = controller.classroomData;
    final textTheme = Get.textTheme;

    final currentUserRole = controller.currentUserRole;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.updateValues(controller.classroomData);
          await controller.getUsersData();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * percentGapMedium),
            child: Obx(() {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Teachers',
                    style: textTheme.titleMedium!
                        .copyWith(color: colorScheme.primary),
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
                      itemCount: controller.teachersData.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            _buildUsersList(
                              controller.teachersData[index],
                              userRole: 'Teacher',
                              forTeacher: true,
                            ),
                            if (controller.teachersData.length > 1)
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
                        itemCount: controller.cRsData.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              _buildUsersList(
                                controller.cRsData[index],
                                userRole: 'CR',
                              ),
                              if (controller.cRsData.length > 1)
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
                        currentUserRole == 'Teacher'
                            ? 'Students'
                            : 'Classmates',
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
                      padding: controller.classroomData.isArchived
                          ? const EdgeInsets.only(bottom: 80)
                          : EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: controller.studentsData.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            _buildUsersList(
                              controller.studentsData[index],
                              userRole: 'Student',
                            ),
                            if (controller.studentsData.length > 1)
                              const Divider(
                                thickness: 0.3,
                              )
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList(
    UserModel user, {
    required String userRole,
    bool forTeacher = false,
  }) {
    final isTeacher = controller.currentUserRole == 'Teacher';

    final currentUserAuthUid =
        Get.find<CloudFirestoreController>().currentUser.authUid;

    Color color = colorScheme.primary;
    double percent = 0;
    int missedClasses = 0;
    int totalClasses = controller.attendances.length;

    return InkWell(
      onTap: () {
        if (!isTeacher ||
            currentUserAuthUid == user.authUid ||
            user.authUid ==
                controller.classroomData.teachers.first['authUid']) {
          return;
        }
        Get.find<CloudFirestoreController>().selectedUserRole = userRole;
        _handleUserPrivilege(
          user: user,
          userRole: userRole,
          color: color,
          percent: percent,
          forTeacher: forTeacher,
          missedClasses: missedClasses,
          totalClasses: totalClasses,
        );
      },
      child: Container(
        color: colorScheme.surface,
        child: Obx(() {
          missedClasses = controller.getUserMissedClassesCount(user.authUid);
          percent = totalClasses > 0
              ? (totalClasses - missedClasses) / totalClasses
              : 0;
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
                      radius: 19.5,
                      lineWidth: 3,
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
                          color: colorScheme.outline.withOpacity(0.4),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(user.profilePic),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.outline.withOpacity(0.4),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(user.profilePic),
                        ),
                      ),
                    ),
              horizontalGap(width * percentGapLarge),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: textTheme.bodyMedium!,
                  ),
                  Text(
                    forTeacher ? user.designation : user.userId,
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

  void _handleUserPrivilege({
    required UserModel user,
    required String userRole,
    required bool forTeacher,
    required double percent,
    required int missedClasses,
    required int totalClasses,
    required Color color,
  }) {
    String status = 'Collegiate';
    if (percent < 0.6) {
      status = 'Dis-Collegiate';
    } else if (percent < 0.7) {
      status = 'Non-Collegiate';
    }

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
      SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(height * percentGapMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircularPercentIndicator(
                    radius: 36,
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
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.outline.withOpacity(0.4),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(user.profilePic),
                        ),
                      ),
                    ),
                  ),
                  horizontalGap(width * percentGapMedium),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user.userId,
                        style: textTheme.bodyMedium,
                      ),
                      verticalGap(height * percentGapVerySmall),
                      Row(
                        children: [
                          Text(
                            'Attendance: ',
                            style: textTheme.bodySmall,
                          ),
                          Text(
                            '${(percent * 100).toStringAsFixed(0)}% | $status',
                            style: textTheme.bodySmall!.copyWith(color: color),
                          ),
                        ],
                      ),
                      verticalGap(height * percentGapVerySmall),
                      Row(
                        children: [
                          Text(
                            'Missed Class: ',
                            style: textTheme.bodySmall,
                          ),
                          Text(
                            '$missedClasses/$totalClasses',
                            style: textTheme.bodySmall!.copyWith(color: color),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              verticalGap(height * percentGapMedium),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mobile',
                        style: textTheme.bodySmall,
                      ),
                      verticalGap(height * percentGapVerySmall),
                      Text(
                        user.mobile == '' ? 'Number not set' : user.mobile,
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      if (user.mobile == '') {
                        return;
                      }
                      await launchPhoneDialer(user.mobile);
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: user.mobile == ''
                            ? colorScheme.outline.withOpacity(0.3)
                            : colorScheme.surfaceVariant,
                      ),
                      child: Icon(
                        Icons.call,
                        size: 25,
                        color: user.mobile == ''
                            ? colorScheme.outline
                            : colorScheme.primary,
                      ),
                    ),
                  ),
                ],
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
                        if (!controller.classroomData.isArchived) {
                          cloudFirestoreController.selectedUserRole = value!;
                        }
                      },
                      title: const Text('Teacher'),
                    ),
                    RadioListTile.adaptive(
                      contentPadding: const EdgeInsets.all(0),
                      value: 'CR',
                      groupValue: cloudFirestoreController.selectedUserRole,
                      onChanged: (value) {
                        if (!controller.classroomData.isArchived) {
                          cloudFirestoreController.selectedUserRole = value!;
                        }
                      },
                      title: const Text('CR'),
                    ),
                    RadioListTile.adaptive(
                      contentPadding: const EdgeInsets.all(0),
                      value: 'Student',
                      groupValue: cloudFirestoreController.selectedUserRole,
                      onChanged: (value) {
                        if (!controller.classroomData.isArchived) {
                          cloudFirestoreController.selectedUserRole = value!;
                        }
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
                      if (controller.classroomData.isArchived) {
                        return;
                      }
                      await cloudFirestoreController.changeUserRole(
                        user: {
                          'authUid': user.authUid,
                          'name': user.name,
                          'userId': user.userId,
                        },
                        classroom: controller.classroomData,
                        currentRole: userRole,
                      );
                      Get.back();
                      await controller.getUsersData();
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> launchPhoneDialer(String contactNumber) async {
    final Uri phoneUri = Uri(scheme: "tel", path: contactNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (error) {
      throw ("Cannot dial");
    }
  }
}
