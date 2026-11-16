class TestCaseValidator {
  /// Normalizes test outputs for comparison (strips trailing whitespace, brackets, quotes)
  static bool areOutputsEquivalent(String actual, String expected) {
    final normActual = _normalize(actual);
    final normExpected = _normalize(expected);

    if (normActual == normExpected) return true;

    // Handle boolean conversions ("True" vs "true")
    if (normActual.toLowerCase() == normExpected.toLowerCase()) return true;

    // Handle array representations with varying spacing (e.g., "[0,1]" vs "[0, 1]")
    final cleanA = normActual.replaceAll(' ', '');
    final cleanB = normExpected.replaceAll(' ', '');
    if (cleanA == cleanB) return true;

    return false;
  }

  static String _normalize(String s) {
    return s.trim().replaceAll('\r\n', '\n').replaceAll('"', '\'');
  }
}
