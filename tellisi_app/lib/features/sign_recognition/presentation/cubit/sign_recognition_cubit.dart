import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/classify_camera_frame_usecase.dart';
import '../../domain/usecases/classify_image_usecase.dart';
import '../../domain/usecases/initialize_sign_model_usecase.dart';
import 'sign_recognition_state.dart';

class SignRecognitionCubit extends Cubit<SignRecognitionState> {
  SignRecognitionCubit({
    required InitializeSignModelUseCase initializeSignModel,
    required ClassifyImageUseCase classifyImage,
    required ClassifyCameraFrameUseCase classifyCameraFrame,
  })  : _initializeSignModel = initializeSignModel,
        _classifyImage = classifyImage,
        _classifyCameraFrame = classifyCameraFrame,
        super(const SignRecognitionState());

  final InitializeSignModelUseCase _initializeSignModel;
  final ClassifyImageUseCase _classifyImage;
  final ClassifyCameraFrameUseCase _classifyCameraFrame;

  Future<void> initializeModel() async {
    emit(
      state.copyWith(
        status: SignRecognitionStatus.loadingModel,
        clearError: true,
      ),
    );

    try {
      await _initializeSignModel();
      emit(
        state.copyWith(
          status: SignRecognitionStatus.ready,
          isModelReady: true,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: SignRecognitionStatus.failure,
          isModelReady: false,
          errorMessage: 'Could not load the AI model: $error',
        ),
      );
    }
  }

  Future<void> classifySelectedImage(File imageFile) async {
    if (!state.isModelReady) return;

    emit(
      state.copyWith(
        status: SignRecognitionStatus.processing,
        selectedImage: imageFile,
        clearPrediction: true,
        clearError: true,
      ),
    );

    try {
      final prediction = await _classifyImage(imageFile);
      emit(
        state.copyWith(
          status: SignRecognitionStatus.success,
          prediction: prediction,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: SignRecognitionStatus.failure,
          errorMessage: 'Could not analyze this image: $error',
        ),
      );
    }
  }

  Future<void> classifyLiveFrame(
    CameraImage cameraImage, {
    required int rotationDegrees,
  }) async {
    if (!state.isModelReady) return;

    try {
      final prediction = await _classifyCameraFrame(
        cameraImage,
        rotationDegrees: rotationDegrees,
      );
      emit(
        state.copyWith(
          status: SignRecognitionStatus.success,
          prediction: prediction,
          clearError: true,
        ),
      );
    } catch (error) {
      // A frame can be dropped or unsupported on a particular device.
      // We keep the latest successful result visible instead of flashing errors.
    }
  }

  void clearPrediction() {
    emit(
      state.copyWith(
        status: state.isModelReady
            ? SignRecognitionStatus.ready
            : SignRecognitionStatus.initial,
        clearSelectedImage: true,
        clearPrediction: true,
        clearError: true,
      ),
    );
  }
}
