enum PlasterType { wall, ceiling }

extension PlasterTypeLabel on PlasterType {
  String get label => this == PlasterType.wall ? 'Wall Plaster' : 'Ceiling Plaster';
}

class PlasterResult {
  final double area, wetVolume, dryVolume, cementBags, sandM3, sandBrass;
  const PlasterResult({required this.area, required this.wetVolume, required this.dryVolume, required this.cementBags, required this.sandM3, required this.sandBrass});
}
