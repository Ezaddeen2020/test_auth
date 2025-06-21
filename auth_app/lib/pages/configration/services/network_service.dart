// // lib/services/network_service.dart

// import 'dart:io';
// import 'package:auth_app/models/network_device.dart';
// import 'package:auth_app/pages/configration/services/network_config.dart';
// import 'package:network_info_plus/network_info_plus.dart';
// import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:auth_app/classes/shared_preference.dart';

// class NetworkService {
//   static final NetworkInfo _networkInfo = NetworkInfo();

//   /// طلب الأذونات المطلوبة
//   static Future<bool> requestPermissions() async {
//     try {
//       Map<Permission, PermissionStatus> permissions = await [
//         Permission.location,
//         Permission.nearbyWifiDevices,
//       ].request();

//       bool allGranted = permissions.values.every(
//         (status) => status == PermissionStatus.granted,
//       );

//       return allGranted;
//     } catch (e) {
//       print('Error requesting permissions: $e');
//       return false;
//     }
//   }

//   /// الحصول على معلومات الشبكة الحالية
//   static Future<Map<String, String?>> getNetworkInfo() async {
//     try {
//       final wifiName = await _networkInfo.getWifiName();
//       final wifiIP = await _networkInfo.getWifiIP();
//       final wifiBSSID = await _networkInfo.getWifiBSSID();
//       final wifiGatewayIP = await _networkInfo.getWifiGatewayIP();
//       final wifiSubmask = await _networkInfo.getWifiSubmask();

//       return {
//         'wifiName': wifiName?.replaceAll('"', '') ?? 'Unknown Network',
//         'wifiIP': wifiIP ?? 'Not Connected',
//         'wifiBSSID': wifiBSSID ?? 'Unknown',
//         'wifiGatewayIP': wifiGatewayIP ?? 'Unknown',
//         'wifiSubmask': wifiSubmask ?? 'Unknown',
//       };
//     } catch (e) {
//       print('Error getting network info: $e');
//       return {
//         'wifiName': 'Error',
//         'wifiIP': 'Error',
//         'wifiBSSID': 'Error',
//         'wifiGatewayIP': 'Error',
//         'wifiSubmask': 'Error',
//       };
//     }
//   }

//   /// البحث المتقدم عن الطابعات مع عدة منافذ
//   static Future<List<NetworkDevice>> discoverPrintersAdvanced() async {
//     List<NetworkDevice> devices = [];

//     try {
//       if (!await requestPermissions()) {
//         throw Exception('لم يتم منح الأذونات المطلوبة');
//       }

//       final networkInfo = await getNetworkInfo();
//       final subnet = _getSubnet(networkInfo['wifiIP']);

//       if (subnet == null || subnet.isEmpty) {
//         throw Exception('لا يمكن تحديد الشبكة الفرعية');
//       }

//       // منافذ الطابعات الشائعة
//       List<int> printerPorts = [9100, 631, 515, 721];

//       for (int port in printerPorts) {
//         try {
//           final stream =
//               NetworkAnalyzer.discover2(subnet, port, timeout: const Duration(seconds: 3));

//           await for (NetworkAddress addr in stream) {
//             if (addr.exists) {
//               // التحقق من أن الجهاز طابعة فعلاً
//               bool isPrinter = await _verifyPrinterDevice(addr.ip, port);

//               if (isPrinter) {
//                 String deviceName = 'Printer_${addr.ip.split('.').last}';
//                 String macAddress = await _getMacAddress(addr.ip) ?? _generateMacAddress(addr.ip);

//                 // تجنب الأجهزة المكررة
//                 bool alreadyExists = devices.any((device) => device.ip == addr.ip);
//                 if (!alreadyExists) {
//                   devices.add(NetworkDevice(
//                     ip: addr.ip,
//                     name: deviceName,
//                     macAddress: macAddress,
//                     isOnline: true,
//                     port: port,
//                   ));
//                 }
//               }
//             }
//           }
//         } catch (e) {
//           print('Error scanning port $port: $e');
//           continue;
//         }
//       }
//     } catch (e) {
//       print('Error in advanced discovery: $e');
//       rethrow;
//     }

//     return devices;
//   }

//   /// التحقق من أن الجهاز طابعة حقيقية
//   static Future<bool> _verifyPrinterDevice(String ip, int port) async {
//     try {
//       final socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 2));

//       // إرسال أمر بسيط للتحقق من استجابة الطابعة
//       if (port == 9100) {
//         try {
//           socket.write('\x1B@'); // ESC @ - Reset command
//           await Future.delayed(const Duration(milliseconds: 300));
//         } catch (e) {
//           print('Error sending printer command: $e');
//         }
//       }

//       await socket.close();
//       return true;
//     } catch (e) {
//       print('Error verifying printer device $ip:$port: $e');
//       return false;
//     }
//   }

//   /// توليد MAC address وهمي بناءً على IP
//   static String _generateMacAddress(String ip) {
//     final parts = ip.split('.');
//     if (parts.length < 4) return '00:1A:2B:00:00:01';

//     final lastOctet = int.parse(parts[3]);
//     final secondLastOctet = int.parse(parts[2]);

//     return '00:1A:2B:${secondLastOctet.toRadixString(16).padLeft(2, '0').toUpperCase()}:'
//         '${lastOctet.toRadixString(16).padLeft(2, '0').toUpperCase()}:'
//         '${(lastOctet + 1).toRadixString(16).padLeft(2, '0').toUpperCase()}';
//   }

