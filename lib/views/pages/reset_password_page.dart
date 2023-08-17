import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../controller/cloud_firestore_controller.dart';
import '../../controller/timer_controller.dart';
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

    return WillPopScope(
      onWillPop: () async {
        return !(Get.isDialogOpen ?? false);
      },
      child: Scaffold(
        appBar: AppBar(),
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
                      "Enter the email associated with your account and we’ll send an email with instructions to reset your password",
                      textAlign: TextAlign.justify,
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
                    Obx(() {
                      final timerController = Get.find<TimerController>();
                      final timeLeft = timerController.resetPassTimeLeft;
                      return CustomButton(
                        text:
                            'Reset Password${timeLeft < 60 ? '($timeLeft)' : ''}',
                        onPressed: timerController.resetPassTimeLeft < 60
                            ? null
                            : () async {
                                await validateEmail();
                                if (formKey.currentState!.validate()) {
                                  timerController.startResetPassTimer();
                                  Get.find<AuthController>().resetPassword(
                                      emailController.text.trim());
                                }
                              },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
