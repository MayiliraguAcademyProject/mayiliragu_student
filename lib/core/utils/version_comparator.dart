class VersionComparator {
  /// Returns [true] if [installedVersion] is strictly older than [requiredVersion].
  /// Strings are expected to be in semantic format: x.y.z (major.minor.patch).
  static bool isVersionOutdated(String installedVersion, String requiredVersion) {
    try {
      final List<int> installedParts = installedVersion
          .split('+')[0] // remove build number if any: e.g. 1.0.0+4 -> 1.0.0
          .split('.')
          .map((part) => int.parse(part))
          .toList();

      final List<int> requiredParts = requiredVersion
          .split('+')[0]
          .split('.')
          .map((part) => int.parse(part))
          .toList();

      // Pad versions to same length just in case
      while (installedParts.length < 3) {
        installedParts.add(0);
      }
      while (requiredParts.length < 3) {
        requiredParts.add(0);
      }

      for (int i = 0; i < 3; i++) {
        if (installedParts[i] < requiredParts[i]) {
          return true;
        } else if (installedParts[i] > requiredParts[i]) {
          return false;
        }
      }
    } catch (e) {
      // In case of parsing failure, fail-open (return false) so user is not blocked
      return false;
    }
    return false; // Equal versions or no newer version required
  }
}
