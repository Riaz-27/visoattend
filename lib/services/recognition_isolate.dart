import 'dart:isolate';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';
import 'package:tflite_flutter_plus/src/bindings/types.dart';
import 'package:image/image.dart' as img;

import '../models/entities/user.dart';
import 'image_converter.dart';

Future<dynamic> recognitionIsolate(
    {required int interpreterAddress,
    required CameraImage cameraImage,
    required List<Face> faces,
    required isRegistration,
    List<User>? users,
    required CameraLensDirection cameraLensDirection}) async {

  final receivePort = ReceivePort();

  Isolate.spawn(
    _recognitionIsolate,
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

Future<void> _recognitionIsolate(List<dynamic> data) async {
  //arguments
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
  final outputBuffer =
      TensorBuffer.createFixedSize(outputShape, TfLiteType.float32);
  const threshold = 1.0;

  List<double> emb = [];
  List<dynamic> recognitionResults = [];

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
        .add(ResizeOp(
            inputShape[1], inputShape[2], ResizeMethod.nearestneighbour))
        .add(preProcessNormalizeOp)
        .build()
        .process(inputImage);
    final pre = DateTime.now().millisecondsSinceEpoch - pres;
    print('Time to load image: $pre ms');

    /// run model
    final runs = DateTime.now().millisecondsSinceEpoch;
    interpreter.run(inputImage.buffer, outputBuffer.getBuffer());
    final run = DateTime.now().millisecondsSinceEpoch - runs;
    print('Time to run inference: $run ms');

    /// prepare results
    emb = outputBuffer.getDoubleList();

    if (!isRegistration) {
      if (!isRegistration) {
        if (users == null) {
          print('Users data not found');
          return;
        }
        final recognitionResult = findNearest(emb, users);
        recognitionResult[2] = faceRect;
        if (recognitionResult[1] > threshold) {
          recognitionResult[0] = 'Uk';
        }
        print('The result : $recognitionResult');
        recognitionResults.add(recognitionResult);
      }
    }
  }

  if (isRegistration) {
    sendPort.send(emb);
  } else {
    sendPort.send(recognitionResults);
  }
}

///  looks for the nearest embedding in the dataset
dynamic findNearest(List<double> emb, List<User> users) {
  dynamic recognitionResult = [User(), -5.0, Rect.zero];

  for (User user in users) {
    final userEmbeddings = [
      user.faceDataFront,
      user.faceDataRight,
      user.faceDataLeft
    ];
    double averageDistance = 0;

    for (List<double> embedding in userEmbeddings) {
      double distance = 0;
      for (int i = 0; i < emb.length; i++) {
        double diff = emb[i] - embedding[i];
        distance += diff * diff;
      }
      distance = sqrt(distance);
      averageDistance += distance;
    }

    averageDistance /= 3;
    if (recognitionResult[1] == -5 || averageDistance < recognitionResult[1]) {
      recognitionResult[0] = user;
      recognitionResult[1] = averageDistance;
    }
  }

  return recognitionResult;
}
