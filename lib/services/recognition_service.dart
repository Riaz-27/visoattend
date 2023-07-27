import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';
import 'package:tflite_flutter_plus/src/bindings/types.dart';

import '../models/entities/isar_user.dart';
import 'image_converter.dart';
import 'isar_service.dart';

class RecognitionService {
  late tfl.Interpreter _interpreter;
  tfl.Interpreter get interpreter => _interpreter;

  late int _interpreterAddress;
  int get interpreterAddress => _interpreterAddress;

  late tfl.InterpreterOptions _interpreterOptions;

  late List<int> _inputShape;
  late List<int> _outputShape;

  late TensorImage _inputImage;
  late TensorBuffer _outputBuffer;

  final _inputType = TfLiteType.float32;

  String get modelPath => 'assets/facenet.tflite';

  NormalizeOp get preProcessNormalizeOp => NormalizeOp(127.5, 127.5);

  final threshold = 1;

  final isarService = IsarService();

  void initialize({int numThreads = 2}) {
    late tfl.Delegate delegate;
    try {
      if (Platform.isAndroid) {
        delegate = tfl.XNNPackDelegate();

        // Use GPU Delegate
        // doesn't work on emulator
        // if (Platform.isAndroid) {
        //   options.addDelegate(GpuDelegateV2());
        // }

      } else if (Platform.isIOS) {
        delegate = tfl.GpuDelegate();
      }
      _interpreterOptions = tfl.InterpreterOptions();
      print('Interpreter created on GPU');
    } catch (e) {
      print('Failed to create gpu delegate: $e\nrunning on cpu');
      _interpreterOptions = tfl.InterpreterOptions();
    }

    _interpreterOptions.threads = numThreads;

    loadModel();
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await tfl.Interpreter.fromAsset(
        modelPath,
        options: _interpreterOptions,
      );
      _interpreterAddress = _interpreter.address;
      print('Interpreter Created Successfully');
      _inputShape = _interpreter.getInputTensor(0).shape;
      _outputShape = _interpreter.getOutputTensor(0).shape;
      print('The _inputShape = ${_inputShape.toString()}');

      _outputBuffer = TensorBuffer.createFixedSize(_outputShape, _inputType);
    } catch (e) {
      print('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  TensorImage _preProcess() {
    int cropSize = min(_inputImage.height, _inputImage.width);
    return ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(cropSize, cropSize))
        .add(ResizeOp(
            _inputShape[1], _inputShape[2], ResizeMethod.nearestneighbour))
        // .add(preProcessNormalizeOp)
        .build()
        .process(_inputImage);
  }

  Future<List<double>> runModel(img.Image faceImage) async {
    final pres = DateTime.now().millisecondsSinceEpoch;
    _inputImage = TensorImage(_inputType);
    _inputImage.loadImage(faceImage);
    _inputImage = _preProcess();
    final pre = DateTime.now().millisecondsSinceEpoch - pres;
    print(
        'Time to load image: $pre ms, The inputShape = ${_inputShape.toString()}');
    final runs = DateTime.now().millisecondsSinceEpoch;
    // final receivePort = ReceivePort();
    await Isolate.spawn(
      (data) {
        final interpreter = tfl.Interpreter.fromAddress(data[2] as int);
        final input = data[0];
        final output = data[1] as TensorBuffer;
        // final sendPort = data[3] as SendPort;
        interpreter.run(input, output.getBuffer());
        // sendPort.send(output.getDoubleList());
      },
      [
        _inputImage.buffer,
        _outputBuffer,
        _interpreter.address,
        // receivePort.sendPort,
      ],
    );
    // List<double> returnedBuffer = await receivePort.first;
    // receivePort.close();
    // _interpreter.run(_inputImage.buffer, _outputBuffer.getBuffer());
    final run = DateTime.now().millisecondsSinceEpoch - runs;
    print('Time to run inference: $run ms');

    return _outputBuffer.getDoubleList();
  }

  // Future<dynamic> performFaceRecognition({
  //   required CameraImage cameraImage,
  //   required List<Face> faces,
  //   required CameraLensDirection cameraLensDirection,
  //   bool isRegistration = false,
  // }) async {
  //   img.Image image;
  //   //convert CameraImage to Image and rotate it so that our frame will be in a portrait
  //   image = convertYUV420ToImage(cameraImage);
  //   image = img.copyRotate(
  //       image, cameraLensDirection == CameraLensDirection.front ? 270 : 90);
  //
  //   List<double> emb = [];
  //   List<dynamic> recognitionResults = [];
  //
  //   for (Face face in faces) {
  //     Rect faceRect = face.boundingBox;
  //     //crop face
  //     final faceImage = img.copyCrop(
  //         image,
  //         faceRect.left.toInt(),
  //         faceRect.top.toInt(),
  //         faceRect.width.toInt(),
  //         faceRect.height.toInt());
  //
  //     emb = runModel(faceImage, faceRect);
  //
  //     if (!isRegistration) {
  //       final recognitionResult = await findNearest(emb);
  //       recognitionResult[2] = faceRect;
  //       if (recognitionResult[1] > threshold) {
  //         recognitionResult[0] = 'Unknown';
  //       }
  //       print('The result : $recognitionResult');
  //       recognitionResults.add(recognitionResult);
  //     }
  //   }
  //
  //   if (isRegistration) {
  //     return emb;
  //   } else {
  //     return recognitionResults;
  //   }
  // }

  //
  ///  looks for the nearest embeeding in the dataset
  dynamic findNearest(List<double> emb, List<IsarUser> users) {
    dynamic recognitionResult = [IsarUser(), -5.0, Rect.zero];

    for (IsarUser user in users) {
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
      if (recognitionResult[1] == -5 ||
          averageDistance < recognitionResult[1]) {
        recognitionResult[0] = user;
        recognitionResult[1] = averageDistance;
      }
    }

    return recognitionResult;
  }

  dispose() {
    _interpreter.close();
  }
}
