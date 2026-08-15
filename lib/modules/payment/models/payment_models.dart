class PaymentSettingModel {
  final String id;
  final String qrImageUrl;
  final String instructions;
  final String updatedAt;

  PaymentSettingModel({
    required this.id,
    required this.qrImageUrl,
    required this.instructions,
    required this.updatedAt,
  });

  factory PaymentSettingModel.fromJson(Map<String, dynamic> json) {
    return PaymentSettingModel(
      id: json['id'] as String? ?? '',
      qrImageUrl: json['qrImageUrl'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qrImageUrl': qrImageUrl,
      'instructions': instructions,
      'updatedAt': updatedAt,
    };
  }
}

class PaymentRequestModel {
  final String id;
  final String studentId;
  final String linkType;
  final String linkId;
  final double amount;
  final String screenshotUrl;
  final String status;
  final String? adminNote;
  final String createdAt;
  final String updatedAt;

  PaymentRequestModel({
    required this.id,
    required this.studentId,
    required this.linkType,
    required this.linkId,
    required this.amount,
    required this.screenshotUrl,
    required this.status,
    this.adminNote,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentRequestModel.fromJson(Map<String, dynamic> json) {
    return PaymentRequestModel(
      id: json['id'] as String? ?? '',
      studentId: json['studentId'] as String? ?? '',
      linkType: json['linkType'] as String? ?? '',
      linkId: json['linkId'] as String? ?? '',
      amount: json['amount'] is num 
          ? (json['amount'] as num).toDouble() 
          : (json['amount'] is String ? double.tryParse(json['amount'] as String) ?? 0.0 : 0.0),
      screenshotUrl: json['screenshotUrl'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      adminNote: json['adminNote'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'linkType': linkType,
      'linkId': linkId,
      'amount': amount,
      'screenshotUrl': screenshotUrl,
      'status': status,
      'adminNote': adminNote,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
