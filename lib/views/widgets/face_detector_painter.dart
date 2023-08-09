import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../helper/constants.dart';
import '../../models/recognition_model.dart';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter({
    required this.imageSize,
    required this.faces,
    required this.camDirection,
    this.recognitionResults,
    required this.performedRecognition,
  });

  final Size imageSize;
  final List<Face> faces;
  CameraLensDirection camDirection;
  final Map<int, RecognitionModel>? recognitionResults;
  final bool performedRecognition;

  @override
  void paint(Canvas canvas, Size size) {

    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.red;

    if (recognitionResults == null) {
      int i = 0;
      for (Face face in faces) {
        i++;
        Color color = Colors.greenAccent;
        final faceAngle = face.headEulerAngleY!;
        if (i > 1 ||
            faceAngle > 35 ||
            faceAngle < -35 ||
            (faceAngle > -15 && faceAngle < -10) ||
            (faceAngle < 15 && faceAngle > 10)) {
          color = colorScheme.error;
        }

        final path = facePath(face.boundingBox, scaleX, scaleY);
        canvas.drawPath(path, paint..color = color);
      }
    } else {
      recognitionResults!.forEach((key, value) {
        String text = '';
        Color color;

        if (value.userOrNot is String) {
          // text = '${value.userOrNot} ${value.distance.toStringAsFixed(2)}';
          text = 'Unknown';
          color = colorScheme.error;
        } else {
          text =
              // '${value.userOrNot.userId} ${value.distance.toStringAsFixed(2)}';
          text = '${value.userOrNot.userId}';
          color = Colors.green.shade600;
        }

        TextSpan span = TextSpan(
          style: textTheme.labelSmall!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            backgroundColor: color.withOpacity(0.4),
          ),
          text: text,
        );
        TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(
          canvas,
          Offset(
            camDirection == CameraLensDirection.front
                ? (value.position.width - value.position.right) * scaleX
                : value.position.left * scaleX,
            value.position.bottom * scaleY - 5,
          ),
        );

        final path = facePath(value.position, scaleX, scaleY);
        canvas.drawPath(path, paint..color = color);
      });
    }
  }

  Path facePath(Rect rect, double scaleX, double scaleY) {
    final rectWidth = rect.right * scaleX - rect.left * scaleX;
    final radius = rectWidth * 0.07;
    final extend = radius * 2.5;
    final arcSize = Size.square(radius * 2);

    // canvas.translate(
    //     face.boundingBox.left * scaleX, face.boundingBox.top * scaleY);
    final path = Path();
    Path singlePath = Path();
    for (var i = 0; i < 4; i++) {
      final l = i & 1 == 0;
      final t = i & 2 == 0;
      singlePath
        ..moveTo(l ? 0 : rectWidth, t ? extend : rectWidth - extend)
        ..arcTo(
            Offset(l ? 0 : rectWidth - arcSize.width,
                    t ? 0 : rectWidth - arcSize.width) &
                arcSize,
            l ? pi : pi * 2,
            l == t ? pi / 2 : -pi / 2,
            false)
        ..lineTo(l ? extend : rectWidth - extend, t ? 0 : rectWidth);
    }
    path.addPath(
      singlePath,
      Offset(
          camDirection == CameraLensDirection.front
              ? (imageSize.width - rect.right) * scaleX
              : rect.left * scaleX,
          rect.top * scaleY),
    );

    return path;
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return true;
  }

  /// OLD RECTANGLE CODE
// canvas.drawRRect(
//   RRect.fromLTRBR(
//     camDirection == CameraLensDirection.front
//         ? (imageSize.width - face.boundingBox.right) * scaleX
//         : face.boundingBox.left * scaleX,
//     face.boundingBox.top * scaleY,
//     camDirection == CameraLensDirection.front
//         ? (imageSize.width - face.boundingBox.left) * scaleX
//         : face.boundingBox.right * scaleX,
//     face.boundingBox.bottom * scaleY,
//     const Radius.circular(10),
//   ),
//   paint..color = color,
// );
}
