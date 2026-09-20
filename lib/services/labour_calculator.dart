import '../models/productivity_standard.dart';
import 'estimate_cost_calculator.dart';

class LabourCalculator {
  static LabourEstimate calculate({
    required ProductivityEstimate productivity,
    required Map<LabourRole, double> dailyWages,
  }) {
    final costs = <LabourRole, double>{};
    if (dailyWages.length != productivity.mandays.length) {
      throw ArgumentError('Enter a daily wage for every labour role.');
    }
    for (final entry in productivity.mandays.entries) {
      costs[entry.key] = EstimateCostCalculator.lineCost(
        entry.value,
        dailyWages[entry.key] ?? 0,
        '${entry.key.label} labour',
      );
    }
    return LabourEstimate(
      dailyWages: dailyWages,
      costs: costs,
      totalCost: EstimateCostCalculator.total(costs.values),
    );
  }
}
