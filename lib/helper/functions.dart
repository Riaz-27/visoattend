import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../helper/constants.dart';

/// For UI

Widget verticalGap(double height) => SizedBox(height: height);

Widget horizontalGap(double width) => SizedBox(width: width);

void loadingDialog([String? msg]) {
  Get.dialog(
    barrierDismissible: false,
    Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 8),
            Text(msg ?? ''),
          ],
        ),
      ),
    ),
  );
}

void errorDialog({required String title, required String msg}) {
  Get.dialog(
    barrierDismissible: false,
    AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Ok'),
        ),
      ],
    ),
  );
}

void hideLoadingDialog() {
  if (Get.isDialogOpen ?? false) Get.back();
}
