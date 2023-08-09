import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../controller/cloud_firestore_controller.dart';
import '../../helper/constants.dart';
import '../../helper/functions.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_form_field.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final validEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,5}');

    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    String? emailValidatorString;

    Future<void> validateEmail() async {
      final cloudFirestoreController = Get.find<CloudFirestoreController>();
      final userData = await cloudFirestoreController
          .getUserDataFromFirestoreByEmail(emailController.text);
      if (userData == null) {
        emailValidatorString = 'No user found with this Email address';
        return;
      }
      emailValidatorString = null;
    }

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: deviceHeight * 0.025),
        child: Form(
          key: formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Enter the email associated with your account and we’ll send an email with instructions toreset your password",
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium!.copyWith(
                      color: textColorLight,
                    ),
                  ),
                  verticalGap(deviceHeight * percentGapMedium),
                  CustomTextFormField(
                    labelText: 'Enter your email address',
                    controller: emailController,
                    validator: (value) {
                      if (value!.isEmpty || !validEmail.hasMatch(value)) {
                        return 'Email is not valid';
                      }
                      return emailValidatorString;
                    },
                  ),
                  verticalGap(deviceHeight * percentGapMedium),
                  CustomButton(
                    text: 'Reset Password',
                    onPressed: () async {
                      await validateEmail();
                      if (formKey.currentState!.validate()) {
                        Get.find<AuthController>()
                            .resetPassword(emailController.text.trim());
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
