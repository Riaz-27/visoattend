import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:visoattend/helper/functions.dart';
import 'package:visoattend/views/widgets/custom_button.dart';
import 'package:visoattend/views/widgets/custom_input.dart';

import '../../../helper/constants.dart';
import '../../widgets/custom_text_form_field.dart';

class ApplyLeavePage extends StatelessWidget {
  const ApplyLeavePage({super.key, this.isSelectedClass = true});

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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Apply for leave',
          style: textTheme.bodyMedium,
        ),
        forceMaterialTransparency: true,
        centerTitle: true,
      ),
      body: Padding(
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
                      'Courses*',
                      style: textTheme.bodyMedium!
                          .copyWith(color: textTheme.bodySmall!.color),
                    ),
                  ),
                  verticalGap(height * percentGapVerySmall),
                  CustomTextFormField(
                    controller: classroomsTextController,
                  ),
                ],
              ),
              verticalGap(height * percentGapSmall),
              CustomInput(
                controller: reasonTextController,
                title: 'Reason*',
                validator: (value) => value == null && value!.isEmpty
                    ? 'This field cannot be empty'
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
                      validator: (value) => value == null && value!.isEmpty
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
                        final picked = await showDatePicker(
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
                        toDateString = picked != null ? picked.toString() : '';
                        toDateTextController.text = picked != null
                            ? DateFormat('dd MMMM y').format(picked)
                            : '';
                      },
                      validator: (value) => value == null && value!.isEmpty
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
                text: 'Send Request',
                onPressed: () {},
              )
            ],
          ),
        ),
      ),
    );
  }
}
