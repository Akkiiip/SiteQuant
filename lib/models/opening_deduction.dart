/// Reusable rectangular opening. Dimensions are always stored in metres.
class OpeningDeduction {
  final String name;
  final double widthMetres, heightMetres;
  final int quantity;

  const OpeningDeduction({
    required this.name,
    required this.widthMetres,
    required this.heightMetres,
    required this.quantity,
  });
}

class AreaTakeoff {
  final double grossArea, deductionArea, netArea;
  final List<OpeningDeduction> openings;

  AreaTakeoff({
    required this.grossArea,
    required this.deductionArea,
    required this.netArea,
    required List<OpeningDeduction> openings,
  }) : openings = List.unmodifiable(openings);
}
