enum BatchType {
  regular('REGULAR', 'Regular Batch', 'Weekday Full-Time (Mon–Sat)'),
  weekend('WEEKEND', 'Weekend Batch', 'Saturday & Sunday Only'),
  evening('EVENING', 'Evening Batch', 'Weekday After-Hours Sessions');

  final String value;
  final String displayName;
  final String description;

  const BatchType(this.value, this.displayName, this.description);

  static BatchType fromString(String? type) {
    if (type == null) return BatchType.regular;
    switch (type.toUpperCase()) {
      case 'WEEKEND':
        return BatchType.weekend;
      case 'EVENING':
        return BatchType.evening;
      case 'REGULAR':
      default:
        return BatchType.regular;
    }
  }

  String toApiString() => value;
}
