import 'package:camera/camera.dart';

import '../entities/sign_prediction.dart';
import '../repositories/sign_recognition_repository.dart';

class ClassifyCameraFrameUseCase {
  const ClassifyCameraFrameUseCase(this._repository);

  final SignRecognitionRepository _repository;

  Future<SignPrediction> call(
    CameraImage cameraImage, {
    required int rotationDegrees,
  }) {
    return _repository.classifyCameraFrame(
      cameraImage,
      rotationDegrees: rotationDegrees,
    );
  }
}
