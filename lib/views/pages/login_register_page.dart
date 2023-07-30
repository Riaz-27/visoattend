import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/auth_controller.dart';
import '../../models/user_model.dart';
import '../../views/pages/reset_password_page.dart';
import '../../views/widgets/custom_button.dart';
import '../../controller/cloud_firestore_controller.dart';
import '../../helper/constants.dart';
import '../../helper/functions.dart';
import '../widgets/custom_text_form_field.dart';

import 'auth_page.dart';
import 'face_register_page.dart';

class LoginRegisterPage extends StatelessWidget {
  const LoginRegisterPage({Key? key, this.isSignUp = false}) : super(key: key);

  final bool isSignUp;

  @override
  Widget build(BuildContext context) {
    // final validEmail = RegExp(
    //     r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    final validEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,5}');

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final userIdController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final authController = Get.find<AuthController>();
    final cloudFirestoreController = Get.find<CloudFirestoreController>();

    final formKey = GlobalKey<FormState>();

    String? emailValidatorString;
    String? userValidatorString;

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

    Future<void> handleSignInOrSignUp() async {
      final name = nameController.text.trim();
      final password = passwordController.text;
      final userId = userIdController.text.trim();

      String email = emailController.text.trim();
      UserModel? userData;

      if (isSignUp) {
        authController.tempPassword = password;
        final user = UserModel(
          authUid: 'null',
          profilePic:
              'https://firebasestorage.googleapis.com/v0/b/visoattend.appspot.com/o/profile_pics%2Fdefault_profile.jpg?alt=media&token=0ff37477-4ac1-41df-8522-73a5eacceee7',
          userId: userId,
          name: name,
          email: email,
          mobile: '',
          gender: '',
          dob: '',
          semesterOrDesignation: '',
          department: '',
          classrooms: {},
          faceDataFront: [],
          faceDataLeft: [],
          faceDataRight: [],
        );
        hideLoadingDialog();
        Get.to(() => FaceRegisterPage(user: user));
      } else {
        final bool emailValid = validEmail.hasMatch(userId);
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
          cloudFirestoreController.currentUser = userData!;
          await cloudFirestoreController.getUserClassrooms();
          // Get.offAll(() => const AuthPage());
        } else {
          Get.snackbar(
            'Invalid user',
            'User not found with this credentials',
            colorText: Colors.red,
            animationDuration: const Duration(milliseconds: 200),
          );
        }
        hideLoadingDialog();
      }
    }

    Future<void> validateEmail(String email) async {
      final userData =
          await cloudFirestoreController.getUserDataFromFirestoreByEmail(email);
      if (userData != null) {
        emailValidatorString = 'A user with this Email address already exists';
        return;
      }
      emailValidatorString = null;
    }

    Future<void> validateUser(String userId) async {
      final userData =
          await cloudFirestoreController.getUserDataFromFirestore(userId);
      if (userData != null) {
        userValidatorString = 'A user with this User ID already exists';
        return;
      }
      userValidatorString = null;
    }

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: height * 0.025),
        child: Form(
          key: formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isSignUp) ...[
                    SizedBox(
                      width: width * 0.55,
                      child: Image.asset('assets/icons/text_icon.png'),
                    ),
                    // Text(
                    //   'VisoAttend',
                    //   style: Get.textTheme.titleLarge!
                    //       .copyWith(fontWeight: FontWeight.bold),
                    // ),
                    verticalGap(height * percentGapMedium),
                    Text(
                      'Welcome Back Please sign in to continue',
                      style: textTheme.titleMedium!
                          .copyWith(fontSize: width * 0.04),
                    ),
                    verticalGap(height * percentGapLarge),
                  ],
                  if (isSignUp) ...[
                    Text(
                      'Create Account',
                      style: textTheme.titleLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    verticalGap(height * percentGapLarge),
                    CustomTextFormField(
                      labelText: 'Full Name (According to the registration)',
                      controller: nameController,
                      validator: (value) {
                        if (value!.isEmpty ||
                            !RegExp(r'^[a-z A-Z]+$').hasMatch(value)) {
                          print('The Value: $value');
                          return 'Name should only contains letters.';
                        }
                        return null;
                      },
                    ),
                    verticalGap(height * percentGapMedium),
                    CustomTextFormField(
                      labelText: 'Email',
                      controller: emailController,
                      validator: (value) {
                        if (value!.isEmpty || !validEmail.hasMatch(value)) {
                          return 'Email is not valid';
                        }
                        return emailValidatorString;
                      },
                    ),
                    verticalGap(height * percentGapMedium),
                  ],
                  CustomTextFormField(
                    labelText: isSignUp
                        ? 'Student/Teacher Metric ID'
                        : 'Metric ID / Email',
                    controller: userIdController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Field cannot be empty';
                      }
                      if (isSignUp) {
                        if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                          return 'User ID must be letters or number';
                        }
                        return userValidatorString;
                      }
                      return null;
                    },
                  ),
                  verticalGap(height * percentGapMedium),
                  CustomTextFormField(
                    labelText: 'Password',
                    controller: passwordController,
                    isPassword: true,
                    maxLines: 1,
                    validator: (value) {
                      if (isSignUp &&
                          (value!.isEmpty ||
                              confirmPasswordController.text != value)) {
                        return 'Password do not match';
                      }
                      return null;
                    },
                  ),
                  verticalGap(height * percentGapMedium),
                  if (isSignUp) ...[
                    CustomTextFormField(
                      labelText: 'Confirm Password',
                      controller: confirmPasswordController,
                      isPassword: true,
                      maxLines: 1,
                      validator: (value) {
                        if (value!.isEmpty ||
                            passwordController.text != value) {
                          return 'Password do not match';
                        }
                        return null;
                      },
                    ),
                    verticalGap(height * percentGapLarge),
                  ],
                  if (!isSignUp) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.to(() => const ResetPasswordPage());
                          },
                          child: Text(
                            'Forgotten Password?',
                            style: textTheme.labelMedium!.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    verticalGap(height * percentGapMedium),
                  ],
                  CustomButton(
                    text: isSignUp ? 'Sign Up' : 'Sign In',
                    onPressed: () async {
                      loadingDialog('Loading...');
                      authController.isLoading = true;
                      await validateEmail(emailController.text);
                      await validateUser(userIdController.text);
                      if (formKey.currentState!.validate()) {
                        await handleSignInOrSignUp();
                      } else {
                        authController.isLoading = false;
                      }
                    },
                  ),
                  verticalGap(height * percentGapSmall),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Text(
                          isSignUp
                              ? 'Already have an account?'
                              : "Don't have an account?",
                          style: textTheme.labelLarge,
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: () {
                          authController.isLoading = false;
                          Get.offAll(
                            () => LoginRegisterPage(
                              isSignUp: !isSignUp,
                            ),
                            transition: Transition.cupertino,
                          );
                        },
                        child: Text(
                          isSignUp ? 'Sign In' : 'Sign up',
                          style: textTheme.labelLarge!.copyWith(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
