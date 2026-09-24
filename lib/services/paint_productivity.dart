import '../models/productivity_standard.dart';
import 'estimate_validation.dart';

class PaintProductivity {
  PaintProductivity._();
  static ProductivityStandard siteSpecific({
    required double painterDaysPer10M2,
    required double helperDaysPer10M2,
    String name = 'Editable Paint reference',
    String basis =
        'Editable labour coefficients per 10 m² for the specified operation.',
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
      name: name,
      basis: basis,
      daysPerBaseQuantity: {
        LabourRole.painter: painterDaysPer10M2,
        LabourRole.helper: helperDaysPer10M2,
      },
      maximumCrewPerRole: 5,
    );
  }
}