//   /// استخراج الشبكة الفرعية من IP
//   static String? _getSubnet(String? ip) {
//     if (ip == null || ip.isEmpty || ip == 'Not Connected') return null;

//     List<String> parts = ip.split('.');
//     if (parts.length == 4) {
//       return '${parts[0]}.${parts[1]}.${parts[2]}';
//     }
//     return null;
//   }

//   /// محاولة الحصول على MAC Address (محدود في Flutter)
//   static Future<String?> _getMacAddress(String ip) async {
//     try {
//       if (Platform.isAndroid) {
//         final result = await Process.run('cat', ['/proc/net/arp']);
//         final lines = result.stdout.toString().split('\n');

//         for (String line in lines) {
//           if (line.contains(ip)) {
//             final parts = line.split(RegExp(r'\s+'));
//             if (parts.length >= 4 && parts[3].contains(':')) {
//               return parts[3].toUpperCase();
//             }
//           }
//         }
//       }
//     } catch (e) {
//       print('Error getting MAC address: $e');
//     }
//     return null;
//   }

//   /// فحص الاتصال بجهاز معين
//   static Future<bool> pingDevice(String ip) async {
//     try {
//       final result = await Process.run('ping', ['-c', '1', '-W', '3', ip]);
//       return result.exitCode == 0;
//     } catch (e) {
//       print('Error pinging $ip: $e');
//       // محاولة اتصال مباشر كبديل
//       try {
//         final socket = await Socket.connect(ip, 9100, timeout: const Duration(seconds: 2));
//         await socket.close();
//         return true;
//       } catch (e) {
//         return false;
//       }
//     }
//   }

//   /// حفظ إعدادات الشبكة
//   static Future<void> saveNetworkConfiguration({
//     required String connectionType,
//     required String printerMac,
//     required String deviceName,
//     String? printerIP,
//     String? networkName,
//     String? networkIP,
//     String? gateway,
//     String? subnet,
//   }) async {
//     try {
//       await Future.wait([
//         Preferences.setString('connection_type', connectionType),
//         Preferences.setString('printer_mac_address', printerMac),
//         Preferences.setString('device_name', deviceName),
//         Preferences.setString('printer_ip', printerIP ?? ''),
//         Preferences.setString('network_name', networkName ?? ''),
//         Preferences.setString('network_ip', networkIP ?? ''),
//         Preferences.setString('gateway', gateway ?? ''),
//         Preferences.setString('subnet', subnet ?? ''),
//         Preferences.setBoolean('configuration_saved', true),
//         Preferences.setString('configuration_date', DateTime.now().toIso8601String()),
//       ]);
//     } catch (e) {
//       print('Error saving network configuration: $e');
//       rethrow;
//     }
//   }

//   /// قراءة إعدادات الشبكة المحفوظة
//   static NetworkConfiguration getNetworkConfiguration() {
//     try {
//       return NetworkConfiguration(
//         connectionType: Preferences.getString('connection_type'),
//         printerMac: Preferences.getString('printer_mac_address'),
//         deviceName: Preferences.getString('device_name'),
//         printerIP: Preferences.getString('printer_ip'),
//         networkName: Preferences.getString('network_name'),
//         networkIP: Preferences.getString('network_ip'),
//         gateway: Preferences.getString('gateway'),
//         subnet: Preferences.getString('subnet'),
//         isConfigured: Preferences.getBoolean('configuration_saved'),
//         configurationDate: Preferences.getString('configuration_date'),
//       );
//     } catch (e) {
//       print('Error getting network configuration: $e');
//       return NetworkConfiguration.empty();
//     }
//   }

//   /// التحقق من صحة إعدادات الشبكة
//   static bool validateNetworkConfiguration() {
//     try {
//       final config = getNetworkConfiguration();
//       return config.isConfigured && config.printerMac.isNotEmpty && config.deviceName.isNotEmpty;
//     } catch (e) {
//       print('Error validating network configuration: $e');
//       return false;
//     }
//   }

//   /// إعادة تعيين إعدادات الشبكة
//   static Future<void> resetNetworkConfiguration() async {
//     try {
//       await Future.wait([
//         Preferences.clearKeyData('connection_type'),
//         Preferences.clearKeyData('printer_mac_address'),
//         Preferences.clearKeyData('device_name'),
//         Preferences.clearKeyData('printer_ip'),
//         Preferences.clearKeyData('network_name'),
//         Preferences.clearKeyData('network_ip'),
//         Preferences.clearKeyData('gateway'),
//         Preferences.clearKeyData('subnet'),
//         Preferences.clearKeyData('configuration_saved'),
//         Preferences.clearKeyData('configuration_date'),
//       ]);
//     } catch (e) {
//       print('Error resetting network configuration: $e');
//       rethrow;
//     }
//   }
// }

// /// كلاس لتمثيل إعدادات الشبكة
// class NetworkConfiguration {
//   final String connectionType;
//   final String printerMac;
//   final String deviceName;
//   final String printerIP;
//   final String networkName;
//   final String networkIP;
//   final String gateway;
//   final String subnet;
//   final bool isConfigured;
//   final String configurationDate;

