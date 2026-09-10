enum BatchType {
  regular('REGULAR', 'Regular Batch', 'Weekday Full-Time (Mon–Sat)'),
  weekend('WEEKEND', 'Weekend Batch', 'Saturday & Sunday Only'),
  evening('EVENING', 'Evening Batch', 'Weekday After-Hours Sessions'),
  testBatch('TESTBATCH', 'Test Batch', 'Structured Test Series Students');

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
      case 'TESTBATCH':
        return BatchType.testBatch;
      case 'REGULAR':
      default:
        return BatchType.regular;
    }
  }

  String toApiString() => value;
}
