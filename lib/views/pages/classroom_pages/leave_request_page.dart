import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visoattend/controller/attendance_controller.dart';
import 'package:visoattend/helper/functions.dart';
import 'package:visoattend/views/widgets/custom_button.dart';

import '../../../helper/constants.dart';
import 'apply_leave_page.dart';

class LeaveRequestPage extends GetView<AttendanceController> {
  const LeaveRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          right: height * percentGapSmall,
          left: height * percentGapSmall,
        ),
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index){
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: _buildLeaveRequestList(),
            );
          },
        )
      ),
      floatingActionButton: Obx(
        () {
          return controller.currentUserRole != 'Teacher'
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

  Widget _buildLeaveRequestList() {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: height * percentGapSmall,
        horizontal: width * percentGapLarge,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surfaceVariant.withOpacity(0.4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Approved',
                style: textTheme.labelMedium!
                    .copyWith(color: colorScheme.primary),
              ),
              const Spacer(),
              Icon(
                Icons.check_circle,
                size: 25,
                color: colorScheme.primaryContainer,
              )
            ],
          ),
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
                      image: const DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                            'https://images.pexels.com/photos/614810/pexels-photo-614810.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
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
                    'Riaz Uddin Emon',
                    style: textTheme.bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  verticalGap(height * percentGapVerySmall),
                  Text(
                    'C183044',
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
                size: 20,
                color: colorScheme.secondary,
              ),
              horizontalGap(width * percentGapSmall),
              Text(
                '19 July 2023',
                style: textTheme.labelMedium,
              ),
              horizontalGap(width * percentGapSmall),
              Text(
                'To',
                style: textTheme.labelMedium,
              ),
              horizontalGap(width * percentGapSmall),
              Text(
                '21 July 2023',
                style: textTheme.labelMedium,
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
                  '3 Days',
                  style: textTheme.labelMedium,
                ),
              ),
            ],
          ),
          verticalGap(height * percentGapVerySmall),
          Row(
            children: [
              Icon(
                Icons.attach_file_rounded,
                size: 18,
                color: colorScheme.secondary,
              ),
              horizontalGap(width * percentGapSmall),
              Text(
                'High fever',
                style: textTheme.labelMedium,
              ),
            ],
          ),
          verticalGap(height * percentGapVerySmall),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.subject_rounded,
                size: 18,
                color: colorScheme.secondary,
              ),
              horizontalGap(width * percentGapSmall),
              Expanded(
                child: Text(
                  'I am writing this letter to request you to grant me leave for two days, as I am suffering from high fever and have been advised by the doctor to take rest.',
                  style: textTheme.labelMedium,
                ),
              ),
            ],
          ),
          verticalGap(height * percentGapSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomButton(
                text: 'Approve',
                textStyle: textTheme.bodyMedium!.copyWith(color: colorScheme.surface),
                width: width*0.3,
                height: 35,
                backgroundColor: colorScheme.primary.withOpacity(0.6),
                onPressed: () {},
              ),
              CustomButton(
                text: 'Decline',
                textColor: colorScheme.error,
                textStyle: textTheme.bodyMedium!.copyWith(color: colorScheme.surface),
                width: width*0.3,
                backgroundColor: colorScheme.onSurface.withOpacity(0.8),
                height: 35,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
