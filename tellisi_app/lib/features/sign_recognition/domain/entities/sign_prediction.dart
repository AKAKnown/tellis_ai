import 'package:equatable/equatable.dart';

class SignPrediction extends Equatable {
  const SignPrediction({
    required this.label,
    required this.confidence,
    required this.probabilities,
  });

  final String label;
  final double confidence;
  final List<double> probabilities;

  bool get isHighConfidence => confidence >= 0.80;

  String get arabicLabel {
    const labels = <String, String>{
      'Alef': 'ألف',
      'Beh': 'باء',
      'Jeem': 'جيم',
      'Seen': 'سين',
      'Teh': 'تاء',
    };

    return labels[label] ?? label;
  }

  @override
  List<Object> get props => [label, confidence, probabilities];
}
