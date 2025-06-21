// lib/models/network_device.dart

class NetworkDevice {
  final String ip;
  final String name;
  final String macAddress;
  final int port;
  final bool isOnline;
  final String deviceType;
  final DateTime discoveredAt;

  NetworkDevice({
    required this.ip,
    required this.name,
    required this.macAddress,
    required this.port,
    required this.isOnline,
    String? deviceType,
    DateTime? discoveredAt,
  })  : deviceType = deviceType ?? 'Unknown',
        discoveredAt = discoveredAt ?? DateTime.now();

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'ip': ip,
      'name': name,
      'macAddress': macAddress,
      'port': port,
      'isOnline': isOnline,
      'deviceType': deviceType,
      'discoveredAt': discoveredAt.toIso8601String(),
    };
  }

  /// إنشاء من JSON
  factory NetworkDevice.fromJson(Map<String, dynamic> json) {
    return NetworkDevice(
      ip: json['ip'] ?? '',
      name: json['name'] ?? 'Unknown Device',
      macAddress: json['macAddress'] ?? '00:00:00:00:00:00',
      port: json['port'] ?? 9100,
      isOnline: json['isOnline'] ?? false,
      deviceType: json['deviceType'] ?? 'Unknown',
      discoveredAt: json['discoveredAt'] != null
          ? DateTime.tryParse(json['discoveredAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// نسخ مع تعديلات
  NetworkDevice copyWith({
    String? ip,
    String? name,
    String? macAddress,
    int? port,
    bool? isOnline,
    String? deviceType,
    DateTime? discoveredAt,
  }) {
    return NetworkDevice(
      ip: ip ?? this.ip,
      name: name ?? this.name,
      macAddress: macAddress ?? this.macAddress,
      port: port ?? this.port,
      isOnline: isOnline ?? this.isOnline,
      deviceType: deviceType ?? this.deviceType,
      discoveredAt: discoveredAt ?? this.discoveredAt,
    );
  }

  /// التحقق من المساواة
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NetworkDevice && other.ip == ip && other.macAddress == macAddress;
  }

  @override
  int get hashCode => ip.hashCode ^ macAddress.hashCode;

  @override
  String toString() {
    return 'NetworkDevice(ip: $ip, name: $name, mac: $macAddress, port: $port, online: $isOnline)';
  }

  /// الحصول على معلومات مختصرة للعرض
  String get displayInfo => '$name\nIP: $ip\nMAC: $macAddress';

  /// التحقق من صحة البيانات
  bool get isValid {
    return ip.isNotEmpty &&
        macAddress.isNotEmpty &&
        name.isNotEmpty &&
        _isValidIP(ip) &&
        _isValidMacAddress(macAddress);
  }

  /// التحقق من صحة IP
  bool _isValidIP(String ip) {
    RegExp ipRegex = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$');
    if (!ipRegex.hasMatch(ip)) return false;

    List<String> parts = ip.split('.');
    for (String part in parts) {
      int? num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }
    return true;
  }

  /// التحقق من صحة MAC Address
  bool _isValidMacAddress(String mac) {
    RegExp macRegex = RegExp(
        r'^[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}$');
    return macRegex.hasMatch(mac);
  }

  /// الحصول على نوع الجهاز حسب المنفذ
  String get printerType {
    switch (port) {
      case 9100:
        return 'RAW Printer';
      case 631:
        return 'IPP Printer';
      case 515:
        return 'LPD Printer';
      case 721:
        return 'Network Printer';
      default:
        return 'Unknown Printer';
    }
  }

  /// الحصول على أيقونة حسب حالة الاتصال
  String get statusIcon {
    return isOnline ? '🟢' : '🔴';
  }

  /// الحصول على لون حسب حالة الاتصال
  String get statusColor {
    return isOnline ? 'green' : 'red';
  }
}


// // Network Device Model
// class NetworkDevice {
//   final String ip;
//   final String name;
//   final String macAddress;
//   final int port;
//   final bool isOnline;

//   NetworkDevice({
//     required this.ip,
//     required this.name,
//     required this.macAddress,
//     required this.port,
//     required this.isOnline,
//   });

//   Map<String, dynamic> toJson() => {
//         'ip': ip,
//         'name': name,
//         'macAddress': macAddress,
//         'port': port,
//         'isOnline': isOnline,
//       };

//   factory NetworkDevice.fromJson(Map<String, dynamic> json) => NetworkDevice(
//         ip: json['ip'] ?? '',
//         name: json['name'] ?? '',
//         macAddress: json['macAddress'] ?? '',
//         port: json['port'] ?? 9100,
//         isOnline: json['isOnline'] ?? false,
//       );
// }
