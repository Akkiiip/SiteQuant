/// Validation shared by estimating services, independent of Flutter widgets.
class EstimateValidation {
  static double number(double value, String label, {bool allowZero = false}) {
    if (!value.isFinite || (allowZero ? value < 0 : value <= 0)) {
      throw ArgumentError(
        '$label must be a finite number ${allowZero ? "of zero or more" : "greater than zero"}.',
      );
    }
    return value;
  }

  static int count(int value, String label, {int? maximum}) {
    if (value <= 0 || (maximum != null && value > maximum)) {
      throw ArgumentError(
        '$label must be a whole number from 1 to ${maximum ?? "a valid positive count"}.',
      );
    }
    return value;
  }
}
