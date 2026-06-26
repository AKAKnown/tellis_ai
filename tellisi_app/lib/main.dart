import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'core/di/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const SignBridgeApp());
}
