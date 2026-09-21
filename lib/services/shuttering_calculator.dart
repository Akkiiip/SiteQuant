import '../models/productivity_standard.dart';
import '../models/shuttering_result.dart';
import 'estimate_cost_calculator.dart';
import 'estimate_validation.dart';
import 'labour_calculator.dart';
import 'productivity_calculator.dart';

class ShutteringCalculator {
  static ShutteringResult calculate({
    required ShutteringType type,
    required double length,
    required double width,
    required double height,
    required int quantity,
    int wallSides = 2,
    required double wastagePercent,
    required double materialRate,
    required double carpenterDaysPer10M2,
    required double helperDaysPer10M2,
    required Map<LabourRole, int> crew,
    required Map<LabourRole, double> dailyWages,
  }) {
    EstimateValidation.number(length, 'Length');
    EstimateValidation.number(width, 'Width');
    EstimateValidation.number(height, 'Height');
    EstimateValidation.count(quantity, 'Quantity');
    EstimateValidation.number(
      wastagePercent,
      'Material wastage',
      allowZero: true,
    );
    if (type == ShutteringType.wall && wallSides != 1 && wallSides != 2) {
      throw ArgumentError('Wall shuttering sides must be one or two.');
    }
    final perItem = switch (type) {
      ShutteringType.column => 2 * (length + width) * height,
      ShutteringType.beam => (2 * height + width) * length,
      ShutteringType.footing => 2 * (length + width) * height,
      ShutteringType.wall => wallSides * length * height,
      ShutteringType.slab => length * width,
    };
    final contactArea = perItem * quantity;
    final panelArea = contactArea * (1 + wastagePercent / 100);
    final materialCost = EstimateCostCalculator.lineCost(
      panelArea,
      materialRate,
      'Shuttering material',
    );
    final productivity = ProductivityCalculator.calculate(
      quantity: contactArea,
      standard: ProductivityStandard(
        name: 'Reference shuttering productivity',
        basis:
            'Editable reference estimate; not a universal productivity standard.',
        daysPerBaseQuantity: {
          LabourRole.carpenter: carpenterDaysPer10M2,
          LabourRole.helper: helperDaysPer10M2,
        },
      ),
      crew: crew,
    );
    final labour = LabourCalculator.calculate(
      productivity: productivity,
      dailyWages: dailyWages,
    );
    final total = EstimateCostCalculator.total([
      materialCost,
      labour.totalCost,
    ]);
    return ShutteringResult(
      type: type,
      length: length,
      width: width,
      height: height,
      quantity: quantity,
      wallSides: wallSides,
      contactArea: contactArea,
      wastagePercent: wastagePercent,
      panelArea: panelArea,
      materialRate: materialRate,
      materialCost: materialCost,
      productivity: productivity,
      labour: labour,
      totalCost: total,
    );
  }
}
