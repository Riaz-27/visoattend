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
    final mobileController = TextEditingController(text: currentUser.mobile);
    final genderController = TextEditingController(text: currentUser.gender);
    final semesterOrDesignationController =
        TextEditingController(text: currentUser.semesterOrDesignation);
    final departmentController =
        TextEditingController(text: currentUser.department);

    final semesterDesignation = [
      '1st',
      '2nd',
      '3rd',
      '4th',
      '5th',
      '6th',
      '7th',
      '8th',
      'Outgoing',
      'Chairman  & Associate Professor',
      'Professor',
      'Associate Professor',
      'Assistant Professor',
      'Lecturer',
      'Assistant Lecturer',
      'Medical Physicist',
      'Adjunct Lecturer',
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
      'Business Administration',
      'Economics & Banking',
      'Department of Law',
      'English Language and Literature (ELL)',
      'Arabic Language and Literature (ALL)',
      'Library and Information Science  (LIS)',
      'Shariah and Islamic Studies',
      'Institute of Foreign Language',
      'Center for General Education',
      'Morality Development Program',
    ];

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              print('text : ${semesterOrDesignationController.text}');
            },
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
              Text('Account Details', style: textTheme.titleMedium),
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
              _autocompleteField(
                  controller: semesterOrDesignationController,
                  options: semesterDesignation,
                  title: 'Semester or Designation'),
              verticalGap(height * percentGapSmall),
              _autocompleteField(
                  controller: departmentController,
                  options: departmentOptions,
                  title: 'Department'),
              verticalGap(height * 0.3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _autocompleteField(
      {required TextEditingController controller,
      required List<String> options,
      required String title}) {
    final colorScheme = Get.theme.colorScheme;
    final textTheme = Get.theme.textTheme;
    final height = Get.height;
    final width = Get.width;

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
          controller: fieldController,
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
              margin: EdgeInsets.only(top: height * percentGapVerySmall),
              width: width * 0.9,
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
                        Text(option, style: textTheme.bodyMedium),
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
}
