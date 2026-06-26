import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/entities/sign_prediction.dart';

class PredictionProbabilitiesCard extends StatelessWidget {
  final SignPrediction prediction;
  final VoidCallback onSpeak;

  const PredictionProbabilitiesCard({
    super.key,
    required this.prediction,
    required this.onSpeak,
  });

  static const _labels = <_LabelInfo>[
    _LabelInfo(english: 'Alef', arabic: 'ألف'),
    _LabelInfo(english: 'Beh', arabic: 'باء'),
    _LabelInfo(english: 'Jeem', arabic: 'جيم'),
    _LabelInfo(english: 'Seen', arabic: 'سين'),
    _LabelInfo(english: 'Teh', arabic: 'تاء'),
  ];

  @override
  Widget build(BuildContext context) {
    final count = min(prediction.probabilities.length, _labels.length);

    final scores = List<_PredictionScore>.generate(
      count,
      (index) => _PredictionScore(
        label: _labels[index],
        probability: prediction.probabilities[index],
      ),
    )..sort((first, second) => second.probability.compareTo(first.probability));

    final topLabel = _labels.firstWhere(
      (item) => item.english == prediction.label,
      orElse: () =>
          _LabelInfo(english: prediction.label, arabic: prediction.label),
    );

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'جميع احتمالات التوقع',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 18),

            ...scores.map((score) => _ProbabilityRow(score: score)),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onSpeak,
                icon: const Icon(Icons.volume_up_rounded),
                label: Text('استمع إلى: ${topLabel.arabic}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProbabilityRow extends StatelessWidget {
  final _PredictionScore score;

  const _ProbabilityRow({required this.score});

  @override
  Widget build(BuildContext context) {
    final probability = score.probability < 0
        ? 0.0
        : score.probability > 1
        ? 1.0
        : score.probability;

    final percentage = probability * 100;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  score.label.arabic,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(value: probability, minHeight: 9),
          ),
        ],
      ),
    );
  }
}

class _PredictionScore {
  final _LabelInfo label;
  final double probability;

  const _PredictionScore({required this.label, required this.probability});
}

class _LabelInfo {
  final String english;
  final String arabic;

  const _LabelInfo({required this.english, required this.arabic});
}
