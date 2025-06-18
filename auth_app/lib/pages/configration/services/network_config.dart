// كلاس لتمثيل إعدادات الشبكة
class NetworkConfiguration {
  final String connectionType;
  final String printerMac;
  final String deviceName;
  final String printerIP;
  final bool isConfigured;
  final String configurationDate;

  NetworkConfiguration({
    required this.connectionType,
    required this.printerMac,
    required this.deviceName,
    required this.printerIP,
    required this.isConfigured,
    required this.configurationDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'connectionType': connectionType,
      'printerMac': printerMac,
      'deviceName': deviceName,
      'printerIP': printerIP,
      'isConfigured': isConfigured,
      'configurationDate': configurationDate,
    };
  }

  factory NetworkConfiguration.fromJson(Map<String, dynamic> json) {
    return NetworkConfiguration(
      connectionType: json['connectionType'] ?? 'LAN',
      printerMac: json['printerMac'] ?? '',
      deviceName: json['deviceName'] ?? '',
      printerIP: json['printerIP'] ?? '',
      isConfigured: json['isConfigured'] ?? false,
      configurationDate: json['configurationDate'] ?? '',
    );
  }
}