//   NetworkConfiguration({
//     required this.connectionType,
//     required this.printerMac,
//     required this.deviceName,
//     required this.printerIP,
//     required this.networkName,
//     required this.networkIP,
//     required this.gateway,
//     required this.subnet,
//     required this.isConfigured,
//     required this.configurationDate,
//   });

//   /// إنشاء كونفيجريشن فارغ
//   factory NetworkConfiguration.empty() {
//     return NetworkConfiguration(
//       connectionType: 'LAN',
//       printerMac: '',
//       deviceName: '',
//       printerIP: '',
//       networkName: '',
//       networkIP: '',
//       gateway: '',
//       subnet: '',
//       isConfigured: false,
//       configurationDate: '',
//     );
//   }

//   /// تحويل إلى JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'connectionType': connectionType,
//       'printerMac': printerMac,
//       'deviceName': deviceName,
//       'printerIP': printerIP,
//       'networkName': networkName,
//       'networkIP': networkIP,
//       'gateway': gateway,
//       'subnet': subnet,
//       'isConfigured': isConfigured,
//       'configurationDate': configurationDate,
//     };
//   }

//   /// إنشاء من JSON
//   factory NetworkConfiguration.fromJson(Map<String, dynamic> json) {
//     return NetworkConfiguration(
//       connectionType: json['connectionType'] ?? 'LAN',
//       printerMac: json['printerMac'] ?? '',
//       deviceName: json['deviceName'] ?? '',
//       printerIP: json['printerIP'] ?? '',
//       networkName: json['networkName'] ?? '',
//       networkIP: json['networkIP'] ?? '',
//       gateway: json['gateway'] ?? '',
//       subnet: json['subnet'] ?? '',
//       isConfigured: json['isConfigured'] ?? false,
//       configurationDate: json['configurationDate'] ?? '',
//     );
//   }

//   /// نسخ مع تعديلات
//   NetworkConfiguration copyWith({
//     String? connectionType,
//     String? printerMac,
//     String? deviceName,
//     String? printerIP,
//     String? networkName,
//     String? networkIP,
//     String? gateway,
//     String? subnet,
//     bool? isConfigured,
//     String? configurationDate,
//   }) {
//     return NetworkConfiguration(
//       connectionType: connectionType ?? this.connectionType,
//       printerMac: printerMac ?? this.printerMac,
//       deviceName: deviceName ?? this.deviceName,
//       printerIP: printerIP ?? this.printerIP,
//       networkName: networkName ?? this.networkName,
//       networkIP: networkIP ?? this.networkIP,
//       gateway: gateway ?? this.gateway,
//       subnet: subnet ?? this.subnet,
//       isConfigured: isConfigured ?? this.isConfigured,
//       configurationDate: configurationDate ?? this.configurationDate,
//     );
//   }
// }

// lib/services/network_service.dart

// lib/services/network_service.dart

// lib/services/network_service.dart
// lib/services/network_service_hybrid.dart - الكود المهجن العامل

// lib/services/network_service_hybrid.dart - الكود المهجن العامل

import 'dart:io';
import 'dart:async';
import 'package:auth_app/models/network_device.dart';
import 'package:auth_app/pages/configration/services/network_config.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart'; // المكتبة المهمة!
import 'package:permission_handler/permission_handler.dart';
import 'package:auth_app/classes/shared_preference.dart';

class NetworkService {
  static final NetworkInfo _networkInfo = NetworkInfo();
  static final List<Socket> _activeSockets = [];
  static bool _cancelled = false;
  static Timer? _timeoutTimer;

  /// طلب الأذونات (من الكود الأصلي)
  static Future<bool> requestPermissions() async {
    try {
      Map<Permission, PermissionStatus> permissions = await [
        Permission.location,
        Permission.nearbyWifiDevices,
      ].request();

      bool allGranted = permissions.values.every(
        (status) => status == PermissionStatus.granted,
      );

      if (!allGranted) {
        print('❌ Permissions not granted');
      }
      return allGranted;
    } catch (e) {
      print('❌ Permission error: $e');
      return false;
    }
  }

  /// معلومات الشبكة (محسنة)
  static Future<Map<String, String?>> getNetworkInfo() async {
    try {
      final wifiName = await _networkInfo.getWifiName();
      final wifiIP = await _networkInfo.getWifiIP();
      final wifiBSSID = await _networkInfo.getWifiBSSID();
      final wifiGatewayIP = await _networkInfo.getWifiGatewayIP();
      final wifiSubmask = await _networkInfo.getWifiSubmask();

      print('🌐 Network Info:');
      print('   Name: $wifiName');
      print('   IP: $wifiIP');
      print('   Gateway: $wifiGatewayIP');
      print('   Submask: $wifiSubmask');

      return {
        'wifiName': wifiName?.replaceAll('"', '') ?? 'Unknown Network',
        'wifiIP': wifiIP ?? 'Not Connected',
        'wifiBSSID': wifiBSSID ?? 'Unknown',
        'wifiGatewayIP': wifiGatewayIP ?? 'Unknown',
        'wifiSubmask': wifiSubmask ?? 'Unknown',
      };
    } catch (e) {
      print('❌ Network info error: $e');
      return {
        'wifiName': 'Error',
        'wifiIP': 'Error',
        'wifiBSSID': 'Error',
        'wifiGatewayIP': 'Error',
        'wifiSubmask': 'Error',
      };
    }
  }

