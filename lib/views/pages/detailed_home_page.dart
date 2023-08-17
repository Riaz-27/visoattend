import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../views/widgets/shimmer_loading.dart';
import '../../views/pages/detailed_classroom_page.dart';
import '../../controller/navigation_controller.dart';
import '../../views/pages/all_classroom_page.dart';
import '../../views/pages/home_page.dart';
import '../../controller/classroom_controller.dart';
import '../../controller/cloud_firestore_controller.dart';
import '../../controller/profile_pic_controller.dart';
import '../../helper/constants.dart';
import '../../helper/functions.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_form_field.dart';
import 'create_edit_classroom_page.dart';
import 'profile_pages/profile_page.dart';

class DetailedHomePage extends GetView<NavigationController> {
  const DetailedHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    if (!cloudFirestoreController.isInitialized) {
      cloudFirestoreController.isHomeLoading = true;
      cloudFirestoreController.initialize().then((_) {
        cloudFirestoreController.isHomeLoading = false;
      });
    }

    final navigationPages = [const HomePage(), const AllClassroomPage()];

    DateTime? backPressTime;

    return WillPopScope(
      onWillPop: () async {
        if(Get.isDialogOpen ?? false) return false;
        if (controller.selectedHomeIndex == 0) {
          final now = DateTime.now();
          if (backPressTime == null ||
              now.difference(backPressTime!) > const Duration(seconds: 2)) {
            backPressTime = now;
            Fluttertoast.showToast(msg: 'Press back again to exit');
            return false;
          }
          return true;
        } else {
          controller.selectedHomeIndex = 0;
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: Obx(() {
            return cloudFirestoreController.isHomeLoading
                ? _loadingWidget()
                : Column(
                    children: [
                      // verticalGap(height * percentGapSmall),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          horizontalGap(deviceWidth * percentGapSmall),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() {
                                final userName =
                                    cloudFirestoreController.currentUser.name;
                                return Text(
                                  'Hi, $userName',
                                  style: textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: textColorDefault,
                                  ),
                                );
                              }),
                              verticalGap(deviceHeight * percentGapVerySmall),
                              Text(
                                DateFormat('EEE, d MMMM y')
                                    .format(DateTime.now()),
                                style: textTheme.bodySmall!.copyWith(
                                  color: textColorLight,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Obx(() {
                            final picUrl =
                                Get.find<ProfilePicController>().profilePicUrl;
                            return GestureDetector(
                              onTap: () => Get.to(() => const ProfilePage()),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorScheme.outline.withOpacity(0.4),
                                  border: Border.all(color: colorScheme.primary),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(picUrl),
                                  ),
                                ),
                              ),
                            );
                          }),
                          horizontalGap(deviceWidth * percentGapMedium)
                        ],
                      ),
                    ],
                  );
          }),
        ),
        body: Obx(() {
          return navigationPages[controller.selectedHomeIndex];
        }),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 15, right: 8),
          child: FloatingActionButton(
            onPressed: () {
              Get.bottomSheet(
                backgroundColor: colorScheme.surface,
                enableDrag: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: kSmall, vertical: kMedium),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomButton(
                        height: deviceHeight * 0.055,
                        backgroundColor: colorScheme.secondaryContainer,
                        textColor: colorScheme.onSecondaryContainer,
                        text: 'Join Class',
                        onPressed: () {
                          Get.back();
                          _handleJoinClass();
                        },
                      ),
                      verticalGap(deviceHeight * percentGapSmall),
                      CustomButton(
                        height: deviceHeight * 0.055,
                        backgroundColor: colorScheme.secondaryContainer,
                        textColor: colorScheme.onSecondaryContainer,
                        text: 'Create Class',
                        onPressed: () {
                          Get.to(() => const CreateEditClassroomPage());
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        bottomNavigationBar: Obx(() {
          return NavigationBar(
            selectedIndex: controller.selectedHomeIndex,
            onDestinationSelected: (index) {
              controller.selectedHomeIndex = index;
            },
            height: 65,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.collections_bookmark_outlined),
                selectedIcon: Icon(Icons.collections_bookmark),
                label: 'Classrooms',
              ),
            ],
          );
        }),
      ),
    );
  }

  void _handleJoinClass() {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    final TextEditingController classroomIdController = TextEditingController();
    Get.bottomSheet(
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(15),
          topLeft: Radius.circular(15),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 80,
              width: double.infinity,
              child: CustomTextFormField(
                controller: classroomIdController,
                labelText: 'Enter Classroom ID',
              ),
            ),
            CustomButton(
              height: deviceHeight * 0.055,
              text: 'Join Class',
              onPressed: () async {
                loadingDialog('Joining...');
                await Get.find<ClassroomController>()
                    .joinClassroom(classroomIdController.text);
                final classroomData = cloudFirestoreController.classrooms
                    .firstWhereOrNull((classroom) =>
                        classroom.classroomId == classroomIdController.text);
                hideLoadingDialog();
                if (classroomData == null) {
                  errorDialog(
                    title: 'Failed to join classroom',
                    msg: 'The classroom code is invalid',
                  );
                } else {
                  Get.back();
                  Get.to(
                    () => DetailedClassroomPage(classroomData: classroomData),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadingWidget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            horizontalGap(deviceWidth * percentGapSmall),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoading(height: 15, width: 150),
                verticalGap(deviceHeight * percentGapVerySmall),
                ShimmerLoading(height: 12, width: 100, color: loadColorLight),
              ],
            ),
            const Spacer(),
            const ShimmerLoading(height: 40, width: 40, radius: 100),
            horizontalGap(deviceWidth * percentGapMedium)
          ],
        ),
      ],
    );
  }
}
