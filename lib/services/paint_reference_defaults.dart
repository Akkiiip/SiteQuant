import '../models/paint_result.dart';

class PaintReferenceMaterial {
  const PaintReferenceMaterial({
    required this.coats,
    required this.coverage,
    required this.wastagePercent,
    required this.rate,
    required this.coverageBasis,
    required this.coverageCoats,
    required this.coverageDescription,
    required this.referenceLabel,
    required this.note,
    this.puttyPackSizeKg,
  });
  final int coats, coverageCoats;
  final double coverage, wastagePercent, rate;
  final PaintCoverageBasis coverageBasis;
  final String coverageDescription, referenceLabel, note;
  final double? puttyPackSizeKg;
  PuttyCoverageBasis get puttyCoverageBasis =>
      coverageBasis == PaintCoverageBasis.completeOperation &&
          coverageCoats == 2
      ? PuttyCoverageBasis.completeTwoCoats
      : PuttyCoverageBasis.perCoat;
}

class PaintReferencePreset {
  const PaintReferencePreset({
    required this.workType,
    required this.materials,
    required this.painterDaysPer10M2,
    required this.helperDaysPer10M2,
    required this.painterDailyWage,
    required this.helperDailyWage,
    required this.productivityName,
    required this.labourNote,
  });
  final PaintWorkType workType;
  final Map<PaintMaterialKind, PaintReferenceMaterial> materials;
  final double painterDaysPer10M2, helperDaysPer10M2;
  final double painterDailyWage, helperDailyWage;
  final String productivityName, labourNote;
}

class PaintReferenceDefaults {
  PaintReferenceDefaults._();

  static const _putty = PaintReferenceMaterial(
    coats: 2,
    coverage: 2.02064,
    wastagePercent: 5,
    rate: 35,
    coverageBasis: PaintCoverageBasis.perCoat,
    coverageCoats: 1,
    coverageDescription: '2.02 m²/kg/coat (21.75 sq ft/kg/coat)',
    referenceLabel: 'SiteQuant Reference Average',
    puttyPackSizeKg: 20,
    note:
        'SiteQuant Reference Average: midpoint average of comparable cement-based per-coat references—Asian Paints Wall Putty 20–25 and JK WallMaxX 20–22 sq ft/kg. Five percent wastage and ₹35/kg are editable site/market references. Roughness and thickness can materially change consumption.',
  );
  static const _interiorPrimer = PaintReferenceMaterial(
    coats: 1,
    coverage: 15.75,
    wastagePercent: 5,
    rate: 150,
    coverageBasis: PaintCoverageBasis.perCoat,
    coverageCoats: 1,
    coverageDescription: '15.75 m²/L for one coat',
    referenceLabel: 'SiteQuant Reference Average',
    note:
        'SiteQuant Reference Average normalized to one coat from Asian Paints water-thinnable primer (170–200 sq ft/L) and CPWD DAR interior primer consumption (0.70 L/10 m²). ₹150/L and 5% wastage are editable market/site references.',
  );
  static const _interiorEmulsion = PaintReferenceMaterial(
    coats: 2,
    coverage: 13.94,
    wastagePercent: 5,
    rate: 420,
    coverageBasis: PaintCoverageBasis.completeOperation,
    coverageCoats: 2,
    coverageDescription: '13.94 m²/L for the complete two-coat operation',
    referenceLabel: 'SiteQuant Reference Average',
    note:
        'SiteQuant Reference Average of comparable two-coat interior emulsions: Asian Paints Apcolite Premium 130–150 and Berger premium interior reference 150–170 sq ft/L for two coats. ₹420/L and 5% wastage are editable market/site references.',
  );
  static const _exteriorPrimer = PaintReferenceMaterial(
    coats: 1,
    coverage: 12.08,
    wastagePercent: 7,
    rate: 190,
    coverageBasis: PaintCoverageBasis.perCoat,
    coverageCoats: 1,
    coverageDescription: '12.08 m²/L (130 sq ft/L) for one coat',
    referenceLabel: 'SiteQuant Reference Average',
    note:
        'SiteQuant Reference Average for mainstream exterior masonry primers, normalized to one coat; aligned with Dulux Weathershield 110–150 sq ft/L. ₹190/L and 7% wastage are editable market/site references.',
  );
  static const _exteriorEmulsion = PaintReferenceMaterial(
    coats: 2,
    coverage: 6.35,
    wastagePercent: 7,
    rate: 340,
    coverageBasis: PaintCoverageBasis.completeOperation,
    coverageCoats: 2,
    coverageDescription:
        '6.35 m²/L (68.3 sq ft/L) for the complete two-coat operation',
    referenceLabel: 'SiteQuant Reference Average',
    note:
        'SiteQuant Reference Average of comparable exterior emulsions normalized to two coats: Asian Paints Apex 70–80, Ace 55–65, and Nerolac Excel 130–150 sq ft/L/coat. ₹340/L and 7% wastage are editable market/site references. Scaffolding/access cost excluded.',
  );
  static const _coating = PaintReferenceMaterial(
    coats: 2,
    coverage: 10,
    wastagePercent: 5,
    rate: 350,
    coverageBasis: PaintCoverageBasis.perCoat,
    coverageCoats: 1,
    coverageDescription: '10 m²/L/coat',
    referenceLabel: 'Site Reference Assumption',
    note:
        'Site Reference Assumption for ordinary wood/metal coating. Product, preparation, substrate and shade vary; edit from the selected product sheet.',
  );
  static const _texture = PaintReferenceMaterial(
    coats: 1,
    coverage: 1,
    wastagePercent: 7,
    rate: 150,
    coverageBasis: PaintCoverageBasis.perCoat,
    coverageCoats: 1,
    coverageDescription: '1 kg/m²/coat consumption',
    referenceLabel: 'Site Reference Assumption',
    note:
        'Site Reference Assumption for texture consumption and rate; texture profile and product can vary widely.',
  );