  /// إلغاء العمليات
  static Future<void> cancelOperations() async {
    print('🛑 Cancelling all network operations...');
    _cancelled = true;

    _timeoutTimer?.cancel();
    _timeoutTimer = null;

    final sockets = List<Socket>.from(_activeSockets);
    _activeSockets.clear();

    for (Socket socket in sockets) {
      try {
        await socket.close().timeout(Duration(milliseconds: 500));
      } catch (e) {
        try {
          socket.destroy();
        } catch (e2) {}
      }
    }

    await Future.delayed(Duration(milliseconds: 100));
    _cancelled = false;
    print('✅ All operations cancelled');
  }

  /// البحث المتقدم عن الطابعات (محسن لتجنب أخطاء Windows)
  static Future<List<NetworkDevice>> discoverPrintersAdvanced() async {
    if (_cancelled) return [];

    print('🔍 Starting ENHANCED printer discovery...');
    List<NetworkDevice> devices = [];

    try {
      // التحقق من الأذونات
      if (!await requestPermissions()) {
        throw Exception('لم يتم منح الأذونات المطلوبة');
      }

      final networkInfo = await getNetworkInfo();
      final subnet = _getSubnet(networkInfo['wifiIP']);

      if (subnet == null || subnet.isEmpty) {
        throw Exception('لا يمكن تحديد الشبكة الفرعية');
      }

      print('🎯 Enhanced scanning subnet: $subnet');

      // منافذ الطابعات الشائعة (مرتبة حسب الأولوية)
      List<int> printerPorts = [9100, 631, 515]; // حذف 721 لتقليل الأخطاء

      // البحث المحسن مع معالجة أفضل للأخطاء
      for (int port in printerPorts) {
        if (_cancelled) break;

        print('🔍 Enhanced scan port $port...');

        try {
          // استخدام timeout أقصر لتجنب التعليق
          final completer = Completer<List<NetworkDevice>>();
          final portDevices = <NetworkDevice>[];

          Timer(Duration(seconds: 8), () {
            if (!completer.isCompleted) {
              print('⏰ Port $port scan timeout');
              completer.complete(portDevices);
            }
          });

          // فحص NetworkAnalyzer مع معالجة محسنة للأخطاء
          _scanPortSafely(subnet, port, portDevices, completer);

          final foundDevices = await completer.future;
          devices.addAll(foundDevices);

          print('📊 Port $port found ${foundDevices.length} devices');
        } catch (e) {
          print('⚠️ Port $port scan failed: ${e.toString().substring(0, 100)}...');
          continue;
        }

        // انتظار قصير بين المنافذ لتقليل الضغط على الشبكة
        if (!_cancelled) {
          await Future.delayed(Duration(milliseconds: 500));
        }
      }

      // البحث اليدوي المحسن إذا لم نجد أجهزة كافية
      if (devices.length < 2 && !_cancelled) {
        print('🎯 Starting enhanced manual scan...');
        final manualDevices = await _enhancedManualScan(subnet);
        devices.addAll(manualDevices);
      }

      final uniqueDevices = _removeDuplicates(devices);
      print('🏆 Total unique devices found: ${uniqueDevices.length}');

      return uniqueDevices;
    } catch (e) {
      print('❌ Discovery error: ${e.toString()}');
      return devices; // إرجاع ما وجدناه حتى لو حدث خطأ
    }
  }

  /// فحص منفذ بطريقة آمنة
  static void _scanPortSafely(String subnet, int port, List<NetworkDevice> devices,
      Completer<List<NetworkDevice>> completer) async {
    try {
      final stream =
          NetworkAnalyzer.discover2(subnet, port, timeout: Duration(seconds: 3) // timeout أقصر
              );

      await for (NetworkAddress addr in stream) {
        if (_cancelled || completer.isCompleted) break;

        if (addr.exists) {
          print('📡 Response: ${addr.ip}:$port');

          // التحقق السريع من الطابعة
          try {
            bool isPrinter = await _quickVerifyPrinter(addr.ip, port);

            if (isPrinter) {
              final device = NetworkDevice(
                ip: addr.ip,
                name: 'Printer_${addr.ip.split('.').last}',
                macAddress: _generateMacAddress(addr.ip),
                isOnline: true,
                port: port,
              );

              // تجنب المكررات
              if (!devices.any((d) => d.ip == addr.ip)) {
                devices.add(device);
                print('✅ Added printer: ${addr.ip}:$port');
              }
            }
          } catch (verifyError) {
            print('⚠️ Verify error for ${addr.ip}:$port');
            // إضافة الجهاز حتى لو فشل التحقق
            if (!devices.any((d) => d.ip == addr.ip)) {
              devices.add(NetworkDevice(
                ip: addr.ip,
                name: 'Device_${addr.ip.split('.').last}',
                macAddress: _generateMacAddress(addr.ip),
                isOnline: true,
                port: port,
              ));
            }
          }
        }
      }

      if (!completer.isCompleted) {
        completer.complete(devices);
      }
    } catch (e) {
      print('🚨 NetworkAnalyzer error: ${e.toString().substring(0, 50)}...');
      if (!completer.isCompleted) {
        completer.complete(devices);
      }
    }
  }

