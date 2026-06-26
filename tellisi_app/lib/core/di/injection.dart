import 'package:get_it/get_it.dart';

import '../../features/sign_recognition/data/datasources/tflite_sign_data_source.dart';
import '../../features/sign_recognition/data/repositories/sign_recognition_repository_impl.dart';
import '../../features/sign_recognition/domain/repositories/sign_recognition_repository.dart';
import '../../features/sign_recognition/domain/usecases/classify_camera_frame_usecase.dart';
import '../../features/sign_recognition/domain/usecases/classify_image_usecase.dart';
import '../../features/sign_recognition/domain/usecases/initialize_sign_model_usecase.dart';
import '../../features/sign_recognition/presentation/cubit/sign_recognition_cubit.dart';
import '../service/speech_service.dart';

final GetIt sl = GetIt.instance;

void configureDependencies() {
  sl
    ..registerLazySingleton<TFLiteSignDataSource>(TFLiteSignDataSource.new)
    ..registerLazySingleton<SignRecognitionRepository>(
      () => SignRecognitionRepositoryImpl(sl<TFLiteSignDataSource>()),
    )
    ..registerLazySingleton<InitializeSignModelUseCase>(
      () => InitializeSignModelUseCase(sl<SignRecognitionRepository>()),
    )
    ..registerLazySingleton<ClassifyImageUseCase>(
      () => ClassifyImageUseCase(sl<SignRecognitionRepository>()),
    )
    ..registerLazySingleton<ClassifyCameraFrameUseCase>(
      () => ClassifyCameraFrameUseCase(sl<SignRecognitionRepository>()),
    )
    ..registerFactory<SignRecognitionCubit>(
      () => SignRecognitionCubit(
        initializeSignModel: sl<InitializeSignModelUseCase>(),
        classifyImage: sl<ClassifyImageUseCase>(),
        classifyCameraFrame: sl<ClassifyCameraFrameUseCase>(),
      ),
    )..registerLazySingleton<SpeechService>(SpeechService.new);
}
