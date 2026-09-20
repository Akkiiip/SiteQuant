import '../models/productivity_standard.dart';
import 'estimate_validation.dart';

class PaintProductivity {
  PaintProductivity._();

  /// Paint productivity depends on the product, substrate, preparation,
  /// application method and access. SiteQuant intentionally has no default.
  static ProductivityStandard siteSpecific({
    required double painterDaysPer10M2,
    required double helperDaysPer10M2,
  }) {
    EstimateValidation.number(
      painterDaysPer10M2,
      'Painter productivity coefficient',
    );
    EstimateValidation.number(
      helperDaysPer10M2,
      'Helper productivity coefficient',
    );
    return ProductivityStandard(
      name: 'Site-specific productivity',
      basis:
          'User-entered labour coefficients per 10 m². Confirm for the '
          'product, substrate, preparation, application method and access.',
      daysPerBaseQuantity: {
        LabourRole.painter: painterDaysPer10M2,
        LabourRole.helper: helperDaysPer10M2,
      },
    );
  }
}
