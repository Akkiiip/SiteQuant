import '../models/opening_deduction.dart';
import 'estimate_validation.dart';

class OpeningCalculator {
  static double grossArea({
    required double lengthMetres,
    required double heightMetres,
    int surfaces = 1,
  }) {
    EstimateValidation.number(lengthMetres, 'Length');
    EstimateValidation.number(heightMetres, 'Height / width');
    EstimateValidation.count(surfaces, 'Number of surfaces');
    return EstimateValidation.number(
      lengthMetres * heightMetres * surfaces,
      'Gross area',
    );
  }

  static double openingArea(OpeningDeduction opening) {
    if (opening.name.trim().isEmpty) {
      throw ArgumentError('Enter an opening type or name.');
    }
    EstimateValidation.number(opening.widthMetres, '${opening.name}: width');
    EstimateValidation.number(opening.heightMetres, '${opening.name}: height');
    EstimateValidation.count(opening.quantity, '${opening.name}: quantity');
    return EstimateValidation.number(
      opening.widthMetres * opening.heightMetres * opening.quantity,
      '${opening.name}: area',
    );
  }

  /// Quantities cover ALL surfaces, not openings per wall.
  static AreaTakeoff calculate({
    required double grossArea,
    List<OpeningDeduction> openings = const [],
  }) {
    EstimateValidation.number(grossArea, 'Gross area');
    final deductions = openings.fold<double>(
      0,
      (sum, opening) => sum + openingArea(opening),
    );
    EstimateValidation.number(
      deductions,
      'Opening deductions',
      allowZero: true,
    );
    if (deductions > grossArea) {
      throw ArgumentError('Opening deductions cannot exceed the gross area.');
    }
    return AreaTakeoff(
      grossArea: grossArea,
      deductionArea: deductions,
      netArea: grossArea - deductions,
      openings: openings,
    );
  }
}
