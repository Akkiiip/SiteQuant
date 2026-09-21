class ShutteringReferenceDefaults {
  const ShutteringReferenceDefaults({
    required this.ratePerSquareMetre,
    required this.wastagePercent,
    required this.carpenterDaysPer10M2,
    required this.helperDaysPer10M2,
    required this.carpenterDailyWage,
    required this.helperDailyWage,
    required this.note,
  });
  final double ratePerSquareMetre,
      wastagePercent,
      carpenterDaysPer10M2,
      helperDaysPer10M2,
      carpenterDailyWage,
      helperDailyWage;
  final String note;
  static const standard = ShutteringReferenceDefaults(
    ratePerSquareMetre: 650,
    wastagePercent: 5,
    carpenterDaysPer10M2: 1.2,
    helperDaysPer10M2: .9,
    carpenterDailyWage: 1000,
    helperDailyWage: 650,
    note:
        'Editable reference assumptions only. Adjust for the shuttering system, reuse cycles, access, labour skill and local conditions.',
  );
}
