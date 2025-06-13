// lib/pages/configuration/real_network_configuration_controller.dart

import 'dart:io';
import 'dart:async';
import 'package:auth_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/classes/shared_preference.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';
import 'package:permission_handler/permission_handler.dart';

class ConfigurationController extends GetxController {
  // Text Controllers
  final TextEditingController macAddressController = TextEditingController();
  final TextEditingController deviceNameController = TextEditingController();
  final TextEditingController ipAddressController = TextEditingController();
  final TextEditingController customSubnetController = TextEditingController();

  // Configuration Variables
  String connectionType = 'LAN';
  String connectionStatus = '';
  bool isConnected = false;
  bool isLoading = false;
  bool isScanning = false;

  // Network Info
  String? currentNetworkIP;
  String? currentNetworkName;
  String? currentSubnet;
  List<NetworkDevice> discoveredDevices = [];

  // Network Info Service
  final NetworkInfo _networkInfo = NetworkInfo();

  @override
  void onInit() {
    super.onInit();
    loadSavedConfiguration();
    _initializeNetworkInfo();
  }

  @override
  void onClose() {
    macAddressController.dispose();
    deviceNameController.dispose();
    ipAddressController.dispose();
    customSubnetController.dispose();
    super.onClose();
  }

  // Initialize network info
  Future<void> _initializeNetworkInfo() async {
    try {
      currentNetworkIP = await _networkInfo.getWifiIP();
      currentNetworkName = await _networkInfo.getWifiName();
      currentSubnet = _getSubnet(currentNetworkIP ?? '');
      customSubnetController.text = currentSubnet ?? '192.168.1';
      update();
    } catch (e) {
      print('Error initializing network info: $e');
    }
  }

  // Set Connection Type with real functionality
  void setConnectionType(String? type) {
    if (type != null && type != connectionType) {
      connectionType = type;

      // Clear previous results when connection type changes
      discoveredDevices.clear();
      connectionStatus = '';
      isConnected = false;

      // Update UI elements based on connection type
      _updateUIForConnectionType();

      update();

      // Show information about the selected connection type
      _showConnectionTypeInfo(type);
    }
  }

  // Update UI elements based on connection type
  void _updateUIForConnectionType() {
    switch (connectionType) {
      case 'LAN':
        // For LAN, we use local network scanning
        customSubnetController.text = currentSubnet ?? '192.168.1';
        connectionStatus = 'سيتم البحث في الشبكة المحلية';
        break;

      case 'WAN':
        // For WAN, we might need different approach
        customSubnetController.text = '';
        connectionStatus = 'سيتم البحث عبر الإنترنت (يتطلب IP محدد)';
        break;
    }
  }

