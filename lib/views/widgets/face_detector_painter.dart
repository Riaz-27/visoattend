import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

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
      ..strokeWidth = 1.5
      ..color = Colors.red;

    if(recognitionResults == null) {
      for (Face face in faces) {
        TextSpan span = TextSpan(
          style: TextStyle(
            color: Colors.black,
            backgroundColor: Colors.white.withAlpha(155),
            fontSize: 15,
          ),
          text: face.headEulerAngleY.toString(),
        );
        TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(
            canvas, Offset(face.boundingBox.left * scaleX, face.boundingBox.top * scaleY));

        canvas.drawRRect(
          RRect.fromLTRBR(
            camDirection == CameraLensDirection.front
                ? (imageSize.width - face.boundingBox.right) * scaleX
                : face.boundingBox.left * scaleX,
            face.boundingBox.top * scaleY,
            camDirection == CameraLensDirection.front
                ? (imageSize.width - face.boundingBox.left) * scaleX
                : face.boundingBox.right * scaleX,
            face.boundingBox.bottom * scaleY,
            const Radius.circular(10),
          ),
          paint..color = Colors.blueGrey,
        );
      }
    } else {
      recognitionResults!.forEach((key, value){
        String text = '';
        Color color;

        if (value.userOrNot is String) {
          text = '${value.userOrNot} ${value.distance.toStringAsFixed(2)}';
          color = Colors.red;
        } else {
          text = '${value.userOrNot.userId} ${value.distance.toStringAsFixed(2)}';
          color = Colors.green;
        }

        TextSpan span = TextSpan(
          style: TextStyle(
            color: Colors.black,
            backgroundColor: Colors.white.withAlpha(155),
            fontSize: 15,
          ),
          text: text,
        );
        TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(
            canvas, Offset(value.position.left * scaleX, value.position.top * scaleY));

        canvas.drawRRect(
          RRect.fromLTRBR(
            camDirection == CameraLensDirection.front
                ? (imageSize.width - value.position.right) * scaleX
                : value.position.left * scaleX,
            value.position.top * scaleY,
            camDirection == CameraLensDirection.front
                ? (imageSize.width - value.position.left) * scaleX
                : value.position.right * scaleX,
            value.position.bottom * scaleY,
            const Radius.circular(10),
          ),
          paint..color = color,
        );
      });
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return true;
  }
}
