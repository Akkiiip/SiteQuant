import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MeasurementSystem { metric, imperial }

extension MeasurementSystemDetails on MeasurementSystem {
  String get label => this == MeasurementSystem.metric ? 'Metric' : 'Imperial';
  String get lengthUnit => this == MeasurementSystem.metric ? 'm' : 'ft';
  String get areaUnit => this == MeasurementSystem.metric ? 'm²' : 'ft²';
  String get volumeUnit => this == MeasurementSystem.metric ? 'm³' : 'ft³';
}

class MeasurementPreferences {
  MeasurementPreferences._();

  static const _key = 'measurement_system';
  static final ValueNotifier<MeasurementSystem?> system = ValueNotifier(null);

  static Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_key);
    system.value = saved == null
        ? null
        : MeasurementSystem.values.firstWhere(
            (value) => value.name == saved,
            orElse: () => MeasurementSystem.metric,
          );
  }

  static Future<void> setSystem(MeasurementSystem value) async {
    system.value = value;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, value.name);
  }

  static double toMetres(double value, MeasurementSystem system) =>
      system == MeasurementSystem.metric ? value : value * 0.3048;

  static double fromMetres(double value, MeasurementSystem system) =>
      system == MeasurementSystem.metric ? value : value / 0.3048;

  static double fromSquareMetres(double value, MeasurementSystem system) =>
      system == MeasurementSystem.metric ? value : value * 10.7639104167;

  static double fromCubicMetres(double value, MeasurementSystem system) =>
      system == MeasurementSystem.metric ? value : value * 35.3146667215;

  static double toCubicMetres(double value, MeasurementSystem system) =>
      system == MeasurementSystem.metric ? value : value / 35.3146667215;
}
