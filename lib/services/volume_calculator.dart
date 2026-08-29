import 'dart:math';

class VolumeCalculator {
  static double cuboid({
    required double length,
    required double width,
    required double height,
  }) => length * width * height;
  static double cylinder({required double diameter, required double height}) {
    final radius = diameter / 2;
    return pi * radius * radius * height;
  }

  static double cone({required double diameter, required double height}) {
    final radius = diameter / 2;
    return pi * radius * radius * height / 3;
  }

  static double sphere({required double diameter}) {
    final radius = diameter / 2;
    return 4 * pi * radius * radius * radius / 3;
  }

  // Slab
  static double slab({
    required double length,
    required double width,
    required double thickness,
  }) {
    return length * width * thickness;
  }

  // Beam
  static double beam({
    required double length,
    required double width,
    required double depth,
  }) {
    return length * width * depth;
  }

  // Rectangular Column
  static double column({
    required double length,
    required double breadth,
    required double height,
    required int number,
  }) {
    return length * breadth * height * number;
  }

  // Rectangular Footing
  static double footing({
    required double length,
    required double width,
    required double depth,
    required int number,
  }) {
    return length * width * depth * number;
  }

  // Circular Column
  static double circularColumn({
    required double diameter,
    required double height,
    required int number,
  }) {
    return (pi * diameter * diameter / 4) * height * number;
  }

  // Circular Footing
  static double circularFooting({
    required double diameter,
    required double depth,
    required int number,
  }) {
    return (pi * diameter * diameter / 4) * depth * number;
  }

  // Custom Volume
  static double custom({required double volume}) {
    return volume;
  }
}
