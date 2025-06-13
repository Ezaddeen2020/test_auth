// lib/services/network_service.dart

import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:auth_app/classes/shared_preference.dart';

class NetworkService {
  static final NetworkInfo _networkInfo = NetworkInfo();

  // طلب الأذونات المطلوبة
  static Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> permissions = await [
      Permission.location,
      Permission.nearbyWifiDevices,
    ].request();

    bool allGranted = permissions.values.every(
      (status) => status == PermissionStatus.granted,
    );

    return allGranted;
  }

  // الحصول على معلومات الشبكة الحالية
  static Future<Map<String, String?>> getNetworkInfo() async {
    try {
      final wifiName = await _networkInfo.getWifiName();
      final wifiIP = await _networkInfo.getWifiIP();
      final wifiBSSID = await _networkInfo.getWifiBSSID();
      final wifiGatewayIP = await _networkInfo.getWifiGatewayIP();
      final wifiSubmask = await _networkInfo.getWifiSubmask();

      return {
        'wifiName': wifiName,
        'wifiIP': wifiIP,
        'wifiBSSID': wifiBSSID,
        'wifiGatewayIP': wifiGatewayIP,
        'wifiSubmask': wifiSubmask,
      };
    } catch (e) {
      print('Error getting network info: $e');
      return {};
    }
  }

  // البحث عن الأجهزة على الشبكة
  static Future<List<NetworkDevice>> discoverNetworkDevices() async {
    List<NetworkDevice> devices = [];

    try {
      // التحقق من الأذونات
      if (!await requestPermissions()) {
        throw Exception('لم يتم منح الأذونات المطلوبة');
      }

      final networkInfo = await getNetworkInfo();
      final subnet = _getSubnet(networkInfo['wifiIP']);

      if (subnet != null) {
        final stream = NetworkAnalyzer.discover2(subnet, 9100); // Port 9100 للطابعات

        await for (NetworkAddress addr in stream) {
          if (addr.exists) {
            String? deviceName = await _getDeviceName(addr.ip);
            String? macAddress = await _getMacAddress(addr.ip);

            devices.add(NetworkDevice(
              ip: addr.ip,
              name: deviceName ?? 'Unknown Device',
              macAddress: macAddress ?? 'Unknown MAC',
              isOnline: true,
            ));
          }
        }
      }
    } catch (e) {
      print('Error discovering devices: $e');
    }

    return devices;
  }

  // استخراج الشبكة الفرعية من IP
  static String? _getSubnet(String? ip) {
    if (ip == null) return null;

    List<String> parts = ip.split('.');
    if (parts.length == 4) {
      return '${parts[0]}.${parts[1]}.${parts[2]}';
    }
    return null;
  }

  // الحصول على اسم الجهاز من IP
  static Future<String?> _getDeviceName(String ip) async {
    try {
      final result = await InternetAddress.lookup(ip);
      if (result.isNotEmpty) {
        return result.first.host;
      }
    } catch (e) {
      print('Error getting device name for $ip: $e');
    }
    return null;
  }

  // محاولة الحصول على MAC Address (محدود في Flutter)
  static Future<String?> _getMacAddress(String ip) async {
    // في Flutter، الحصول على MAC Address صعب جداً
    // هذه طريقة محدودة ولن تعمل في جميع الحالات
    try {
      if (Platform.isAndroid) {
        // يمكن استخدام ARP table في Android
        final result = await Process.run('cat', ['/proc/net/arp']);
        final lines = result.stdout.toString().split('\n');

        for (String line in lines) {
          if (line.contains(ip)) {
            final parts = line.split(RegExp(r'\s+'));
            if (parts.length >= 4) {
              return parts[3].toUpperCase();
            }
          }
        }
      }
    } catch (e) {
      print('Error getting MAC address: $e');
    }
    return null;
  }

  // فحص الاتصال بجهاز معين
  static Future<bool> pingDevice(String ip) async {
    try {
      final result = await Process.run('ping', ['-c', '1', ip]);
      return result.exitCode == 0;
    } catch (e) {
      print('Error pinging $ip: $e');
      return false;
    }
  }

  // حفظ إعدادات الشبكة
  static Future<void> saveNetworkConfiguration({
    required String connectionType,
    required String printerMac,
    required String deviceName,
    String? printerIP,
  }) async {
    await Preferences.setString('connection_type', connectionType);
    await Preferences.setString('printer_mac_address', printerMac);
    await Preferences.setString('device_name', deviceName);
    if (printerIP != null) {
      await Preferences.setString('printer_ip', printerIP);
    }
    await Preferences.setBoolean('configuration_saved', true);

    // حفظ تاريخ التكوين
    await Preferences.setString('configuration_date', DateTime.now().toIso8601String());
  }

  // قراءة إعدادات الشبكة المحفوظة
  static NetworkConfiguration getNetworkConfiguration() {
    return NetworkConfiguration(
      connectionType: Preferences.getString('connection_type'),
      printerMac: Preferences.getString('printer_mac_address'),
      deviceName: Preferences.getString('device_name'),
      printerIP: Preferences.getString('printer_ip'),
      isConfigured: Preferences.getBoolean('configuration_saved'),
      configurationDate: Preferences.getString('configuration_date'),
    );
  }

  // التحقق من صحة إعدادات الشبكة
  static bool validateNetworkConfiguration() {
    final config = getNetworkConfiguration();
    return config.isConfigured && config.printerMac.isNotEmpty && config.deviceName.isNotEmpty;
  }

  // إعادة تعيين إعدادات الشبكة
  static Future<void> resetNetworkConfiguration() async {
    await Preferences.clearKeyData('connection_type');
    await Preferences.clearKeyData('printer_mac_address');
    await Preferences.clearKeyData('device_name');
    await Preferences.clearKeyData('printer_ip');
    await Preferences.clearKeyData('configuration_saved');
    await Preferences.clearKeyData('configuration_date');
  }
}

// كلاس لتمثيل جهاز الشبكة
class NetworkDevice {
  final String ip;
  final String name;
  final String macAddress;
  final bool isOnline;

  NetworkDevice({
    required this.ip,
    required this.name,
    required this.macAddress,
    required this.isOnline,
  });

  Map<String, dynamic> toJson() {
    return {
      'ip': ip,
      'name': name,
      'macAddress': macAddress,
      'isOnline': isOnline,
    };
  }

  factory NetworkDevice.fromJson(Map<String, dynamic> json) {
    return NetworkDevice(
      ip: json['ip'] ?? '',
      name: json['name'] ?? '',
      macAddress: json['macAddress'] ?? '',
      isOnline: json['isOnline'] ?? false,
    );
  }
}

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
