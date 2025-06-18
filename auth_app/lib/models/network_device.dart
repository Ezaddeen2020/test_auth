// Network Device Model
class NetworkDevice {
  final String ip;
  final String name;
  final String macAddress;
  final int port;
  final bool isOnline;

  NetworkDevice({
    required this.ip,
    required this.name,
    required this.macAddress,
    required this.port,
    required this.isOnline,
  });

  Map<String, dynamic> toJson() => {
        'ip': ip,
        'name': name,
        'macAddress': macAddress,
        'port': port,
        'isOnline': isOnline,
      };

  factory NetworkDevice.fromJson(Map<String, dynamic> json) => NetworkDevice(
        ip: json['ip'] ?? '',
        name: json['name'] ?? '',
        macAddress: json['macAddress'] ?? '',
        port: json['port'] ?? 9100,
        isOnline: json['isOnline'] ?? false,
      );
}