  // Show information about connection type
  void _showConnectionTypeInfo(String type) {
    String message = '';
    switch (type) {
      case 'LAN':
        message = 'تم اختيار الشبكة المحلية\nسيتم البحث عن الطابعات في نفس الشبكة';
        break;
      case 'WAN':
        message = 'تم اختيار الشبكة الواسعة\nيجب إدخال IP الطابعة يدوياً';
        break;
    }

    if (message.isNotEmpty) {
      Get.snackbar(
        'نوع الاتصال',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue.withOpacity(0.8),
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  // Auto-detect printer based on connection type
  Future<void> autoDetectPrinter() async {
    if (!await _requestPermissions()) {
      return;
    }

    isLoading = true;
    isScanning = true;
    discoveredDevices.clear();
    update();

    try {
      switch (connectionType) {
        case 'LAN':
          await _scanLocalNetwork();
          break;
        case 'WAN':
          await _handleWANConnection();
          break;
      }
    } catch (e) {
      connectionStatus = 'خطأ في البحث: ${e.toString()}';
      isConnected = false;
      EasyLoading.showError('حدث خطأ أثناء البحث: ${e.toString()}');
    } finally {
      isLoading = false;
      isScanning = false;
      update();
    }
  }

  // Scan local network (LAN)
  Future<void> _scanLocalNetwork() async {
    EasyLoading.show(status: 'جاري البحث في الشبكة المحلية...');

    // Get current network info
    await _initializeNetworkInfo();

    if (currentNetworkIP == null) {
      throw Exception('غير متصل بالشبكة المحلية');
    }

    String subnet = customSubnetController.text.isNotEmpty
        ? customSubnetController.text
        : _getSubnet(currentNetworkIP!);

    // Common printer ports to scan
    List<int> printerPorts = [9100, 631, 515, 721];

    EasyLoading.show(status: 'فحص الشبكة: $subnet.x\nالمنافذ: ${printerPorts.join(", ")}');

    Completer<void> scanCompleter = Completer<void>();
    int completedScans = 0;
    int totalPorts = printerPorts.length;

    // Scan each port
    for (int port in printerPorts) {
      _scanPortForPrinters(subnet, port).then((devices) {
        discoveredDevices.addAll(devices);
        completedScans++;

        EasyLoading.show(status: 'فحص المنفذ $port... (${completedScans}/${totalPorts})');

        if (completedScans == totalPorts) {
          scanCompleter.complete();
        }
      }).catchError((error) {
        print('Error scanning port $port: $error');
        completedScans++;
        if (completedScans == totalPorts) {
          scanCompleter.complete();
        }
      });
    }

    await scanCompleter.future;
    _processDiscoveredDevices();
  }

  // Handle WAN connection
  Future<void> _handleWANConnection() async {
    EasyLoading.show(status: 'إعداد الاتصال عبر الإنترنت...');

    // For WAN, we need manual IP input
    if (ipAddressController.text.isEmpty) {
      EasyLoading.dismiss();

      // Show dialog to input IP address
      await _showIPInputDialog();

      if (ipAddressController.text.isEmpty) {
        connectionStatus = 'يجب إدخال IP للطابعة في اتصال WAN';
        EasyLoading.showError(connectionStatus);
        return;
      }
    }

    EasyLoading.show(status: 'اختبار الاتصال مع: ${ipAddressController.text}');

    // Test connection to the specified IP
    bool isReachable = await _testWANConnection(ipAddressController.text);

    if (isReachable) {
      // Create a device entry for the WAN printer
      NetworkDevice wanDevice = NetworkDevice(
        ip: ipAddressController.text,
        name: deviceNameController.text.isNotEmpty
            ? deviceNameController.text
            : 'WAN_Printer_${ipAddressController.text.split('.').last}',
        macAddress:
            macAddressController.text.isNotEmpty ? macAddressController.text : _generateFakeMac(),
        port: 9100,
        isOnline: true,
      );

      discoveredDevices.add(wanDevice);

      // Auto-fill if empty
      if (deviceNameController.text.isEmpty) {
        deviceNameController.text = wanDevice.name;
      }
      if (macAddressController.text.isEmpty) {
        macAddressController.text = wanDevice.macAddress;
      }

      connectionStatus = 'تم العثور على طابعة WAN';
      isConnected = true;
      EasyLoading.showSuccess('تم الاتصال بالطابعة عبر الإنترنت!');
    } else {
      connectionStatus = 'فشل الاتصال بالطابعة عبر WAN';
      isConnected = false;
      EasyLoading.showError('فشل الاتصال. تحقق من IP والاتصال بالإنترنت');
    }
  }

  // Show IP input dialog for WAN connection
  Future<void> _showIPInputDialog() async {
    final TextEditingController tempController = TextEditingController();
    tempController.text = ipAddressController.text;

    await Get.dialog(
      AlertDialog(
        title: Text('إدخال IP الطابعة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('يرجى إدخال عنوان IP للطابعة للاتصال عبر WAN'),
            SizedBox(height: 16),
            TextField(
              controller: tempController,
              decoration: InputDecoration(
                labelText: 'عنوان IP',
                hintText: '192.168.1.100',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              ipAddressController.text = tempController.text;
              Get.back();
            },
            child: Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  // Test WAN connection
  Future<bool> _testWANConnection(String ip) async {
    try {
      // Try multiple ports commonly used by printers
      List<int> portsToTest = [9100, 631, 515, 80, 443];

      for (int port in portsToTest) {
        try {
          Socket socket = await Socket.connect(ip, port, timeout: Duration(seconds: 5));
          socket.close();
          return true; // If any port responds, consider it reachable
        } catch (e) {
          continue; // Try next port
        }
      }

      // If socket connection fails, try ping
      return await _pingDevice(ip);
    } catch (e) {
      print('WAN connection test failed: $e');
      return false;
    }
  }

  // Process discovered devices
  void _processDiscoveredDevices() {
    // Remove duplicates based on IP
    Map<String, NetworkDevice> uniqueDevices = {};
    for (var device in discoveredDevices) {
      uniqueDevices[device.ip] = device;
    }
    discoveredDevices = uniqueDevices.values.toList();

    if (discoveredDevices.isNotEmpty) {
      // Auto-select first printer found
      NetworkDevice firstPrinter = discoveredDevices.first;
      macAddressController.text = firstPrinter.macAddress;
      deviceNameController.text = firstPrinter.name;
      ipAddressController.text = firstPrinter.ip;

      connectionStatus = 'تم العثور على ${discoveredDevices.length} طابعة';
      isConnected = true;

      EasyLoading.showSuccess('تم العثور على ${discoveredDevices.length} طابعة!');
    } else {
      connectionStatus = connectionType == 'LAN'
          ? 'لم يتم العثور على أي طابعة في الشبكة المحلية'
          : 'لم يتم العثور على طابعة في الشبكة الواسعة';
      isConnected = false;
      EasyLoading.showInfo('لم يتم العثور على طابعات. تأكد من تشغيل الطابعة واتصالها بالشبكة');
    }
  }

  // Request necessary permissions
  Future<bool> _requestPermissions() async {
    try {
      Map<Permission, PermissionStatus> permissions = await [
        Permission.location,
        Permission.nearbyWifiDevices,
      ].request();

      bool allGranted = permissions.values.every(
        (status) => status == PermissionStatus.granted,
      );

      if (!allGranted) {
        EasyLoading.showError('يرجى منح الأذونات المطلوبة للوصول للشبكة');
        return false;
      }

      return true;
    } catch (e) {
      print('Error requesting permissions: $e');
      EasyLoading.showError('خطأ في طلب الأذونات');
      return false;
    }
  }

  // MAC Address Change Handler
  void onMacAddressChanged(String value) {
    String formatted = formatMacAddress(value);
    if (formatted != value) {
      macAddressController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    if (formatted.length == 17) {
      autoFillDeviceName(formatted);
    }
  }

  // Format MAC Address (XX:XX:XX:XX:XX:XX)
  String formatMacAddress(String input) {
    String cleaned = input.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');

    if (cleaned.length > 12) {
      cleaned = cleaned.substring(0, 12);
    }

    String formatted = '';
    for (int i = 0; i < cleaned.length; i += 2) {
      if (i > 0) formatted += ':';
      formatted += cleaned.substring(i, i + 2 > cleaned.length ? cleaned.length : i + 2);
    }

    return formatted.toUpperCase();
  }

  // Auto-fill device name based on MAC address
  void autoFillDeviceName(String macAddress) {
    String prefix = connectionType == 'LAN' ? 'LAN_Printer' : 'WAN_Printer';
    String deviceName = '${prefix}_${macAddress.replaceAll(':', '').substring(6)}';
    deviceNameController.text = deviceName;
    update();
  }

  // Extract subnet from IP address
  String _getSubnet(String ip) {
    List<String> parts = ip.split('.');
    if (parts.length == 4) {
      return '${parts[0]}.${parts[1]}.${parts[2]}';
    }
    return '192.168.1'; // Default fallback
  }

  // Scan specific port for printers
  Future<List<NetworkDevice>> _scanPortForPrinters(String subnet, int port) async {
    List<NetworkDevice> devices = [];

    try {
      final stream = NetworkAnalyzer.discover2(subnet, port, timeout: Duration(seconds: 3));

      await for (NetworkAddress addr in stream) {
        if (addr.exists) {
          String deviceName = await _identifyPrinterDevice(addr.ip, port);
          String macAddress = await _getMacAddress(addr.ip) ?? _generateFakeMac();

          devices.add(NetworkDevice(
            ip: addr.ip,
            name: deviceName,
            macAddress: macAddress,
            port: port,
            isOnline: true,
          ));
        }
      }
    } catch (e) {
      print('Error scanning port $port: $e');
    }

    return devices;
  }

  // Identify if device is a printer
  Future<String> _identifyPrinterDevice(String ip, int port) async {
    try {
      Socket socket = await Socket.connect(ip, port, timeout: Duration(seconds: 2));
      socket.close();

      String deviceType = _getDeviceTypeByPort(port);
      String prefix = connectionType == 'LAN' ? 'LAN' : 'WAN';
      return '${prefix}_${deviceType}_${ip.split('.').last}';
    } catch (e) {
      return '${connectionType}_Unknown_Printer_${ip.split('.').last}';
    }
  }

  // Get device type by port
  String _getDeviceTypeByPort(int port) {
    switch (port) {
      case 9100:
        return 'RAW_Printer';
      case 631:
        return 'IPP_Printer';
      case 515:
        return 'LPD_Printer';
      case 721:
        return 'Printer';
      default:
        return 'Network_Printer';
    }
  }

  // Get MAC address (limited in Flutter mobile)
  Future<String?> _getMacAddress(String ip) async {
    try {
      if (Platform.isAndroid) {
        final result = await Process.run('cat', ['/proc/net/arp']);
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
    } catch (e) {
      print('Error getting MAC address: $e');
    }
    return null;
  }

  // Generate a fake MAC address for demonstration
  String _generateFakeMac() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return '00:1A:2B:${(random % 256).toRadixString(16).padLeft(2, '0').toUpperCase()}:'
        '${((random ~/ 256) % 256).toRadixString(16).padLeft(2, '0').toUpperCase()}:'
        '${((random ~/ 65536) % 256).toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  // Test connection to printer with real network ping
  Future<void> testConnection() async {
    if (macAddressController.text.isEmpty) {
      EasyLoading.showError('يرجى إدخال عنوان MAC للطابعة');
      return;
    }

    String testType = connectionType == 'LAN' ? 'الشبكة المحلية' : 'الشبكة الواسعة';
    EasyLoading.show(status: 'جاري اختبار الاتصال عبر $testType...');

    try {
      bool testResult = false;

      if (ipAddressController.text.isNotEmpty) {
        if (connectionType == 'WAN') {
          testResult = await _testWANConnection(ipAddressController.text);
        } else {
          testResult = await _pingDevice(ipAddressController.text);
        }
      } else {
        NetworkDevice? device = discoveredDevices.firstWhereOrNull(
            (d) => d.macAddress.toLowerCase() == macAddressController.text.toLowerCase());

        if (device != null) {
          testResult = connectionType == 'WAN'
              ? await _testWANConnection(device.ip)
              : await _pingDevice(device.ip);
          ipAddressController.text = device.ip;
        }
      }

      if (testResult) {
        connectionStatus = 'تم الاتصال بالطابعة بنجاح عبر $testType';
        isConnected = true;
        EasyLoading.showSuccess('تم الاتصال بنجاح عبر $testType!');
      } else {
        connectionStatus = 'فشل في الاتصال بالطابعة عبر $testType';
        isConnected = false;
        EasyLoading.showError('فشل في الاتصال - تأكد من إعدادات $testType');
      }
    } catch (e) {
      connectionStatus = 'خطأ في الاختبار: ${e.toString()}';
      isConnected = false;
      EasyLoading.showError('حدث خطأ أثناء الاختبار');
    }

    update();
  }

  // Ping device to test connectivity
  Future<bool> _pingDevice(String ip) async {
    try {
      final result = await Process.run('ping', ['-c', '1', '-W', '3', ip]);
      return result.exitCode == 0;
    } catch (e) {
      print('Error pinging $ip: $e');

      // Fallback: try socket connection
      try {
        Socket socket = await Socket.connect(ip, 9100, timeout: Duration(seconds: 3));
        socket.close();
        return true;
      } catch (e) {
        return false;
      }
    }
  }

  // Save configuration
  Future<void> saveConfiguration() async {
    if (macAddressController.text.isEmpty || deviceNameController.text.isEmpty) {
      EasyLoading.showError('يرجى ملء جميع الحقول المطلوبة');
      return;
    }

    if (!_isValidMacAddress(macAddressController.text)) {
      EasyLoading.showError('عنوان MAC غير صحيح');
      return;
    }

    // Additional validation for WAN
    if (connectionType == 'WAN' && ipAddressController.text.isEmpty) {
      EasyLoading.showError('يرجى إدخال IP الطابعة لاتصال WAN');
      return;
    }

    EasyLoading.show(status: 'جاري حفظ إعدادات $connectionType...');

    try {
      await Preferences.setString('connection_type', connectionType);
      await Preferences.setString('printer_mac_address', macAddressController.text);
      await Preferences.setString('device_name', deviceNameController.text);
      await Preferences.setString('printer_ip', ipAddressController.text);
      await Preferences.setString('custom_subnet', customSubnetController.text);
      await Preferences.setBoolean('configuration_saved', true);
      await Preferences.setString('configuration_date', DateTime.now().toIso8601String());

      EasyLoading.showSuccess('تم حفظ إعدادات $connectionType بنجاح!');

      await Future.delayed(const Duration(milliseconds: 1500));
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      EasyLoading.showError('حدث خطأ أثناء الحفظ');
    }
  }

  // Load saved configuration
  void loadSavedConfiguration() {
    connectionType = Preferences.getString('connection_type');
    if (connectionType.isEmpty) connectionType = 'LAN';

    macAddressController.text = Preferences.getString('printer_mac_address');
    deviceNameController.text = Preferences.getString('device_name');
    ipAddressController.text = Preferences.getString('printer_ip');
    customSubnetController.text = Preferences.getString('custom_subnet');

    // Update UI based on loaded connection type
    _updateUIForConnectionType();

    update();
  }

  // Validate MAC address format
  bool _isValidMacAddress(String mac) {
    RegExp macRegex = RegExp(
        r'^[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}$');
    return macRegex.hasMatch(mac);
  }

  // Select discovered device
  void selectDiscoveredDevice(NetworkDevice device) {
    macAddressController.text = device.macAddress;
    deviceNameController.text = device.name;
    ipAddressController.text = device.ip;
    update();
  }

  // Clear configuration
  void clearConfiguration() {
    macAddressController.clear();
    deviceNameController.clear();
    ipAddressController.clear();
    customSubnetController.clear();
    connectionStatus = '';
    isConnected = false;
    discoveredDevices.clear();
    update();
  }

  // Get current network status info
  String getNetworkStatusInfo() {
    if (connectionType == 'LAN') {
      return 'الشبكة المحلية: ${currentNetworkName ?? "غير معروف"}\n'
          'IP الحالي: ${currentNetworkIP ?? "غير متصل"}\n'
          'الشبكة الفرعية: ${currentSubnet ?? "غير محددة"}';
    } else {
      return 'الشبكة الواسعة (WAN)\n'
          'يتطلب IP مباشر للطابعة\n'
          'IP الطابعة: ${ipAddressController.text.isEmpty ? "غير محدد" : ipAddressController.text}';
    }
  }
}

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




// // lib/pages/configuration/configuration_controller.dart

// import 'dart:io';
// import 'package:auth_app/routes/app_routes.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:auth_app/classes/shared_preference.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';

// class ConfigurationController extends GetxController {
//   // Text Controllers
//   final TextEditingController macAddressController = TextEditingController();
//   final TextEditingController deviceNameController = TextEditingController();

//   // Configuration Variables
//   String connectionType = 'LAN';
//   String connectionStatus = '';
//   bool isConnected = false;
//   bool isLoading = false;

//   @override
//   void onInit() {
//     super.onInit();
//     loadSavedConfiguration();
//   }

//   @override
//   void onClose() {
//     macAddressController.dispose();
//     deviceNameController.dispose();
//     super.onClose();
//   }

//   // Set Connection Type
//   void setConnectionType(String? type) {
//     if (type != null) {
//       connectionType = type;
//       update();
//     }
//   }

//   // MAC Address Change Handler
//   void onMacAddressChanged(String value) {
//     // Format MAC address automatically
//     String formatted = formatMacAddress(value);
//     if (formatted != value) {
//       macAddressController.value = TextEditingValue(
//         text: formatted,
//         selection: TextSelection.collapsed(offset: formatted.length),
//       );
//     }

//     // Auto-fill device name based on MAC
//     if (formatted.length == 17) {
//       autoFillDeviceName(formatted);
//     }
//   }

//   // Format MAC Address (XX:XX:XX:XX:XX:XX)
//   String formatMacAddress(String input) {
//     // Remove all non-hex characters
//     String cleaned = input.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');

//     // Limit to 12 characters
//     if (cleaned.length > 12) {
//       cleaned = cleaned.substring(0, 12);
//     }

//     // Add colons every 2 characters
//     String formatted = '';
//     for (int i = 0; i < cleaned.length; i += 2) {
//       if (i > 0) formatted += ':';
//       formatted += cleaned.substring(i, i + 2 > cleaned.length ? cleaned.length : i + 2);
//     }

//     return formatted.toUpperCase();
//   }

//   // Auto-fill device name based on MAC address
//   void autoFillDeviceName(String macAddress) {
//     // Simple logic to generate device name from MAC
//     String deviceName = 'Printer_${macAddress.replaceAll(':', '').substring(6)}';
//     deviceNameController.text = deviceName;
//     update();
//   }

//   // Auto-detect printer on network
//   Future<void> autoDetectPrinter() async {
//     isLoading = true;
//     update();

//     EasyLoading.show(status: 'جاري البحث عن الطابعات...');

//     try {
//       // Simulate network scanning
//       await Future.delayed(const Duration(seconds: 3));

//       // Mock discovered printers
//       List<Map<String, String>> discoveredPrinters = [
//         {'mac': '00:11:22:33:44:55', 'name': 'HP_Printer_001'},
//         {'mac': 'AA:BB:CC:DD:EE:FF', 'name': 'Canon_Printer_002'},
//       ];

//       if (discoveredPrinters.isNotEmpty) {
//         // For demo, select the first one
//         macAddressController.text = discoveredPrinters[0]['mac']!;
//         deviceNameController.text = discoveredPrinters[0]['name']!;

//         connectionStatus = 'تم العثور على ${discoveredPrinters.length} طابعة';
//         isConnected = true;

//         EasyLoading.showSuccess('تم العثور على الطابعات بنجاح!');
//       } else {
//         connectionStatus = 'لم يتم العثور على أي طابعة';
//         isConnected = false;
//         EasyLoading.showError('لم يتم العثور على أي طابعة');
//       }
//     } catch (e) {
//       connectionStatus = 'خطأ في البحث: ${e.toString()}';
//       isConnected = false;
//       EasyLoading.showError('حدث خطأ أثناء البحث');
//     } finally {
//       isLoading = false;
//       update();
//     }
//   }

//   // Test connection to printer
//   Future<void> testConnection() async {
//     if (macAddressController.text.isEmpty) {
//       EasyLoading.showError('يرجى إدخال عنوان MAC للطابعة');
//       return;
//     }

//     EasyLoading.show(status: 'جاري اختبار الاتصال...');

//     try {
//       // Simulate connection test
//       await Future.delayed(const Duration(seconds: 2));

//       // Mock connection test result
//       bool testResult = await _performConnectionTest();

//       if (testResult) {
//         connectionStatus = 'تم الاتصال بالطابعة بنجاح';
//         isConnected = true;
//         EasyLoading.showSuccess('تم الاتصال بنجاح!');
//       } else {
//         connectionStatus = 'فشل في الاتصال بالطابعة';
//         isConnected = false;
//         EasyLoading.showError('فشل في الاتصال');
//       }
//     } catch (e) {
//       connectionStatus = 'خطأ في الاختبار: ${e.toString()}';
//       isConnected = false;
//       EasyLoading.showError('حدث خطأ أثناء الاختبار');
//     }

//     update();
//   }

//   // Perform actual connection test (mock implementation)
//   Future<bool> _performConnectionTest() async {
//     // Here you would implement actual network testing
//     // For now, we'll simulate success/failure
//     return macAddressController.text.isNotEmpty && deviceNameController.text.isNotEmpty;
//   }

//   // Save configuration to SharedPreferences
//   Future<void> saveConfiguration() async {
//     if (macAddressController.text.isEmpty || deviceNameController.text.isEmpty) {
//       EasyLoading.showError('يرجى ملء جميع الحقول المطلوبة');
//       return;
//     }

//     if (!_isValidMacAddress(macAddressController.text)) {
//       EasyLoading.showError('عنوان MAC غير صحيح');
//       return;
//     }

//     EasyLoading.show(status: 'جاري حفظ الإعدادات...');

//     try {
//       // Save to SharedPreferences
//       await Preferences.setString('connection_type', connectionType);
//       await Preferences.setString('printer_mac_address', macAddressController.text);
//       await Preferences.setString('device_name', deviceNameController.text);
//       await Preferences.setBoolean('configuration_saved', true);

//       EasyLoading.showSuccess('تم حفظ الإعدادات بنجاح!');

//       // Navigate back or to home
//       await Future.delayed(const Duration(milliseconds: 1500));

//       Get.offAllNamed(AppRoutes.login);

//       // Get.back();
//     } catch (e) {
//       EasyLoading.showError('حدث خطأ أثناء الحفظ');
//     }
//   }

//   // Load saved configuration
//   void loadSavedConfiguration() {
//     connectionType = Preferences.getString('connection_type');
//     if (connectionType.isEmpty) connectionType = 'LAN';

//     macAddressController.text = Preferences.getString('printer_mac_address');
//     deviceNameController.text = Preferences.getString('device_name');

//     update();
//   }

//   // Validate MAC address format
//   bool _isValidMacAddress(String mac) {
//     RegExp macRegex = RegExp(
//         r'^[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}$');
//     return macRegex.hasMatch(mac);
//   }

//   // Get network interface information (for advanced users)
//   Future<void> getNetworkInfo() async {
//     try {
//       List<NetworkInterface> interfaces = await NetworkInterface.list();
//       for (NetworkInterface interface in interfaces) {
//         print('Interface: ${interface.name}');
//         for (InternetAddress address in interface.addresses) {
//           print('Address: ${address.address}');
//         }
//       }
//     } catch (e) {
//       print('Error getting network info: $e');
//     }
//   }
// }
