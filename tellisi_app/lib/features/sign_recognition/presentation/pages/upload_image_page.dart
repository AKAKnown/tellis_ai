import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/service/speech_service.dart';
import '../cubit/sign_recognition_cubit.dart';
import '../cubit/sign_recognition_state.dart';
import '../widgets/prediction_probabilities_card.dart';
import '../widgets/prediction_result_card.dart';

class UploadImagePage extends StatefulWidget {
  const UploadImagePage({super.key});

  @override
  State<UploadImagePage> createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  final ImagePicker _imagePicker = ImagePicker();
  late final SpeechService _speechService;

  @override
  void initState() {
    super.initState();
    _speechService = sl<SpeechService>();
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );

    if (!mounted || image == null) return;

    await context.read<SignRecognitionCubit>().classifySelectedImage(
      File(image.path),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التعرف على الصور')),
      body: SafeArea(
        child: BlocConsumer<SignRecognitionCubit, SignRecognitionState>(
          listenWhen: (previous, current) {
            final hasNewError =
                previous.errorMessage != current.errorMessage &&
                current.errorMessage != null;

            final hasNewPrediction =
                previous.prediction != current.prediction &&
                current.prediction != null;

            return hasNewError || hasNewPrediction;
          },
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }

            final prediction = state.prediction;

            if (prediction != null) {
              _speechService.speakLetter(prediction.arabicLabel);
            }
          },
          builder: (context, state) {
            final selectedImage = state.selectedImage;
            final isProcessing =
                state.status == SignRecognitionStatus.processing;

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text(
                  'اختر صورة واضحة لإحدى إشارات اليد العربية المدعومة.',
                  style: TextStyle(color: Color(0xFF5D6678), height: 1.5),
                ),
                const SizedBox(height: 20),
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF3FF),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFD9E2FF)),
                    ),
                    child: selectedImage == null
                        ? const _EmptyImageState()
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(selectedImage, fit: BoxFit.cover),
                              if (isProcessing)
                                ColoredBox(
                                  color: Colors.black45,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'جاري تحليل الصورة…',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: isProcessing ? null : _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('اختر صورة من المعرض'),
                ),
                if (state.prediction != null) ...[
                  const SizedBox(height: 22),
                  PredictionResultCard(prediction: state.prediction!),
                  const SizedBox(height: 16),

                  PredictionProbabilitiesCard(
                    prediction: state.prediction!,
                    onSpeak: () {
                      _speechService.speakLetter(
                        _arabicLetterFor(state.prediction!.label),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: isProcessing
                      ? null
                      : () => context
                            .read<SignRecognitionCubit>()
                            .clearPrediction(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة التعيين واختيار صورة أخرى'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _arabicLetterFor(String label) {
    const labels = {
      'Alef': 'ألف',
      'Beh': 'باء',
      'Jeem': 'جيم',
      'Seen': 'سين',
      'Teh': 'تاء',
    };

    return labels[label] ?? label;
  }
}

class _EmptyImageState extends StatelessWidget {
  const _EmptyImageState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 66,
            color: Color(0xFF2457F5),
          ),
          SizedBox(height: 14),
          Text(
            'لم يتم اختيار صورة بعد',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF172033),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'حمّل صورة لبدء التعرف.',
            style: TextStyle(color: Color(0xFF5D6678)),
          ),
        ],
      ),
    );
  }
}
