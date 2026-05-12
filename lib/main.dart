import 'package:flutter/material.dart';

import 'screens/initial_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  runApp(const ActeAlertApp());
}

class ActeAlertApp extends StatelessWidget {
  const ActeAlertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ActeAlert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: const InitialScreen(),
    );
  }
}