  /// التحقق السريع من الطابعة (محسن)
  static Future<bool> _quickVerifyPrinter(String ip, int port) async {
    Socket? socket;
    try {
      // timeout أقصر للتحقق السريع
      socket = await Socket.connect(ip, port, timeout: Duration(seconds: 1));
      _activeSockets.add(socket);

      // إرسال أمر بسيط للمنفذ 9100 فقط
      if (port == 9100) {
        try {
          socket.write('\x1B@'); // ESC @ - Reset command
          await Future.delayed(Duration(milliseconds: 100)); // انتظار أقصر
        } catch (e) {
          // تجاهل أخطاء الكتابة
        }
      }

      await socket.close();
      _activeSockets.remove(socket);
      return true;
    } catch (e) {
      if (socket != null) {
        _activeSockets.remove(socket);
        try {
          await socket.close();
        } catch (closeError) {
          try {
            socket.destroy();
          } catch (destroyError) {}
        }
      }
      return false;
    }
  }

  /// البحث اليدوي المحسن
  static Future<List<NetworkDevice>> _enhancedManualScan(String subnet) async {
    List<NetworkDevice> devices = [];

    // IPs محددة أكثر احتمالاً للطابعات
    final targetIPs = ['$subnet.100', '$subnet.101', '$subnet.110', '$subnet.200'];

    print('🎯 Enhanced manual scan for ${targetIPs.length} target IPs...');

    for (String ip in targetIPs) {
      if (_cancelled) break;

      try {
        // جرب المنفذ الأكثر شيوعاً أولاً
        if (await _quickTestConnection(ip, 9100)) {
          devices.add(NetworkDevice(
            ip: ip,
            name: 'Manual_Printer_${ip.split('.').last}',
            macAddress: _generateMacAddress(ip),
            port: 9100,
            isOnline: true,
          ));
          print('✅ Manual found: $ip:9100');
        }
      } catch (e) {
        print('⚠️ Manual scan error for $ip: ${e.toString().substring(0, 30)}...');
      }

      // انتظار قصير بين الفحوصات
      if (!_cancelled) {
        await Future.delayed(Duration(milliseconds: 300));
      }
    }

    return devices;
  }

  /// اختبار الاتصال السريع
  static Future<bool> _quickTestConnection(String ip, int port) async {
    if (_cancelled || !_isValidIP(ip)) return false;

    Socket? socket;
    try {
      socket = await Socket.connect(ip, port, timeout: Duration(milliseconds: 800));
      _activeSockets.add(socket);

      await socket.close();
      _activeSockets.remove(socket);
      return true;
    } catch (e) {
      if (socket != null) {
        _activeSockets.remove(socket);
        try {
          await socket.close();
        } catch (closeError) {
          try {
            socket.destroy();
          } catch (destroyError) {}
        }
      }
      return false;
    }
  }

  /// محاولة الحصول على MAC Address (من الكود الأصلي)
  static Future<String?> _getMacAddress(String ip) async {
    try {
      if (Platform.isWindows) {
        final result = await Process.run('arp', ['-a', ip]).timeout(Duration(seconds: 3));

        if (result.exitCode == 0) {
          final output = result.stdout.toString();
          final lines = output.split('\n');

          for (String line in lines) {
            if (line.contains(ip)) {
              final regex = RegExp(
                  r'([0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2}-[0-9a-fA-F]{2})');
              final match = regex.firstMatch(line);
              if (match != null) {
                return match.group(1)?.replaceAll('-', ':').toUpperCase();
              }
            }
          }
        }
      } else if (Platform.isAndroid) {
        // للأندرويد
        final result = await Process.run('cat', ['/proc/net/arp']).timeout(Duration(seconds: 3));

        if (result.exitCode == 0) {
          final lines = result.stdout.toString().split('\n');
          for (String line in lines) {
            if (line.contains(ip)) {
              final parts = line.split(RegExp(r'\s+'));
              if (parts.length >= 4 && parts[3].contains(':')) {
                return parts[3].toUpperCase();
              }
            }
          }
        }
      }
    } catch (e) {
      print('⚠️ Error getting MAC address for $ip: $e');
    }

    return null;
  }

