// models/printer_model.dart
class PrinterModel {
  final String name;
  final String ipAddress;
  final String macAddress;
  final int port;
  final bool isConnected;
  final String deviceType;
  final DateTime? lastConnected;

  PrinterModel({
    required this.name,
    required this.ipAddress,
    required this.macAddress,
    this.port = 9100,
    this.isConnected = false,
    this.deviceType = 'Unknown',
    this.lastConnected,
  });

  // تحويل من JSON
  factory PrinterModel.fromJson(Map<String, dynamic> json) {
    return PrinterModel(
      name: json['name'] ?? 'Unknown Device',
      ipAddress: json['ipAddress'] ?? '',
      macAddress: json['macAddress'] ?? '',
      port: json['port'] ?? 9100,
      isConnected: json['isConnected'] ?? false,
      deviceType: json['deviceType'] ?? 'Unknown',
      lastConnected: json['lastConnected'] != null ? DateTime.parse(json['lastConnected']) : null,
    );
  }

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ipAddress': ipAddress,
      'macAddress': macAddress,
      'port': port,
      'isConnected': isConnected,
      'deviceType': deviceType,
      'lastConnected': lastConnected?.toIso8601String(),
    };
  }

  // نسخ مع تعديل
  PrinterModel copyWith({
    String? name,
    String? ipAddress,
    String? macAddress,
    int? port,
    bool? isConnected,
    String? deviceType,
    DateTime? lastConnected,
  }) {
    return PrinterModel(
      name: name ?? this.name,
      ipAddress: ipAddress ?? this.ipAddress,
      macAddress: macAddress ?? this.macAddress,
      port: port ?? this.port,
      isConnected: isConnected ?? this.isConnected,
      deviceType: deviceType ?? this.deviceType,
      lastConnected: lastConnected ?? this.lastConnected,
    );
  }

  @override
  String toString() {
    return 'PrinterModel(name: $name, ip: $ipAddress, mac: $macAddress, connected: $isConnected)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrinterModel && other.ipAddress == ipAddress && other.macAddress == macAddress;
  }

  @override
  int get hashCode => ipAddress.hashCode ^ macAddress.hashCode;
}
