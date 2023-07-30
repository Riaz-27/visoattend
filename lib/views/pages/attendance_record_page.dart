import 'dart:collection';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:visoattend/helper/constants.dart';
import 'package:visoattend/helper/functions.dart';

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

    final height = Get.height;
    final width = Get.width;
    List<Widget> stackChildren = [];
    cameraServiceController.isSignUp = false;

    //camera view
    stackChildren.add(
      Positioned(
        height: height,
        width: width,
        child: Obx(() {
          // final size = Get.size;
          // final deviceRatio = size.width / size.height;
          return (cameraServiceController.isInitialized)
              // old method - too much narrow preview
              ? ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: 1,
                      child: AspectRatio(
                        aspectRatio: cameraServiceController
                            .cameraController.value.aspectRatio,
                        child: CameraPreview(
                            cameraServiceController.cameraController),
                      ),
                    ),
                  ),
                )
              // ? Transform.scale(
              //     scale: cameraServiceController
              //             .cameraController.value.aspectRatio /
              //         deviceRatio,
              //     child: Center(
              //       child: AspectRatio(
              //         aspectRatio: cameraServiceController
              //             .cameraController.value.aspectRatio,
              //         child: CameraPreview(
              //             cameraServiceController.cameraController),
              //       ),
              //     ),
              //   )
              : Container(
                  color: Colors.black,
                );
        }),
      ),
    );

    // face painter
    stackChildren.add(
      Positioned(
        top: 0.0,
        left: 0.0,
        width: width,
        height: height,
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

    //bottom capture and rotate button
    stackChildren.add(
      Positioned(
        left: 0.0,
        right: 0.0,
        bottom: 0.0,
        child: Container(
          height: 130,
          color: Colors.black.withOpacity(0.4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () async {
                    await cameraServiceController.toggleCameraDirection();
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.circle_rounded,
                        size: 60,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      const Icon(
                        Icons.flip_camera_android_sharp,
                        size: 25,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () async {
                    await attendanceController.setMatchedStudents().then((_) =>
                        attendanceController
                            .saveDataToFirestore()
                            .then((_) => Navigator.of(context).maybePop()));
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.circle_outlined,
                        size: 85,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      const Icon(
                        Icons.circle_rounded,
                        size: 70,
                        color: Colors.white,
                      ),
                      Icon(
                        Icons.cloud_done,
                        size: 25,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
              ),
              const Expanded(
                flex: 1,
                child: SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );

    //top count increasing button
    stackChildren.add(
      Positioned(
        left: 0.0,
        right: 0.0,
        top: 0.0,
        child: Container(
          height: 80,
          color: Colors.black.withOpacity(0.6),
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Number of Attendance',
                style: textTheme.titleMedium!.copyWith(color: Colors.white),
              ),
              const Spacer(),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.white.withOpacity(0.7),
                  border: Border.all(width: 0.5, color: Colors.white),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (attendanceController.attendanceCount != 1) {
                          attendanceController.attendanceCount--;
                        }
                      },
                      child: Container(
                        color: Colors.transparent,
                        width: 40,
                        child: const Icon(
                          Icons.remove,
                          size: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 25,
                      child: Obx(() {
                        return Text(
                          attendanceController.attendanceCount.toString(),
                          textAlign: TextAlign.center,
                          style: Get.textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                    ),
                    GestureDetector(
                      onTap: () {
                        attendanceController.attendanceCount++;
                      },
                      child: Container(
                        color: Colors.transparent,
                        width: 40,
                        child: const Icon(
                          Icons.add,
                          size: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              horizontalGap(width * percentGapLarge)
              // Expanded(
              //   flex: 1,
              //   child: GestureDetector(
              //     onTap: () {
              //       if (attendanceController.attendanceCount != 1) {
              //         attendanceController.attendanceCount--;
              //       }
              //     },
              //     child: Stack(
              //       alignment: Alignment.center,
              //       children: [
              //         Icon(
              //           Icons.circle_rounded,
              //           size: 50,
              //           color: Colors.white.withOpacity(0.3),
              //         ),
              //         const Icon(
              //           Icons.remove,
              //           size: 15,
              //           color: Colors.white,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // Expanded(
              //   flex: 1,
              //   child: Stack(
              //     alignment: Alignment.center,
              //     children: [
              //       Icon(
              //         Icons.circle_rounded,
              //         size: 50,
              //         color: Colors.white.withOpacity(0.3),
              //       ),
              //       Obx(() {
              //         return Text(
              //           attendanceController.attendanceCount.toString(),
              //           style: Get.textTheme.titleSmall!.copyWith(
              //             color: Colors.white,
              //           ),
              //         );
              //       }),
              //     ],
              //   ),
              // ),
              // Expanded(
              //   flex: 1,
              //   child: GestureDetector(
              //     onTap: () {
              //       attendanceController.attendanceCount++;
              //     },
              //     child: Stack(
              //       alignment: Alignment.center,
              //       children: [
              //         Icon(
              //           Icons.circle_rounded,
              //           size: 50,
              //           color: Colors.white.withOpacity(0.3),
              //         ),
              //         const Icon(
              //           Icons.add,
              //           size: 15,
              //           color: Colors.white,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        loadingDialog();
        cameraServiceController.isBusy = true;
        await cameraServiceController.cameraController.stopImageStream();
        cameraServiceController.isStopped = true;
        final classCount = attendanceController.classroomData
            .weekTimes[DateFormat('EEEE').format(DateTime.now())]['classCount'];
        attendanceController.attendanceCount =
            classCount == null || classCount == '' ? 1 : int.parse(classCount);
        final durationMs = faceDetectorController.faces.length * 100 + 500;
        await Future.delayed(Duration(milliseconds: durationMs));
        hideLoadingDialog();
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: GestureDetector(
            onScaleUpdate: (updateDetails) async {
              final cameraController = cameraServiceController.cameraController;
              final maxZoomLevel = await cameraController.getMaxZoomLevel();

              double dragIntensity = updateDetails.scale;
              if (dragIntensity < 1) {
                cameraController.setZoomLevel(1);
              } else if (dragIntensity > 1 && dragIntensity < maxZoomLevel) {
                cameraController.setZoomLevel(dragIntensity);
              }
            },
            child: Stack(
              children: stackChildren,
            ),
          ),
        ),
      ),
    );
  }
}
