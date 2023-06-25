import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visoattend/helper/functions.dart';
import 'package:visoattend/views/pages/classroom_page.dart';
import 'package:visoattend/views/widgets/custom_text_form_field.dart';

import '../../controller/cloud_firestore_controller.dart';
import '../../helper/constants.dart';
import '../../models/classroom_model.dart';

class AllClassroomPage extends StatelessWidget {
  const AllClassroomPage({super.key});

  @override
  Widget build(BuildContext context) {
    final height = Get.height;
    final width = Get.width;
    final searchController = TextEditingController();
    final cloudFirestoreController = Get.find<CloudFirestoreController>()..filterSearchResult('');

    final classroomList = cloudFirestoreController.filteredClassroom;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Classes',
          style: Get.textTheme.titleLarge,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: height * percentGapVerySmall,
            right: height * percentGapSmall,
            left: height * percentGapSmall,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomTextFormField(
                labelText: 'Search Class',
                controller: searchController,
                onChanged: (value) => cloudFirestoreController.filterSearchResult(value),
              ),
              verticalGap(height * percentGapMedium),
              Expanded(
                child: Obx(() {
                  return ListView.builder(
                    itemCount: classroomList.length,
                    itemBuilder: (_, index) {
                      return GestureDetector(
                        onTap: () => Get.to(() =>
                            ClassroomPage(classroomData: classroomList[index])),
                        child:
                            _buildCustomCard(classroom: classroomList[index]),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildCustomCard({
  required ClassroomModel classroom,
}) {
  final height = Get.height;
  final width = Get.width;

  return Container(
    margin: EdgeInsets.only(bottom: height * percentGapSmall),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Get.theme.colorScheme.surfaceVariant.withAlpha(150),
    ),
    child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classroom.courseTitle,
                  style: Get.textTheme.titleSmall!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  classroom.courseCode,
                  style: Get.textTheme.titleSmall!.copyWith(
                    color: Get.theme.colorScheme.onBackground.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
          horizontalGap(width * percentGapVerySmall),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                classroom.section,
                style: Get.textTheme.titleSmall!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                classroom.session,
                style: Get.textTheme.titleSmall!.copyWith(
                  color: Get.theme.colorScheme.onBackground.withAlpha(150),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
