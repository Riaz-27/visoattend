import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/cloud_firestore_controller.dart';
import '../../../helper/constants.dart';
import '../../../helper/functions.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

class AccountDetailsPage extends StatelessWidget {
  const AccountDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Get.theme.colorScheme;
    final textTheme = Get.theme.textTheme;
    final height = Get.height;
    final width = Get.width;

    final currentUser = Get.find<CloudFirestoreController>().currentUser;

    final nameController = TextEditingController(text: currentUser.name);
    final idController = TextEditingController(text: currentUser.userId);
    final emailController = TextEditingController(text: currentUser.email);
    final mobileController = TextEditingController(text: '01812345678');
    final genderController = TextEditingController(text: 'Male');
    final semesterController = TextEditingController(text: '');
    final departmentController = TextEditingController(text: 'Computer Science and Engineering');

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.check, color: colorScheme.primary),
          ),
        ],
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
                'Account Details',
                style: textTheme.titleMedium,
              ),
              verticalGap(height * percentGapLarge),
              CustomInput(
                controller: nameController,
                title: 'Full Name',
                enableTextField: false,
              ),
              verticalGap(height * percentGapSmall),
              CustomInput(
                controller: idController,
                title: 'Metric ID No',
                enableTextField: false,
              ),
              verticalGap(height * percentGapSmall),
              CustomInput(
                controller: emailController,
                title: 'Email',
                enableTextField: false,
              ),
              verticalGap(height * percentGapSmall),
              CustomInput(controller: mobileController, title: 'Mobile Number'),
              verticalGap(height * percentGapSmall),
              CustomInput(controller: genderController, title: 'Gender'),
              verticalGap(height * percentGapSmall),
              CustomInput(controller: semesterController, title: 'Semester or Designation'),
              verticalGap(height * percentGapSmall),
              CustomInput(controller: departmentController, title: 'Department'),
              verticalGap(height * percentGapLarge),
            ],
          ),
        ),
      ),
    );
  }
}
