import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/di/injection.dart';
import '../core/theme/app_theme.dart';
import '../features/sign_recognition/presentation/cubit/sign_recognition_cubit.dart';
import '../features/sign_recognition/presentation/pages/home_page.dart';

class SignBridgeApp extends StatelessWidget {
  const SignBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (_) => sl<SignRecognitionCubit>()..initializeModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ساين بريدج AI',
        theme: AppTheme.lightTheme,
        home: const HomePage(),
      ),
    );
  }
}
