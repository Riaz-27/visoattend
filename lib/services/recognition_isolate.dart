import 'dart:isolate';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';
import 'package:tflite_flutter_plus/src/bindings/types.dart';
import 'package:image/image.dart' as img;

import '../../models/recognition_model.dart';
import '../../models/user_model.dart';

import 'image_converter.dart';

/// For the firestore database data

Future<dynamic> recognitionIsolateForFirestore({
  required int interpreterAddress,
  required CameraImage cameraImage,
  required List<Face> faces,
  required isRegistration,
  List<UserModel>? users,
  required CameraLensDirection cameraLensDirection,
}) async {
  final receivePort = ReceivePort();

  await Isolate.spawn(
    _recognitionIsolateFirestore,
    [
      receivePort.sendPort,
      interpreterAddress,
      cameraImage,
      faces,
      isRegistration,
      users,
      cameraLensDirection
    ],
  );

  return await receivePort.first;
}

Future<void> _recognitionIsolateFirestore(List<dynamic> data) async {
  /// arguments
  final sendPort = data[0] as SendPort;
  final interpreter = tfl.Interpreter.fromAddress(data[1] as int);
  final cameraImage = data[2] as CameraImage;
  final faces = data[3] as List<Face>;
  final isRegistration = data[4] as bool;
  final users = data[5];
  final cameraLensDirection = data[6] as CameraLensDirection;

  final inputShape = interpreter.getInputTensor(0).shape;
  final outputShape = interpreter.getOutputTensor(0).shape;
  NormalizeOp preProcessNormalizeOp = NormalizeOp(127.5, 127.5);
  final outputBuffer = TensorBuffer.createFixedSize(
    outputShape,
    TfLiteType.float32,
  );
  const threshold = 0.76;

  List<double> emb = [];
  Map<int, RecognitionModel> recognitionResults = {};

  img.Image image;
  //convert CameraImage to Image and rotate it so that our frame will be in a portrait
  image = convertYUV420ToImage(cameraImage);
  image = img.copyRotate(
      image, cameraLensDirection == CameraLensDirection.front ? 270 : 90);

  for (Face face in faces) {
    Rect faceRect = face.boundingBox;
    final faceImage = img.copyCrop(
      image,
      faceRect.left.toInt(),
      faceRect.top.toInt(),
      faceRect.width.toInt(),
      faceRect.height.toInt(),
    );

    /// load image and preprocess
    final pres = DateTime.now().millisecondsSinceEpoch;
    var inputImage = TensorImage(TfLiteType.float32);
    inputImage.loadImage(faceImage);
    int cropSize = min(inputImage.height, inputImage.width);
    inputImage = ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(cropSize, cropSize))
        .add(ResizeOp(inputShape[1], inputShape[2], ResizeMethod.bilinear))
        .add(preProcessNormalizeOp)
        .build()
        .process(inputImage);
    final pre = DateTime.now().millisecondsSinceEpoch - pres;
    dev.log('Time to load image: $pre ms');

    /// run model
    final runs = DateTime.now().millisecondsSinceEpoch;
    interpreter.run(inputImage.buffer, outputBuffer.getBuffer());
    final run = DateTime.now().millisecondsSinceEpoch - runs;
    dev.log('Time to run inference: $run ms');

    /// prepare results
    emb = outputBuffer.getDoubleList();

    if (!isRegistration) {
      if (users == null) {
        dev.log('recognition isolate: Users data not found');
        return;
      }
      final recognitionResult = findNearestFirestore(emb, users);
      recognitionResult.position = faceRect;
      recognitionResult.face = faceImage;
      if (recognitionResult.distance > threshold) {
        recognitionResult.userOrNot =
            '${recognitionResult.userOrNot.userId} - ${face.trackingId}';
      }
      final key = face.trackingId!;

      recognitionResults[key] = recognitionResult;
    } else {
      break;
    }
  }

  if (isRegistration) {
    sendPort.send(emb);
  } else {
    sendPort.send(recognitionResults);
  }
}

///  looks for the nearest embedding in the dataset
RecognitionModel findNearestFirestore(List<double> emb, List<UserModel> users) {
  RecognitionModel recognitionResult =
      RecognitionModel(userOrNot: '', distance: 50.0, position: Rect.zero);

  for (UserModel user in users) {
    final userEmbeddings = [
      List<double>.from(user.faceDataFront),
      List<double>.from(user.faceDataRight),
      List<double>.from(user.faceDataLeft),
    ];
    double averageDistance = 0;
    // double divider = 3.0;
    List<double> distances = [];
    for (List<double> embedding in userEmbeddings) {
      double distance = 0;
      for (int i = 0; i < emb.length; i++) {
        double diff = emb[i] - embedding[i];
        distance += diff * diff;
      }
      distance = sqrt(distance);
      distances.add(distance);
      // if (distance < 0.68) {
      //   divider += 0.5;
      //   // distance *= 0.65;
      // } else {
      //   divider -= distance > 0.7 ? 0.3 + (distance - 0.7) : 0.3 - (0.7 - distance);
      //   // distance *= 1.2;
      // }
      averageDistance += distance;
      // if (distance < 0.75) {
      //   divider += 0.5;
      // } else {
      //   divider -= distance > 1 ? 0.25 + (distance - 1) : 0.25 - (1 - distance);
      // }
    }

    // if (divider < 1) divider = 1;
    // averageDistance /= divider;

    distances.sort();
    if (distances[1] < 0.68) {
      averageDistance = distances[1];
    } else if (distances[1] > 0.75) {
      averageDistance = distances[2];
    } else {
      averageDistance = (distances[1] + distances[2]) / 2.0;
      // averageDistance = distances[2]*1.2;
    }

    if (recognitionResult.distance == 50.0 ||
        averageDistance < recognitionResult.distance) {
      recognitionResult.userOrNot = user;
      recognitionResult.distance = averageDistance;
    }
  }

  return recognitionResult;
}

// RecognitionModel findNearestFirestoreCosine(
//     List<double> emb, List<UserModel> users) {
//   // dynamic recognitionResult = [UserModel.empty(), -5.0, Rect.zero];
//   RecognitionModel recognitionResult = RecognitionModel(
//       userOrNot: UserModel.empty(), distance: -5.0, position: Rect.zero);
//
//   for (UserModel user in users) {
//     final userEmbeddings = [
//       List<double>.from(user.faceDataFront),
//       List<double>.from(user.faceDataRight),
//       List<double>.from(user.faceDataLeft),
//     ];
//     double averageDistance = 0;
//     double divider = 3.0;
//     for (List<double> embedding in userEmbeddings) {
//       double embSquare = 0;
//       double embeddingSquare = 0;
//       double vectorProduct = 0;
//       for (int i = 0; i < emb.length; i++) {
//         vectorProduct += emb[i] * embedding[i];
//         embSquare += emb[i] * emb[i];
//         embeddingSquare += embedding[i] * embedding[i];
//       }
//       embSquare = sqrt(embSquare);
//       embeddingSquare = sqrt(embeddingSquare);
//       double cosineSimilarity = vectorProduct / (embSquare * embeddingSquare);
//       double distance = (1 - cosineSimilarity).abs();
//       averageDistance += distance;
//     }
//
//     averageDistance /= divider;
//     if (recognitionResult.distance == -5.0 ||
//         averageDistance < recognitionResult.distance) {
//       recognitionResult.userOrNot = user;
//       recognitionResult.distance = averageDistance;
//     }
//   }
//
//   return recognitionResult;
// }
