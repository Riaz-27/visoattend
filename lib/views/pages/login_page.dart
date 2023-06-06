import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/entities/user.dart';
import '../../controller/user_database_controller.dart';
import '../widgets/custom_text_form_field.dart';
import 'face_register_page.dart';
import 'classroom_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key, this.isSignUp = false}) : super(key: key);

  final bool isSignUp;

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController idController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    final userDatabaseController = Get.find<UserDatabaseController>();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isSignUp ? 'Create Account' : 'Welcome Back',
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20.0),
            if (isSignUp) ...[
              CustomTextFormField(
                hintText: 'Full Name (According to the registration)',
                controller: nameController,
              ),
              const SizedBox(height: 10.0),
            ],
            CustomTextFormField(
              hintText: 'Student / Teacher ID',
              controller: idController,
            ),
            const SizedBox(height: 10.0),
            CustomTextFormField(
              hintText: 'Password',
              controller: passwordController,
              isPassword: true,
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              height: 48.0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () async {
                  final name = nameController.text;
                  final userId = idController.text;
                  final password = passwordController.text;
                  if (isSignUp) {
                    if (name.isNotEmpty &&
                        userId.isNotEmpty &&
                        password.isNotEmpty) {
                      final newUser = User()
                        ..name = name
                        ..userId = userId
                        ..password = password;
                      userDatabaseController.checkUser(userId).then(
                        (userFound) {
                          nameController.text = '';
                          idController.text = '';
                          passwordController.text = '';
                          if (!userFound) {
                            Get.offAll(()=>
                              FaceRegisterPage(user: newUser),
                            );
                          }
                        },
                      );
                    }
                  } else {
                    userDatabaseController.verifyUser(userId, password).then((userFound) {
                      if (userFound != null) {
                        Get.offAll(() =>
                          const ClassroomPage(),
                        );
                      }
                    });
                  }
                },
                child: Text(isSignUp ? 'Sign Up' : 'Login'),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isSignUp
                      ? 'Already have an account?'
                      : "Don't have an account?",
                  style: const TextStyle(fontSize: 14.0),
                ),
                TextButton(
                  onPressed: () {
                    Get.offAll(() =>
                      LoginPage(
                        isSignUp: !isSignUp,
                      ),
                      transition: Transition.cupertino,
                    );
                  },
                  child: Text(
                    isSignUp ? 'Login' : 'Sign up',
                    style: const TextStyle(fontSize: 14.0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
