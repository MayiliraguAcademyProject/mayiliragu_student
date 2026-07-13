class AppConfigModel {
  final String? requiredVersion;
  final String? apkDownloadUrl;
  final String? releaseNotes;

  AppConfigModel({
    this.requiredVersion,
    this.apkDownloadUrl,
    this.releaseNotes,
  });

  factory AppConfigModel.fromJson(Map<String, dynamic> json) {
    return AppConfigModel(
      requiredVersion: json['requiredVersion'] as String?,
      apkDownloadUrl: json['apkDownloadUrl'] as String?,
      releaseNotes: json['releaseNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requiredVersion': requiredVersion,
      'apkDownloadUrl': apkDownloadUrl,
      'releaseNotes': releaseNotes,
    };
  }
}
