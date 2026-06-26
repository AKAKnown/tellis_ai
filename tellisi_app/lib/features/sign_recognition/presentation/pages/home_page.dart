import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/sign_recognition_cubit.dart';
import '../cubit/sign_recognition_state.dart';
import 'about_page.dart';
import 'live_camera_page.dart';
import 'upload_image_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تطبيق التليسي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, size: 35),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const AboutPage())),
            tooltip: 'حول التطبيق',
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<SignRecognitionCubit, SignRecognitionState>(
          builder: (context, state) {
            final modelReady = state.isModelReady;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 12),
                    Image.asset(
                      'assets/images/logo_sign.png',
                      height: 120,
                      width: 80,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'التعرف على الإشارات العربية',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172033),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'تعرف على الألف والباء والجيم والسين والتاء باستخدام نموذج MobileNetV2 على الجهاز.',
                      textAlign: TextAlign.center,
                      style: TextStyle(height: 1.5, color: Color(0xFF5D6678)),
                    ),
                    const SizedBox(height: 28),
                    _ModelStatusBanner(state: state),
                    const SizedBox(height: 20),
                    _RecognitionModeCard(
                      icon: Icons.image_outlined,
                      title: 'تحميل صورة',
                      subtitle:
                          'اختر صورة لإشارة يدوية من المعرض واحصل على تنبؤ واحد.',
                      enabled: modelReady,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const UploadImagePage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _RecognitionModeCard(
                      icon: Icons.videocam_outlined,
                      title: 'الكاميرا الحية',
                      subtitle:
                          'استخدم الكاميرا الخلفية واحصل على التنبؤات بشكل مستمر.',
                      enabled: modelReady,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const LiveCameraPage(),
                        ),
                      ),
                    ),
                    if (state.status == SignRecognitionStatus.failure) ...[
                      const SizedBox(height: 18),
                      Text(
                        state.errorMessage ?? 'حدث خطأ غير معروف',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFDC2626)),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ModelStatusBanner extends StatelessWidget {
  const _ModelStatusBanner({required this.state});

  final SignRecognitionState state;

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status == SignRecognitionStatus.loadingModel;
    final isReady = state.isModelReady;
    final color = isReady
        ? const Color(0xFF16A34A)
        : isLoading
        ? const Color(0xFF2457F5)
        : const Color(0xFFDC2626);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          if (isLoading)
            const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else
            Icon(
              isReady ? Icons.verified_rounded : Icons.error_outline_rounded,
              color: color,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isReady
                  ? 'نموذج الذكاء الاصطناعي جاهز على هذا الجهاز.'
                  : isLoading
                  ? 'جارٍ تحميل نموذج TensorFlow Lite…'
                  : 'تعذر تحميل النموذج.',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecognitionModeCard extends StatelessWidget {
  const _RecognitionModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(24),
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2457F5).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: const Color(0xFF2457F5), size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF172033),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF5D6678),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
