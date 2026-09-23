import '../models/paint_result.dart';

class PaintReferenceMaterial {
  const PaintReferenceMaterial({
    required this.coats,
    required this.coverage,
    required this.wastagePercent,
    required this.rate,
    required this.coverageBasis,
    required this.note,
    this.puttyCoverageBasis = PuttyCoverageBasis.perCoat,
    this.puttyPackSizeKg,
  });

  final int coats;
  final double coverage, wastagePercent, rate;
  final String coverageBasis, note;
  final PuttyCoverageBasis puttyCoverageBasis;
  final double? puttyPackSizeKg;
}

class PaintReferencePreset {
  const PaintReferencePreset({
    required this.workType,
    required this.materials,
    required this.painterDaysPer10M2,
    required this.helperDaysPer10M2,
    required this.painterDailyWage,
    required this.helperDailyWage,
    required this.labourNote,
  });

  final PaintWorkType workType;
  final Map<PaintMaterialKind, PaintReferenceMaterial> materials;
  final double painterDaysPer10M2, helperDaysPer10M2;
  final double painterDailyWage, helperDailyWage;
  final String labourNote;
}

class PaintReferenceDefaults {
  PaintReferenceDefaults._();

  // Product sheet: 10–15 sq ft/kg for the complete two-coat application.
  // 1.16 m²/kg is about 12.49 sq ft/kg, within that product range.
  // https://www.asianpaints.com/content/dam/asianpaints/website/products/pis-files/professional-wall-putty.pdf
  static const _putty = PaintReferenceMaterial(
    coats: 2,
    coverage: 1.16,
    wastagePercent: 5,
    rate: 35,
    coverageBasis: '1.16 m²/kg for the complete two-coat application',
    puttyCoverageBasis: PuttyCoverageBasis.completeTwoCoats,
    puttyPackSizeKg: 20,
    note:
        'Editable product reference assumption from a 10–15 sq ft/kg complete two-coat wall-putty range. '
        'Pack sizes are editable assumptions; verify the selected product and available packaging.',
  );
  static const _primer = PaintReferenceMaterial(
    coats: 1,
    coverage: 10,
    wastagePercent: 5,
    rate: 120,
    coverageBasis: '10 m2/L/coat',
    note: 'Reference estimate; verify the selected primer data sheet.',
  );
  static const _paint = PaintReferenceMaterial(
    coats: 2,
    coverage: 26,
    wastagePercent: 5,
    rate: 300,
    coverageBasis: '26 m2/L/coat',
    note:
        'Reference based on an approximately 260-300 sq ft/L/coat emulsion range on normal masonry.',
  );
  static const _coating = PaintReferenceMaterial(
    coats: 2,
    coverage: 10,
    wastagePercent: 5,
    rate: 350,
    coverageBasis: '10 m2/L/coat',
    note:
        'Reference assumption; wood and metal coverage depends on product and surface preparation.',
  );
  static const _texture = PaintReferenceMaterial(
    coats: 1,
    coverage: 1,
    wastagePercent: 7,
    rate: 150,
    coverageBasis: '1 kg/m2/coat',
    note:
        'Reference assumption only. Texture consumption is product-specific and should be verified.',
  );

  // These figures apply to the cited individual wall items only. Composite
  // systems and different substrates retain editable site assumptions.
  // CPWD DAR 2013 Vol II, items 13.82.2 and 13.43.1:
  // https://www.cpwd.gov.in/Publication/DARVol2-2013.pdf
  static const _acrylicWallTwoCoats = (
    painter: .54,
    helper: .54,
    note:
        'CPWD DAR reference for wall acrylic emulsion, two coats (item 13.82.2). '
        'Editable reference only; adjust for product, preparation and access.',
  );
  static const _waterThinnableWallPrimer = (
    painter: .40,
    helper: .20,
    note:
        'CPWD DAR reference for one coat of water-thinnable cement primer on wall '
        '(item 13.43.1). Editable reference only; adjust for other primers and surfaces.',
  );

  static ({double painter, double helper, String note}) _siteAssumption(
    String work,
  ) => (
    painter: 1.0,
    helper: .5,
    note:
        'Editable Site Reference Assumption for $work, not a CPWD/DAR item. '
        'Confirm labour days per 10 m² for the finish, substrate, access and crew.',
  );

  static PaintReferencePreset forWorkType(PaintWorkType workType) {
    final materials = <PaintMaterialKind, PaintReferenceMaterial>{
      for (final material in workType.materials)
        material: switch (material) {
          PaintMaterialKind.putty => _putty,
          PaintMaterialKind.primer => _primer,
          PaintMaterialKind.paint => _paint,
          PaintMaterialKind.texture => _texture,
          PaintMaterialKind.coating => _coating,
        },
    };
    final labour = switch (workType) {
      PaintWorkType.interiorWalls => _siteAssumption(
        'combined putty, primer and interior wall paint',
      ),
      PaintWorkType.ceiling => _siteAssumption(
        'ceiling putty, primer and paint',
      ),
      PaintWorkType.exteriorWalls => _siteAssumption(
        'exterior primer and paint',
      ),
      PaintWorkType.texture => _siteAssumption('texture or special finish'),
      PaintWorkType.wood => _siteAssumption('wood coating'),
      PaintWorkType.metal => _siteAssumption('metal coating'),
      PaintWorkType.puttyOnly => _siteAssumption('putty only'),
      PaintWorkType.primerOnly => _waterThinnableWallPrimer,
      PaintWorkType.paintOnly => _acrylicWallTwoCoats,
    };
    return PaintReferencePreset(
      workType: workType,
      materials: materials,
      painterDaysPer10M2: labour.painter,
      helperDaysPer10M2: labour.helper,
      painterDailyWage: 900,
      helperDailyWage: 600,
      labourNote: labour.note,
    );
  }
}
