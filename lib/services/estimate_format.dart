class EstimateFormat {
  /// Strip fractional padding only; whole-number zeroes are significant.
  static String number(double value, [int precision = 3]) {
    final fixed = value.toStringAsFixed(precision);
    return fixed.contains('.') && !fixed.contains('e')
        ? fixed
              .replaceFirst(RegExp(r'0+$'), '')
              .replaceFirst(RegExp(r'\.$'), '')
        : fixed;
  }

  static String money(double value) => '₹${value.toStringAsFixed(2)}';
}
