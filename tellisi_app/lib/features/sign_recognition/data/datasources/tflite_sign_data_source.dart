import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../domain/entities/sign_prediction.dart';

class TFLiteSignDataSource {
  static const _modelPath = 'assets/model/signbridge_mobilenet.tflite';
  static const _labelsPath = 'assets/model/labels.txt';
  static const inputSize = 224;

  Interpreter? _interpreter;
  List<String> _labels = const [];

  bool get isInitialized => _interpreter != null;

  Future<void> initialize() async {
    if (isInitialized) return;

    _interpreter = await Interpreter.fromAsset(_modelPath);

    final labelsRaw = await rootBundle.loadString(_labelsPath);
    _labels = labelsRaw
        .split(RegExp(r'\r?\n'))
        .map((label) => label.trim())
        .where((label) => label.isNotEmpty)
        .toList(growable: false);

    _validateConfiguration();
  }

  Future<SignPrediction> predictFromFile(File imageFile) async {
    _ensureInitialized();

    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      throw const FormatException('The selected file is not a supported image.');
    }

    final oriented = img.bakeOrientation(decoded);
    final resized = img.copyResize(
      oriented,
      width: inputSize,
      height: inputSize,
    );

    return _runInference(_imageToInput(resized));
  }

  /// Converts each camera frame directly to the model tensor.
  /// Android commonly supplies YUV420; iOS supplies BGRA8888.
  Future<SignPrediction> predictFromCameraImage(
    CameraImage cameraImage, {
    required int rotationDegrees,
  }) async {
    _ensureInitialized();

    final normalizedRotation = _normalizeRotation(rotationDegrees);
    final input = _cameraImageToInput(cameraImage, normalizedRotation);

    return _runInference(input);
  }

  List<List<List<List<double>>>> _imageToInput(img.Image image) {
    return List<List<List<List<double>>>>.generate(
      1,
      (_) => List<List<List<double>>>.generate(
        inputSize,
        (y) => List<List<double>>.generate(
          inputSize,
          (x) {
            final pixel = image.getPixel(x, y);
            return <double>[
              _mobileNetNormalize(pixel.r.toDouble()),
              _mobileNetNormalize(pixel.g.toDouble()),
              _mobileNetNormalize(pixel.b.toDouble()),
            ];
          },
          growable: false,
        ),
        growable: false,
      ),
      growable: false,
    );
  }

  List<List<List<List<double>>>> _cameraImageToInput(
    CameraImage image,
    int rotationDegrees,
  ) {
    final isQuarterTurn = rotationDegrees == 90 || rotationDegrees == 270;
    final rotatedWidth = isQuarterTurn ? image.height : image.width;
    final rotatedHeight = isQuarterTurn ? image.width : image.height;

    return List<List<List<List<double>>>>.generate(
      1,
      (_) => List<List<List<double>>>.generate(
        inputSize,
        (outputY) => List<List<double>>.generate(
          inputSize,
          (outputX) {
            final rotatedX = _scaleCoordinate(
              outputX,
              inputSize,
              rotatedWidth,
            );
            final rotatedY = _scaleCoordinate(
              outputY,
              inputSize,
              rotatedHeight,
            );

            final source = _mapRotatedToSource(
              rotatedX: rotatedX,
              rotatedY: rotatedY,
              imageWidth: image.width,
              imageHeight: image.height,
              rotationDegrees: rotationDegrees,
            );

            final rgb = _readCameraRgb(image, source.x, source.y);

            return <double>[
              _mobileNetNormalize(rgb.r),
              _mobileNetNormalize(rgb.g),
              _mobileNetNormalize(rgb.b),
            ];
          },
          growable: false,
        ),
        growable: false,
      ),
      growable: false,
    );
  }

  SignPrediction _runInference(List<List<List<List<double>>>> input) {
    final output = List<List<double>>.generate(
      1,
      (_) => List<double>.filled(_labels.length, 0),
      growable: false,
    );

    _interpreter!.run(input, output);

    final probabilities = List<double>.from(output.first);
    var bestIndex = 0;
    var bestConfidence = probabilities.first;

    for (var index = 1; index < probabilities.length; index++) {
      if (probabilities[index] > bestConfidence) {
        bestConfidence = probabilities[index];
        bestIndex = index;
      }
    }

    return SignPrediction(
      label: _labels[bestIndex],
      confidence: _clampDouble(bestConfidence, 0, 1),
      probabilities: probabilities,
    );
  }

  _Rgb _readCameraRgb(CameraImage image, int x, int y) {
    final format = image.format.group;

    if (format == ImageFormatGroup.bgra8888) {
      final plane = image.planes.first;
      final index = y * plane.bytesPerRow + x * 4;
      final bytes = plane.bytes;

      return _Rgb(
        r: bytes[index + 2].toDouble(),
        g: bytes[index + 1].toDouble(),
        b: bytes[index].toDouble(),
      );
    }

    if (format == ImageFormatGroup.yuv420) {
      final yPlane = image.planes[0];
      final uPlane = image.planes[1];
      final vPlane = image.planes[2];

      final yIndex = y * yPlane.bytesPerRow +
          x * (yPlane.bytesPerPixel ?? 1);
      final uvX = x ~/ 2;
      final uvY = y ~/ 2;
      final uIndex = uvY * uPlane.bytesPerRow +
          uvX * (uPlane.bytesPerPixel ?? 1);
      final vIndex = uvY * vPlane.bytesPerRow +
          uvX * (vPlane.bytesPerPixel ?? 1);

      final yValue = yPlane.bytes[yIndex].toDouble();
      final uValue = uPlane.bytes[uIndex].toDouble() - 128.0;
      final vValue = vPlane.bytes[vIndex].toDouble() - 128.0;

      return _Rgb(
        r: _clampDouble(yValue + 1.402 * vValue, 0, 255),
        g: _clampDouble(
          yValue - 0.344136 * uValue - 0.714136 * vValue,
          0,
          255,
        ),
        b: _clampDouble(yValue + 1.772 * uValue, 0, 255),
      );
    }

    throw UnsupportedError(
      'Unsupported camera image format: ${image.format.group}. '
      'Use Android YUV420 or iOS BGRA8888.',
    );
  }

  _SourceCoordinate _mapRotatedToSource({
    required int rotatedX,
    required int rotatedY,
    required int imageWidth,
    required int imageHeight,
    required int rotationDegrees,
  }) {
    switch (rotationDegrees) {
      case 90:
        return _SourceCoordinate(
          x: rotatedY,
          y: imageHeight - 1 - rotatedX,
        );
      case 180:
        return _SourceCoordinate(
          x: imageWidth - 1 - rotatedX,
          y: imageHeight - 1 - rotatedY,
        );
      case 270:
        return _SourceCoordinate(
          x: imageWidth - 1 - rotatedY,
          y: rotatedX,
        );
      case 0:
      default:
        return _SourceCoordinate(x: rotatedX, y: rotatedY);
    }
  }

  int _scaleCoordinate(int value, int outputSize, int sourceSize) {
    final coordinate = (value * sourceSize / outputSize).floor();
    return coordinate >= sourceSize ? sourceSize - 1 : coordinate;
  }

  int _normalizeRotation(int degrees) {
    final normalized = degrees % 360;
    if (normalized == 0 ||
        normalized == 90 ||
        normalized == 180 ||
        normalized == 270) {
      return normalized;
    }
    return 0;
  }

  double _mobileNetNormalize(double value) => (value / 127.5) - 1.0;

  double _clampDouble(double value, double minimum, double maximum) {
    if (value < minimum) return minimum;
    if (value > maximum) return maximum;
    return value;
  }

  void _validateConfiguration() {
    final inputShape = _interpreter!.getInputTensor(0).shape;
    final outputShape = _interpreter!.getOutputTensor(0).shape;

    const expectedInput = <int>[1, inputSize, inputSize, 3];
    final expectedOutput = <int>[1, _labels.length];

    if (!_hasSameValues(inputShape, expectedInput)) {
      throw StateError(
        'Unexpected model input shape: $inputShape. Expected: $expectedInput.',
      );
    }

    if (!_hasSameValues(outputShape, expectedOutput)) {
      throw StateError(
        'Unexpected model output shape: $outputShape. '
        'Expected: $expectedOutput.',
      );
    }
  }

  bool _hasSameValues(List<int> first, List<int> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }

  void _ensureInitialized() {
    if (!isInitialized) {
      throw StateError('Call initialize() before running a prediction.');
    }
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}

class _Rgb {
  const _Rgb({required this.r, required this.g, required this.b});

  final double r;
  final double g;
  final double b;
}

class _SourceCoordinate {
  const _SourceCoordinate({required this.x, required this.y});

  final int x;
  final int y;
}
