class UpgradeInfo {
  final String appStoreInfo;
  final String appGooglePlayInfo;
  final bool maintain;

  UpgradeInfo({
    required this.appStoreInfo,
    required this.appGooglePlayInfo,
    required this.maintain,
  });

  factory UpgradeInfo.fromJson(Map<String, dynamic> json) {
    return UpgradeInfo(
      appStoreInfo: json['appStoreInfo'] ?? '',
      appGooglePlayInfo: json['appGooglePlayInfo'] ?? '',
      maintain: json['maintain'] ?? false,
    );
  }
}