  /// توليد MAC address (من الكود الأصلي)
  static String _generateMacAddress(String ip) {
    final parts = ip.split('.');
    if (parts.length < 4) return '00:1A:2B:00:00:01';

    final lastOctet = int.parse(parts[3]);
    final secondLastOctet = int.parse(parts[2]);

    return '00:1A:2B:${secondLastOctet.toRadixString(16).padLeft(2, '0').toUpperCase()}:'
        '${lastOctet.toRadixString(16).padLeft(2, '0').toUpperCase()}:'
        '${(lastOctet + 1).toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  /// فحص جهاز بـ ping (محسن مع معالجة أفضل للأخطاء)
  static Future<bool> pingDevice(String ip) async {
    if (_cancelled || !_isValidIP(ip)) return false;

    print('🏓 Enhanced ping: $ip');

    try {
      // جرب الاتصال المباشر أولاً مع timeout قصير
      for (int port in [9100, 631]) {
        // منافذ أساسية فقط
        if (await _quickTestConnection(ip, port)) {
          print('✅ Direct connection: $ip:$port');
          return true;
        }
      }

      // جرب ping command مع timeout محدود
      try {
        final args =
            Platform.isWindows ? ['-n', '1', '-w', '1000', ip] : ['-c', '1', '-W', '1', ip];

        // final result = await Process.run('ping', args, timeout: Duration(seconds: 3));
        final result = await Process.run(
          'ping',
          Platform.isWindows ? ['-n', '1', '-w', '2000', ip] : ['-c', '1', '-W', '2', ip],
        ).timeout(Duration(seconds: 5));
        final success = result.exitCode == 0;
        print(success ? '✅ Ping OK: $ip' : '❌ Ping failed: $ip');
        return success;
      } catch (pingError) {
        print('⚠️ Ping command failed for $ip');
        return false;
      }
    } catch (e) {
      print('❌ Ping error for $ip: ${e.toString().substring(0, 50)}...');
      return false;
    }
  }

  /// التحقق من صحة IP
  static bool _isValidIP(String ip) {
    if (ip.isEmpty) return false;

    final parts = ip.split('.');
    if (parts.length != 4) return false;

    for (final part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }

    return true;
  }

  /// إزالة المكررات
  static List<NetworkDevice> _removeDuplicates(List<NetworkDevice> devices) {
    final Map<String, NetworkDevice> unique = {};
    for (final device in devices) {
      unique[device.ip] = device;
    }
    print('📋 Found ${unique.length} unique devices');
    return unique.values.toList();
  }

  /// استخراج الشبكة الفرعية (من الكود الأصلي)
  static String? _getSubnet(String? ip) {
    if (ip == null || ip.isEmpty || ip == 'Not Connected') return null;

    List<String> parts = ip.split('.');
    if (parts.length == 4) {
      return '${parts[0]}.${parts[1]}.${parts[2]}';
    }
    return null;
  }

  // باقي الوظائف تبقى كما هي من الكود الأصلي...
  static Future<void> saveNetworkConfiguration({
    required String connectionType,
    required String printerMac,
    required String deviceName,
    String? printerIP,
    String? networkName,
    String? networkIP,
    String? gateway,
    String? subnet,
  }) async {
    try {
      await Future.wait([
        Preferences.setString('connection_type', connectionType),
        Preferences.setString('printer_mac_address', printerMac),
        Preferences.setString('device_name', deviceName),
        Preferences.setString('printer_ip', printerIP ?? ''),
        Preferences.setString('network_name', networkName ?? ''),
        Preferences.setString('network_ip', networkIP ?? ''),
        Preferences.setString('gateway', gateway ?? ''),
        Preferences.setString('subnet', subnet ?? ''),
        Preferences.setBoolean('configuration_saved', true),
        Preferences.setString('configuration_date', DateTime.now().toIso8601String()),
      ]);
      print('✅ Network configuration saved successfully');
    } catch (e) {
      print('❌ Error saving network configuration: $e');
      rethrow;
    }
  }

  static NetworkConfiguration getNetworkConfiguration() {
    try {
      return NetworkConfiguration(
        connectionType: Preferences.getString('connection_type'),
        printerMac: Preferences.getString('printer_mac_address'),
        deviceName: Preferences.getString('device_name'),
        printerIP: Preferences.getString('printer_ip'),
        networkName: Preferences.getString('network_name'),
        networkIP: Preferences.getString('network_ip'),
        gateway: Preferences.getString('gateway'),
        subnet: Preferences.getString('subnet'),
        isConfigured: Preferences.getBoolean('configuration_saved'),
        configurationDate: Preferences.getString('configuration_date'),
      );
    } catch (e) {
      print('⚠️ Error getting network configuration: $e');
      return NetworkConfiguration.empty();
    }
  }

  static bool validateNetworkConfiguration() {
    try {
      final config = getNetworkConfiguration();
      return config.isConfigured && config.printerMac.isNotEmpty && config.deviceName.isNotEmpty;
    } catch (e) {
      print('⚠️ Error validating network configuration: $e');
      return false;
    }
  }

  static Future<void> resetNetworkConfiguration() async {
    try {
      final keys = [
        'connection_type',
        'printer_mac_address',
        'device_name',
        'printer_ip',
        'network_name',
        'network_ip',
        'gateway',
        'subnet',
        'configuration_saved',
        'configuration_date'
      ];

      await Future.wait(keys.map((key) => Preferences.clearKeyData(key)));
      print('✅ Network configuration reset successfully');
    } catch (e) {
      print('❌ Error resetting network configuration: $e');
      rethrow;
    }
  }
}

/// إعدادات الشبكة (كما هي)
class NetworkConfiguration {
  final String connectionType, printerMac, deviceName, printerIP;
  final String networkName, networkIP, gateway, subnet, configurationDate;
  final bool isConfigured;

  NetworkConfiguration({
    required this.connectionType,
    required this.printerMac,
    required this.deviceName,
    required this.printerIP,
    required this.networkName,
    required this.networkIP,
    required this.gateway,
    required this.subnet,
    required this.isConfigured,
    required this.configurationDate,
  });

  factory NetworkConfiguration.empty() => NetworkConfiguration(
        connectionType: 'LAN',
        printerMac: '',
        deviceName: '',
        printerIP: '',
        networkName: '',
        networkIP: '',
        gateway: '',
        subnet: '',
        isConfigured: false,
        configurationDate: '',
      );

