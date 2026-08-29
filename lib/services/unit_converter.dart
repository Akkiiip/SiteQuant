enum UnitCategory { length, area, volume, weight }

extension UnitCategoryDetails on UnitCategory {
  String get label => switch (this) {
    UnitCategory.length => 'Length',
    UnitCategory.area => 'Area',
    UnitCategory.volume => 'Volume',
    UnitCategory.weight => 'Weight',
  };
}

class UnitDefinition {
  final String label;
  final double factorToBase;

  const UnitDefinition(this.label, this.factorToBase);
}

class UnitConverter {
  static const Map<UnitCategory, List<UnitDefinition>> units = {
    UnitCategory.length: [
      UnitDefinition('mm', 0.001),
      UnitDefinition('cm', 0.01),
      UnitDefinition('m', 1),
      UnitDefinition('km', 1000),
      UnitDefinition('inch', 0.0254),
      UnitDefinition('ft', 0.3048),
    ],
    UnitCategory.area: [
      UnitDefinition('mm²', 0.000001),
      UnitDefinition('cm²', 0.0001),
      UnitDefinition('m²', 1),
      UnitDefinition('ft²', 0.09290304),
      UnitDefinition('yd²', 0.83612736),
      UnitDefinition('acre', 4046.8564224),
      UnitDefinition('hectare', 10000),
    ],
    UnitCategory.volume: [
      UnitDefinition('cm³', 0.000001),
      UnitDefinition('litre (L)', 0.001),
      UnitDefinition('m³', 1),
      UnitDefinition('ft³', 0.028316846592),
      UnitDefinition('Brass', 2.8316846592),
    ],
    UnitCategory.weight: [
      UnitDefinition('gram', 0.001),
      UnitDefinition('kilogram', 1),
      UnitDefinition('tonne', 1000),
    ],
  };

  static double convert({
    required double value,
    required UnitDefinition from,
    required UnitDefinition to,
  }) => value * from.factorToBase / to.factorToBase;
}
