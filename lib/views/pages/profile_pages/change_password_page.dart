import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../helper/functions.dart';
import '../../../views/widgets/custom_button.dart';
import '../../../views/widgets/custom_input.dart';
import '../../../controller/auth_controller.dart';
import '../../../helper/constants.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmNewPasswordController = TextEditingController();

    String? oldPasswordValidateText;

    return WillPopScope(
      onWillPop: () async {
        return !(Get.isDialogOpen ?? false);
      },
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.only(
            right: deviceHeight * percentGapSmall,
            left: deviceHeight * percentGapSmall,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change Password',
                    style: textTheme.titleMedium!.copyWith(
                      color: textColorDefault,
                    ),
                  ),
                  verticalGap(deviceHeight * percentGapMedium),
                  Text(
                    'We strongly suggest you to use at least 1 letter, 1 number and 1 symbol as your new password.',
                    style: textTheme.bodySmall!.copyWith(color: textColorLight),
                  ),
                  verticalGap(deviceHeight * percentGapVerySmall),
                  Text(
                    'Minimum password length is 6.',
                    style: textTheme.bodySmall!.copyWith(color: textColorLight),
                  ),
                  verticalGap(deviceHeight * percentGapLarge),
                  CustomInput(
                    controller: oldPasswordController,
                    title: 'Old Password',
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password.';
                      }
                      return oldPasswordValidateText;
                    },
                  ),
                  verticalGap(deviceHeight * percentGapSmall),
                  CustomInput(
                    controller: newPasswordController,
                    title: 'New Password',
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password.';
                      }
                      return null;
                    },
                  ),
                  verticalGap(deviceHeight * percentGapSmall),
                  CustomInput(
                    controller: confirmNewPasswordController,
                    title: 'Confirm Password',
                    isPassword: true,
                    validator: (value) {
                      if (newPasswordController.text != '' && value!.isEmpty) {
                        return 'Please re-enter the password';
                      }
                      if (newPasswordController.text != value) {
                        return 'Password do not match';
                      }
                      return null;
                    },
                  ),
                  verticalGap(deviceHeight * percentGapLarge),
                  CustomButton(
                    text: 'Confirm',
                    onPressed: () async {
                      loadingDialog('Updating...');
                      final authController = Get.find<AuthController>();
                      oldPasswordValidateText = await authController
                          .matchOldPassword(oldPasswordController.text);
                      if (formKey.currentState!.validate()) {
                        oldPasswordValidateText = null;
                        await authController
                            .changePassword(newPasswordController.text);
                        oldPasswordController.clear();
                        newPasswordController.clear();
                        confirmNewPasswordController.clear();
                        hideLoadingDialog();
                        Fluttertoast.showToast(
                            msg: 'Password changed successfully');
                        Get.back();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
