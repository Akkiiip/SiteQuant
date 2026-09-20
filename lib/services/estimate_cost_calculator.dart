import 'estimate_validation.dart';

class EstimateCostCalculator {
  static double lineCost(double quantity, double rate, String label) {
    EstimateValidation.number(quantity, '$label quantity', allowZero: true);
    EstimateValidation.number(rate, '$label rate');
    return EstimateValidation.number(
      quantity * rate,
      '$label cost',
      allowZero: true,
    );
  }

  static double total(Iterable<double> costs) {
    var sum = 0.0;
    for (final cost in costs) {
      sum += EstimateValidation.number(cost, 'Cost', allowZero: true);
    }
    return EstimateValidation.number(sum, 'Total cost', allowZero: true);
  }

  /// A fully deducted area has no meaningful unit cost.
  static double? perUnit(double cost, double quantity) {
    EstimateValidation.number(cost, 'Total cost', allowZero: true);
    EstimateValidation.number(quantity, 'Net quantity', allowZero: true);
    return quantity == 0
        ? null
        : EstimateValidation.number(
            cost / quantity,
            'Unit cost',
            allowZero: true,
          );
  }
}
