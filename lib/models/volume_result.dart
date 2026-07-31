class VolumeResult {
  final double m3;
  const VolumeResult(this.m3);
  double get ft3 => m3 * 35.3147;
  double get brass => ft3 / 100;
  double get litres => m3 * 1000;
}
