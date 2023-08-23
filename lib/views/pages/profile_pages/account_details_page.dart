import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controller/auth_controller.dart';
import '../../../controller/cloud_firestore_controller.dart';
import '../../../helper/constants.dart';
import '../../../helper/functions.dart';
import '../../widgets/custom_input.dart';

class AccountDetailsPage extends StatelessWidget {
  const AccountDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cloudFirestoreController = Get.find<CloudFirestoreController>();
    final currentUser = cloudFirestoreController.currentUser;

    final nameController = TextEditingController(text: currentUser.name);
    final idController = TextEditingController(text: currentUser.userId);
    final emailController = TextEditingController(text: currentUser.email);

    final mobileController = TextEditingController(text: currentUser.mobile);
    final genderController = TextEditingController(text: currentUser.gender);
    final dobController = TextEditingController(text: currentUser.dob);
    final batchController = TextEditingController(text: currentUser.batch);
    final designationController =
        TextEditingController(text: currentUser.designation);
    final departmentController =
        TextEditingController(text: currentUser.department);

    final designationOptions = [
      'Chairman  & Associate Professor',
      'Professor',
      'Associate Professor',
      'Assistant Professor',
      'Lecturer',
      'Assistant Lecturer',
      'Medical Physicist',
      'Adjunct Lecturer',
      'Teacher Assistant'
    ];

    final departmentOptions = [
      'Qur\'anic Sciences and Islamic Studies (QSIS)',
      'Da\'wah and Islamic Studies (DIS)',
      'Science of Hadith and Islamic Studies (SHIS)',
      'Computer Science and Engineering (CSE)',
      'Computer and Communication Engineering (CCE)',
      'Electrical and Electronic Engineering (EEE)',
      'Electronic and Telecommunication Engineering (ETE)',
      'Civil Engineering (CE)',
      'Pharmacy',
      'Business Administration (BBA)',
      'Economics & Banking (EB)',
      'Law',
      'English Language and Literature (ELL)',
      'Arabic Language and Literature (ALL)',
      'Library and Information Science  (LIS)',
      'Shariah and Islamic Studies',
      'Institute of Foreign Language',
      'Center for General Education',
      'Morality Development Program',
    ];

    final genderOptions = ['Male', 'Female', 'Other'];

