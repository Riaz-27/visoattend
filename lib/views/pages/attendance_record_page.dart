import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/camera_service_controller.dart';
import '../../controller/face_detector_controller.dart';
import '../../controller/recognition_controller.dart';
import '../../controller/user_database_controller.dart';
import '../widgets/face_detector_painter.dart';

class AttendanceRecordPage extends StatelessWidget {
  const AttendanceRecordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cameraServiceController = Get.find<CameraServiceController>();
    final faceDetectorController = Get.find<FaceDetectorController>();
    final recognitionController = Get.find<RecognitionController>();
    final userDatabaseController = Get.find<UserDatabaseController>();

    final size = Get.size;
    List<Widget> stackChildren = [];
    var recognitionResults = recognitionController.recognitionResults;


    stackChildren.add(
      Positioned(
        height: size.height,
        width: size.width,
        child: Obx(() {
          return (cameraServiceController.isInitialized)
              ? AspectRatio(
                  aspectRatio: cameraServiceController
                      .cameraController.value.aspectRatio,
                  child:
                      CameraPreview(cameraServiceController.cameraController),
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
          return cameraServiceController.isInitialized &&
              recognitionController.performedRecognition
              ? CustomPaint(
                  painter: FaceDetectorPainter(
                    imageSize: cameraServiceController.getImageSize(),
                    faces: faceDetectorController.faces,
                    camDirection: cameraServiceController.cameraLensDirection,
                    recognitionResults: recognitionResults,
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
                    // await faceDetectorController.doFaceDetectionOnFrame(
                    //   cameraServiceController.cameraImage,
                    //   cameraServiceController.cameraRotation!,
                    // );
                    final pres = DateTime.now().millisecondsSinceEpoch;
                    final cameraImage = cameraServiceController.cameraImage;
                    final faces = faceDetectorController.faces;
                    final camDirection =
                        cameraServiceController.cameraLensDirection;
                    final users = await userDatabaseController.getAllIsarUsers();
                    recognitionResults =
                        await recognitionController.performRecognitionOnIsolate(
                      cameraImage: cameraImage,
                      faces: faces,
                      cameraLensDirection: camDirection,
                      users: users,
                    );
                    final pre = DateTime.now().millisecondsSinceEpoch - pres;
                    print('Time total: $pre ms');
                    // print(recognitionResults);
                  },
                  child: const Text('Record'),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: stackChildren,
        ),
      ),
    );
  }
}

class SquareCard extends StatelessWidget {
  final String position;
  final Color color;

  const SquareCard(
      {super.key, required this.position, this.color = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100.0,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: color,
            size: 35,
          ),
          const SizedBox(height: 10.0),
          Text(
            position,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
