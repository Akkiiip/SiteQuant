import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/measurement_system.dart';
import 'widgets/measurement_system_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterError.onError =
      FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(const SiteQuantApp());
}

class SiteQuantApp extends StatelessWidget {
  const SiteQuantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SiteQuant',
      theme: AppTheme.lightTheme,
      home: const _MeasurementSetupGate(),
    );
  }
}

class _MeasurementSetupGate extends StatefulWidget {
  const _MeasurementSetupGate();

  @override
  State<_MeasurementSetupGate> createState() => _MeasurementSetupGateState();
}

class _MeasurementSetupGateState extends State<_MeasurementSetupGate> {
  var _loaded = false;

  @override
  void initState() {
    super.initState();
    MeasurementPreferences.load().whenComplete(() {
      if (mounted) setState(() => _loaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(body: SizedBox.expand());
    return ValueListenableBuilder<MeasurementSystem?>(
      valueListenable: MeasurementPreferences.system,
      builder: (context, system, _) {
        if (system == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && MeasurementPreferences.system.value == null) {
              showMeasurementSystemDialog(context, initial: MeasurementSystem.metric);
            }
          });
          return const Scaffold(body: SizedBox.expand());
        }
        return const HomeScreen();
      },
    );
  }
}
