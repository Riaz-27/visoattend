import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../helper/functions.dart';
import '../../../views/pages/profile_pages/account_details_page.dart';
import '../../../views/pages/profile_pages/change_password_page.dart';
import '../../../controller/auth_controller.dart';
import '../../../controller/cloud_firestore_controller.dart';
import '../../../controller/profile_pic_controller.dart';
import '../../../helper/constants.dart';
import '../auth_page.dart';
import '../face_register_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profilePicController = Get.find<ProfilePicController>();
    final cloudFirestoreController = Get.find<CloudFirestoreController>();

    final currentUser = cloudFirestoreController.currentUser;

    return WillPopScope(
      onWillPop: () async {
        return !(Get.isDialogOpen ?? false);
      },
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          centerTitle: true,
          title: Text(
            'Profile',
            style: textTheme.titleMedium!.copyWith(color: textColorDefault),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              right: deviceHeight * percentGapSmall,
              left: deviceHeight * percentGapSmall,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  verticalGap(deviceHeight * percentGapLarge),
                  //Center photo
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 102,
                          height: 102,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: colorScheme.surfaceTint, width: 3),
                          ),
                        ),
                        Obx(() {
                          final picUrl = profilePicController.profilePicUrl;
                          return Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorScheme.outline.withOpacity(0.4),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(picUrl),
                              ),
                            ),
                          );
                        }),
                        _handleImageChangeButton(),
                      ],
                    ),
                  ),
                  verticalGap(deviceHeight * percentGapSmall),
                  Text(
                    currentUser.name,
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: textColorDefault,
                    ),
                  ),
                  Text(
                    currentUser.userId,
                    textAlign: TextAlign.center,
                    style: textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: textColorLight,
                    ),
                  ),
                  verticalGap(deviceHeight * percentGapMedium),
                  Divider(
                    height: 0,
                    color: colorScheme.outline.withOpacity(0.4),
                    thickness: 1,
                  ),
                  verticalGap(deviceHeight * percentGapSmall),
                  _optionsWidget(
                    onTap: () {
                      Get.to(
                        () => FaceRegisterPage(
                          user: currentUser,
                          retrainModel: true,
                        ),
                      );
                    },
                    Icons.face_retouching_natural_outlined,
                    'Retrain Face Model',
                  ),
                  verticalGap(deviceHeight * percentGapSmall),
                  _optionsWidget(
                    onTap: () => Get.to(() => const AccountDetailsPage()),
                    Icons.account_circle_rounded,
                    'Account Details',
                  ),
                  verticalGap(deviceHeight * percentGapSmall),
                  _optionsWidget(
                    onTap: () => Get.to(() => const ChangePasswordPage()),
                    Icons.lock_outline_rounded,
                    'Change Password',
                  ),
                  verticalGap(deviceHeight * percentGapMedium),
                  Divider(
                    height: 0,
                    color: colorScheme.outline.withOpacity(0.4),
                    thickness: 1,
                  ),
                  verticalGap(deviceHeight * percentGapSmall),
                  _optionsWidget(
                    onTap: () => showConfirmDialog(context),
                    Icons.logout_rounded,
                    'Logout',
                    color: colorScheme.error,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _handleImageChangeButton() {
    return Positioned(
      bottom: -3,
      right: -3,
      child: PopupMenuButton(
        position: PopupMenuPosition.under,
        tooltip: 'Change Image',
        itemBuilder: (BuildContext context) => [
          const PopupMenuItem(
            value: 'camera',
            child: Text('Camera'),
          ),
          const PopupMenuItem(
            value: 'gallery',
            child: Text('Gallery'),
          ),
        ],
        onSelected: (value) {
          final profilePicController = Get.find<ProfilePicController>();
          if (value == 'camera') {
            profilePicController.pickUploadImage(ImageSource.camera);
          } else {
            profilePicController.pickUploadImage(ImageSource.gallery);
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.surface,
              ),
            ),
            Icon(
              Icons.circle_rounded,
              color: colorScheme.secondary,
              size: 45,
            ),
            Icon(
              Icons.add_a_photo_outlined,
              color: colorScheme.surface,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionsWidget(IconData icon, String text,
      {Color? color, void Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: kSmall),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: colorScheme.surfaceVariant.withAlpha(100),
                ),
                child: Icon(
                  icon,
                  size: 25,
                  color: colorScheme.secondary,
                ),
              ),
              horizontalGap(deviceWidth * percentGapMedium),
              Text(
                text,
                style: textTheme.titleSmall!
                    .copyWith(color: color ?? textColorDefault),
              ),
              const Spacer(),
              const Icon(
                Icons.chevron_right,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: textColorDefault,
            ),
          ),
          content: SizedBox(
            width: deviceWidth,
            child: Text(
              'Do you really want to logout?',
              style: textTheme.bodyMedium!.copyWith(color: textColorDefault),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                loadingDialog();
                await Get.find<AuthController>().signOut();
                Get.find<CloudFirestoreController>().isInitialized = false;
                Get.offAll(() => const AuthPage());
                hideLoadingDialog();
              },
              child: Text(
                'Yes',
                style: textTheme.bodyMedium!.copyWith(color: colorScheme.error),
              ),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }
}
