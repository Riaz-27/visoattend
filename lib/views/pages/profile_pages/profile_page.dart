import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visoattend/helper/functions.dart';

import '../../../controller/auth_controller.dart';
import '../../../controller/cloud_firestore_controller.dart';
import '../../../controller/profile_pic_controller.dart';
import '../../../helper/constants.dart';
import '../auth_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Get.theme.colorScheme;
    final textTheme = Get.theme.textTheme;
    final height = Get.height;
    final width = Get.width;

    final profilePicController = Get.find<ProfilePicController>();
    final cloudFirestoreController = Get.find<CloudFirestoreController>();

    final picUrl = profilePicController.profilePicUrl;
    final currentUser = cloudFirestoreController.currentUser;

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: true,
        title: Text(
          'Profile',
          style: textTheme.titleMedium,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            right: height * percentGapSmall,
            left: height * percentGapSmall,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              verticalGap(height * percentGapLarge),
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
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(picUrl),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -3,
                      right: -3,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
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
                  ],
                ),
              ),
              verticalGap(height * percentGapSmall),
              Text(
                currentUser.name,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Text(
                currentUser.userId,
                textAlign: TextAlign.center,
                style: textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: textTheme.bodySmall!.color,
                ),
              ),
              verticalGap(height * percentGapMedium),
              Divider(
                height: 0,
                color: colorScheme.outline.withOpacity(0.4),
                thickness: 0.5,
              ),
              verticalGap(height * percentGapSmall),
              _optionsWidget(
                Icons.face_retouching_natural_outlined,
                'Retrain Face Model',
              ),
              verticalGap(height * percentGapSmall),
              _optionsWidget(
                Icons.account_circle_rounded,
                'Account Details',
              ),
              verticalGap(height * percentGapSmall),
              _optionsWidget(
                Icons.password,
                'Change Password',
              ),
              verticalGap(height * percentGapMedium),
              Divider(
                height: 0,
                color: colorScheme.outline.withOpacity(0.4),
                thickness: 0.5,
              ),
              verticalGap(height * percentGapSmall),
              _optionsWidget(onTap: () async {
                await Get.find<AuthController>().signOut();
                cloudFirestoreController.isInitialized = false;
                Get.offAll(() => const AuthPage());
              }, Icons.logout_rounded, 'Logout', color: colorScheme.error),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionsWidget(IconData icon, String text,
      {Color? color, void Function()? onTap}) {
    final colorScheme = Get.theme.colorScheme;
    final textTheme = Get.theme.textTheme;
    final height = Get.height;
    final width = Get.width;

    return GestureDetector(
      onTap: onTap,
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
            horizontalGap(width * percentGapMedium),
            Text(
              text,
              style: textTheme.titleSmall!.copyWith(color: color),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
