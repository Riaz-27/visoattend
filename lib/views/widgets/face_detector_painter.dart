import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter({
    required this.imageSize,
    required this.faces,
    required this.camDirection,
    required this.recognitionResults,
    required this.performedRecognition,
  });

  final Size imageSize;
  final List<Face> faces;
  CameraLensDirection camDirection;
  final List<dynamic> recognitionResults;
  final bool performedRecognition;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;

    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.red;

    if(!performedRecognition) {
      for (Face face in faces) {
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
      for (dynamic result in recognitionResults) {
        String text = '';
        Color color;

        if (result[0] == "Uk") {
          text = '${result[0]} ${result[1].toStringAsFixed(2)}';
          color = Colors.red;
        } else {
          text = '${result[0].name} ${result[1].toStringAsFixed(2)}';
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
            canvas, Offset(result[2].left * scaleX, result[2].top * scaleY));

        canvas.drawRRect(
          RRect.fromLTRBR(
            camDirection == CameraLensDirection.front
                ? (imageSize.width - result[2].right) * scaleX
                : result[2].left * scaleX,
            result[2].top * scaleY,
            camDirection == CameraLensDirection.front
                ? (imageSize.width - result[2].left) * scaleX
                : result[2].right * scaleX,
            result[2].bottom * scaleY,
            const Radius.circular(10),
          ),
          paint..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return true;
  }
}
