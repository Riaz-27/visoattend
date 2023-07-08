import 'dart:collection';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/attendance_controller.dart';
import '../../controller/camera_service_controller.dart';
import '../../controller/face_detector_controller.dart';
import '../../controller/recognition_controller.dart';
import '../../controller/user_database_controller.dart';
import '../../models/recognition_model.dart';
import '../widgets/face_detector_painter.dart';

class AttendanceRecordPage extends StatelessWidget {
  const AttendanceRecordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cameraServiceController = Get.find<CameraServiceController>();
    final faceDetectorController = Get.find<FaceDetectorController>();
    final recognitionController = Get.find<RecognitionController>();
    final attendanceController = Get.find<AttendanceController>();

    final size = Get.size;
    List<Widget> stackChildren = [];
    cameraServiceController.isSignUp = false;

    stackChildren.add(
      Positioned(
        height: size.height,
        width: size.width,
        child: Obx(() {
          return (cameraServiceController.isInitialized)
              ? ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: 1,
                      child: AspectRatio(
                        aspectRatio: 1 /
                            cameraServiceController
                                .cameraController.value.aspectRatio,
                        child: CameraPreview(
                            cameraServiceController.cameraController),
                      ),
                    ),
                  ),
                )
              : Container(
                  color: Colors.black,
                );
        }),
      ),
    );

    stackChildren.add(
      Positioned(
        top: 0.0,
        left: 0.0,
        width: size.width,
        height: size.height,
        child: Obx(() {
          final resultOnCurrentFrame = recognitionController.recognitionResults;
          return resultOnCurrentFrame.isNotEmpty
              ? CustomPaint(
                  painter: FaceDetectorPainter(
                    imageSize: cameraServiceController.getImageSize(),
                    faces: faceDetectorController.faces,
                    camDirection: cameraServiceController.cameraLensDirection,
                    recognitionResults: resultOnCurrentFrame,
                    performedRecognition:
                        recognitionController.performedRecognition,
                  ),
                )
              : const SizedBox();
        }),
      ),
    );

    stackChildren.add(
      Positioned(
        left: 10.0,
        right: 10.0,
        bottom: 10.0,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () async {
                    await cameraServiceController.toggleCameraDirection();
                  },
                  child: const Text('Toggle'),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: SizedBox(
                height: 48.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () async {
                    await attendanceController.setMatchedStudents().then(
                        (_) => attendanceController.saveDataToFirestore());
                  },
                  child: const Text('Record'),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        cameraServiceController.isBusy = true;
        await cameraServiceController.cameraController.stopImageStream();
        cameraServiceController.isStopped = true;
        await Future.delayed(const Duration(seconds: 2));
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: stackChildren,
          ),
        ),
      ),
    );
  }
}
