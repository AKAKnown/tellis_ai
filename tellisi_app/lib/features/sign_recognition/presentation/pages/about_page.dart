import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حول التطبيق')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // App Name and Logo Header
                const SizedBox(height: 12),
                const Icon(
                  Icons.info_outline_rounded,
                  size: 72,
                  color: Color(0xFF2457F5),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tellisi App',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172033),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'تطبيق التعرف على لغة الإشارة العربية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF5D6678),
                    height: 1.5,
                  ),
                ),

                // Project Description Section
                const SizedBox(height: 32),
                _InfoCard(
                  icon: Icons.description_outlined,
                  title: 'وصف المشروع',
                  content:
                      'تطبيق ذكاء اصطناعي متقدم للتعرف على لغة الإشارة العربية يستخدم نموذج MobileNetV2 المضبوط بدقة ومحول إلى صيغة TensorFlow Lite ومدمج في Flutter. يدعم التطبيق التعرف على الصور المرفوعة والتعرف الحي عبر الكاميرا.',
                ),

                // Student Section
                const SizedBox(height: 16),
                _InfoCard(
                  icon: Icons.person_outline_rounded,
                  title: 'الطالب',
                  content: 'محمد التليسي',
                ),

                // Supervision Section
                const SizedBox(height: 16),
                _InfoCard(
                  icon: Icons.supervised_user_circle_outlined,
                  title: 'الإشراف',
                  content: 'تحت إشراف الدكتور عبدالمولى الناجح',
                ),

                // Technical Stack Section
                const SizedBox(height: 16),
                _TechnicalStackCard(),

                // Model Performance Section
                const SizedBox(height: 16),
                _ModelPerformanceCard(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF2457F5), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172033),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5D6678),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TechnicalStackCard extends StatelessWidget {
  const _TechnicalStackCard();

  static const _technologies = [
    'Flutter',
    'Cubit',
    'DDD / Clean Architecture',
    'TensorFlow Lite',
    'MobileNetV2',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.build_outlined,
                  color: Color(0xFF2457F5),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'المكدس التقني',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172033),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tech in _technologies)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2457F5).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tech,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2457F5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModelPerformanceCard extends StatelessWidget {
  const _ModelPerformanceCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.assessment_outlined,
                  color: Color(0xFF2457F5),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'ملخص النموذج',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172033),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _PerformanceRow(
              label: 'المهمة',
              value: 'تصنيف حروف لغة الإشارة العربية',
            ),
            const SizedBox(height: 10),
            _PerformanceRow(label: 'الفئات', value: 'ألف، باء، جيم، سين، تاء'),
            const SizedBox(height: 10),
            _PerformanceRow(
              label: 'أفضل نموذج',
              value: 'MobileNetV2 المضبوط بدقة',
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'دقة الاختبار',
                    style: TextStyle(fontSize: 13, color: Color(0xFF5D6678)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '95.19%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceRow extends StatelessWidget {
  const _PerformanceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF5D6678)),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF172033),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
