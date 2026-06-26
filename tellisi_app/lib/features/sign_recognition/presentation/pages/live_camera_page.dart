import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/service/speech_service.dart';
import '../cubit/sign_recognition_cubit.dart';
import '../cubit/sign_recognition_state.dart';
import '../widgets/prediction_result_card.dart';

class LiveCameraPage extends StatefulWidget {
  const LiveCameraPage({super.key});

  @override
  State<LiveCameraPage> createState() => _LiveCameraPageState();
}

class _LiveCameraPageState extends State<LiveCameraPage>
    with WidgetsBindingObserver {
  late final SpeechService _speechService;

  String? _candidateLabel;
  int _sameLabelFrames = 0;

  String? _lastSpokenLabel;
  DateTime _lastSpokenAt = DateTime.fromMillisecondsSinceEpoch(0);

  static const _speechCooldown = Duration(seconds: 3);
  CameraController? _cameraController;
  CameraDescription? _cameraDescription;
  String? _cameraError;
  bool _isProcessingFrame = false;
  DateTime _lastInferenceAt = DateTime.fromMillisecondsSinceEpoch(0);

  static const _inferenceInterval = Duration(milliseconds: 650);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _speechService = sl<SpeechService>();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw StateError('No camera was found on this device.');
      }

      final backCamera = cameras.where(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      _cameraDescription = backCamera.isNotEmpty
          ? backCamera.first
          : cameras.first;

      final controller = CameraController(
        _cameraDescription!,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.yuv420
            : ImageFormatGroup.bgra8888,
      );

      _cameraController = controller;
      await controller.initialize();
      await controller.startImageStream(_onCameraImage);

      if (!mounted) return;
      setState(() => _cameraError = null);
    } on CameraException catch (error) {
      if (!mounted) return;
      setState(
        () => _cameraError = 'Camera error: ${error.description ?? error.code}',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _cameraError = 'Could not start the camera: $error');
    }
  }

  void _onCameraImage(CameraImage image) {
    if (!mounted || _isProcessingFrame) return;

    final now = DateTime.now();
    if (now.difference(_lastInferenceAt) < _inferenceInterval) return;

    _lastInferenceAt = now;
    _isProcessingFrame = true;

    context
        .read<SignRecognitionCubit>()
        .classifyLiveFrame(
          image,
          rotationDegrees: _cameraDescription?.sensorOrientation ?? 0,
        )
        .whenComplete(() => _isProcessingFrame = false);
  }

  Future<void> _releaseCamera() async {
    final controller = _cameraController;
    _cameraController = null;

    if (controller == null) return;

    if (controller.value.isStreamingImages) {
      await controller.stopImageStream();
    }

    await controller.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _releaseCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _releaseCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التعرف بالكاميرا مباشرة')),
      body: SafeArea(
        child: BlocListener<SignRecognitionCubit, SignRecognitionState>(
          listenWhen: (previous, current) =>
              previous.prediction != current.prediction &&
              current.prediction != null,
          listener: (context, state) {
            final prediction = state.prediction!;

            if (!prediction.isHighConfidence) {
              _candidateLabel = null;
              _sameLabelFrames = 0;
              return;
            }

            if (_candidateLabel == prediction.label) {
              _sameLabelFrames++;
            } else {
              _candidateLabel = prediction.label;
              _sameLabelFrames = 1;
            }

            if (_sameLabelFrames < 2) return;

            final now = DateTime.now();

            final sameLetterRecently =
                _lastSpokenLabel == prediction.label &&
                now.difference(_lastSpokenAt) < _speechCooldown;

            if (sameLetterRecently) return;

            _lastSpokenLabel = prediction.label;
            _lastSpokenAt = now;

            _speechService.speakLetter(prediction.arabicLabel);
          },

          child: BlocBuilder<SignRecognitionCubit, SignRecognitionState>(
            builder: (context, state) {
              final prediction = state.prediction;
              final borderColor = prediction == null
                  ? const Color(0xFFCCD4E0)
                  : prediction.isHighConfidence
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFF59E0B);

              return Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _CameraPreviewBox(
                        controller: _cameraController,
                        error: _cameraError,
                        borderColor: borderColor,
                        prediction: prediction,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: prediction == null
                        ? const _WaitingForSignCard()
                        : PredictionResultCard(
                            prediction: prediction,
                            compact: true,
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CameraPreviewBox extends StatelessWidget {
  const _CameraPreviewBox({
    required this.controller,
    required this.error,
    required this.borderColor,
    required this.prediction,
  });

  final CameraController? controller;
  final String? error;
  final Color borderColor;
  final dynamic prediction;

  @override
  Widget build(BuildContext context) {
    final ready = controller?.value.isInitialized ?? false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF172033),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor, width: 4),
      ),
      child: error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
          : !ready
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(controller!),
                const Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: _LiveBadge(),
                ),
                if (prediction != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: _PredictionOverlay(prediction: prediction),
                  ),
              ],
            ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(99),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: Color(0xFFEF4444), size: 10),
            SizedBox(width: 7),
            Text(
              'مباشر • تحليل كل ~0.6 ثانية',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PredictionOverlay extends StatelessWidget {
  const _PredictionOverlay({required this.prediction});

  final dynamic prediction;

  @override
  Widget build(BuildContext context) {
    final strong = prediction.isHighConfidence as bool;
    final color = strong ? const Color(0xFF16A34A) : const Color(0xFFF59E0B);
    final confidence = ((prediction.confidence as double) * 100)
        .toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        '${prediction.arabicLabel} • ${prediction.label}  ($confidence%)',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _WaitingForSignCard extends StatelessWidget {
  const _WaitingForSignCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FA),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          Icon(Icons.visibility_outlined, color: Color(0xFF2457F5)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'ضع إشارة يدوية مدعومة بوضوح داخل إطار الكاميرا.',
              style: TextStyle(color: Color(0xFF334155), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
