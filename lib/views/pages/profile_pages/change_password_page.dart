import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visoattend/helper/functions.dart';
import 'package:visoattend/views/widgets/custom_button.dart';
import 'package:visoattend/views/widgets/custom_input.dart';
import 'package:visoattend/views/widgets/custom_text_form_field.dart';

import '../../../helper/constants.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Get.theme.colorScheme;
    final textTheme = Get.theme.textTheme;
    final height = Get.height;
    final width = Get.width;

    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmNewPasswordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(
          right: height * percentGapSmall,
          left: height * percentGapSmall,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Password',
                style: textTheme.titleMedium,
              ),
              verticalGap(height * percentGapMedium),
              Text(
                'We strongly suggest you to use at least 1 letter, 1 number and 1 symbol as your new password.',
                style: textTheme.bodySmall,
              ),
              verticalGap(height * percentGapVerySmall),
              Text(
                'Minimum password length is 6.',
                style: textTheme.bodySmall,
              ),
              verticalGap(height * percentGapLarge),
              CustomInput(
                controller: oldPasswordController,
                title: 'Old Password',
                isPassword: true,
              ),
              verticalGap(height * percentGapSmall),
              CustomInput(
                controller: newPasswordController,
                title: 'New Password',
                isPassword: true,
              ),
              verticalGap(height * percentGapSmall),
              CustomInput(
                controller: confirmNewPasswordController,
                title: 'Confirm Password',
                isPassword: true,
              ),
              verticalGap(height * percentGapLarge),
              CustomButton(text: 'Confirm', onPressed: (){}),
            ],
          ),
        ),
      ),
    );
  }
}
