import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:site_quant/main.dart';
import 'package:site_quant/services/measurement_system.dart';

void main() {
  testWidgets('opens the concrete calculator from the dashboard', (
    tester,
  ) async {
    // The app loads this preference asynchronously before showing its dashboard.
    SharedPreferences.setMockInitialValues({'measurement_system': 'metric'});
    MeasurementPreferences.system.value = MeasurementSystem.metric;
    addTearDown(() => MeasurementPreferences.system.value = null);
    await tester.pumpWidget(const SiteQuantApp());
    await tester.pumpAndSettle();

    expect(find.text('Civil Engineering Toolkit'), findsOneWidget);
    await tester.tap(find.text('Concrete'));
    await tester.pumpAndSettle();

    expect(find.text('Concrete Calculator'), findsOneWidget);
    expect(find.text('Custom Volume'), findsWidgets);
    expect(find.text('Volume'), findsOneWidget);
    expect(find.text('Wall'), findsNothing);
  });
}
