// lib/pages/configuration/real_network_configuration_controller.dart

import 'dart:io';
import 'dart:async';
import 'package:auth_app/models/network_device.dart';
import 'package:auth_app/pages/configration/services/network_service.dart';
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
  String? currentGateway;
  List<NetworkDevice> discoveredDevices = [];

  // Network Info Service
  final NetworkInfo _networkInfo = NetworkInfo();

  @override
  void onInit() {
    super.onInit();
    resetScanningState(); // إضافة هذه السطر

    loadSavedConfiguration();
    _initializeNetworkInfo();

    // getNetworkStatusInfo();
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
      currentGateway = await _networkInfo.getWifiGatewayIP();
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
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> autoDetectPrinter() async {
    if (!await _requestPermissions()) {
      return;
    }

    // التحقق من حالة الشبكة أولاً
    if (connectionType == 'LAN') {
      await _initializeNetworkInfo();
      if (currentNetworkIP == null || currentNetworkIP!.isEmpty) {
        EasyLoading.showError('غير متصل بالشبكة المحلية. تحقق من اتصال WiFi');
        return;
      }
    }

    isLoading = true;
    isScanning = true;
    discoveredDevices.clear();
    update();

    EasyLoading.show(status: 'بدء البحث عن الطابعات...');

    Timer? timeoutTimer = Timer(const Duration(minutes: 2), () {
      if (isScanning) {
        _stopScanning();
        EasyLoading.showInfo('انتهت مهلة البحث. جرب مرة أخرى.');
      }
    });

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
      EasyLoading.showError('حدث خطأ أثناء البحث');
      print('Auto detect error: $e');
    } finally {
      timeoutTimer.cancel();
      _stopScanning();
    }
  }

  void _stopScanning() {
    isLoading = false;
    isScanning = false;
    EasyLoading.dismiss();
    update();
  }

  Future<void> _scanLocalNetwork() async {
    try {
      EasyLoading.show(status: 'جاري البحث في الشبكة المحلية...');

      String subnet = customSubnetController.text.isNotEmpty
          ? customSubnetController.text.trim()
          : _getSubnet(currentNetworkIP!);

      // التحقق من صحة الشبكة الفرعية
      if (!_isValidSubnet(subnet)) {
        throw Exception('الشبكة الفرعية غير صحيحة: $subnet');
      }

      List<NetworkDevice> foundDevices = [];

      // البحث المتقدم مع معالجة الأخطاء
      try {
        EasyLoading.show(status: 'البحث المتقدم...');
        List<NetworkDevice> advancedDevices =
            await NetworkService.discoverPrintersAdvanced().timeout(const Duration(seconds: 30));
        if (advancedDevices.isNotEmpty) {
          foundDevices.addAll(advancedDevices);
        }
      } catch (e) {
        print('Advanced search failed: $e');
      }

      // البحث التقليدي مع تحسينات
      List<int> printerPorts = [9100, 631, 515];

      for (int port in printerPorts) {
        if (!isScanning) break; // إيقاف البحث إذا تم الإلغاء

        try {
          EasyLoading.show(status: 'فحص المنفذ $port...');
          List<NetworkDevice> portDevices =
              await _scanPortWithEnhancement(subnet, port).timeout(const Duration(seconds: 20));
          foundDevices.addAll(portDevices);
        } catch (e) {
          print('Port $port scan failed: $e');
          continue;
        }
      }

      // فحص IPs محددة شائعة للطابعات
      await _scanCommonPrinterIPs(subnet, foundDevices);

      discoveredDevices = foundDevices;
      _processDiscoveredDevices();
    } catch (e) {
      print('Error in enhanced scan: $e');
      // العودة للطريقة التقليدية عند الفشل
      String subnet = _getSubnet(currentNetworkIP ?? '192.168.1.1');
      await _fallbackScan(subnet);
    }
  }

  Future<void> _scanCommonPrinterIPs(String subnet, List<NetworkDevice> foundDevices) async {
    List<String> commonPrinterIPs = [
      '$subnet.100',
      '$subnet.101',
      '$subnet.200',
      '$subnet.201',
      '$subnet.10',
      '$subnet.20',
      '$subnet.30',
      '$subnet.50'
    ];

    EasyLoading.show(status: 'فحص عناوين IP الشائعة...');

    for (String ip in commonPrinterIPs) {
      if (!isScanning) break;

      try {
        if (await _testSpecificIP(ip)) {
          NetworkDevice device = NetworkDevice(
            ip: ip,
            name: 'Printer_${ip.split('.').last}',
            macAddress: _generateFakeMac(),
            port: 9100,
            isOnline: true,
          );
          foundDevices.add(device);
        }
      } catch (e) {
        print('Failed to test IP $ip: $e');
        continue;
      }
    }
  }

  bool _isValidSubnet(String subnet) {
    RegExp subnetRegex = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}$');
    if (!subnetRegex.hasMatch(subnet)) return false;

    List<String> parts = subnet.split('.');
    for (String part in parts) {
      int? num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }
    return true;
  }

  // فحص محسن للمنفذ
  Future<List<NetworkDevice>> _scanPortWithEnhancement(String subnet, int port) async {
    List<NetworkDevice> devices = [];

    try {
      final stream = NetworkAnalyzer.discover2(subnet, port, timeout: const Duration(seconds: 4));

      await for (NetworkAddress addr in stream) {
        if (addr.exists) {
          // تأكيد إضافي أن الجهاز يستجيب
          bool isResponding = await _testSpecificIP(addr.ip);

          if (isResponding) {
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
      }
    } catch (e) {
      print('Error in enhanced port scan: $e');
    }

    return devices;
  }

  Future<bool> _testSpecificIP(String ip) async {
    try {
      // التحقق من صحة IP أولاً
      if (!_isValidIP(ip)) return false;

      List<int> testPorts = [9100, 631, 515, 80];

      for (int port in testPorts) {
        try {
          Socket socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 2));
          await socket.close();
          return true;
        } catch (e) {
          continue;
        }
      }

      // إذا فشل Socket، جرب ping
      return await _pingDevice(ip);
    } catch (e) {
      print('Error testing IP $ip: $e');
      return false;
    }
  }

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

  // البحث الاحتياطي
  Future<void> _fallbackScan(String subnet) async {
    EasyLoading.show(status: 'البحث الاحتياطي...');

    List<NetworkDevice> fallbackDevices = [];

    // فحص مجموعة IPs محددة يدوياً
    for (int i = 1; i <= 254; i++) {
      String testIP = '$subnet.$i';

      if (i % 50 == 0) {
        EasyLoading.show(status: 'فحص: $testIP');
      }

      bool responds = await _testSpecificIP(testIP);

      if (responds) {
        fallbackDevices.add(NetworkDevice(
          ip: testIP,
          name: 'Device_$i',
          macAddress: _generateFakeMac(),
          port: 9100,
          isOnline: true,
        ));

        // إيقاف البحث بعد العثور على 3 أجهزة
        if (fallbackDevices.length >= 3) break;
      }
    }

    discoveredDevices = fallbackDevices;
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

      // استبدال الكود في دالة _handleWANConnection حوالي السطر 250:
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
        title: const Text('إدخال IP الطابعة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('يرجى إدخال عنوان IP للطابعة للاتصال عبر WAN'),
            const SizedBox(height: 16),
            TextField(
              controller: tempController,
              decoration: const InputDecoration(
                labelText: 'عنوان IP',
                hintText: '192.168.1.100',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              ipAddressController.text = tempController.text;
              Get.back();
            },
            child: const Text('تأكيد'),
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
          Socket socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 5));
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

  // استبدال دالة _scanPortForPrinters:
  // استبدال دالة _scanPortForPrinters بالكامل
  Future<List<NetworkDevice>> _scanPortForPrinters(String subnet, int port) async {
    List<NetworkDevice> devices = [];

    try {
      final stream = NetworkAnalyzer.discover2(subnet, port, timeout: const Duration(seconds: 3));

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
      Socket socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 2));
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

  Future<bool> _pingDevice(String ip) async {
    try {
      if (!_isValidIP(ip)) return false;

      final result =
          await Process.run('ping', ['-c', '1', '-W', '3', ip]).timeout(const Duration(seconds: 5));

      return result.exitCode == 0;
    } catch (e) {
      print('Error pinging $ip: $e');

      // Fallback: try socket connection
      try {
        Socket socket = await Socket.connect(ip, 9100, timeout: const Duration(seconds: 2));
        await socket.close();
        return true;
      } catch (e) {
        return false;
      }
    }
  }

  // Save configuration - محسنة
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
      // حفظ جميع البيانات مع التأكد من الثبات
      await Future.wait([
        Preferences.setString('connection_type', connectionType),
        Preferences.setString('printer_mac_address', macAddressController.text),
        Preferences.setString('device_name', deviceNameController.text),
        Preferences.setString('printer_ip', ipAddressController.text),
        Preferences.setString('custom_subnet', customSubnetController.text),
        Preferences.setString('current_network_name', currentNetworkName ?? ''),
        Preferences.setString('current_network_ip', currentNetworkIP ?? ''),
        Preferences.setString('current_gateway', currentGateway ?? ''),
        Preferences.setBoolean('configuration_saved', true),
        Preferences.setString('configuration_date', DateTime.now().toIso8601String()),
      ]);

      // التحقق من نجاح الحفظ
      bool saveVerification = await _verifySavedConfiguration();

      if (saveVerification) {
        EasyLoading.showSuccess('تم حفظ إعدادات $connectionType بنجاح!\nالبيانات محفوظة بشكل دائم');

        await Future.delayed(const Duration(milliseconds: 1500));
        Get.offAllNamed(AppRoutes.login);
      } else {
        EasyLoading.showError('فشل في التحقق من حفظ البيانات، حاول مرة أخرى');
      }
    } catch (e) {
      EasyLoading.showError('حدث خطأ أثناء الحفظ: ${e.toString()}');
    }
  }

  // التحقق من نجاح حفظ الإعدادات
  Future<bool> _verifySavedConfiguration() async {
    try {
      String savedConnectionType = Preferences.getString('connection_type');
      String savedMac = Preferences.getString('printer_mac_address');
      String savedDeviceName = Preferences.getString('device_name');
      bool isConfigSaved = Preferences.getBoolean('configuration_saved');

      return savedConnectionType == connectionType &&
          savedMac == macAddressController.text &&
          savedDeviceName == deviceNameController.text &&
          isConfigSaved;
    } catch (e) {
      return false;
    }
  }

  void resetScanningState() {
    isScanning = false;
    isLoading = false;
    discoveredDevices.clear();
    connectionStatus = connectionType == 'LAN'
        ? 'سيتم البحث في الشبكة المحلية'
        : 'سيتم البحث عبر الإنترنت (يتطلب IP محدد)';
    update();
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

  // في NetworkInfoCard - تحديث دالة getNetworkStatusInfo في الكونترولر
  String getNetworkStatusInfo() {
    if (connectionType == 'LAN') {
      return 'اسم الشبكة: ${currentNetworkName ?? "غير معروف"}\n'
          'IP الحالي: ${currentNetworkIP ?? "غير متصل"}\n'
          'البوابة: ${currentGateway ?? "غير محددة"}\n'
          'الشبكة الفرعية: ${currentSubnet ?? "غير محددة"}';
    } else {
      return 'الشبكة الواسعة (WAN)\n'
          'يتطلب IP مباشر للطابعة\n'
          'IP الطابعة: ${ipAddressController.text.isEmpty ? "غير محدد" : ipAddressController.text}';
    }
  }
}
