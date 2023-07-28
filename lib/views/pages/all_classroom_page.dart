import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/functions.dart';
import '../../views/pages/detailed_classroom_page.dart';
import '../../views/widgets/custom_text_form_field.dart';
import '../../controller/cloud_firestore_controller.dart';
import '../../helper/constants.dart';
import '../../models/classroom_model.dart';

class AllClassroomPage extends StatelessWidget {
  const AllClassroomPage({super.key, this.isArchived = false});

  final bool isArchived;

  @override
  Widget build(BuildContext context) {
    final height = Get.height;
    final width = Get.width;
    final searchController = TextEditingController();
    final cloudFirestoreController = Get.find<CloudFirestoreController>();

    final classroomList = isArchived
        ? cloudFirestoreController.filteredArchivedClassroom
        : cloudFirestoreController.filteredClassroom;

    return Scaffold(
      appBar: isArchived
          ? AppBar(
        forceMaterialTransparency: true,
        centerTitle: true,
        title: Text(
          'Archived Classes',
          style: textTheme.titleMedium,
        ),
      )
          : null,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            top: height * percentGapVerySmall,
            right: height * percentGapSmall,
            left: height * percentGapSmall,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalGap(height * percentGapSmall),
              CustomTextFormField(
                labelText: 'Search Class',
                controller: searchController,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                onChanged: (value) =>
                isArchived
                    ? cloudFirestoreController
                    .filterArchiveClassesSearchResult(value)
                    : cloudFirestoreController
                    .filterAllClassesSearchResult(value),
              ),
              verticalGap(height * percentGapSmall),
              Obx(() {
                return Text(
                  isArchived
                      ? 'Archived Classes (${classroomList.length})'
                      : 'All Classes (${classroomList.length})',
                  style: Get.textTheme.bodySmall,
                );
              }),
              verticalGap(height * percentGapSmall),
              Expanded(
                child: Obx(() {
                  return ListView.builder(
                    itemCount: classroomList.length,
                    itemBuilder: (_, index) {
                      return GestureDetector(
                        onTap: () {
                          if(isArchived){
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(days: 365),
                                content: Text(
                                  "Class has been archived. You can't add or edit anything.",
                                ),
                              ),
                            );
                          }
                          Get.to(() =>
                              DetailedClassroomPage(
                                  classroomData: classroomList[index]));
                        },
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

  Widget _buildCustomCard({
    required ClassroomModel classroom,
  }) {
    final height = Get.height;
    final width = Get.width;

    return Container(
      margin: EdgeInsets.only(bottom: height * percentGapSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Get.theme.colorScheme.surfaceVariant.withAlpha(150),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classroom.courseTitle,
                    style: Get.textTheme.titleSmall!
                        .copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
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
}