  Map<String, dynamic> toJson() => {
        'connectionType': connectionType,
        'printerMac': printerMac,
        'deviceName': deviceName,
        'printerIP': printerIP,
        'networkName': networkName,
        'networkIP': networkIP,
        'gateway': gateway,
        'subnet': subnet,
        'isConfigured': isConfigured,
        'configurationDate': configurationDate,
      };

  factory NetworkConfiguration.fromJson(Map<String, dynamic> json) => NetworkConfiguration(
        connectionType: json['connectionType'] ?? 'LAN',
        printerMac: json['printerMac'] ?? '',
        deviceName: json['deviceName'] ?? '',
        printerIP: json['printerIP'] ?? '',
        networkName: json['networkName'] ?? '',
        networkIP: json['networkIP'] ?? '',
        gateway: json['gateway'] ?? '',
        subnet: json['subnet'] ?? '',
        isConfigured: json['isConfigured'] ?? false,
        configurationDate: json['configurationDate'] ?? '',
      );
}

// // lib/services/network_service.dart

// import 'dart:io';
// import 'package:auth_app/models/network_device.dart';
// import 'package:auth_app/pages/configration/services/network_config.dart';
// import 'package:network_info_plus/network_info_plus.dart';
// import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:auth_app/classes/shared_preference.dart';

// class NetworkService {
//   static final NetworkInfo _networkInfo = NetworkInfo();

//   // طلب الأذونات المطلوبة
//   static Future<bool> requestPermissions() async {
//     Map<Permission, PermissionStatus> permissions = await [
//       Permission.location,
//       Permission.nearbyWifiDevices,
//     ].request();

//     bool allGranted = permissions.values.every(
//       (status) => status == PermissionStatus.granted,
//     );

//     return allGranted;
//   }

//   // الحصول على معلومات الشبكة الحالية
//   static Future<Map<String, String?>> getNetworkInfo() async {
//     try {
//       final wifiName = await _networkInfo.getWifiName();
//       final wifiIP = await _networkInfo.getWifiIP();
//       final wifiBSSID = await _networkInfo.getWifiBSSID();
//       final wifiGatewayIP = await _networkInfo.getWifiGatewayIP();
//       final wifiSubmask = await _networkInfo.getWifiSubmask();

//       return {
//         'wifiName': wifiName,
//         'wifiIP': wifiIP,
//         'wifiBSSID': wifiBSSID,
//         'wifiGatewayIP': wifiGatewayIP,
//         'wifiSubmask': wifiSubmask,
//       };
//     } catch (e) {
//       print('Error getting network info: $e');
//       return {};
//     }
//   }

//   // البحث عن الأجهزة على الشبكة
// // استبدال دالة discoverNetworkDevices في NetworkService
//   static Future<List<NetworkDevice>> discoverNetworkDevices() async {
//     List<NetworkDevice> devices = [];

//     try {
//       // التحقق من الأذونات
//       if (!await requestPermissions()) {
//         throw Exception('لم يتم منح الأذونات المطلوبة');
//       }

//       final networkInfo = await getNetworkInfo();
//       final subnet = _getSubnet(networkInfo['wifiIP']);

//       if (subnet != null) {
//         final stream = NetworkAnalyzer.discover2(subnet, 9100, timeout: Duration(seconds: 5));

//         await for (NetworkAddress addr in stream) {
//           if (addr.exists) {
//             String? deviceName = await _getDeviceName(addr.ip);
//             String? macAddress = await _getMacAddress(addr.ip);

//             devices.add(NetworkDevice(
//               ip: addr.ip,
//               name: deviceName ?? 'Unknown Device',
//               macAddress: macAddress ?? 'Unknown MAC',
//               port: 9100,
//               isOnline: true,
//             ));
//           }
//         }
//       }
//     } catch (e) {
//       print('Error discovering devices: $e');
//     }

//     return devices;
//   }

//   // البحث المتقدم عن الطابعات مع عدة منافذ
//   static Future<List<NetworkDevice>> discoverPrintersAdvanced() async {
//     List<NetworkDevice> devices = [];

//     try {
//       if (!await requestPermissions()) {
//         throw Exception('لم يتم منح الأذونات المطلوبة');
//       }

//       final networkInfo = await getNetworkInfo();
//       final subnet = _getSubnet(networkInfo['wifiIP']);

//       if (subnet == null || subnet.isEmpty) {
//         throw Exception('لا يمكن تحديد الشبكة الفرعية');
//       }

//       // منافذ الطابعات الشائعة
//       List<int> printerPorts = [9100, 631, 515, 721];

//       for (int port in printerPorts) {
//         try {
//           final stream = NetworkAnalyzer.discover2(subnet, port, timeout: Duration(seconds: 3));

//           await for (NetworkAddress addr in stream) {
//             if (addr.exists) {
//               // التحقق من أن الجهاز طابعة فعلاً
//               bool isPrinter = await _verifyPrinterDevice(addr.ip, port);

//               if (isPrinter) {
//                 String deviceName = 'Printer_${addr.ip.split('.').last}';
//                 String macAddress = _generateMacAddress(addr.ip);

//                 // تجنب الأجهزة المكررة
//                 bool alreadyExists = devices.any((device) => device.ip == addr.ip);
//                 if (!alreadyExists) {
//                   devices.add(NetworkDevice(
//                     ip: addr.ip,
//                     name: deviceName,
//                     macAddress: macAddress,
//                     isOnline: true,
//                     port: port,
//                   ));
//                 }
//               }
//             }
//           }
//         } catch (e) {
//           print('Error scanning port $port: $e');
//           continue;
//         }
//       }
//     } catch (e) {
//       print('Error in advanced discovery: $e');
//       rethrow;
//     }

//     return devices;
//   }

//   static Future<bool> _verifyPrinterDevice(String ip, int port) async {
//     try {
//       final socket = await Socket.connect(ip, port, timeout: Duration(seconds: 2));

//       // إرسال أمر بسيط للتحقق من استجابة الطابعة
//       if (port == 9100) {
//         try {
//           socket.write('\x1B@'); // ESC @ - Reset command
//           await Future.delayed(Duration(milliseconds: 300));
//         } catch (e) {
//           print('Error sending printer command: $e');
//         }
//       }

//       await socket.close();
//       return true;
//     } catch (e) {
//       print('Error verifying printer device $ip:$port: $e');
//       return false;
//     }
//   }

//   // توليد MAC address وهمي بناءً على IP
//   static String _generateMacAddress(String ip) {
//     final parts = ip.split('.');
//     final lastOctet = int.parse(parts[3]);
//     final secondLastOctet = int.parse(parts[2]);

//     return '00:1A:2B:${secondLastOctet.toRadixString(16).padLeft(2, '0').toUpperCase()}:'
//         '${lastOctet.toRadixString(16).padLeft(2, '0').toUpperCase()}:'
//         '${(lastOctet + 1).toRadixString(16).padLeft(2, '0').toUpperCase()}';
//   }

//   // استخراج الشبكة الفرعية من IP
//   static String? _getSubnet(String? ip) {
//     if (ip == null) return null;

//     List<String> parts = ip.split('.');
//     if (parts.length == 4) {
//       return '${parts[0]}.${parts[1]}.${parts[2]}';
//     }
//     return null;
//   }

//   // الحصول على اسم الجهاز من IP
//   static Future<String?> _getDeviceName(String ip) async {
//     try {
//       final result = await InternetAddress.lookup(ip);
//       if (result.isNotEmpty) {
//         return result.first.host;
//       }
//     } catch (e) {
//       print('Error getting device name for $ip: $e');
//     }
//     return null;
//   }

//   // محاولة الحصول على MAC Address (محدود في Flutter)
//   static Future<String?> _getMacAddress(String ip) async {
//     // في Flutter، الحصول على MAC Address صعب جداً
//     // هذه طريقة محدودة ولن تعمل في جميع الحالات
//     try {
//       if (Platform.isAndroid) {
//         // يمكن استخدام ARP table في Android
//         final result = await Process.run('cat', ['/proc/net/arp']);
//         final lines = result.stdout.toString().split('\n');

//         for (String line in lines) {
//           if (line.contains(ip)) {
//             final parts = line.split(RegExp(r'\s+'));
//             if (parts.length >= 4) {
//               return parts[3].toUpperCase();
//             }
//           }
//         }
//       }
//     } catch (e) {
//       print('Error getting MAC address: $e');
//     }
//     return null;
//   }

//   // فحص الاتصال بجهاز معين
//   static Future<bool> pingDevice(String ip) async {
//     try {
//       final result = await Process.run('ping', ['-c', '1', ip]);
//       return result.exitCode == 0;
//     } catch (e) {
//       print('Error pinging $ip: $e');
//       return false;
//     }
//   }

//   // حفظ إعدادات الشبكة
//   static Future<void> saveNetworkConfiguration({
//     required String connectionType,
//     required String printerMac,
//     required String deviceName,
//     String? printerIP,
//   }) async {
//     await Preferences.setString('connection_type', connectionType);
//     await Preferences.setString('printer_mac_address', printerMac);
//     await Preferences.setString('device_name', deviceName);
//     if (printerIP != null) {
//       await Preferences.setString('printer_ip', printerIP);
//     }
//     await Preferences.setBoolean('configuration_saved', true);

//     // حفظ تاريخ التكوين
//     await Preferences.setString('configuration_date', DateTime.now().toIso8601String());
//   }

//   // قراءة إعدادات الشبكة المحفوظة
//   static NetworkConfiguration getNetworkConfiguration() {
//     return NetworkConfiguration(
//       connectionType: Preferences.getString('connection_type'),
//       printerMac: Preferences.getString('printer_mac_address'),
//       deviceName: Preferences.getString('device_name'),
//       printerIP: Preferences.getString('printer_ip'),
//       isConfigured: Preferences.getBoolean('configuration_saved'),
//       configurationDate: Preferences.getString('configuration_date'),
//     );
//   }

//   // التحقق من صحة إعدادات الشبكة
//   static bool validateNetworkConfiguration() {
//     final config = getNetworkConfiguration();
//     return config.isConfigured && config.printerMac.isNotEmpty && config.deviceName.isNotEmpty;
//   }

//   // إعادة تعيين إعدادات الشبكة
//   static Future<void> resetNetworkConfiguration() async {
//     await Preferences.clearKeyData('connection_type');
//     await Preferences.clearKeyData('printer_mac_address');
//     await Preferences.clearKeyData('device_name');
//     await Preferences.clearKeyData('printer_ip');
//     await Preferences.clearKeyData('configuration_saved');
//     await Preferences.clearKeyData('configuration_date');
//   }
// }
