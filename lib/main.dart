import 'package:flutter/material.dart';

import 'app.dart';
import 'injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = await AppContainer.bootstrap();
  runApp(ExpenseManagerApp(container: container));
}
