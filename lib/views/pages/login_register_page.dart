import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visoattend/controller/auth_controller.dart';
import 'package:visoattend/models/user_model.dart';

import '../../controller/cloud_firestore_controller.dart';
import '../../models/entities/isar_user.dart';
import '../../controller/user_database_controller.dart';
import '../widgets/custom_text_form_field.dart';
import 'face_register_page.dart';
import 'classroom_page.dart';

class LoginRegisterPage extends StatelessWidget {
  const LoginRegisterPage({Key? key, this.isSignUp = false}) : super(key: key);

  final bool isSignUp;

  @override
  Widget build(BuildContext context) {
    final emailValidator = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController userIdController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // final userDatabaseController = Get.find<UserDatabaseController>();
    final authController = Get.find<AuthController>();
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    // final cloudFirestoreController = Get.find<CloudFirestoreController>();

    // void signUpUser() {
    //   final name = nameController.text.trim();
    //   final email = emailController.text.trim();
    //   final userId = userIdController.text.trim();
    //   final password = passwordController.text.trim();
    //   if (name.isNotEmpty &&
    //       userId.isNotEmpty &&
    //       email.isNotEmpty &&
    //       password.isNotEmpty) {
    //     final newUser = IsarUser()
    //       ..name = name
    //       ..userId = userId
    //       ..password = password;
    //     userDatabaseController.checkUser(userId).then(
    //       (userFound) {
    //         nameController.text = '';
    //         userIdController.text = '';
    //         passwordController.text = '';
    //         if (!userFound) {
    //           Get.offAll(
    //             () => FaceRegisterPage(user: newUser),
    //           );
    //         }
    //       },
    //     );
    //   }
    // }

    // void loginUser() {
    //   final userId = userIdController.text.trim();
    //   final password = passwordController.text.trim();
    //   // cloudFirestoreController.getUserData(userId);
    //   userDatabaseController.verifyUser(userId, password).then((userFound) {
    //     if (userFound != null) {
    //       Get.offAll(
    //         () => const ClassroomPage(),
    //       );
    //     }
    //   });
    // }

    void handleSignInOrSignUp() async {
      final name = nameController.text.trim();
      final password = passwordController.text;
      final userId = userIdController.text.trim();

      String email = emailController.text.trim();
      UserModel? userData;

      if (isSignUp) {
        userData =
            await cloudFirestoreController.getUserDataFromFirestore(userId);
        if (userData == null) {
          final userCredential = await authController
              .createUserWithEmailAndPassword(email: email, password: password);
          if (userCredential != null) {
            final user = UserModel(
              authUid: userCredential.user!.uid,
              userId: userId,
              name: name,
              email: email,
              classrooms: [],
              faceDataFront: [],
              faceDataLeft: [],
              faceDataRight: [],
            );
            Get.to(() => FaceRegisterPage(user: user));
          }
        }
      } else {
        final bool emailValid = emailValidator.hasMatch(userId);
        if (emailValid) {
          email = userId;
        } else {
          userData =
              await cloudFirestoreController.getUserDataFromFirestore(userId);
          if (userData == null) {
            email = '';
          } else {
            email = userData.email;
          }
        }
        if (email != '') {
          await authController.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          cloudFirestoreController.currentUser = userData;
          cloudFirestoreController.currentUsername = userData!.name;
        } else {
          Get.snackbar(
            'Invalid user',
            'User not found with this credentials',
            colorText: Colors.red,
            animationDuration: const Duration(milliseconds: 200),
          );
        }
      }
    }

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
              CustomTextFormField(
                hintText: 'Email',
                controller: emailController,
              ),
              const SizedBox(height: 10.0),
            ],
            CustomTextFormField(
              hintText: isSignUp ? 'UserID' : 'UserID',
              controller: userIdController,
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
                onPressed: () {
                  handleSignInOrSignUp();
                  // if(isSignUp){
                  //   signUpUser();
                  // } else {
                  //   loginUser();
                  //
                  // }
                },
                child: Obx(
                  () => authController.isLoading
                      ? const CircularProgressIndicator()
                      : Text(isSignUp ? 'Sign Up' : 'Login'),
                ),
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
                    Get.offAll(
                      () => LoginRegisterPage(
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
