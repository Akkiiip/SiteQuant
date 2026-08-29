enum MasonryType { clayBrick, aacBlock, concreteBlock, lateriteStone }

extension MasonryTypeDetails on MasonryType {
  String get label => switch (this) {
    MasonryType.clayBrick => 'Clay Brick',
    MasonryType.aacBlock => 'AAC Block',
    MasonryType.concreteBlock => 'Concrete Block',
    MasonryType.lateriteStone => 'Laterite Stone Masonry',
  };

  String get unitLabel => switch (this) {
    MasonryType.clayBrick => 'Bricks',
    MasonryType.aacBlock => 'AAC Blocks',
    MasonryType.concreteBlock => 'Concrete Blocks',
    MasonryType.lateriteStone => 'Stones',
  };
}

class MasonryResult {
  final double masonryVolume;
  final double wallArea;
  final int unitCount;
  final double mortarVolume;
  final double cementKg;
  final double cementBags;
  final double sandM3;
  final double sandBrass;

  const MasonryResult({
    required this.masonryVolume,
    required this.wallArea,
    required this.unitCount,
    required this.mortarVolume,
    required this.cementKg,
    required this.cementBags,
    required this.sandM3,
    required this.sandBrass,
  });
}

class MasonryUnitSize {
  final double lengthMm;
  final double widthMm;
  final double heightMm;

  const MasonryUnitSize({
    required this.lengthMm,
    required this.widthMm,
    required this.heightMm,
  });

  String get displayLabel =>
      '${lengthMm.toStringAsFixed(0)} × ${widthMm.toStringAsFixed(0)} × ${heightMm.toStringAsFixed(0)} mm';
}
