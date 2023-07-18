import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visoattend/controller/cloud_firestore_controller.dart';
import 'package:visoattend/controller/leave_request_controller.dart';
import 'package:visoattend/helper/functions.dart';
import 'package:visoattend/models/leave_request_model.dart';
import 'package:visoattend/views/widgets/custom_button.dart';
import 'package:visoattend/views/widgets/custom_input.dart';

import '../../../helper/constants.dart';
import '../../../models/classroom_model.dart';
import '../../widgets/custom_text_form_field.dart';

class ApplyLeavePage extends GetView<LeaveRequestController> {
  const ApplyLeavePage({super.key, this.isSelectedClass = false});

  final bool isSelectedClass;

  @override
  Widget build(BuildContext context) {
    final classroomsTextController = TextEditingController();
    final reasonTextController = TextEditingController();
    final fromDateTextController = TextEditingController();
    final toDateTextController = TextEditingController();
    final descriptionTextController = TextEditingController();

    String fromDateString = '';
    String toDateString = '';

    //set values
    controller.setValues(isSelectedClass: isSelectedClass);

    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Apply for leave',
          style: textTheme.bodyMedium,
        ),
        forceMaterialTransparency: true,
        centerTitle: true,
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: height * percentGapSmall),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Classrooms*',
                        style: textTheme.bodyMedium!
                            .copyWith(color: textTheme.bodySmall!.color),
                      ),
                    ),
                    verticalGap(height * percentGapVerySmall),
                    Obx(() {
                      return Wrap(
                        crossAxisAlignment: WrapCrossAlignment.start,
                        children: controller.selectedClassrooms
                            .map((classroom) =>
                                _selectedClassroomView(classroom))
                            .toList(),
                      );
                    }),
                    verticalGap(height * percentGapSmall),
                    _autocompleteField(),
                  ],
                ),
                verticalGap(height * percentGapSmall),
                CustomInput(
                  controller: reasonTextController,
                  title: 'Reason*',
                  validator: (value) => reasonTextController.text == ''
                      ? 'The field cannot be empty'
                      : null,
                ),
                verticalGap(height * percentGapSmall),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: CustomInput(
                        controller: fromDateTextController,
                        title: 'From*',
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: toDateString == ''
                                ? DateTime.now()
                                : DateTime.parse(toDateString),
                            firstDate:
                                DateTime.now().add(const Duration(days: -365)),
                            lastDate: toDateString == ''
                                ? DateTime.now().add(const Duration(days: 365))
                                : DateTime.parse(toDateString),
                          );
                          fromDateString =
                              picked != null ? picked.toString() : '';
                          fromDateTextController.text = picked != null
                              ? DateFormat('dd MMMM y').format(picked)
                              : '';
                        },
                        validator: (value) => fromDateTextController.text == ''
                            ? 'Must select a date'
                            : null,
                      ),
                    ),
                    horizontalGap(height * percentGapMedium),
                    Expanded(
                      flex: 1,
                      child: CustomInput(
                        controller: toDateTextController,
                        title: 'To*',
                        readOnly: true,
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: fromDateString == ''
                                ? DateTime.now()
                                : DateTime.parse(fromDateString),
                            firstDate: fromDateString == ''
                                ? DateTime.now().add(const Duration(days: -365))
                                : DateTime.parse(fromDateString),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          picked = picked?.add(const Duration(days: 1)).add(const Duration(milliseconds: -1));
                          toDateString =
                              picked != null ? picked.toString() : '';
                          toDateTextController.text = picked != null
                              ? DateFormat('dd MMMM y').format(picked)
                              : '';
                        },
                        validator: (value) => toDateTextController.text == ''
                            ? 'Must select a date'
                            : null,
                      ),
                    ),
                  ],
                ),
                verticalGap(height * percentGapSmall),
                CustomInput(
                  controller: descriptionTextController,
                  title: 'Description',
                  borderRadius: 20,
                  maxLength: 200,
                  maxLines: 6,
                ),
                verticalGap(height * percentGapSmall),
                CustomButton(
                  text: 'Apply',
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final currentUser =
                          Get.find<CloudFirestoreController>().currentUser;
                      final leaveRequest = LeaveRequestModel(
                        leaveRequestId: '',
                        dateTime: DateTime.now().toString(),
                        userAuthUid: currentUser.authUid,
                        reason: reasonTextController.text.trim(),
                        fromDate: fromDateString,
                        toDate: toDateString,
                        description: descriptionTextController.text.trim(),
                        applicationStatus: {},
                      );
                      await controller.saveLeaveRequestData(leaveRequest);
                      Get.back();
                      Fluttertoast.showToast(msg: 'Leave request sent to selected classes');
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectedClassroomView(ClassroomModel classroom) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.6)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: SizedBox(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              classroom.courseTitle,
              style: textTheme.labelMedium,
              overflow: TextOverflow.ellipsis,
            ),
            GestureDetector(
              onTap: () {
                controller.selectedClassrooms.remove(classroom);
                controller.availableClassrooms.add(classroom);
              },
              child: Icon(
                Icons.clear_rounded,
                size: 18,
                color: colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _autocompleteField() {
    TextEditingController textController = TextEditingController();
    return Autocomplete<ClassroomModel>(
      optionsBuilder: (textEditingValue) {
        return controller.availableClassrooms.where((classroom) =>
            classroom.courseTitle
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()) ||
            classroom.courseCode
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (value) {
        textController.clear();
        controller.selectedClassrooms.add(value);
        controller.availableClassrooms.remove(value);
      },
      displayStringForOption: (ClassroomModel classroom) =>
          classroom.courseTitle,
      fieldViewBuilder: (context, fieldController, focusNode, onSubmitted) {
        textController = fieldController;
        return CustomTextFormField(
          controller: fieldController,
          focusNode: focusNode,
          hintText: 'Add more classroom',
          hintStyle: textTheme.labelMedium!
              .copyWith(color: colorScheme.onBackground.withOpacity(0.5)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          style: textTheme.labelMedium,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.4),
          maxLines: 1,
          validator: (value) {
            if (controller.selectedClassrooms.isEmpty) {
              return 'Must select at least one classroom';
            }
            return null;
          },
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(option.courseTitle,
                                style: textTheme.bodyMedium),
                            Text(option.courseCode, style: textTheme.bodySmall),
                          ],
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
}
