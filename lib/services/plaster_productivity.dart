import '../models/productivity_standard.dart';
import 'estimate_validation.dart';

class PlasterProductivity {
  // User-selected estimating benchmarks. CPWD DAR 2014 Vol II, Chapter 13:
  // 13.1.1 (12 mm); the 20 mm base labour rows also appear in 13.9.2.
  // These are NOT the entire DAR analysis or a specification-specific quotation.
  static const sourceUrl = 'https://www.cpwd.gov.in/Publication/DAR14-Vol2.pdf';
  static const reference12 = ProductivityStandard(
    name: '12 mm reference',
    basis:
        'CPWD Analysis of Rates concept: selected labour coefficients. '
        'Confirm suitability for the finish, mortar mix and site.',
    daysPerBaseQuantity: {LabourRole.mason: .67, LabourRole.helper: .75},
  );
  static const reference20 = ProductivityStandard(
    name: '20 mm reference',
    basis:
        'CPWD Analysis of Rates concept: selected labour coefficients. '
        'Confirm suitability for the finish, mortar mix and site.',
    daysPerBaseQuantity: {LabourRole.mason: .94, LabourRole.helper: 1.02},
  );

  static ProductivityStandard forThickness(double thicknessMm) {
    EstimateValidation.number(thicknessMm, 'Thickness');
    if (thicknessMm == 12) return reference12;
    if (thicknessMm == 20) return reference20;
    if (thicknessMm < 12 || thicknessMm > 20) {
      throw ArgumentError(
        'For thickness outside 12–20 mm, select site-specific productivity '
        'and enter positive labour coefficients.',
      );
    }
    final fraction = (thicknessMm - 12) / 8;
    return ProductivityStandard(
      name: 'Interpolated thickness estimate',
      basis:
          'Linear interpolation between the supplied 12 mm and 20 mm '
          'references; this is a SiteQuant estimate, not a published CPWD item.',
      daysPerBaseQuantity: {
        LabourRole.mason: .67 + (.94 - .67) * fraction,
        LabourRole.helper: .75 + (1.02 - .75) * fraction,
      },
    );
  }

  static ProductivityStandard siteSpecific({
    required double masonDaysPer10M2,
    required double helperDaysPer10M2,
  }) {
    EstimateValidation.number(
      masonDaysPer10M2,
      'Mason productivity coefficient',
    );
    EstimateValidation.number(
      helperDaysPer10M2,
      'Helper productivity coefficient',
    );
    return ProductivityStandard(
      name: 'Site-specific productivity',
      basis: 'User-entered labour coefficients per 10 m²; confirm on site.',
      daysPerBaseQuantity: {
        LabourRole.mason: masonDaysPer10M2,
        LabourRole.helper: helperDaysPer10M2,
      },
    );
  }
}