    return WillPopScope(
      onWillPop: () async {
        return !(Get.isDialogOpen ?? false);
      },
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () async {
                _handleSaveDetails(
                  context,
                  emailController: emailController,
                  mobileController: mobileController,
                  genderController: genderController,
                  dobController: dobController,
                  batchController: batchController,
                  designationController: designationController,
                  departmentController: departmentController,
                );
              },
              icon: Icon(Icons.check, color: colorScheme.primary),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.only(
            right: deviceHeight * percentGapSmall,
            left: deviceHeight * percentGapSmall,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Details',
                  style: textTheme.titleMedium!.copyWith(
                    color: textColorDefault,
                  ),
                ),
                verticalGap(deviceHeight * percentGapLarge),
                CustomInput(
                  controller: nameController,
                  title: 'Full Name',
                  enableTextField: false,
                ),
                verticalGap(deviceHeight * percentGapSmall),
                CustomInput(
                  controller: idController,
                  title: 'Metric ID No',
                  enableTextField: false,
                ),
                verticalGap(deviceHeight * percentGapSmall),
                CustomInput(
                  controller: emailController,
                  title: 'Email',
                  // enableTextField: false,
                ),
                verticalGap(deviceHeight * percentGapSmall),
                CustomInput(
                    controller: mobileController, title: 'Mobile Number'),
                verticalGap(deviceHeight * percentGapSmall),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          CustomInput(
                            controller: genderController,
                            title: 'Gender',
                            readOnly: true,
                          ),
                          PopupMenuButton<String>(
                            itemBuilder: (context) => genderOptions
                                .map(
                                  (String gender) => PopupMenuItem<String>(
                                    value: gender,
                                    child: Text(gender),
                                  ),
                                )
                                .toList(),
                            onSelected: (value) =>
                                genderController.text = value,
                            constraints: BoxConstraints.expand(
                                width: deviceWidth * 0.4, height: 150),
                            position: PopupMenuPosition.under,
                            child: Container(
                              width: deviceWidth,
                              height: 45,
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    horizontalGap(deviceWidth * percentGapMedium),
                    Expanded(
                      flex: 3,
                      child: CustomInput(
                        controller: dobController,
                        title: 'Date Of Birth',
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1970),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            final dob = DateFormat('dd-MM-y').format(picked);
                            dobController.text = dob;
                          }
                        },
                      ),
                    ),
                  ],
                ),
                verticalGap(deviceHeight * percentGapSmall),
                CustomInput(
                  controller: batchController,
                  title: 'Batch',
                ),
                verticalGap(deviceHeight * percentGapSmall),
                _autocompleteField(
                  controller: designationController,
                  options: designationOptions,
                  title: 'Designation',
                ),
                verticalGap(deviceHeight * percentGapSmall),
                _autocompleteField(
                  controller: departmentController,
                  options: departmentOptions,
                  title: 'Department',
                ),
                verticalGap(deviceHeight * 0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _autocompleteField({
    required TextEditingController controller,
    required List<String> options,
    required String title,
  }) {
    return Autocomplete<String>(
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return options.where((opt) =>
            opt.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (value) {
        controller.text = value;
      },
      fieldViewBuilder: (context, fieldController, focusNode, onSubmitted) {
        return CustomInput(
          controller: fieldController..text = controller.text,
          title: title,
          focusNode: focusNode,
          onChanged: (value) => controller.text = value,
        );
      },
      optionsViewBuilder: (context, onSelected, optionsData) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            child: Container(
              margin: EdgeInsets.only(top: deviceHeight * percentGapVerySmall),
              width: deviceWidth * 0.9,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                itemCount: optionsData.length,
                itemBuilder: (BuildContext context, int index) {
                  final option = optionsData.elementAt(index);
                  return GestureDetector(
                    onTap: () => onSelected(option),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        verticalGap(10),
                        Text(
                          option,
                          style: textTheme.bodyMedium!.copyWith(
                            color: textColorDefault,
                          ),
                        ),
                        verticalGap(10),
                        if (index < optionsData.length - 1)
                          const Divider(height: 0, thickness: 0.5),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleSaveDetails(
    BuildContext context, {
    required TextEditingController emailController,
    required TextEditingController mobileController,
    required TextEditingController genderController,
    required TextEditingController dobController,
    required TextEditingController batchController,
    required TextEditingController designationController,
    required TextEditingController departmentController,
  }) {
    final passwordController = TextEditingController();
    final authController = Get.find<AuthController>();
    final cloudFirestoreController = Get.find<CloudFirestoreController>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Verify Password',
            style: textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: textColorDefault,
            ),
          ),
          content: SizedBox(
            width: deviceWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Please enter your password to verify that it's you.",
                  style:
                      textTheme.bodyMedium!.copyWith(color: textColorDefault),
                ),
                verticalGap(deviceHeight * percentGapSmall),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    isDense: true,
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String? wrongPass = await authController
                    .matchOldPassword(passwordController.text);
                if (wrongPass == null) {
                  loadingDialog('Saving...');
                  if (cloudFirestoreController.currentUser.email !=
                      emailController.text) {
                    await Get.find<AuthController>()
                        .changeEmail(emailController.text);
                  }
                  cloudFirestoreController.currentUser.email =
                      emailController.text;
                  cloudFirestoreController.currentUser.mobile =
                      mobileController.text;
                  cloudFirestoreController.currentUser.gender =
                      genderController.text;
                  cloudFirestoreController.currentUser.dob = dobController.text;
                  cloudFirestoreController.currentUser.batch =
                      batchController.text;
                  cloudFirestoreController.currentUser.designation =
                      designationController.text;
                  cloudFirestoreController.currentUser.department =
                      departmentController.text;

                  await cloudFirestoreController
                      .updateUserData(cloudFirestoreController.currentUser)
                      .then(
                        (_) => Fluttertoast.showToast(
                          msg: 'Updated details successfully',
                        ),
                      );
                  hideLoadingDialog();
                  Get.back();
                } else {
                  passwordController.clear();
                  errorDialog(
                    title: 'Failed to verify',
                    msg: 'You entered wrong password',
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
