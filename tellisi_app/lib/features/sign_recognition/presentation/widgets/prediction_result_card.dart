import 'package:flutter/material.dart';

import '../../domain/entities/sign_prediction.dart';

class PredictionResultCard extends StatelessWidget {
  const PredictionResultCard({
    required this.prediction,
    this.compact = false,
    super.key,
  });

  final SignPrediction prediction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isStrong = prediction.isHighConfidence;
    final color = isStrong ? const Color(0xFF16A34A) : const Color(0xFFF59E0B);
    final icon = isStrong ? Icons.check_circle_rounded : Icons.info_rounded;
    final confidence = (prediction.confidence * 100).toStringAsFixed(1);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(compact ? 16 : 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.55), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: compact ? 34 : 42),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isStrong ? 'تم التعرف على الإشارة' : 'نتيجة بثقة منخفضة',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 13 : 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  prediction.arabicLabel,
                  style: TextStyle(
                    color: const Color(0xFF172033),
                    fontWeight: FontWeight.w800,
                    fontSize: compact ? 19 : 23,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'نسبة الثقة: $confidence%',
                  style: const TextStyle(color: Color(0xFF5D6678)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
