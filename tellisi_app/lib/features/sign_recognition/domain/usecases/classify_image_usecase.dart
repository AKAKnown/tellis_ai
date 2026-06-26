import 'dart:io';

import '../entities/sign_prediction.dart';
import '../repositories/sign_recognition_repository.dart';

class ClassifyImageUseCase {
  const ClassifyImageUseCase(this._repository);

  final SignRecognitionRepository _repository;

  Future<SignPrediction> call(File imageFile) {
    return _repository.classifyImage(imageFile);
  }
}
