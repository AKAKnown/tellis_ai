import '../repositories/sign_recognition_repository.dart';

class InitializeSignModelUseCase {
  const InitializeSignModelUseCase(this._repository);

  final SignRecognitionRepository _repository;

  Future<void> call() => _repository.initialize();
}
