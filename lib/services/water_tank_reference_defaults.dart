class WaterTankReferenceDefaults {
  const WaterTankReferenceDefaults({
    required this.rccRatePerCubicMetre,
    required this.masonDaysPerCubicMetre,
    required this.helperDaysPerCubicMetre,
    required this.masonDailyWage,
    required this.helperDailyWage,
    required this.note,
  });
  final double rccRatePerCubicMetre,
      masonDaysPerCubicMetre,
      helperDaysPerCubicMetre;
  final double masonDailyWage, helperDailyWage;
  final String note;

  static const standard = WaterTankReferenceDefaults(
    rccRatePerCubicMetre: 8500,
    masonDaysPerCubicMetre: 1.2,
    helperDaysPerCubicMetre: 1.5,
    masonDailyWage: 900,
    helperDailyWage: 650,
    note:
        'Editable reference assumptions only. Adjust for tank geometry, concrete system, access, local labour and project conditions.',
  );
}
