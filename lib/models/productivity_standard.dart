enum LabourRole { mason, painter, helper }

extension LabourRoleLabel on LabourRole {
  String get label => switch (this) {
    LabourRole.mason => 'Mason',
    LabourRole.painter => 'Painter',
    LabourRole.helper => 'Helper/Coolie',
  };
}

/// Labour days per base quantity (m² for plaster).
/// Other work types can supply their own quantity basis and coefficients.
class ProductivityStandard {
  final String name, basis;
  final double baseQuantity;
  final Map<LabourRole, double> daysPerBaseQuantity;
  final int maximumCrewPerRole;

  const ProductivityStandard({
    required this.name,
    required this.basis,
    required this.daysPerBaseQuantity,
    this.baseQuantity = 10,
    this.maximumCrewPerRole = 3,
  });
}

class ProductivityEstimate {
  final ProductivityStandard standard;
  final Map<LabourRole, double> mandays;
  final Map<LabourRole, int> crew;
  final double workingDays, crewOutputPerDay;

  ProductivityEstimate({
    required this.standard,
    required Map<LabourRole, double> mandays,
    required Map<LabourRole, int> crew,
    required this.workingDays,
    required this.crewOutputPerDay,
  }) : mandays = Map.unmodifiable(mandays),
       crew = Map.unmodifiable(crew);
}

class LabourEstimate {
  final Map<LabourRole, double> dailyWages, costs;
  final double totalCost;

  LabourEstimate({
    required Map<LabourRole, double> dailyWages,
    required Map<LabourRole, double> costs,
    required this.totalCost,
  }) : dailyWages = Map.unmodifiable(dailyWages),
       costs = Map.unmodifiable(costs);
}
