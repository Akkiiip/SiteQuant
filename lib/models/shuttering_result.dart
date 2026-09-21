import 'productivity_standard.dart';

enum ShutteringType { column, beam, footing, wall, slab }

extension ShutteringTypeInfo on ShutteringType {
  String get label => switch (this) {
    ShutteringType.column => 'Shuttering Column',
    ShutteringType.beam => 'Shuttering Beam',
    ShutteringType.footing => 'Shuttering Footing',
    ShutteringType.wall => 'Shuttering Wall',
    ShutteringType.slab => 'Shuttering Slab',
  };
  String get formula => switch (this) {
    ShutteringType.column => '2 x (L + W) x H x Quantity',
    ShutteringType.beam => '(2 x D + B) x L x Quantity',
    ShutteringType.footing => '2 x (L + W) x D x Quantity',
    ShutteringType.wall => 'Sides x L x H x Quantity',
    ShutteringType.slab => 'L x W x Quantity',
  };
}

class ShutteringResult {
  final ShutteringType type;
  final double length, width, height;
  final int quantity, wallSides;
  final double contactArea,
      wastagePercent,
      panelArea,
      materialRate,
      materialCost,
      totalCost;
  final ProductivityEstimate productivity;
  final LabourEstimate labour;
  const ShutteringResult({
    required this.type,
    required this.length,
    required this.width,
    required this.height,
    required this.quantity,
    required this.wallSides,
    required this.contactArea,
    required this.wastagePercent,
    required this.panelArea,
    required this.materialRate,
    required this.materialCost,
    required this.productivity,
    required this.labour,
    required this.totalCost,
  });
  double? get costPerSquareMetre =>
      contactArea == 0 ? null : totalCost / contactArea;
}
