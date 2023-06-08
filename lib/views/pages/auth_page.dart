import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visoattend/controller/auth_controller.dart';

import 'classroom_page.dart';
import 'login_register_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return StreamBuilder<User?>(
      stream: authController.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const ClassroomPage();
        } else {
          return const LoginRegisterPage();
        }
      },
    );
  }
}
