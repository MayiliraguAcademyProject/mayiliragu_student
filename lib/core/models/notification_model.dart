class NotificationModel {
  final String id;
  final String? campaignId;
  final String studentId;
  final String status;
  final DateTime sentAt;
  final bool isRead;
  final DateTime? readAt;
  final String title;
  final String body;
  final String? pdfUrl;

  NotificationModel({
    required this.id,
    this.campaignId,
    required this.studentId,
    required this.status,
    required this.sentAt,
    required this.isRead,
    this.readAt,
    required this.title,
    required this.body,
    this.pdfUrl,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final campaignJson = json['campaign'] as Map<String, dynamic>?;
    return NotificationModel(
      id: json['id'] as String,
      campaignId: json['campaignId'] as String?,
      studentId: json['studentId'] as String,
      status: json['status'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt'] as String) : null,
      title: campaignJson?['title'] as String? ?? 'Notification',
      body: campaignJson?['body'] as String? ?? '',
      pdfUrl: campaignJson?['pdfUrl'] as String? ?? json['pdfUrl'] as String?,
    );
  }
}
