import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:visoattend/controller/auth_controller.dart';
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
  const FaceRegisterPage(
      {Key? key, required this.user, this.retrainModel = false})
      : super(key: key);
  final UserModel user;
  final bool retrainModel;

  @override
  Widget build(BuildContext context) {
    final cameraServiceController = Get.find<CameraServiceController>();
    final faceDetectorController = Get.find<FaceDetectorController>();
    final userDatabaseController = Get.find<UserDatabaseController>()
      ..resetValues();
    cameraServiceController.isSignUp = true;
    final size = Get.size;
    final colorScheme = Get.theme.colorScheme;

    List<Widget> stackChildren = [];

    stackChildren.add(
      Positioned(
        height: size.height,
        width: size.width,
        child: Obx(
          () {
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
          },
        ),
      ),
    );

    stackChildren.add(
      Positioned(
        top: 0.0,
        left: 0.0,
        width: size.width,
        height: size.height,
        child: Obx(
          () {
            return faceDetectorController.updateDraw > 0
                ? CustomPaint(
                    painter: FaceDetectorPainter(
                      imageSize: cameraServiceController.getImageSize(),
                      faces: faceDetectorController.faces,
                      camDirection: cameraServiceController.cameraLensDirection,
                      performedRecognition: false,
                    ),
                  )
                : const SizedBox();
          },
        ),
      ),
    );

    //bottom capture and rotate button
    stackChildren.add(
      Positioned(
        left: 0.0,
        right: 0.0,
        bottom: 0.0,
        child: Container(
          height: 200,
          padding: const EdgeInsets.only(bottom: 20),
          color: Colors.black.withOpacity(0.3),
          child: Align(
            alignment: Alignment.bottomCenter,
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
                      final registerRetrainSuccess = await userDatabaseController
                          .registerRetrainUserToFirestore(user, retrainModel: retrainModel);
                      if (registerRetrainSuccess) {
                        if(retrainModel) {
                          Get.back();
                          return;
                        }
                        Get.offAll(() => const AuthPage());
                      }
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
      ),
    );

    stackChildren.add(
      Positioned(
        left: 10.0,
        right: 10.0,
        bottom: 110,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Obx(() {
                final faceAngle = faceDetectorController.faceHeadAngleY;
                return SquareCard(
                  position: 'Left',
                  color: userDatabaseController.isLeft
                      ? Colors.greenAccent
                      : Colors.white,
                  circleColor: faceAngle < -15 && faceAngle > -35
                      ? Colors.green
                      : Colors.white.withOpacity(0.1),
                );
              }),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Obx(() {
                final faceAngle = faceDetectorController.faceHeadAngleY;
                return SquareCard(
                  position: 'Front',
                  color: userDatabaseController.isFront
                      ? Colors.greenAccent
                      : Colors.white,
                  circleColor: faceAngle > -10 && faceAngle < 10
                      ? Colors.green
                      : Colors.white.withOpacity(0.1),
                );
              }),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Obx(() {
                final faceAngle = faceDetectorController.faceHeadAngleY;
                return SquareCard(
                  position: 'Right',
                  color: userDatabaseController.isRight
                      ? Colors.greenAccent
                      : Colors.white,
                  circleColor: faceAngle > 15 && faceAngle < 35
                      ? Colors.green
                      : Colors.white.withOpacity(0.1),
                );
              }),
            ),
          ],
        ),
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        Get.find<AuthController>().isLoading = false;
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

class SquareCard extends StatelessWidget {
  final String position;
  final Color color;
  final Color circleColor;

  const SquareCard({
    super.key,
    required this.position,
    this.color = Colors.white,
    this.circleColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.circle_outlined,
              size: 60,
              color: circleColor,
            ),
            Icon(
              Icons.check_circle,
              size: 50,
              color: color,
            ),
          ],
        ),
        Text(
          position,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
