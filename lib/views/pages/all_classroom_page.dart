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
      body: RefreshIndicator(
        onRefresh: () async {
          await cloudFirestoreController.initialize();
        },
        child: SafeArea(
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
                  labelText: 'Search Classroom',
                  controller: searchController,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  onChanged: (value) => isArchived
                      ? cloudFirestoreController
                          .filterArchiveClassesSearchResult(value)
                      : cloudFirestoreController
                          .filterAllClassesSearchResult(value),
                ),
                verticalGap(height * percentGapSmall),
                Obx(() {
                  final archivedClasses =
                      cloudFirestoreController.archivedClassrooms.length;
                  if (isArchived || archivedClasses == 0) {
                    return const SizedBox();
                  }
                  return InkWell(
                    onTap: () =>
                        Get.to(() => const AllClassroomPage(isArchived: true)),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color:
                            Get.theme.colorScheme.surfaceVariant.withAlpha(150),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.archive_rounded,
                              color: colorScheme.secondary,
                            ),
                            horizontalGap(width * percentGapMedium),
                            Text(
                              'Archived Classrooms',
                              style: textTheme.bodyMedium,
                            ),
                            const Spacer(),
                            Text(
                              archivedClasses.toString(),
                              style: textTheme.titleMedium!.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                            horizontalGap(width * percentGapSmall),
                          ],
                        ),
                      ),
                    ),
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
                            if (isArchived) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(days: 365),
                                  content: Text(
                                    "This class has been archived. You can't add or edit anything.",
                                  ),
                                ),
                              );
                            }
                            Get.to(() => DetailedClassroomPage(
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
      ),
    );
  }

  Widget _buildCustomCard({
    required ClassroomModel classroom,
  }) {
    final classSession = classroom.session.split(',').first;

    final cloudFirestoreController = Get.find<CloudFirestoreController>();


    return Container(
      margin: EdgeInsets.only(bottom: height * percentGapSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Get.theme.colorScheme.surfaceVariant.withAlpha(100),
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
                  // Text(
                  //   classroom.courseCode,
                  //   style: Get.textTheme.titleSmall!.copyWith(
                  //     color: Get.theme.colorScheme.onBackground.withAlpha(150),
                  //   ),
                  // ),
                  verticalGap(height * 0.01),
                  Row(
                    children: [
                      Obx(() {
                        final teacherProfileUrl = cloudFirestoreController
                            .classroomTeacherInfo[classroom.teachers[0]['authUid']]!['profilePic']!;
                        return Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.outline.withOpacity(0.4),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(teacherProfileUrl),
                            ),
                          ),
                        );
                      }),
                      horizontalGap(width * percentGapMedium),
                      Obx(
                        () {
                          final teacherUid = cloudFirestoreController.classroomTeacherInfo[classroom.teachers[0]['authUid']];
                          final teacherName = teacherUid == null? '' : teacherUid['name'];
                          return Text(
                            teacherName??'',
                            style: Get.textTheme.titleSmall!.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.9),
                            ),
                          );
                        }
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _customClassroomTag(text: classroom.courseCode),
                      if (classroom.section != '')
                        _customClassroomTag(text: classroom.section),
                      if (classSession != '')
                        _customClassroomTag(text: classSession),
                    ],
                  ),
                ],
              ),
            ),
            // horizontalGap(width * percentGapVerySmall),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.end,
            //   children: [
            //     Text(
            //       classroom.section,
            //       style: Get.textTheme.titleSmall!
            //           .copyWith(fontWeight: FontWeight.bold),
            //     ),
            //     Text(
            //       classroom.session,
            //       style: Get.textTheme.titleSmall!.copyWith(
            //         color: Get.theme.colorScheme.onBackground.withAlpha(150),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget _customClassroomTag(
      {Color? bgColor, Color? textColor, required String text}) {
    return Container(
      margin: EdgeInsets.only(top: height * percentGapSmall, right: 10),
      padding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: bgColor ?? colorScheme.surfaceVariant.withOpacity(0.7),
      ),
      child: Text(
        text,
        style: textTheme.labelMedium!.copyWith(
            color: textColor ?? colorScheme.onSurface.withOpacity(0.8),
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
