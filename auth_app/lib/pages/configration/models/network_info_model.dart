enum ConnectionType {
  lan,
  wan,
  none,
}

class NetworkInfoModel {
  final ConnectionType connectionType;
  final String? ipAddress;
  final String? gateway;
  final String? wifiName;
  final String? wifiBSSID;
  final String? subnet;
  final bool isConnected;

  NetworkInfoModel({
    required this.connectionType,
    this.ipAddress,
    this.gateway,
    this.wifiName,
    this.wifiBSSID,
    this.subnet,
    required this.isConnected,
  });

  factory NetworkInfoModel.empty() {
    return NetworkInfoModel(
      connectionType: ConnectionType.none,
      isConnected: false,
    );
  }

  String get connectionTypeString {
    switch (connectionType) {
      case ConnectionType.lan:
        return 'LAN (Local Area Network)';
      case ConnectionType.wan:
        return 'WAN (Wide Area Network)';
      case ConnectionType.none:
        return 'غير متصل';
    }
  }

  bool get isPrivateIP {
    if (ipAddress == null) return false;

    final ip = ipAddress!;
    return ip.startsWith('192.168.') ||
        ip.startsWith('10.') ||
        (ip.startsWith('172.') &&
            int.tryParse(ip.split('.')[1]) != null &&
            int.parse(ip.split('.')[1]) >= 16 &&
            int.parse(ip.split('.')[1]) <= 31);
  }
}
