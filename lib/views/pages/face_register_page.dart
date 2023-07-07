import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visoattend/views/pages/auth_page.dart';
import 'package:visoattend/views/pages/classroom_pages/classroom_page.dart';
import 'package:visoattend/views/pages/home_page.dart';

import '../../controller/face_detector_controller.dart';
import '../../models/entities/isar_user.dart';
import '../../controller/camera_service_controller.dart';
import '../../controller/user_database_controller.dart';
import '../../models/user_model.dart';
import '../widgets/face_detector_painter.dart';

class FaceRegisterPage extends StatelessWidget {
  const FaceRegisterPage({Key? key, required this.user}) : super(key: key);
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final cameraServiceController = Get.find<CameraServiceController>();
    final faceDetectorController = Get.find<FaceDetectorController>();
    final userDatabaseController = Get.find<UserDatabaseController>();
    cameraServiceController.isSignUp = true;
    final size = Get.size;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
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
                      : Container();
                })),
            Positioned(
              top: 0.0,
              left: 0.0,
              width: size.width,
              height: size.height,
              child: Obx(() {
                return faceDetectorController.faceDetected > 0
                    ? CustomPaint(
                        painter: FaceDetectorPainter(
                          imageSize: cameraServiceController.getImageSize(),
                          faces: faceDetectorController.faces,
                          camDirection:
                              cameraServiceController.cameraLensDirection,
                          performedRecognition: false,
                        ),
                      )
                    : const SizedBox();
              }),
            ),
            Positioned(
              left: 10.0,
              right: 10.0,
              bottom: 75,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Obx(() {
                      return SquareCard(
                        position: 'Left',
                        color: userDatabaseController.isLeft
                            ? Colors.green
                            : Colors.grey,
                      );
                    }),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Obx(() {
                      return SquareCard(
                        position: 'Front',
                        color: userDatabaseController.isFront
                            ? Colors.green
                            : Colors.grey,
                      );
                    }),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Obx(() {
                      return SquareCard(
                        position: 'Right',
                        color: userDatabaseController.isRight
                            ? Colors.green
                            : Colors.grey,
                      );
                    }),
                  ),
                ],
              ),
            ),
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
                  const SizedBox(width: 10,),
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
                          final registerSuccess = await userDatabaseController
                              .registerNewUserToFirestore(user);
                          if (registerSuccess) {
                            Get.to(() => const AuthPage());
                          }
                        },
                        child: const Text('Take Picture'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
