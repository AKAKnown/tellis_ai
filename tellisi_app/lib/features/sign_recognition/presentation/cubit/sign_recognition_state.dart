import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../domain/entities/sign_prediction.dart';

enum SignRecognitionStatus {
  initial,
  loadingModel,
  ready,
  processing,
  success,
  failure,
}

class SignRecognitionState extends Equatable {
  const SignRecognitionState({
    this.status = SignRecognitionStatus.initial,
    this.isModelReady = false,
    this.selectedImage,
    this.prediction,
    this.errorMessage,
  });

  final SignRecognitionStatus status;
  final bool isModelReady;
  final File? selectedImage;
  final SignPrediction? prediction;
  final String? errorMessage;

  bool get isBusy =>
      status == SignRecognitionStatus.loadingModel ||
      status == SignRecognitionStatus.processing;

  SignRecognitionState copyWith({
    SignRecognitionStatus? status,
    bool? isModelReady,
    File? selectedImage,
    bool clearSelectedImage = false,
    SignPrediction? prediction,
    bool clearPrediction = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SignRecognitionState(
      status: status ?? this.status,
      isModelReady: isModelReady ?? this.isModelReady,
      selectedImage:
          clearSelectedImage ? null : selectedImage ?? this.selectedImage,
      prediction: clearPrediction ? null : prediction ?? this.prediction,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        isModelReady,
        selectedImage?.path,
        prediction,
        errorMessage,
      ];
}
