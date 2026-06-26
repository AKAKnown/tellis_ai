import 'dart:io';

import 'package:camera/camera.dart';

import '../../domain/entities/sign_prediction.dart';
import '../../domain/repositories/sign_recognition_repository.dart';
import '../datasources/tflite_sign_data_source.dart';

class SignRecognitionRepositoryImpl implements SignRecognitionRepository {
  const SignRecognitionRepositoryImpl(this._dataSource);

  final TFLiteSignDataSource _dataSource;

  @override
  Future<void> initialize() => _dataSource.initialize();

  @override
  Future<SignPrediction> classifyImage(File imageFile) {
    return _dataSource.predictFromFile(imageFile);
  }

  @override
  Future<SignPrediction> classifyCameraFrame(
    CameraImage cameraImage, {
    required int rotationDegrees,
  }) {
    return _dataSource.predictFromCameraImage(
      cameraImage,
      rotationDegrees: rotationDegrees,
    );
  }

  @override
  void dispose() => _dataSource.dispose();
}
