import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visoattend/controller/navigation_controller.dart';
import 'package:visoattend/views/pages/all_classroom_page.dart';
import 'package:visoattend/views/pages/home_page.dart';

import '../../controller/auth_controller.dart';
import '../../controller/classroom_controller.dart';
import '../../controller/cloud_firestore_controller.dart';
import '../../controller/profile_pic_controller.dart';
import '../../helper/constants.dart';
import '../../helper/functions.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_form_field.dart';
import 'auth_page.dart';
import 'create_edit_classroom_page.dart';
import 'profile_pages/profile_page.dart';

class DetailedHomePage extends GetView<NavigationController> {
  const DetailedHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    if (!cloudFirestoreController.isInitialized) {
      cloudFirestoreController.initialize();
    }

    final height = Get.height;

    final navigationPages = [const HomePage(), const AllClassroomPage()];

    DateTime? backPressTime;

    return WillPopScope(
      onWillPop: () async {
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
          title: Column(
            children: [
              verticalGap(height*percentGapSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        final userName =
                            cloudFirestoreController.currentUser.name;
                        return Text(
                          'Welcome, $userName',
                          style: Get.textTheme.titleMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        );
                      }),
                      verticalGap(height * percentGapVerySmall),
                      Text(
                        DateFormat('EEE, d MMMM y').format(DateTime.now()),
                        style: Get.textTheme.bodySmall!.copyWith(
                            color: Get.theme.colorScheme.onBackground
                                .withAlpha(150)),
                      ),
                    ],
                  ),
                  Obx(() {
                    final picUrl =
                        Get.find<ProfilePicController>().profilePicUrl;
                    return GestureDetector(
                      onTap: () => Get.to(()=>const ProfilePage()),
                      child: Container(
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
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
        body: Obx(() {
          return navigationPages[controller.selectedHomeIndex];
        }),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom:15, right: 8),
          child: FloatingActionButton(
            onPressed: () {
              Get.bottomSheet(
                backgroundColor: Get.theme.colorScheme.surface,
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
                        height: height * 0.055,
                        backgroundColor:
                            Get.theme.colorScheme.secondaryContainer,
                        textColor: Get.theme.colorScheme.onSecondaryContainer,
                        text: 'Join Class',
                        onPressed: () {
                          Get.back();
                          _handleJoinClass();
                        },
                      ),
                      verticalGap(height * percentGapSmall),
                      CustomButton(
                        height: height * 0.055,
                        backgroundColor:
                            Get.theme.colorScheme.secondaryContainer,
                        textColor: Get.theme.colorScheme.onSecondaryContainer,
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
            onDestinationSelected: (index) =>
                controller.selectedHomeIndex = index,
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
                label: 'All Classes',
              ),
            ],
          );
        }),
      ),
    );
  }

  void _handleJoinClass() {
    final TextEditingController classroomIdController = TextEditingController();
    final height = Get.height;
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
              height: height * 0.055,
              text: 'Join Class',
              onPressed: () async {
                await Get.find<ClassroomController>()
                    .joinClassroom(classroomIdController.text);
              },
            ),
          ],
        ),
      ),
    );
  }
}
