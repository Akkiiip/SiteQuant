import '../models/paint_result.dart';

class PaintReferenceMaterial {
  const PaintReferenceMaterial({required this.coats, required this.coverage, required this.wastagePercent, required this.rate, required this.coverageBasis, required this.note});
  final int coats;
  final double coverage, wastagePercent, rate;
  final String coverageBasis, note;
}
class PaintReferencePreset {
  const PaintReferencePreset({required this.workType, required this.materials, required this.painterDaysPer10M2, required this.helperDaysPer10M2, required this.painterDailyWage, required this.helperDailyWage, required this.labourNote});
  final PaintWorkType workType;
  final Map<PaintMaterialKind, PaintReferenceMaterial> materials;
  final double painterDaysPer10M2, helperDaysPer10M2, painterDailyWage, helperDailyWage;
  final String labourNote;
}
class PaintReferenceDefaults {
  PaintReferenceDefaults._();
  static const _putty=PaintReferenceMaterial(coats:2,coverage:.58,wastagePercent:5,rate:35,coverageBasis:'0.58 m2/kg/coat',note:'Reference assumption from a 10-15 sq ft/kg two-coat wall-putty range; verify product data.');
  static const _primer=PaintReferenceMaterial(coats:1,coverage:10,wastagePercent:5,rate:120,coverageBasis:'10 m2/L/coat',note:'Reference estimate; verify the selected primer data sheet.');
  static const _paint=PaintReferenceMaterial(coats:2,coverage:26,wastagePercent:5,rate:300,coverageBasis:'26 m2/L/coat',note:'Reference based on an approximately 260-300 sq ft/L/coat emulsion range on normal masonry.');
  static const _coating=PaintReferenceMaterial(coats:2,coverage:10,wastagePercent:5,rate:350,coverageBasis:'10 m2/L/coat',note:'Reference assumption; wood and metal coverage depends on product and surface preparation.');
  static const _texture=PaintReferenceMaterial(coats:1,coverage:1,wastagePercent:7,rate:150,coverageBasis:'1 kg/m2/coat',note:'Reference assumption only. Texture consumption is product-specific and should be verified.');
  static PaintReferencePreset forWorkType(PaintWorkType workType) {
    final materials=<PaintMaterialKind,PaintReferenceMaterial>{for(final material in workType.materials) material:switch(material){PaintMaterialKind.putty=>_putty,PaintMaterialKind.primer=>_primer,PaintMaterialKind.paint=>_paint,PaintMaterialKind.texture=>_texture,PaintMaterialKind.coating=>_coating}};
    return PaintReferencePreset(workType:workType,materials:materials,painterDaysPer10M2:1,helperDaysPer10M2:.5,painterDailyWage:900,helperDailyWage:600,labourNote:'Site reference assumption, not a CPWD/DAR standard. Adjust for surface, access and crew conditions.');
  }
}