  static PaintReferencePreset forWorkType(PaintWorkType workType) {
    final materials = <PaintMaterialKind, PaintReferenceMaterial>{
      for (final material in workType.materials)
        material: switch (material) {
          PaintMaterialKind.putty => _putty,
          PaintMaterialKind.primer =>
            workType == PaintWorkType.exteriorWalls
                ? _exteriorPrimer
                : _interiorPrimer,
          PaintMaterialKind.paint =>
            workType == PaintWorkType.exteriorWalls
                ? _exteriorEmulsion
                : _interiorEmulsion,
          PaintMaterialKind.texture => _texture,
          PaintMaterialKind.coating => _coating,
        },
    };
    final labour = switch (workType) {
      PaintWorkType.puttyOnly => (
        p: .45,
        h: .45,
        name: 'CPWD DAR 2023 item 13.80',
        note:
            'CPWD DAR 2023 item 13.80: 1 mm white-cement-based wall putty—0.45 mason and 0.45 beldar day per 10 m². Used as painter/helper roles in SiteQuant. Editable for substrate and finish.',
      ),
      PaintWorkType.primerOnly => (
        p: .40,
        h: .20,
        name: 'CPWD DAR wall-primer reference',
        note:
            'CPWD DAR item 13.43.1: one coat water-thinnable cement primer—0.40 painter and 0.20 coolie day per 10 m². Editable for product and preparation.',
      ),
      PaintWorkType.paintOnly => (
        p: .54,
        h: .54,
        name: 'CPWD DAR acrylic-emulsion reference',
        note:
            'CPWD DAR item 13.82.2: two-coat wall acrylic emulsion—0.54 painter and 0.54 coolie day per 10 m². Editable for substrate and application method.',
      ),
      PaintWorkType.interiorWalls => (
        p: 1.39,
        h: 1.19,
        name: 'Summed operation references',
        note:
            'Transparent sum per 10 m²: putty 0.45/0.45 + primer 0.40/0.20 + two-coat interior emulsion 0.54/0.54 painter/helper days. Editable; no crew multiplication.',
      ),
      PaintWorkType.ceiling => (
        p: 1.60,
        h: 1.37,
        name: 'Site Reference Assumption',
        note:
            'Site Reference Assumption: interior system sum with a 15% overhead-position productivity allowance. Not an official CPWD rate; edit for height and access.',
      ),
      PaintWorkType.exteriorWalls => (
        p: .60,
        h: .30,
        name: 'CPWD DAR exterior-system reference',
        note:
            'CPWD DAR item 13.46.1 reference for exterior primer plus two-or-more coats of acrylic smooth exterior paint. Scaffolding/access cost excluded and must be priced separately when required.',
      ),
      PaintWorkType.texture => (
        p: .60,
        h: .30,
        name: 'CPWD DAR textured-exterior reference',
        note:
            'CPWD DAR item 13.45.1 reference for exterior primer plus textured finish. Edit for texture profile and method. Scaffolding/access cost excluded.',
      ),
      PaintWorkType.wood || PaintWorkType.metal => (
        p: .54,
        h: .54,
        name: 'CPWD DAR coating reference',
        note:
            'CPWD DAR two-or-more-coat painting reference for ordinary wood/metal work. Edit for preparation, geometry and coating system.',
      ),
    };
    return PaintReferencePreset(
      workType: workType,
      materials: materials,
      painterDaysPer10M2: labour.p,
      helperDaysPer10M2: labour.h,
      painterDailyWage: 900,
      helperDailyWage: 750,
      productivityName: labour.name,
      labourNote: labour.note,
    );
  }
}
