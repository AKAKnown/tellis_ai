import 'dart:io';

import 'package:camera/camera.dart';

import '../entities/sign_prediction.dart';

abstract class SignRecognitionRepository {
  Future<void> initialize();

  Future<SignPrediction> classifyImage(File imageFile);

  Future<SignPrediction> classifyCameraFrame(
    CameraImage cameraImage, {
    required int rotationDegrees,
  });

  void dispose();
}
