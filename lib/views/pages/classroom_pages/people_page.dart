import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:visoattend/helper/constants.dart';

import '../../../controller/attendance_controller.dart';
import '../../../helper/functions.dart';
import '../../../models/classroom_model.dart';

class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key, required this.classroom});

  final ClassroomModel classroom;

  @override
  Widget build(BuildContext context) {
    final height = Get.height;
    final width = Get.width;
    final colorScheme = Get.theme.colorScheme;
    final textTheme = Get.textTheme;

    final currentUserRole = Get.find<AttendanceController>().currentUserRole;

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
                          isTeacher: true,
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
                            isTeacher: true,
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
                  itemCount: classroom.students.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        _buildUsersList(
                          classroom.students[index],
                          isTeacher: true,
                        ),
                        if (classroom.students.length > 1)
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

  Widget _buildUsersList(Map<String, dynamic> user, {bool isTeacher = false}) {
    final height = Get.height;
    final width = Get.width;
    final textTheme = Get.textTheme;
    final colorScheme = Get.theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        CircularPercentIndicator(
          radius: height * 0.025,
          lineWidth: 7,
          percent: 0.6,
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: colorScheme.error,
          backgroundColor: colorScheme.onBackground.withAlpha(15),
          animation: true,
          center: Text(
            '60%',
            style: textTheme.labelSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.error,
            ),
          ),
        ),
        horizontalGap(width * percentGapMedium),
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
      ],
    );
  }
}
