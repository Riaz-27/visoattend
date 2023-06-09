import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/entities/isar_user.dart';
import '../../controller/camera_service_controller.dart';
import '../../controller/user_database_controller.dart';
import '../../models/user_model.dart';

class FaceRegisterPage extends StatelessWidget {
  const FaceRegisterPage({Key? key, required this.user}) : super(key: key);
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final cameraServiceController = Get.find<CameraServiceController>();
    final userDatabaseController = Get.find<UserDatabaseController>();

    final size = Get.size;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
                height: size.height - 220,
                width: size.width,
                child: Obx(() {
                  return (cameraServiceController.isInitialized)
                      ? CameraPreview(cameraServiceController.cameraController)
                      : Container();
                })),
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
              child: SizedBox(
                width: double.infinity,
                height: 48.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () async {
                    await userDatabaseController
                        .registerNewUserToFirestore(user);
                  },
                  child: const Text('Take Picture'),
                ),
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
