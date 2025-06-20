// lib/services/network_service.dart

import 'dart:io';
import 'package:auth_app/models/network_device.dart';
import 'package:auth_app/pages/configration/services/network_config.dart';
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
// استبدال دالة discoverNetworkDevices في NetworkService
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
        final stream = NetworkAnalyzer.discover2(subnet, 9100, timeout: Duration(seconds: 5));

        await for (NetworkAddress addr in stream) {
          if (addr.exists) {
            String? deviceName = await _getDeviceName(addr.ip);
            String? macAddress = await _getMacAddress(addr.ip);

            devices.add(NetworkDevice(
              ip: addr.ip,
              name: deviceName ?? 'Unknown Device',
              macAddress: macAddress ?? 'Unknown MAC',
              port: 9100,
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

  // البحث المتقدم عن الطابعات مع عدة منافذ
  static Future<List<NetworkDevice>> discoverPrintersAdvanced() async {
    List<NetworkDevice> devices = [];

    try {
      if (!await requestPermissions()) {
        throw Exception('لم يتم منح الأذونات المطلوبة');
      }

      final networkInfo = await getNetworkInfo();
      final subnet = _getSubnet(networkInfo['wifiIP']);

      if (subnet == null || subnet.isEmpty) {
        throw Exception('لا يمكن تحديد الشبكة الفرعية');
      }

      // منافذ الطابعات الشائعة
      List<int> printerPorts = [9100, 631, 515, 721];

      for (int port in printerPorts) {
        try {
          final stream = NetworkAnalyzer.discover2(subnet, port, timeout: Duration(seconds: 3));

          await for (NetworkAddress addr in stream) {
            if (addr.exists) {
              // التحقق من أن الجهاز طابعة فعلاً
              bool isPrinter = await _verifyPrinterDevice(addr.ip, port);

              if (isPrinter) {
                String deviceName = 'Printer_${addr.ip.split('.').last}';
                String macAddress = _generateMacAddress(addr.ip);

                // تجنب الأجهزة المكررة
                bool alreadyExists = devices.any((device) => device.ip == addr.ip);
                if (!alreadyExists) {
                  devices.add(NetworkDevice(
                    ip: addr.ip,
                    name: deviceName,
                    macAddress: macAddress,
                    isOnline: true,
                    port: port,
                  ));
                }
              }
            }
          }
        } catch (e) {
          print('Error scanning port $port: $e');
          continue;
        }
      }
    } catch (e) {
      print('Error in advanced discovery: $e');
      rethrow;
    }

    return devices;
  }

  static Future<bool> _verifyPrinterDevice(String ip, int port) async {
    try {
      final socket = await Socket.connect(ip, port, timeout: Duration(seconds: 2));

      // إرسال أمر بسيط للتحقق من استجابة الطابعة
      if (port == 9100) {
        try {
          socket.write('\x1B@'); // ESC @ - Reset command
          await Future.delayed(Duration(milliseconds: 300));
        } catch (e) {
          print('Error sending printer command: $e');
        }
      }

      await socket.close();
      return true;
    } catch (e) {
      print('Error verifying printer device $ip:$port: $e');
      return false;
    }
  }

  // توليد MAC address وهمي بناءً على IP
  static String _generateMacAddress(String ip) {
    final parts = ip.split('.');
    final lastOctet = int.parse(parts[3]);
    final secondLastOctet = int.parse(parts[2]);

    return '00:1A:2B:${secondLastOctet.toRadixString(16).padLeft(2, '0').toUpperCase()}:'
        '${lastOctet.toRadixString(16).padLeft(2, '0').toUpperCase()}:'
        '${(lastOctet + 1).toRadixString(16).padLeft(2, '0').toUpperCase()}';
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
