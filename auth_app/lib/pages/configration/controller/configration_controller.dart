import 'dart:async';
import 'dart:io';
import 'package:auth_app/models/network_device.dart';
import 'package:auth_app/pages/configration/services/network_service.dart';
import 'package:auth_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ConfigurationController extends GetxController {
  // Controllers
  final macAddressController = TextEditingController();
  final deviceNameController = TextEditingController();
  final ipAddressController = TextEditingController();
  final customSubnetController = TextEditingController();

  // State
  String connectionType = 'LAN';
  String connectionStatus = '';
  bool isConnected = false;
  bool isLoading = false;
  bool isScanning = false;

  // Network Info
  String? currentNetworkIP, currentNetworkName, currentSubnet, currentGateway;
  List<NetworkDevice> discoveredDevices = [];

  // Control
  Timer? _operationTimer;
  bool _isOperationActive = false;

  @override
  void onInit() {
    super.onInit();
    print('🚀 ConfigurationController initialized');
    _initialize();
  }

  @override
  void onClose() {
    print('🛑 ConfigurationController disposing...');
    _cleanup();
    super.onClose();
  }

  /// التهيئة الآمنة
  Future<void> _initialize() async {
    try {
      await _safeCancel();
      _resetState();
      _loadConfig();
      await _initNetwork();
      print('✅ ConfigurationController initialized successfully');
    } catch (e) {
      print('❌ Error during initialization: $e');
      _setDefaultState();
    }
  }

  /// التنظيف الآمن
  Future<void> _cleanup() async {
    try {
      await _safeCancel();
      macAddressController.dispose();
      deviceNameController.dispose();
      ipAddressController.dispose();
      customSubnetController.dispose();
      print('✅ ConfigurationController cleaned up successfully');
    } catch (e) {
      print('⚠️ Error during cleanup: $e');
    }
  }

  /// إلغاء العمليات بطريقة آمنة
  Future<void> _safeCancel() async {
    if (_isOperationActive) {
      print('🛑 Cancelling active operations...');
      _isOperationActive = false;

      // إلغاء Timer
      _operationTimer?.cancel();
      _operationTimer = null;

      // إلغاء عمليات الشبكة
      try {
        await NetworkService.cancelOperations();
      } catch (e) {
        print('⚠️ Error cancelling network operations: $e');
      }

      // انتظار قصير للتأكد من اكتمال الإلغاء
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  /// إعادة تعيين الحالة
  void _resetState() {
    isScanning = isLoading = isConnected = false;
    discoveredDevices.clear();
    connectionStatus = _getStatusMessage();
    update();
  }

  /// تعيين حالة افتراضية
  void _setDefaultState() {
    currentNetworkIP = 'Not Connected';
    currentNetworkName = 'Unknown Network';
    currentGateway = 'Unknown';
    currentSubnet = '192.168.1';
    customSubnetController.text = currentSubnet!;
    _resetState();
  }

  /// رسالة الحالة
  String _getStatusMessage() => connectionType == 'LAN'
      ? 'سيتم البحث في الشبكة المحلية'
      : 'سيتم البحث عبر الإنترنت (يتطلب IP محدد)';

  /// تهيئة الشبكة
  Future<void> _initNetwork() async {
    try {
      print('🌐 Initializing network info...');
      final info = await NetworkService.getNetworkInfo();

      currentNetworkIP = info['wifiIP'];
      currentNetworkName = info['wifiName'];
      currentGateway = info['wifiGatewayIP'];
      currentSubnet = _getSubnet(currentNetworkIP ?? '');
      customSubnetController.text = currentSubnet ?? '192.168.1';

      print('✅ Network initialized: IP=${currentNetworkIP}, Subnet=${currentSubnet}');
      update();
    } catch (e) {
      print('⚠️ Error initializing network: $e');
      _setDefaultState();
    }
  }

  /// تغيير نوع الاتصال
  void setConnectionType(String? type) {
    if (type != null && type != connectionType) {
      print('🔄 Changing connection type to: $type');

      // إلغاء العمليات الحالية
      _safeCancel();

      connectionType = type;
      discoveredDevices.clear();
      connectionStatus = _getStatusMessage();
      _updateUI();
      _showInfo(type);
      update();
    }
  }

  /// تحديث الواجهة
  void _updateUI() {
    customSubnetController.text = connectionType == 'LAN' ? (currentSubnet ?? '192.168.1') : '';
  }

  /// عرض المعلومات
  void _showInfo(String type) {
    final message = type == 'LAN'
        ? 'تم اختيار الشبكة المحلية\nسيتم البحث عن الطابعات في نفس الشبكة'
        : 'تم اختيار الشبكة الواسعة\nيجب إدخال IP الطابعة يدوياً';

    Get.snackbar('نوع الاتصال', message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3));
  }

  /// البحث التلقائي المحسن
  Future<void> autoDetectPrinter() async {
    // التحقق من حالة العملية
    if (_isOperationActive) {
      print('⚠️ Operation already active, cancelling first...');
      await _safeCancel();
    }

    print('🔍 Starting auto detect printer...');

    // التحقق من الأذونات
    if (!await _requestPermissions()) {
      print('❌ Permissions not granted');
      return;
    }

    _startOperation();

    try {
      if (connectionType == 'LAN') {
        await _scanLANSafely();
      } else {
        await _handleWANSafely();
      }
    } catch (e) {
      print('❌ Auto detect error: $e');
      _handleError(e);
    } finally {
      _stopOperation();
    }
  }

  /// بدء العملية
  void _startOperation() {
    _isOperationActive = true;
    isLoading = isScanning = true;
    discoveredDevices.clear();
    update();

    EasyLoading.show(status: 'بدء البحث عن الطابعات...');

    // إعداد timeout آمن
    _operationTimer = Timer(const Duration(seconds: 60), () {
      if (_isOperationActive) {
        print('⏰ Operation timeout reached');
        _stopOperation();
        EasyLoading.showInfo('انتهت مهلة البحث');
      }
    });
  }

  /// إيقاف العملية
  void _stopOperation() {
    _isOperationActive = false;
    isLoading = isScanning = false;
    _operationTimer?.cancel();
    _operationTimer = null;
    EasyLoading.dismiss();
    update();
    print('✅ Operation stopped');
  }

  /// معالجة الأخطاء
  void _handleError(dynamic error) {
    connectionStatus = 'خطأ في البحث';
    isConnected = false;

    // عرض رسالة خطأ مناسبة
    if (error.toString().contains('SocketException')) {
      EasyLoading.showError('مشكلة في الاتصال بالشبكة');
    } else if (error.toString().contains('TimeoutException')) {
      EasyLoading.showError('انتهت مهلة البحث');
    } else {
      EasyLoading.showError('حدث خطأ أثناء البحث');
    }

    print('❌ Error handled: $error');
    update();
  }

  /// البحث الآمن في الشبكة المحلية
  Future<void> _scanLANSafely() async {
    if (!_isOperationActive) return;

    print('🏠 Starting LAN scan...');

    // التأكد من معلومات الشبكة
    await _initNetwork();
    if (currentNetworkIP == null || currentNetworkIP == 'Not Connected') {
      throw Exception('غير متصل بالشبكة المحلية');
    }

    EasyLoading.show(status: 'البحث في الشبكة المحلية...');

    try {
      // البحث المتقدم مع timeout محدود
      if (_isOperationActive) {
        print('🔍 Starting advanced discovery...');
        final devices =
            await NetworkService.discoverPrintersAdvanced().timeout(const Duration(seconds: 30));

        if (_isOperationActive) {
          discoveredDevices.addAll(devices);
          print('📱 Found ${devices.length} devices from advanced discovery');
        }
      }

      // إذا لم نجد أي أجهزة، نجرب البحث اليدوي
      if (_isOperationActive && discoveredDevices.isEmpty) {
        print('🔎 No devices found, trying manual scan...');
        EasyLoading.show(status: 'البحث اليدوي...');
        await _manualScan();
      }

      if (_isOperationActive) {
        _processResults();
      }
    } catch (e) {
      print('⚠️ LAN scan error: $e');
      if (_isOperationActive) {
        // في حالة الخطأ، نجرب البحث اليدوي كبديل
        try {
          EasyLoading.show(status: 'البحث البديل...');
          await _manualScan();
          if (_isOperationActive) _processResults();
        } catch (e2) {
          print('❌ Fallback scan also failed: $e2');
          rethrow;
        }
      }
    }
  }

  /// البحث اليدوي الآمن
  Future<void> _manualScan() async {
    if (!_isOperationActive) return;

    final subnet = customSubnetController.text.isNotEmpty
        ? customSubnetController.text.trim()
        : _getSubnet(currentNetworkIP!);

    // فحص IPs شائعة فقط لتجنب الأخطاء
    final commonIPs = ['$subnet.100', '$subnet.101', '$subnet.200', '$subnet.10'];

    print('🎯 Manual scan for ${commonIPs.length} common IPs...');

    for (int i = 0; i < commonIPs.length && _isOperationActive; i++) {
      final ip = commonIPs[i];

      try {
        if (await NetworkService.pingDevice(ip)) {
          print('✅ Manual scan found device at: $ip');
          discoveredDevices.add(NetworkDevice(
            ip: ip,
            name: 'Printer_${ip.split('.').last}',
            macAddress: _generateMac(ip),
            port: 9100,
            isOnline: true,
          ));

          // إذا وجدنا جهازين، نتوقف
          if (discoveredDevices.length >= 2) break;
        }
      } catch (e) {
        print('⚠️ Manual scan error for IP $ip: $e');
        continue;
      }

      // انتظار قصير لتجنب إرهاق الشبكة
      if (_isOperationActive && i < commonIPs.length - 1) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }

  /// معالجة WAN الآمنة
  Future<void> _handleWANSafely() async {
    if (!_isOperationActive) return;

    print('🌍 Starting WAN connection...');
    EasyLoading.show(status: 'إعداد الاتصال عبر الإنترنت...');

    if (ipAddressController.text.isEmpty) {
      EasyLoading.dismiss();
      await _showIPDialog();
      if (ipAddressController.text.isEmpty) {
        connectionStatus = 'يجب إدخال IP للطابعة';
        EasyLoading.showError(connectionStatus);
        return;
      }
    }

    if (!_isOperationActive) return;

    final testIP = ipAddressController.text.trim();
    print('🧪 Testing WAN connection to: $testIP');
    EasyLoading.show(status: 'اختبار الاتصال مع: $testIP');

    try {
      final isReachable =
          await NetworkService.pingDevice(testIP).timeout(const Duration(seconds: 10));

      if (_isOperationActive) {
        if (isReachable) {
          final device = NetworkDevice(
            ip: testIP,
            name: deviceNameController.text.isNotEmpty
                ? deviceNameController.text
                : 'WAN_Printer_${testIP.split('.').last}',
            macAddress: macAddressController.text.isNotEmpty
                ? macAddressController.text
                : _generateMac(testIP),
            port: 9100,
            isOnline: true,
          );

          discoveredDevices.add(device);
          _fillFields(device);

          connectionStatus = 'تم العثور على طابعة WAN';
          isConnected = true;
          EasyLoading.showSuccess('تم الاتصال بالطابعة!');
          print('✅ WAN connection successful');
        } else {
          connectionStatus = 'فشل الاتصال بالطابعة';
          isConnected = false;
          EasyLoading.showError('فشل الاتصال');
          print('❌ WAN connection failed');
        }
      }
    } catch (e) {
      print('❌ WAN connection error: $e');
      if (_isOperationActive) {
        connectionStatus = 'خطأ في اختبار WAN';
        isConnected = false;
        EasyLoading.showError('فشل في الاتصال');
      }
    }
  }

  /// حوار إدخال IP
  Future<void> _showIPDialog() async {
    final controller = TextEditingController(text: ipAddressController.text);

    await Get.dialog(
      AlertDialog(
        title: const Text('إدخال IP الطابعة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('يرجى إدخال عنوان IP للطابعة'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
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
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              ipAddressController.text = controller.text.trim();
              Get.back();
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// معالجة النتائج
  void _processResults() {
    if (!_isOperationActive) return;

    if (discoveredDevices.isNotEmpty) {
      _fillFields(discoveredDevices.first);
      connectionStatus = 'تم العثور على ${discoveredDevices.length} طابعة';
      isConnected = true;
      EasyLoading.showSuccess('تم العثور على ${discoveredDevices.length} طابعة!');
      print('🎉 Found ${discoveredDevices.length} printers');
    } else {
      connectionStatus = 'لم يتم العثور على طابعات';
      isConnected = false;
      EasyLoading.showInfo('لم يتم العثور على طابعات');
      print('😔 No printers found');
    }
    update();
  }

  /// ملء الحقول
  void _fillFields(NetworkDevice device) {
    macAddressController.text = device.macAddress;
    deviceNameController.text = device.name;
    ipAddressController.text = device.ip;
    update();
  }

  /// طلب الأذونات
  Future<bool> _requestPermissions() async {
    try {
      final granted = await NetworkService.requestPermissions();
      if (!granted) {
        EasyLoading.showError('يرجى منح الأذونات المطلوبة');
        print('❌ Permissions denied');
      }
      return granted;
    } catch (e) {
      print('❌ Permission error: $e');
      EasyLoading.showError('خطأ في طلب الأذونات');
      return false;
    }
  }

  /// معالج تغيير MAC
  void onMacAddressChanged(String value) {
    final formatted = _formatMac(value);
    if (formatted != value) {
      macAddressController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    if (formatted.length == 17) _autoFillName(formatted);
  }

  /// تنسيق MAC
  String _formatMac(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
    final limited = cleaned.length > 12 ? cleaned.substring(0, 12) : cleaned;

    String formatted = '';
    for (int i = 0; i < limited.length; i += 2) {
      if (i > 0) formatted += ':';
      formatted += limited.substring(i, (i + 2 > limited.length) ? limited.length : i + 2);
    }
    return formatted.toUpperCase();
  }

  /// ملء الاسم تلقائياً
  void _autoFillName(String mac) {
    final prefix = connectionType == 'LAN' ? 'LAN_Printer' : 'WAN_Printer';
    deviceNameController.text = '${prefix}_${mac.replaceAll(':', '').substring(6)}';
    update();
  }

  /// اختبار الاتصال المحسن
  Future<void> testConnection() async {
    if (macAddressController.text.isEmpty) {
      EasyLoading.showError('يرجى إدخال عنوان MAC');
      return;
    }

    // التحقق من عدم وجود عملية نشطة
    if (_isOperationActive) {
      EasyLoading.showInfo('يرجى انتظار انتهاء العملية الحالية');
      return;
    }

    final testType = connectionType == 'LAN' ? 'الشبكة المحلية' : 'الشبكة الواسعة';
    print('🧪 Testing connection via $testType...');

    EasyLoading.show(status: 'اختبار الاتصال عبر $testType...');

    try {
      bool result = false;

      if (ipAddressController.text.isNotEmpty) {
        result = await NetworkService.pingDevice(ipAddressController.text.trim())
            .timeout(const Duration(seconds: 10));
      } else {
        final device = discoveredDevices.firstWhereOrNull(
            (d) => d.macAddress.toLowerCase() == macAddressController.text.toLowerCase());
        if (device != null) {
          result = await NetworkService.pingDevice(device.ip).timeout(const Duration(seconds: 10));
          ipAddressController.text = device.ip;
        }
      }

      connectionStatus = result
          ? 'تم الاتصال بالطابعة بنجاح عبر $testType'
          : 'فشل في الاتصال بالطابعة عبر $testType';
      isConnected = result;

      EasyLoading.showSuccess(result ? 'تم الاتصال بنجاح!' : 'فشل في الاتصال');
      print(result ? '✅ Connection test successful' : '❌ Connection test failed');
    } catch (e) {
      print('❌ Connection test error: $e');
      connectionStatus = 'خطأ في الاختبار';
      isConnected = false;

      if (e.toString().contains('TimeoutException')) {
        EasyLoading.showError('انتهت مهلة الاختبار');
      } else {
        EasyLoading.showError('حدث خطأ أثناء الاختبار');
      }
    }

    update();
  }

  /// حفظ الإعدادات
  Future<void> saveConfiguration() async {
    if (!_validate()) return;

    print('💾 Saving configuration...');
    EasyLoading.show(status: 'حفظ إعدادات $connectionType...');

    try {
      await NetworkService.saveNetworkConfiguration(
        connectionType: connectionType,
        printerMac: macAddressController.text.trim(),
        deviceName: deviceNameController.text.trim(),
        printerIP: ipAddressController.text.trim(),
        networkName: currentNetworkName,
        networkIP: currentNetworkIP,
        gateway: currentGateway,
        subnet: currentSubnet,
      );

      if (await _verifyConfig()) {
        EasyLoading.showSuccess('تم حفظ إعدادات $connectionType بنجاح!');
        print('✅ Configuration saved successfully');
        await Future.delayed(const Duration(milliseconds: 1500));
        Get.offAllNamed(AppRoutes.login);
      } else {
        EasyLoading.showError('فشل في التحقق من حفظ البيانات');
        print('❌ Configuration verification failed');
      }
    } catch (e) {
      print('❌ Save configuration error: $e');
      EasyLoading.showError('حدث خطأ أثناء الحفظ');
    }
  }

  /// التحقق من البيانات
  bool _validate() {
    if (macAddressController.text.trim().isEmpty || deviceNameController.text.trim().isEmpty) {
      EasyLoading.showError('يرجى ملء جميع الحقول المطلوبة');
      return false;
    }
    if (!_isValidMac(macAddressController.text.trim())) {
      EasyLoading.showError('عنوان MAC غير صحيح');
      return false;
    }
    if (connectionType == 'WAN' && ipAddressController.text.trim().isEmpty) {
      EasyLoading.showError('يرجى إدخال IP الطابعة لاتصال WAN');
      return false;
    }
    return true;
  }

  /// التحقق من الحفظ
  Future<bool> _verifyConfig() async {
    try {
      final config = NetworkService.getNetworkConfiguration();
      return config.connectionType == connectionType &&
          config.printerMac == macAddressController.text.trim() &&
          config.deviceName == deviceNameController.text.trim() &&
          config.isConfigured;
    } catch (e) {
      print('⚠️ Verification error: $e');
      return false;
    }
  }

  /// تحميل الإعدادات
  void _loadConfig() {
    try {
      final config = NetworkService.getNetworkConfiguration();
      connectionType = config.connectionType.isNotEmpty ? config.connectionType : 'LAN';
      macAddressController.text = config.printerMac;
      deviceNameController.text = config.deviceName;
      ipAddressController.text = config.printerIP;
      customSubnetController.text = config.subnet.isNotEmpty ? config.subnet : '192.168.1';
      _updateUI();
      update();
      print('✅ Configuration loaded successfully');
    } catch (e) {
      print('⚠️ Error loading config: $e');
    }
  }

  /// إعادة تعيين حالة البحث
  void resetScanningState() {
    print('🔄 Resetting scanning state...');
    _safeCancel();
    _resetState();
  }

  /// اختيار جهاز مكتشف
  void selectDiscoveredDevice(NetworkDevice device) {
    print('📱 Selected device: ${device.name} (${device.ip})');
    _fillFields(device);
  }

  /// مسح الإعدادات
  void clearConfiguration() {
    print('🧹 Clearing configuration...');
    _safeCancel();
    macAddressController.clear();
    deviceNameController.clear();
    ipAddressController.clear();
    customSubnetController.clear();
    connectionStatus = '';
    isConnected = false;
    discoveredDevices.clear();
    update();
  }

  /// معلومات حالة الشبكة
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

  // =============== Helper Methods ===============

  /// استخراج الشبكة الفرعية
  String _getSubnet(String ip) {
    final parts = ip.split('.');
    return parts.length == 4 ? '${parts[0]}.${parts[1]}.${parts[2]}' : '192.168.1';
  }

  /// التحقق من صحة MAC
  bool _isValidMac(String mac) {
    return RegExp(
            r'^[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}')
        .hasMatch(mac);
  }

  /// توليد MAC وهمي
  String _generateMac(String ip) {
    final random = DateTime.now().millisecondsSinceEpoch;
    return '00:1A:2B:${(random % 256).toRadixString(16).padLeft(2, '0').toUpperCase()}:'
        '${((random ~/ 256) % 256).toRadixString(16).padLeft(2, '0').toUpperCase()}:'
        '${((random ~/ 65536) % 256).toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  // استيراد أداة التشخيص في أعلى الملف
  // import 'package:auth_app/utils/network_diagnostic.dart';

  /// تشخيص شامل للشبكة
  Future<void> runNetworkDiagnostic() async {
    if (_isOperationActive) {
      EasyLoading.showInfo('يرجى انتظار انتهاء العملية الحالية');
      return;
    }

    print('🔍 Starting network diagnostic...');
    EasyLoading.show(status: 'تشخيص الشبكة...');

    try {
      // تشغيل التشخيص الشامل
      // final diagnostic = await NetworkDiagnostic.runFullDiagnostic();

      // البحث عن طابعات باستخدام التشخيص
      // final printerIPs = await NetworkDiagnostic.findPrintersFromDiagnostic();

      // للآن، سنستخدم تشخيص مبسط
      await _simpleDiagnostic();

      EasyLoading.showSuccess('تم التشخيص بنجاح! راجع الـ Console للتفاصيل');
    } catch (e) {
      print('❌ Diagnostic error: $e');
      EasyLoading.showError('حدث خطأ أثناء التشخيص');
    }
  }

  /// تشخيص مبسط
  Future<void> _simpleDiagnostic() async {
    print('\n' + '=' * 50);
    print('🔍 SIMPLE NETWORK DIAGNOSTIC');
    print('=' * 50);

    // 1. معلومات الشبكة الحالية
    final networkInfo = await NetworkService.getNetworkInfo();
    print('🌐 Current Network Info:');
    networkInfo.forEach((key, value) {
      print('   $key: $value');
    });

    // تحليل نوع الشبكة
    final networkName = networkInfo['wifiName'] ?? '';
    final isHotspot = _detectHotspot(networkName);
    final isMobileNetwork = _detectMobileNetwork(networkName);

    print('\n📱 Network Analysis:');
    print(
        '   Network Type: ${isHotspot ? "Mobile Hotspot" : isMobileNetwork ? "Mobile Network" : "WiFi Router"}');
    print('   Is Hotspot: $isHotspot');
    print('   Printer Discovery: ${isHotspot ? "⚠️ LIMITED" : "✅ OPTIMAL"}');

    // 2. اختبار Gateway
    final gateway = networkInfo['wifiGatewayIP'];
    if (gateway != null && gateway != 'Unknown') {
      print('\n🚪 Testing Gateway: $gateway');
      final gatewayReachable = await NetworkService.pingDevice(gateway);
      print('   Gateway reachable: $gatewayReachable');

      if (!gatewayReachable && isHotspot) {
        print('   ⚠️ Gateway unreachable - This is common with Mobile Hotspots');
      }
    }

    // 3. اختبار DNS
    print('\n🔍 Testing DNS...');
    try {
      final result = await InternetAddress.lookup('google.com');
      print('   DNS working: ${result.isNotEmpty}');
    } catch (e) {
      print('   DNS error: $e');
    }

    // 4. البحث عن أجهزة في الشبكة
    final myIP = networkInfo['wifiIP'];
    if (myIP != null && myIP != 'Not Connected') {
      final subnet = _getSubnet(myIP);
      print('\n🔎 Scanning common printer IPs in $subnet:');

      if (isHotspot) {
        print('   ⚠️ WARNING: Mobile Hotspot detected!');
        print('   🔒 Many hotspots block device-to-device communication');
        print('   💡 Recommendation: Use traditional WiFi network');
      }

      final testIPs = [
        '$subnet.1',
        '$subnet.100',
        '$subnet.101',
        '$subnet.110',
        '$subnet.200',
        '$subnet.254'
      ];

      for (String ip in testIPs) {
        final reachable = await NetworkService.pingDevice(ip);
        if (reachable) {
          print('   ✅ Found device at: $ip');
        } else {
          print('   ❌ No response from: $ip');
        }

        // انتظار قصير بين الاختبارات
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // اقتراحات مخصصة
      print('\n💡 RECOMMENDATIONS:');
      if (isHotspot) {
        print('   1. Connect to a traditional WiFi network (router-based)');
        print('   2. Connect printer to the same WiFi network');
        print('   3. Alternatively, connect printer to this hotspot if supported');
        print('   4. Check if hotspot allows device discovery in settings');
      } else {
        print('   1. Ensure printer is connected to network: $networkName');
        print('   2. Check printer network settings');
        print('   3. Try printing network config from printer');
        print('   4. Verify printer supports network printing');
      }
    }

    print('=' * 50 + '\n');
  }

  /// كشف إذا كانت الشبكة hotspot
  bool _detectHotspot(String networkName) {
    final hotspotIndicators = [
      'galaxy',
      'iphone',
      'android',
      'samsung',
      'huawei',
      'xiaomi',
      'hotspot',
      'mobile',
      'phone',
      'nokia',
      'lg',
      'sony',
      'oneplus'
    ];

    final lowerName = networkName.toLowerCase();
    return hotspotIndicators.any((indicator) => lowerName.contains(indicator));
  }

  /// كشف إذا كانت شبكة موبايل
  bool _detectMobileNetwork(String networkName) {
    final mobileIndicators = ['4g', '5g', 'lte', 'edge', 'gprs', '3g'];

    final lowerName = networkName.toLowerCase();
    return mobileIndicators.any((indicator) => lowerName.contains(indicator));
  }

  /// اختبار طابعة محددة
  Future<void> testSpecificPrinter() async {
    // إظهار حوار لإدخال IP الطابعة للاختبار
    final controller = TextEditingController();

    await Get.dialog(
      AlertDialog(
        title: const Text('اختبار طابعة محددة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('أدخل IP الطابعة للاختبار المفصل:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'IP الطابعة',
                hintText: '192.168.1.100',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              if (controller.text.isNotEmpty) {
                await _testPrinterDetailed(controller.text.trim());
              }
            },
            child: const Text('اختبار'),
          ),
        ],
      ),
    );
  }

  /// اختبار مفصل لطابعة
  Future<void> _testPrinterDetailed(String ip) async {
    EasyLoading.show(status: 'اختبار الطابعة $ip...');

    print('\n' + '=' * 50);
    print('🖨️ DETAILED PRINTER TEST: $ip');
    print('=' * 50);

    try {
      // 1. اختبار ping
      print('🏓 Testing ping...');
      final pingResult = await NetworkService.pingDevice(ip);
      print('   Ping result: $pingResult');

      // 2. اختبار منافذ الطابعة
      print('\n🔌 Testing printer ports...');
      final printerPorts = [9100, 631, 515, 9101, 9102, 80, 443, 161];
      List<int> openPorts = [];

      for (int port in printerPorts) {
        try {
          final socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 2));
          openPorts.add(port);
          await socket.close();
          print('   ✅ Port $port: OPEN');
        } catch (e) {
          print('   ❌ Port $port: CLOSED');
        }
      }

      // 3. محاولة الحصول على MAC
      print('\n🔍 Getting MAC address...');
      try {
        if (Platform.isWindows) {
          final result = await Process.run('arp', ['-a', ip]);
          if (result.exitCode == 0) {
            final output = result.stdout.toString();
            print('   ARP result: $output');
          }
        }
      } catch (e) {
        print('   ARP error: $e');
      }

      // 4. تحديد نوع الطابعة
      String printerType = 'Unknown';
      if (openPorts.contains(9100))
        printerType = 'RAW Printer (9100)';
      else if (openPorts.contains(631))
        printerType = 'IPP Printer (631)';
      else if (openPorts.contains(515)) printerType = 'LPD Printer (515)';

      print('\n📊 Results:');
      print('   Reachable: $pingResult');
      print('   Open ports: ${openPorts.join(', ')}');
      print('   Printer type: $printerType');

      // إضافة إلى قائمة الأجهزة إذا تم العثور عليها
      if (openPorts.isNotEmpty) {
        final device = NetworkDevice(
          ip: ip,
          name: '${printerType.split(' ')[0]}_${ip.split('.').last}',
          macAddress: _generateMac(ip),
          isOnline: true,
          port: openPorts.first,
        );

        // إضافة للقائمة إذا لم تكن موجودة
        if (!discoveredDevices.any((d) => d.ip == ip)) {
          discoveredDevices.add(device);
          update();
        }

        EasyLoading.showSuccess('تم العثور على الطابعة!\nالنوع: $printerType');
      } else {
        EasyLoading.showError('لم يتم العثور على منافذ طابعة مفتوحة');
      }
    } catch (e) {
      print('❌ Detailed test error: $e');
      EasyLoading.showError('حدث خطأ أثناء اختبار الطابعة');
    }

    print('=' * 50 + '\n');
  }
}

























// // lib/pages/configuration/configuration_controller.dart

// import 'dart:io';
// import 'dart:async';
// import 'package:auth_app/models/network_device.dart';
// import 'package:auth_app/pages/configration/services/network_service.dart';
// import 'package:auth_app/routes/app_routes.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:network_info_plus/network_info_plus.dart';
// import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';

// class ConfigurationController extends GetxController {
//   // Text Controllers
//   final TextEditingController macAddressController = TextEditingController();
//   final TextEditingController deviceNameController = TextEditingController();
//   final TextEditingController ipAddressController = TextEditingController();
//   final TextEditingController customSubnetController = TextEditingController();

//   // Configuration Variables
//   String connectionType = 'LAN';
//   String connectionStatus = '';
//   bool isConnected = false;
//   bool isLoading = false;
//   bool isScanning = false;

//   // Network Info
//   String? currentNetworkIP;
//   String? currentNetworkName;
//   String? currentSubnet;
//   String? currentGateway;
//   List<NetworkDevice> discoveredDevices = [];

//   // Network Info Service
//   final NetworkInfo _networkInfo = NetworkInfo();

//   // Timer للتحكم في timeout العمليات
//   Timer? _scanTimeout;

//   // Add cancellation token for network operations
//   bool _shouldCancelScan = false;

//   // Track active sockets to properly close them
//   final List<Socket> _activeSockets = [];

//   // Stream subscription for network discovery
//   StreamSubscription? _discoverySubscription;

//   @override
//   void onInit() {
//     super.onInit();
//     _initializeController();
//   }

//   @override
//   void onClose() {
//     _disposeResources();
//     super.onClose();
//   }

//   /// تهيئة الكونترولر
//   Future<void> _initializeController() async {
//     await _cancelAllNetworkOperations();
//     resetScanningState();
//     loadSavedConfiguration();
//     await initializeNetworkInfo();
//   }

//   /// إلغاء جميع العمليات الشبكية النشطة
//   Future<void> _cancelAllNetworkOperations() async {
//     _shouldCancelScan = true;

//     // Cancel discovery subscription
//     await _discoverySubscription?.cancel();
//     _discoverySubscription = null;

//     // Close all active sockets
//     for (Socket socket in _activeSockets) {
//       try {
//         await socket.close();
//       } catch (e) {
//         // Ignore errors when closing sockets
//       }
//     }
//     _activeSockets.clear();

//     // Cancel scan timeout
//     _scanTimeout?.cancel();
//     _scanTimeout = null;

//     // Reset cancellation flag
//     _shouldCancelScan = false;
//   }

//   /// تنظيف الموارد
//   void _disposeResources() {
//     _cancelAllNetworkOperations();
//     macAddressController.dispose();
//     deviceNameController.dispose();
//     ipAddressController.dispose();
//     customSubnetController.dispose();
//   }

//   /// تهيئة معلومات الشبكة
//   Future<void> initializeNetworkInfo() async {
//     try {
//       final networkInfo = await NetworkService.getNetworkInfo();
//       currentNetworkIP = networkInfo['wifiIP'];
//       currentNetworkName = networkInfo['wifiName'];
//       currentGateway = networkInfo['wifiGatewayIP'];
//       currentSubnet = _getSubnet(currentNetworkIP ?? '');
//       customSubnetController.text = currentSubnet ?? '192.168.1';
//       update();
//     } catch (e) {
//       print('Error initializing network info: $e');
//       _setDefaultNetworkInfo();
//     }
//   }

//   /// تعيين معلومات شبكة افتراضية
//   void _setDefaultNetworkInfo() {
//     currentNetworkIP = 'Not Connected';
//     currentNetworkName = 'Unknown Network';
//     currentGateway = 'Unknown';
//     currentSubnet = '192.168.1';
//     customSubnetController.text = currentSubnet!;
//     update();
//   }

//   /// تعيين نوع الاتصال مع التحديث المناسب
//   void setConnectionType(String? type) {
//     if (type != null && type != connectionType) {
//       connectionType = type;
//       _resetConnectionState();
//       _updateUIForConnectionType();
//       _showConnectionTypeInfo(type);
//       update();
//     }
//   }

//   /// إعادة تعيين حالة الاتصال
//   void _resetConnectionState() {
//     _cancelAllNetworkOperations();
//     discoveredDevices.clear();
//     connectionStatus = '';
//     isConnected = false;
//   }

//   /// تحديث واجهة المستخدم حسب نوع الاتصال
//   void _updateUIForConnectionType() {
//     switch (connectionType) {
//       case 'LAN':
//         customSubnetController.text = currentSubnet ?? '192.168.1';
//         connectionStatus = 'سيتم البحث في الشبكة المحلية';
//         break;
//       case 'WAN':
//         customSubnetController.text = '';
//         connectionStatus = 'سيتم البحث عبر الإنترنت (يتطلب IP محدد)';
//         break;
//     }
//   }

//   /// عرض معلومات نوع الاتصال
//   void _showConnectionTypeInfo(String type) {
//     String message = '';
//     switch (type) {
//       case 'LAN':
//         message = 'تم اختيار الشبكة المحلية\nسيتم البحث عن الطابعات في نفس الشبكة';
//         break;
//       case 'WAN':
//         message = 'تم اختيار الشبكة الواسعة\nيجب إدخال IP الطابعة يدوياً';
//         break;
//     }

//     if (message.isNotEmpty) {
//       Get.snackbar(
//         'نوع الاتصال',
//         message,
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.blue.withOpacity(0.8),
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//     }
//   }

//   /// البحث التلقائي عن الطابعات
//   Future<void> autoDetectPrinter() async {
//     // Cancel any existing operations first
//     await _cancelAllNetworkOperations();

//     if (!await _requestPermissions()) {
//       return;
//     }

//     _startScanning();

//     try {
//       switch (connectionType) {
//         case 'LAN':
//           await _scanLocalNetwork();
//           break;
//         case 'WAN':
//           await _handleWANConnection();
//           break;
//       }
//     } catch (e) {
//       _handleScanError(e);
//     } finally {
//       _stopScanning();
//     }
//   }

//   /// بدء عملية البحث
//   void _startScanning() {
//     isLoading = true;
//     isScanning = true;
//     _shouldCancelScan = false;
//     discoveredDevices.clear();
//     update();

//     EasyLoading.show(status: 'بدء البحث عن الطابعات...');

//     // إعداد timeout
//     _scanTimeout = Timer(const Duration(minutes: 2), () {
//       if (isScanning && !_shouldCancelScan) {
//         _stopScanning();
//         EasyLoading.showInfo('انتهت مهلة البحث. جرب مرة أخرى.');
//       }
//     });
//   }

//   /// إيقاف عملية البحث
//   void _stopScanning() {
//     isLoading = false;
//     isScanning = false;
//     _shouldCancelScan = true;
//     _scanTimeout?.cancel();
//     _scanTimeout = null;
//     EasyLoading.dismiss();
//     update();
//   }

//   /// معالجة أخطاء البحث
//   void _handleScanError(dynamic error) {
//     connectionStatus = 'خطأ في البحث: ${error.toString()}';
//     isConnected = false;
//     EasyLoading.showError('حدث خطأ أثناء البحث');
//     print('Auto detect error: $error');
//   }

//   /// البحث في الشبكة المحلية
//   Future<void> _scanLocalNetwork() async {
//     if (_shouldCancelScan) return;

//     // التحقق من اتصال الشبكة
//     await initializeNetworkInfo();
//     if (currentNetworkIP == null || currentNetworkIP == 'Not Connected') {
//       throw Exception('غير متصل بالشبكة المحلية. تحقق من اتصال WiFi');
//     }

//     EasyLoading.show(status: 'جاري البحث في الشبكة المحلية...');

//     String subnet = customSubnetController.text.isNotEmpty
//         ? customSubnetController.text.trim()
//         : _getSubnet(currentNetworkIP!);

//     if (!_isValidSubnet(subnet)) {
//       throw Exception('الشبكة الفرعية غير صحيحة: $subnet');
//     }

//     List<NetworkDevice> foundDevices = [];

//     try {
//       // البحث المتقدم
//       if (!_shouldCancelScan) {
//         EasyLoading.show(status: 'البحث المتقدم...');
//         foundDevices.addAll(await _performAdvancedSearch());
//       }

//       // البحث في المنافذ المختلفة
//       if (!_shouldCancelScan) {
//         foundDevices.addAll(await _scanMultiplePorts(subnet));
//       }

//       // فحص عناوين IP شائعة للطابعات
//       if (!_shouldCancelScan) {
//         foundDevices.addAll(await _scanCommonPrinterIPs(subnet));
//       }
//     } catch (e) {
//       print('Enhanced scan failed: $e');
//       // العودة للبحث الاحتياطي
//       if (!_shouldCancelScan) {
//         foundDevices.addAll(await _fallbackScan(subnet));
//       }
//     }

//     if (!_shouldCancelScan) {
//       discoveredDevices = _removeDuplicateDevices(foundDevices);
//       _processDiscoveredDevices();
//     }
//   }

//   /// البحث المتقدم باستخدام NetworkService
//   Future<List<NetworkDevice>> _performAdvancedSearch() async {
//     if (_shouldCancelScan) return [];

//     try {
//       return await NetworkService.discoverPrintersAdvanced().timeout(const Duration(seconds: 30));
//     } catch (e) {
//       print('Advanced search failed: $e');
//       return [];
//     }
//   }

//   /// البحث في منافذ متعددة
//   Future<List<NetworkDevice>> _scanMultiplePorts(String subnet) async {
//     if (_shouldCancelScan) return [];

//     List<NetworkDevice> devices = [];
//     List<int> printerPorts = [9100, 631, 515];

//     for (int port in printerPorts) {
//       if (_shouldCancelScan) break;

//       try {
//         EasyLoading.show(status: 'فحص المنفذ $port...');
//         devices.addAll(
//             await _scanPortWithEnhancement(subnet, port).timeout(const Duration(seconds: 20)));
//       } catch (e) {
//         print('Port $port scan failed: $e');
//         continue;
//       }
//     }

//     return devices;
//   }

//   /// فحص عناوين IP شائعة للطابعات
//   Future<List<NetworkDevice>> _scanCommonPrinterIPs(String subnet) async {
//     if (_shouldCancelScan) return [];

//     List<NetworkDevice> devices = [];
//     List<String> commonIPs = [
//       '$subnet.100',
//       '$subnet.101',
//       '$subnet.200',
//       '$subnet.201',
//       '$subnet.10',
//       '$subnet.20',
//       '$subnet.30',
//       '$subnet.50'
//     ];

//     EasyLoading.show(status: 'فحص عناوين IP الشائعة...');

//     for (String ip in commonIPs) {
//       if (_shouldCancelScan) break;

//       try {
//         if (await _testSpecificIPSafe(ip)) {
//           devices.add(NetworkDevice(
//             ip: ip,
//             name: 'Printer_${ip.split('.').last}',
//             macAddress: _generateFakeMac(),
//             port: 9100,
//             isOnline: true,
//           ));
//         }
//       } catch (e) {
//         continue;
//       }
//     }

//     return devices;
//   }

//   /// فحص محسن للمنفذ
//   Future<List<NetworkDevice>> _scanPortWithEnhancement(String subnet, int port) async {
//     if (_shouldCancelScan) return [];

//     List<NetworkDevice> devices = [];

//     try {
//       final stream = NetworkAnalyzer.discover2(subnet, port, timeout: const Duration(seconds: 4));

//       _discoverySubscription = stream.listen(
//         (NetworkAddress addr) async {
//           if (_shouldCancelScan) return;

//           if (addr.exists && await _testSpecificIPSafe(addr.ip)) {
//             String deviceName = await _identifyPrinterDevice(addr.ip, port);
//             String macAddress = await _getMacAddress(addr.ip) ?? _generateFakeMac();

//             devices.add(NetworkDevice(
//               ip: addr.ip,
//               name: deviceName,
//               macAddress: macAddress,
//               port: port,
//               isOnline: true,
//             ));
//           }
//         },
//         onError: (error) {
//           print('Error in enhanced port scan stream: $error');
//         },
//       );

//       // Wait for completion or timeout
//       await _discoverySubscription?.asFuture().timeout(
//         const Duration(seconds: 20),
//         onTimeout: () {
//           _discoverySubscription?.cancel();
//         },
//       );
//     } catch (e) {
//       print('Error in enhanced port scan: $e');
//     }

//     return devices;
//   }

//   /// اختبار IP محدد بطريقة آمنة
//   Future<bool> _testSpecificIPSafe(String ip) async {
//     if (_shouldCancelScan || !_isValidIP(ip)) return false;

//     List<int> testPorts = [9100, 631, 515, 80];

//     for (int port in testPorts) {
//       if (_shouldCancelScan) break;

//       Socket? socket;
//       try {
//         socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 2));
//         _activeSockets.add(socket);
//         await socket.close();
//         _activeSockets.remove(socket);
//         return true;
//       } catch (e) {
//         if (socket != null) {
//           _activeSockets.remove(socket);
//           try {
//             await socket.close();
//           } catch (_) {}
//         }
//         continue;
//       }
//     }

//     // محاولة ping كبديل
//     return await _pingDeviceSafe(ip);
//   }

//   /// اختبار IP محدد (النسخة القديمة للتوافق)
//   Future<bool> _testSpecificIP(String ip) async {
//     return await _testSpecificIPSafe(ip);
//   }

//   /// البحث الاحتياطي
//   Future<List<NetworkDevice>> _fallbackScan(String subnet) async {
//     if (_shouldCancelScan) return [];

//     EasyLoading.show(status: 'البحث الاحتياطي...');
//     List<NetworkDevice> devices = [];

//     for (int i = 1; i <= 254 && devices.length < 5; i++) {
//       if (_shouldCancelScan) break;

//       String testIP = '$subnet.$i';

//       if (i % 50 == 0) {
//         EasyLoading.show(status: 'فحص: $testIP');
//       }

//       if (await _testSpecificIPSafe(testIP)) {
//         devices.add(NetworkDevice(
//           ip: testIP,
//           name: 'Device_$i',
//           macAddress: _generateFakeMac(),
//           port: 9100,
//           isOnline: true,
//         ));
//       }
//     }

//     return devices;
//   }

//   /// إزالة الأجهزة المكررة
//   List<NetworkDevice> _removeDuplicateDevices(List<NetworkDevice> devices) {
//     Map<String, NetworkDevice> uniqueDevices = {};
//     for (var device in devices) {
//       uniqueDevices[device.ip] = device;
//     }
//     return uniqueDevices.values.toList();
//   }

//   /// معالجة اتصال WAN
//   Future<void> _handleWANConnection() async {
//     if (_shouldCancelScan) return;

//     EasyLoading.show(status: 'إعداد الاتصال عبر الإنترنت...');

//     if (ipAddressController.text.isEmpty) {
//       EasyLoading.dismiss();
//       await _showIPInputDialog();

//       if (ipAddressController.text.isEmpty) {
//         connectionStatus = 'يجب إدخال IP للطابعة في اتصال WAN';
//         EasyLoading.showError(connectionStatus);
//         return;
//       }
//     }

//     if (_shouldCancelScan) return;

//     EasyLoading.show(status: 'اختبار الاتصال مع: ${ipAddressController.text}');

//     bool isReachable = await _testWANConnection(ipAddressController.text);

//     if (!_shouldCancelScan) {
//       if (isReachable) {
//         NetworkDevice wanDevice = NetworkDevice(
//           ip: ipAddressController.text,
//           name: deviceNameController.text.isNotEmpty
//               ? deviceNameController.text
//               : 'WAN_Printer_${ipAddressController.text.split('.').last}',
//           macAddress:
//               macAddressController.text.isNotEmpty ? macAddressController.text : _generateFakeMac(),
//           port: 9100,
//           isOnline: true,
//         );

//         discoveredDevices.add(wanDevice);

//         // ملء الحقول تلقائياً
//         if (deviceNameController.text.isEmpty) {
//           deviceNameController.text = wanDevice.name;
//         }
//         if (macAddressController.text.isEmpty) {
//           macAddressController.text = wanDevice.macAddress;
//         }

//         connectionStatus = 'تم العثور على طابعة WAN';
//         isConnected = true;
//         EasyLoading.showSuccess('تم الاتصال بالطابعة عبر الإنترنت!');
//       } else {
//         connectionStatus = 'فشل الاتصال بالطابعة عبر WAN';
//         isConnected = false;
//         EasyLoading.showError('فشل الاتصال. تحقق من IP والاتصال بالإنترنت');
//       }
//     }
//   }

//   /// إظهار حوار إدخال IP للاتصال WAN
//   Future<void> _showIPInputDialog() async {
//     final TextEditingController tempController = TextEditingController();
//     tempController.text = ipAddressController.text;

//     await Get.dialog(
//       AlertDialog(
//         title: const Text('إدخال IP الطابعة'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('يرجى إدخال عنوان IP للطابعة للاتصال عبر WAN'),
//             const SizedBox(height: 16),
//             TextField(
//               controller: tempController,
//               decoration: const InputDecoration(
//                 labelText: 'عنوان IP',
//                 hintText: '192.168.1.100',
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               ipAddressController.text = tempController.text;
//               Get.back();
//             },
//             child: const Text('تأكيد'),
//           ),
//         ],
//       ),
//     );
//   }

//   /// اختبار اتصال WAN
//   Future<bool> _testWANConnection(String ip) async {
//     if (_shouldCancelScan) return false;

//     try {
//       List<int> portsToTest = [9100, 631, 515, 80, 443];

//       for (int port in portsToTest) {
//         if (_shouldCancelScan) break;

//         Socket? socket;
//         try {
//           socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 5));
//           _activeSockets.add(socket);
//           await socket.close();
//           _activeSockets.remove(socket);
//           return true;
//         } catch (e) {
//           if (socket != null) {
//             _activeSockets.remove(socket);
//             try {
//               await socket.close();
//             } catch (_) {}
//           }
//           continue;
//         }
//       }

//       return await _pingDeviceSafe(ip);
//     } catch (e) {
//       print('WAN connection test failed: $e');
//       return false;
//     }
//   }

//   /// معالجة الأجهزة المكتشفة
//   void _processDiscoveredDevices() {
//     if (_shouldCancelScan) return;

//     if (discoveredDevices.isNotEmpty) {
//       // اختيار أول طابعة تلقائياً
//       NetworkDevice firstPrinter = discoveredDevices.first;
//       macAddressController.text = firstPrinter.macAddress;
//       deviceNameController.text = firstPrinter.name;
//       ipAddressController.text = firstPrinter.ip;

//       connectionStatus = 'تم العثور على ${discoveredDevices.length} طابعة';
//       isConnected = true;

//       EasyLoading.showSuccess('تم العثور على ${discoveredDevices.length} طابعة!');
//     } else {
//       connectionStatus = connectionType == 'LAN'
//           ? 'لم يتم العثور على أي طابعة في الشبكة المحلية'
//           : 'لم يتم العثور على طابعة في الشبكة الواسعة';
//       isConnected = false;
//       EasyLoading.showInfo('لم يتم العثور على طابعات. تأكد من تشغيل الطابعة واتصالها بالشبكة');
//     }
//   }

//   /// طلب الأذونات المطلوبة
//   Future<bool> _requestPermissions() async {
//     try {
//       bool granted = await NetworkService.requestPermissions();
//       if (!granted) {
//         EasyLoading.showError('يرجى منح الأذونات المطلوبة للوصول للشبكة');
//       }
//       return granted;
//     } catch (e) {
//       print('Error requesting permissions: $e');
//       EasyLoading.showError('خطأ في طلب الأذونات');
//       return false;
//     }
//   }

//   /// معالج تغيير MAC Address
//   void onMacAddressChanged(String value) {
//     String formatted = formatMacAddress(value);
//     if (formatted != value) {
//       macAddressController.value = TextEditingValue(
//         text: formatted,
//         selection: TextSelection.collapsed(offset: formatted.length),
//       );
//     }

//     if (formatted.length == 17) {
//       autoFillDeviceName(formatted);
//     }
//   }

//   /// تنسيق MAC Address
//   String formatMacAddress(String input) {
//     String cleaned = input.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');

//     if (cleaned.length > 12) {
//       cleaned = cleaned.substring(0, 12);
//     }

//     String formatted = '';
//     for (int i = 0; i < cleaned.length; i += 2) {
//       if (i > 0) formatted += ':';
//       formatted += cleaned.substring(i, i + 2 > cleaned.length ? cleaned.length : i + 2);
//     }

//     return formatted.toUpperCase();
//   }

//   /// ملء اسم الجهاز تلقائياً
//   void autoFillDeviceName(String macAddress) {
//     String prefix = connectionType == 'LAN' ? 'LAN_Printer' : 'WAN_Printer';
//     String deviceName = '${prefix}_${macAddress.replaceAll(':', '').substring(6)}';
//     deviceNameController.text = deviceName;
//     update();
//   }

//   /// اختبار الاتصال مع الطابعة
//   Future<void> testConnection() async {
//     if (macAddressController.text.isEmpty) {
//       EasyLoading.showError('يرجى إدخال عنوان MAC للطابعة');
//       return;
//     }

//     String testType = connectionType == 'LAN' ? 'الشبكة المحلية' : 'الشبكة الواسعة';
//     EasyLoading.show(status: 'جاري اختبار الاتصال عبر $testType...');

//     try {
//       bool testResult = false;

//       if (ipAddressController.text.isNotEmpty) {
//         testResult = connectionType == 'WAN'
//             ? await _testWANConnection(ipAddressController.text)
//             : await _pingDeviceSafe(ipAddressController.text);
//       } else {
//         NetworkDevice? device = discoveredDevices.firstWhereOrNull(
//             (d) => d.macAddress.toLowerCase() == macAddressController.text.toLowerCase());

//         if (device != null) {
//           testResult = connectionType == 'WAN'
//               ? await _testWANConnection(device.ip)
//               : await _pingDeviceSafe(device.ip);
//           ipAddressController.text = device.ip;
//         }
//       }

//       if (testResult) {
//         connectionStatus = 'تم الاتصال بالطابعة بنجاح عبر $testType';
//         isConnected = true;
//         EasyLoading.showSuccess('تم الاتصال بنجاح عبر $testType!');
//       } else {
//         connectionStatus = 'فشل في الاتصال بالطابعة عبر $testType';
//         isConnected = false;
//         EasyLoading.showError('فشل في الاتصال - تأكد من إعدادات $testType');
//       }
//     } catch (e) {
//       connectionStatus = 'خطأ في الاختبار: ${e.toString()}';
//       isConnected = false;
//       EasyLoading.showError('حدث خطأ أثناء الاختبار');
//     }

//     update();
//   }

//   /// حفظ الإعدادات
//   Future<void> saveConfiguration() async {
//     if (!_validateInput()) return;

//     EasyLoading.show(status: 'جاري حفظ إعدادات $connectionType...');

//     try {
//       await NetworkService.saveNetworkConfiguration(
//         connectionType: connectionType,
//         printerMac: macAddressController.text,
//         deviceName: deviceNameController.text,
//         printerIP: ipAddressController.text,
//         networkName: currentNetworkName,
//         networkIP: currentNetworkIP,
//         gateway: currentGateway,
//         subnet: currentSubnet,
//       );

//       if (await _verifySavedConfiguration()) {
//         EasyLoading.showSuccess('تم حفظ إعدادات $connectionType بنجاح!\nالبيانات محفوظة بشكل دائم');
//         await Future.delayed(const Duration(milliseconds: 1500));
//         Get.offAllNamed(AppRoutes.login);
//       } else {
//         EasyLoading.showError('فشل في التحقق من حفظ البيانات، حاول مرة أخرى');
//       }
//     } catch (e) {
//       EasyLoading.showError('حدث خطأ أثناء الحفظ: ${e.toString()}');
//     }
//   }

//   /// التحقق من صحة البيانات المدخلة
//   bool _validateInput() {
//     if (macAddressController.text.isEmpty || deviceNameController.text.isEmpty) {
//       EasyLoading.showError('يرجى ملء جميع الحقول المطلوبة');
//       return false;
//     }

//     if (!_isValidMacAddress(macAddressController.text)) {
//       EasyLoading.showError('عنوان MAC غير صحيح');
//       return false;
//     }

//     if (connectionType == 'WAN' && ipAddressController.text.isEmpty) {
//       EasyLoading.showError('يرجى إدخال IP الطابعة لاتصال WAN');
//       return false;
//     }

//     return true;
//   }

//   /// التحقق من نجاح حفظ الإعدادات
//   Future<bool> _verifySavedConfiguration() async {
//     try {
//       final config = NetworkService.getNetworkConfiguration();
//       return config.connectionType == connectionType &&
//           config.printerMac == macAddressController.text &&
//           config.deviceName == deviceNameController.text &&
//           config.isConfigured;
//     } catch (e) {
//       return false;
//     }
//   }

//   /// تحميل الإعدادات المحفوظة
//   void loadSavedConfiguration() {
//     try {
//       final config = NetworkService.getNetworkConfiguration();

//       connectionType = config.connectionType.isNotEmpty ? config.connectionType : 'LAN';
//       macAddressController.text = config.printerMac;
//       deviceNameController.text = config.deviceName;
//       ipAddressController.text = config.printerIP;
//       customSubnetController.text = config.subnet.isNotEmpty ? config.subnet : '192.168.1';

//       _updateUIForConnectionType();
//       update();
//     } catch (e) {
//       print('Error loading saved configuration: $e');
//     }
//   }

//   /// إعادة تعيين حالة البحث
//   void resetScanningState() {
//     _cancelAllNetworkOperations();
//     isScanning = false;
//     isLoading = false;
//     discoveredDevices.clear();
//     connectionStatus = connectionType == 'LAN'
//         ? 'سيتم البحث في الشبكة المحلية'
//         : 'سيتم البحث عبر الإنترنت (يتطلب IP محدد)';
//     update();
//   }

//   /// اختيار جهاز مكتشف
//   void selectDiscoveredDevice(NetworkDevice device) {
//     macAddressController.text = device.macAddress;
//     deviceNameController.text = device.name;
//     ipAddressController.text = device.ip;
//     update();
//   }

//   /// مسح الإعدادات
//   void clearConfiguration() {
//     _cancelAllNetworkOperations();
//     macAddressController.clear();
//     deviceNameController.clear();
//     ipAddressController.clear();
//     customSubnetController.clear();
//     connectionStatus = '';
//     isConnected = false;
//     discoveredDevices.clear();
//     update();
//   }

//   /// الحصول على معلومات حالة الشبكة
//   String getNetworkStatusInfo() {
//     if (connectionType == 'LAN') {
//       return 'اسم الشبكة: ${currentNetworkName ?? "غير معروف"}\n'
//           'IP الحالي: ${currentNetworkIP ?? "غير متصل"}\n'
//           'البوابة: ${currentGateway ?? "غير محددة"}\n'
//           'الشبكة الفرعية: ${currentSubnet ?? "غير محددة"}';
//     } else {
//       return 'الشبكة الواسعة (WAN)\n'
//           'يتطلب IP مباشر للطابعة\n'
//           'IP الطابعة: ${ipAddressController.text.isEmpty ? "غير محدد" : ipAddressController.text}';
//     }
//   }

//   // =============== Helper Methods ===============

//   /// استخراج الشبكة الفرعية من IP
//   String _getSubnet(String ip) {
//     List<String> parts = ip.split('.');
//     if (parts.length == 4) {
//       return '${parts[0]}.${parts[1]}.${parts[2]}';
//     }
//     return '192.168.1';
//   }

//   /// التحقق من صحة الشبكة الفرعية
//   bool _isValidSubnet(String subnet) {
//     RegExp subnetRegex = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}');
//     if (!subnetRegex.hasMatch(subnet)) return false;

//     List<String> parts = subnet.split('.');
//     for (String part in parts) {
//       int? num = int.tryParse(part);
//       if (num == null || num < 0 || num > 255) return false;
//     }
//     return true;
//   }

//   /// التحقق من صحة IP
//   bool _isValidIP(String ip) {
//     RegExp ipRegex = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}');
//     if (!ipRegex.hasMatch(ip)) return false;

//     List<String> parts = ip.split('.');
//     for (String part in parts) {
//       int? num = int.tryParse(part);
//       if (num == null || num < 0 || num > 255) return false;
//     }
//     return true;
//   }

//   /// التحقق من صحة MAC Address
//   bool _isValidMacAddress(String mac) {
//     RegExp macRegex = RegExp(
//         r'^[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}');
//     return macRegex.hasMatch(mac);
//   }

//   /// تعريف نوع الجهاز حسب المنفذ
//   Future<String> _identifyPrinterDevice(String ip, int port) async {
//     if (_shouldCancelScan) return '${connectionType}_Unknown_Printer_${ip.split('.').last}';

//     Socket? socket;
//     try {
//       socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 2));
//       _activeSockets.add(socket);
//       await socket.close();
//       _activeSockets.remove(socket);

//       String deviceType = _getDeviceTypeByPort(port);
//       String prefix = connectionType == 'LAN' ? 'LAN' : 'WAN';
//       return '${prefix}_${deviceType}_${ip.split('.').last}';
//     } catch (e) {
//       if (socket != null) {
//         _activeSockets.remove(socket);
//         try {
//           await socket.close();
//         } catch (_) {}
//       }
//       return '${connectionType}_Unknown_Printer_${ip.split('.').last}';
//     }
//   }

//   /// الحصول على نوع الجهاز حسب المنفذ
//   String _getDeviceTypeByPort(int port) {
//     switch (port) {
//       case 9100:
//         return 'RAW_Printer';
//       case 631:
//         return 'IPP_Printer';
//       case 515:
//         return 'LPD_Printer';
//       case 721:
//         return 'Printer';
//       default:
//         return 'Network_Printer';
//     }
//   }

//   /// الحصول على MAC Address
//   Future<String?> _getMacAddress(String ip) async {
//     if (_shouldCancelScan) return null;

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

//   /// توليد MAC Address وهمي
//   String _generateFakeMac() {
//     final random = DateTime.now().millisecondsSinceEpoch;
//     return '00:1A:2B:${(random % 256).toRadixString(16).padLeft(2, '0').toUpperCase()}:'
//         '${((random ~/ 256) % 256).toRadixString(16).padLeft(2, '0').toUpperCase()}:'
//         '${((random ~/ 65536) % 256).toRadixString(16).padLeft(2, '0').toUpperCase()}';
//   }

//   /// ping الجهاز بطريقة آمنة
//   Future<bool> _pingDeviceSafe(String ip) async {
//     if (_shouldCancelScan || !_isValidIP(ip)) return false;

//     try {
//       final result =
//           await Process.run('ping', ['-c', '1', '-W', '3', ip]).timeout(const Duration(seconds: 5));

//       return result.exitCode == 0;
//     } catch (e) {
//       print('Error pinging $ip: $e');
//       // محاولة اتصال Socket كبديل
//       Socket? socket;
//       try {
//         socket = await Socket.connect(ip, 9100, timeout: const Duration(seconds: 2));
//         _activeSockets.add(socket);
//         await socket.close();
//         _activeSockets.remove(socket);
//         return true;
//       } catch (e) {
//         if (socket != null) {
//           _activeSockets.remove(socket);
//           try {
//             await socket.close();
//           } catch (_) {}
//         }
//         return false;
//       }
//     }
//   }

//   /// ping الجهاز (النسخة القديمة للتوافق)
//   Future<bool> _pingDevice(String ip) async {
//     return await _pingDeviceSafe(ip);
//   }
// }














// // lib/pages/configuration/real_network_configuration_controller.dart

// import 'dart:io';
// import 'dart:async';
// import 'package:auth_app/models/network_device.dart';
// import 'package:auth_app/pages/configration/services/network_service.dart';
// import 'package:auth_app/routes/app_routes.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:auth_app/classes/shared_preference.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:network_info_plus/network_info_plus.dart';
// import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';
// import 'package:permission_handler/permission_handler.dart';

// class ConfigurationController extends GetxController {
//   // Text Controllers
//   final TextEditingController macAddressController = TextEditingController();
//   final TextEditingController deviceNameController = TextEditingController();
//   final TextEditingController ipAddressController = TextEditingController();
//   final TextEditingController customSubnetController = TextEditingController();

//   // Configuration Variables
//   String connectionType = 'LAN';
//   String connectionStatus = '';
//   bool isConnected = false;
//   bool isLoading = false;
//   bool isScanning = false;

//   // Network Info
//   String? currentNetworkIP;
//   String? currentNetworkName;
//   String? currentSubnet;
//   String? currentGateway;
//   List<NetworkDevice> discoveredDevices = [];

//   // Network Info Service
//   final NetworkInfo _networkInfo = NetworkInfo();

//   @override
//   void onInit() {
//     super.onInit();
//     resetScanningState(); // إضافة هذه السطر

//     loadSavedConfiguration();
//     _initializeNetworkInfo();

//     // getNetworkStatusInfo();
//   }

//   @override
//   void onClose() {
//     macAddressController.dispose();
//     deviceNameController.dispose();
//     ipAddressController.dispose();
//     customSubnetController.dispose();
//     super.onClose();
//   }

//   // Initialize network info
//   Future<void> _initializeNetworkInfo() async {
//     try {
//       currentNetworkIP = await _networkInfo.getWifiIP();
//       currentNetworkName = await _networkInfo.getWifiName();
//       currentGateway = await _networkInfo.getWifiGatewayIP();
//       currentSubnet = _getSubnet(currentNetworkIP ?? '');
//       customSubnetController.text = currentSubnet ?? '192.168.1';
//       update();
//     } catch (e) {
//       print('Error initializing network info: $e');
//     }
//   }

//   // Set Connection Type with real functionality
//   void setConnectionType(String? type) {
//     if (type != null && type != connectionType) {
//       connectionType = type;

//       // Clear previous results when connection type changes
//       discoveredDevices.clear();
//       connectionStatus = '';
//       isConnected = false;

//       // Update UI elements based on connection type
//       _updateUIForConnectionType();

//       update();

//       // Show information about the selected connection type
//       _showConnectionTypeInfo(type);
//     }
//   }

//   // Update UI elements based on connection type
//   void _updateUIForConnectionType() {
//     switch (connectionType) {
//       case 'LAN':
//         // For LAN, we use local network scanning
//         customSubnetController.text = currentSubnet ?? '192.168.1';
//         connectionStatus = 'سيتم البحث في الشبكة المحلية';
//         break;

//       case 'WAN':
//         // For WAN, we might need different approach
//         customSubnetController.text = '';
//         connectionStatus = 'سيتم البحث عبر الإنترنت (يتطلب IP محدد)';
//         break;
//     }
//   }

//   // Show information about connection type
//   void _showConnectionTypeInfo(String type) {
//     String message = '';
//     switch (type) {
//       case 'LAN':
//         message = 'تم اختيار الشبكة المحلية\nسيتم البحث عن الطابعات في نفس الشبكة';
//         break;
//       case 'WAN':
//         message = 'تم اختيار الشبكة الواسعة\nيجب إدخال IP الطابعة يدوياً';
//         break;
//     }

//     if (message.isNotEmpty) {
//       Get.snackbar(
//         'نوع الاتصال',
//         message,
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.blue.withOpacity(0.8),
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//     }
//   }

//   Future<void> autoDetectPrinter() async {
//     if (!await _requestPermissions()) {
//       return;
//     }

//     // التحقق من حالة الشبكة أولاً
//     if (connectionType == 'LAN') {
//       await _initializeNetworkInfo();
//       if (currentNetworkIP == null || currentNetworkIP!.isEmpty) {
//         EasyLoading.showError('غير متصل بالشبكة المحلية. تحقق من اتصال WiFi');
//         return;
//       }
//     }

//     isLoading = true;
//     isScanning = true;
//     discoveredDevices.clear();
//     update();

//     EasyLoading.show(status: 'بدء البحث عن الطابعات...');

//     Timer? timeoutTimer = Timer(const Duration(minutes: 2), () {
//       if (isScanning) {
//         _stopScanning();
//         EasyLoading.showInfo('انتهت مهلة البحث. جرب مرة أخرى.');
//       }
//     });

//     try {
//       switch (connectionType) {
//         case 'LAN':
//           await _scanLocalNetwork();
//           break;
//         case 'WAN':
//           await _handleWANConnection();
//           break;
//       }
//     } catch (e) {
//       connectionStatus = 'خطأ في البحث: ${e.toString()}';
//       isConnected = false;
//       EasyLoading.showError('حدث خطأ أثناء البحث');
//       print('Auto detect error: $e');
//     } finally {
//       timeoutTimer.cancel();
//       _stopScanning();
//     }
//   }

//   void _stopScanning() {
//     isLoading = false;
//     isScanning = false;
//     EasyLoading.dismiss();
//     update();
//   }

//   Future<void> _scanLocalNetwork() async {
//     try {
//       EasyLoading.show(status: 'جاري البحث في الشبكة المحلية...');

//       String subnet = customSubnetController.text.isNotEmpty
//           ? customSubnetController.text.trim()
//           : _getSubnet(currentNetworkIP!);

//       // التحقق من صحة الشبكة الفرعية
//       if (!_isValidSubnet(subnet)) {
//         throw Exception('الشبكة الفرعية غير صحيحة: $subnet');
//       }

//       List<NetworkDevice> foundDevices = [];

//       // البحث المتقدم مع معالجة الأخطاء
//       try {
//         EasyLoading.show(status: 'البحث المتقدم...');
//         List<NetworkDevice> advancedDevices =
//             await NetworkService.discoverPrintersAdvanced().timeout(const Duration(seconds: 30));
//         if (advancedDevices.isNotEmpty) {
//           foundDevices.addAll(advancedDevices);
//         }
//       } catch (e) {
//         print('Advanced search failed: $e');
//       }

//       // البحث التقليدي مع تحسينات
//       List<int> printerPorts = [9100, 631, 515];

//       for (int port in printerPorts) {
//         if (!isScanning) break; // إيقاف البحث إذا تم الإلغاء

//         try {
//           EasyLoading.show(status: 'فحص المنفذ $port...');
//           List<NetworkDevice> portDevices =
//               await _scanPortWithEnhancement(subnet, port).timeout(const Duration(seconds: 20));
//           foundDevices.addAll(portDevices);
//         } catch (e) {
//           print('Port $port scan failed: $e');
//           continue;
//         }
//       }

//       // فحص IPs محددة شائعة للطابعات
//       await _scanCommonPrinterIPs(subnet, foundDevices);

//       discoveredDevices = foundDevices;
//       _processDiscoveredDevices();
//     } catch (e) {
//       print('Error in enhanced scan: $e');
//       // العودة للطريقة التقليدية عند الفشل
//       String subnet = _getSubnet(currentNetworkIP ?? '192.168.1.1');
//       await _fallbackScan(subnet);
//     }
//   }

//   Future<void> _scanCommonPrinterIPs(String subnet, List<NetworkDevice> foundDevices) async {
//     List<String> commonPrinterIPs = [
//       '$subnet.100',
//       '$subnet.101',
//       '$subnet.200',
//       '$subnet.201',
//       '$subnet.10',
//       '$subnet.20',
//       '$subnet.30',
//       '$subnet.50'
//     ];

//     EasyLoading.show(status: 'فحص عناوين IP الشائعة...');

//     for (String ip in commonPrinterIPs) {
//       if (!isScanning) break;

//       try {
//         if (await _testSpecificIP(ip)) {
//           NetworkDevice device = NetworkDevice(
//             ip: ip,
//             name: 'Printer_${ip.split('.').last}',
//             macAddress: _generateFakeMac(),
//             port: 9100,
//             isOnline: true,
//           );
//           foundDevices.add(device);
//         }
//       } catch (e) {
//         print('Failed to test IP $ip: $e');
//         continue;
//       }
//     }
//   }

//   bool _isValidSubnet(String subnet) {
//     RegExp subnetRegex = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}$');
//     if (!subnetRegex.hasMatch(subnet)) return false;

//     List<String> parts = subnet.split('.');
//     for (String part in parts) {
//       int? num = int.tryParse(part);
//       if (num == null || num < 0 || num > 255) return false;
//     }
//     return true;
//   }

//   // فحص محسن للمنفذ
//   Future<List<NetworkDevice>> _scanPortWithEnhancement(String subnet, int port) async {
//     List<NetworkDevice> devices = [];

//     try {
//       final stream = NetworkAnalyzer.discover2(subnet, port, timeout: const Duration(seconds: 4));

//       await for (NetworkAddress addr in stream) {
//         if (addr.exists) {
//           // تأكيد إضافي أن الجهاز يستجيب
//           bool isResponding = await _testSpecificIP(addr.ip);

//           if (isResponding) {
//             String deviceName = await _identifyPrinterDevice(addr.ip, port);
//             String macAddress = await _getMacAddress(addr.ip) ?? _generateFakeMac();

//             devices.add(NetworkDevice(
//               ip: addr.ip,
//               name: deviceName,
//               macAddress: macAddress,
//               port: port,
//               isOnline: true,
//             ));
//           }
//         }
//       }
//     } catch (e) {
//       print('Error in enhanced port scan: $e');
//     }

//     return devices;
//   }

//   Future<bool> _testSpecificIP(String ip) async {
//     try {
//       // التحقق من صحة IP أولاً
//       if (!_isValidIP(ip)) return false;

//       List<int> testPorts = [9100, 631, 515, 80];

//       for (int port in testPorts) {
//         try {
//           Socket socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 2));
//           await socket.close();
//           return true;
//         } catch (e) {
//           continue;
//         }
//       }

//       // إذا فشل Socket، جرب ping
//       return await _pingDevice(ip);
//     } catch (e) {
//       print('Error testing IP $ip: $e');
//       return false;
//     }
//   }

//   bool _isValidIP(String ip) {
//     RegExp ipRegex = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$');
//     if (!ipRegex.hasMatch(ip)) return false;

//     List<String> parts = ip.split('.');
//     for (String part in parts) {
//       int? num = int.tryParse(part);
//       if (num == null || num < 0 || num > 255) return false;
//     }
//     return true;
//   }

//   // البحث الاحتياطي
//   Future<void> _fallbackScan(String subnet) async {
//     EasyLoading.show(status: 'البحث الاحتياطي...');

//     List<NetworkDevice> fallbackDevices = [];

//     // فحص مجموعة IPs محددة يدوياً
//     for (int i = 1; i <= 254; i++) {
//       String testIP = '$subnet.$i';

//       if (i % 50 == 0) {
//         EasyLoading.show(status: 'فحص: $testIP');
//       }

//       bool responds = await _testSpecificIP(testIP);

//       if (responds) {
//         fallbackDevices.add(NetworkDevice(
//           ip: testIP,
//           name: 'Device_$i',
//           macAddress: _generateFakeMac(),
//           port: 9100,
//           isOnline: true,
//         ));

//         // إيقاف البحث بعد العثور على 3 أجهزة
//         if (fallbackDevices.length >= 3) break;
//       }
//     }

//     discoveredDevices = fallbackDevices;
//     _processDiscoveredDevices();
//   }

//   // Handle WAN connection
//   Future<void> _handleWANConnection() async {
//     EasyLoading.show(status: 'إعداد الاتصال عبر الإنترنت...');

//     // For WAN, we need manual IP input
//     if (ipAddressController.text.isEmpty) {
//       EasyLoading.dismiss();

//       // Show dialog to input IP address
//       await _showIPInputDialog();

//       if (ipAddressController.text.isEmpty) {
//         connectionStatus = 'يجب إدخال IP للطابعة في اتصال WAN';
//         EasyLoading.showError(connectionStatus);
//         return;
//       }
//     }

//     EasyLoading.show(status: 'اختبار الاتصال مع: ${ipAddressController.text}');

//     // Test connection to the specified IP
//     bool isReachable = await _testWANConnection(ipAddressController.text);

//     if (isReachable) {
//       // Create a device entry for the WAN printer

//       // استبدال الكود في دالة _handleWANConnection حوالي السطر 250:
//       NetworkDevice wanDevice = NetworkDevice(
//         ip: ipAddressController.text,
//         name: deviceNameController.text.isNotEmpty
//             ? deviceNameController.text
//             : 'WAN_Printer_${ipAddressController.text.split('.').last}',
//         macAddress:
//             macAddressController.text.isNotEmpty ? macAddressController.text : _generateFakeMac(),
//         port: 9100,
//         isOnline: true,
//       );

//       discoveredDevices.add(wanDevice);

//       // Auto-fill if empty
//       if (deviceNameController.text.isEmpty) {
//         deviceNameController.text = wanDevice.name;
//       }
//       if (macAddressController.text.isEmpty) {
//         macAddressController.text = wanDevice.macAddress;
//       }

//       connectionStatus = 'تم العثور على طابعة WAN';
//       isConnected = true;
//       EasyLoading.showSuccess('تم الاتصال بالطابعة عبر الإنترنت!');
//     } else {
//       connectionStatus = 'فشل الاتصال بالطابعة عبر WAN';
//       isConnected = false;
//       EasyLoading.showError('فشل الاتصال. تحقق من IP والاتصال بالإنترنت');
//     }
//   }

//   // Show IP input dialog for WAN connection
//   Future<void> _showIPInputDialog() async {
//     final TextEditingController tempController = TextEditingController();
//     tempController.text = ipAddressController.text;

//     await Get.dialog(
//       AlertDialog(
//         title: const Text('إدخال IP الطابعة'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('يرجى إدخال عنوان IP للطابعة للاتصال عبر WAN'),
//             const SizedBox(height: 16),
//             TextField(
//               controller: tempController,
//               decoration: const InputDecoration(
//                 labelText: 'عنوان IP',
//                 hintText: '192.168.1.100',
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               ipAddressController.text = tempController.text;
//               Get.back();
//             },
//             child: const Text('تأكيد'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Test WAN connection
//   Future<bool> _testWANConnection(String ip) async {
//     try {
//       // Try multiple ports commonly used by printers
//       List<int> portsToTest = [9100, 631, 515, 80, 443];

//       for (int port in portsToTest) {
//         try {
//           Socket socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 5));
//           socket.close();
//           return true; // If any port responds, consider it reachable
//         } catch (e) {
//           continue; // Try next port
//         }
//       }

//       // If socket connection fails, try ping
//       return await _pingDevice(ip);
//     } catch (e) {
//       print('WAN connection test failed: $e');
//       return false;
//     }
//   }

//   // Process discovered devices
//   void _processDiscoveredDevices() {
//     // Remove duplicates based on IP
//     Map<String, NetworkDevice> uniqueDevices = {};
//     for (var device in discoveredDevices) {
//       uniqueDevices[device.ip] = device;
//     }
//     discoveredDevices = uniqueDevices.values.toList();

//     if (discoveredDevices.isNotEmpty) {
//       // Auto-select first printer found
//       NetworkDevice firstPrinter = discoveredDevices.first;
//       macAddressController.text = firstPrinter.macAddress;
//       deviceNameController.text = firstPrinter.name;
//       ipAddressController.text = firstPrinter.ip;

//       connectionStatus = 'تم العثور على ${discoveredDevices.length} طابعة';
//       isConnected = true;

//       EasyLoading.showSuccess('تم العثور على ${discoveredDevices.length} طابعة!');
//     } else {
//       connectionStatus = connectionType == 'LAN'
//           ? 'لم يتم العثور على أي طابعة في الشبكة المحلية'
//           : 'لم يتم العثور على طابعة في الشبكة الواسعة';
//       isConnected = false;
//       EasyLoading.showInfo('لم يتم العثور على طابعات. تأكد من تشغيل الطابعة واتصالها بالشبكة');
//     }
//   }

//   // Request necessary permissions
//   Future<bool> _requestPermissions() async {
//     try {
//       Map<Permission, PermissionStatus> permissions = await [
//         Permission.location,
//         Permission.nearbyWifiDevices,
//       ].request();

//       bool allGranted = permissions.values.every(
//         (status) => status == PermissionStatus.granted,
//       );

//       if (!allGranted) {
//         EasyLoading.showError('يرجى منح الأذونات المطلوبة للوصول للشبكة');
//         return false;
//       }

//       return true;
//     } catch (e) {
//       print('Error requesting permissions: $e');
//       EasyLoading.showError('خطأ في طلب الأذونات');
//       return false;
//     }
//   }

//   // MAC Address Change Handler
//   void onMacAddressChanged(String value) {
//     String formatted = formatMacAddress(value);
//     if (formatted != value) {
//       macAddressController.value = TextEditingValue(
//         text: formatted,
//         selection: TextSelection.collapsed(offset: formatted.length),
//       );
//     }

//     if (formatted.length == 17) {
//       autoFillDeviceName(formatted);
//     }
//   }

//   // Format MAC Address (XX:XX:XX:XX:XX:XX)
//   String formatMacAddress(String input) {
//     String cleaned = input.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');

//     if (cleaned.length > 12) {
//       cleaned = cleaned.substring(0, 12);
//     }

//     String formatted = '';
//     for (int i = 0; i < cleaned.length; i += 2) {
//       if (i > 0) formatted += ':';
//       formatted += cleaned.substring(i, i + 2 > cleaned.length ? cleaned.length : i + 2);
//     }

//     return formatted.toUpperCase();
//   }

//   // Auto-fill device name based on MAC address
//   void autoFillDeviceName(String macAddress) {
//     String prefix = connectionType == 'LAN' ? 'LAN_Printer' : 'WAN_Printer';
//     String deviceName = '${prefix}_${macAddress.replaceAll(':', '').substring(6)}';
//     deviceNameController.text = deviceName;
//     update();
//   }

//   // Extract subnet from IP address
//   String _getSubnet(String ip) {
//     List<String> parts = ip.split('.');
//     if (parts.length == 4) {
//       return '${parts[0]}.${parts[1]}.${parts[2]}';
//     }
//     return '192.168.1'; // Default fallback
//   }

//   // استبدال دالة _scanPortForPrinters:
//   // استبدال دالة _scanPortForPrinters بالكامل
//   Future<List<NetworkDevice>> _scanPortForPrinters(String subnet, int port) async {
//     List<NetworkDevice> devices = [];

//     try {
//       final stream = NetworkAnalyzer.discover2(subnet, port, timeout: const Duration(seconds: 3));

//       await for (NetworkAddress addr in stream) {
//         if (addr.exists) {
//           String deviceName = await _identifyPrinterDevice(addr.ip, port);
//           String macAddress = await _getMacAddress(addr.ip) ?? _generateFakeMac();

//           devices.add(NetworkDevice(
//             ip: addr.ip,
//             name: deviceName,
//             macAddress: macAddress,
//             port: port,
//             isOnline: true,
//           ));
//         }
//       }
//     } catch (e) {
//       print('Error scanning port $port: $e');
//     }

//     return devices;
//   }

//   // Identify if device is a printer
//   Future<String> _identifyPrinterDevice(String ip, int port) async {
//     try {
//       Socket socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 2));
//       socket.close();

//       String deviceType = _getDeviceTypeByPort(port);
//       String prefix = connectionType == 'LAN' ? 'LAN' : 'WAN';
//       return '${prefix}_${deviceType}_${ip.split('.').last}';
//     } catch (e) {
//       return '${connectionType}_Unknown_Printer_${ip.split('.').last}';
//     }
//   }

//   // Get device type by port
//   String _getDeviceTypeByPort(int port) {
//     switch (port) {
//       case 9100:
//         return 'RAW_Printer';
//       case 631:
//         return 'IPP_Printer';
//       case 515:
//         return 'LPD_Printer';
//       case 721:
//         return 'Printer';
//       default:
//         return 'Network_Printer';
//     }
//   }

//   // Get MAC address (limited in Flutter mobile)
//   Future<String?> _getMacAddress(String ip) async {
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

//   // Generate a fake MAC address for demonstration
//   String _generateFakeMac() {
//     final random = DateTime.now().millisecondsSinceEpoch;
//     return '00:1A:2B:${(random % 256).toRadixString(16).padLeft(2, '0').toUpperCase()}:'
//         '${((random ~/ 256) % 256).toRadixString(16).padLeft(2, '0').toUpperCase()}:'
//         '${((random ~/ 65536) % 256).toRadixString(16).padLeft(2, '0').toUpperCase()}';
//   }

//   // Test connection to printer with real network ping
//   Future<void> testConnection() async {
//     if (macAddressController.text.isEmpty) {
//       EasyLoading.showError('يرجى إدخال عنوان MAC للطابعة');
//       return;
//     }

//     String testType = connectionType == 'LAN' ? 'الشبكة المحلية' : 'الشبكة الواسعة';
//     EasyLoading.show(status: 'جاري اختبار الاتصال عبر $testType...');

//     try {
//       bool testResult = false;

//       if (ipAddressController.text.isNotEmpty) {
//         if (connectionType == 'WAN') {
//           testResult = await _testWANConnection(ipAddressController.text);
//         } else {
//           testResult = await _pingDevice(ipAddressController.text);
//         }
//       } else {
//         NetworkDevice? device = discoveredDevices.firstWhereOrNull(
//             (d) => d.macAddress.toLowerCase() == macAddressController.text.toLowerCase());

//         if (device != null) {
//           testResult = connectionType == 'WAN'
//               ? await _testWANConnection(device.ip)
//               : await _pingDevice(device.ip);
//           ipAddressController.text = device.ip;
//         }
//       }

//       if (testResult) {
//         connectionStatus = 'تم الاتصال بالطابعة بنجاح عبر $testType';
//         isConnected = true;
//         EasyLoading.showSuccess('تم الاتصال بنجاح عبر $testType!');
//       } else {
//         connectionStatus = 'فشل في الاتصال بالطابعة عبر $testType';
//         isConnected = false;
//         EasyLoading.showError('فشل في الاتصال - تأكد من إعدادات $testType');
//       }
//     } catch (e) {
//       connectionStatus = 'خطأ في الاختبار: ${e.toString()}';
//       isConnected = false;
//       EasyLoading.showError('حدث خطأ أثناء الاختبار');
//     }

//     update();
//   }

//   Future<bool> _pingDevice(String ip) async {
//     try {
//       if (!_isValidIP(ip)) return false;

//       final result =
//           await Process.run('ping', ['-c', '1', '-W', '3', ip]).timeout(const Duration(seconds: 5));

//       return result.exitCode == 0;
//     } catch (e) {
//       print('Error pinging $ip: $e');

//       // Fallback: try socket connection
//       try {
//         Socket socket = await Socket.connect(ip, 9100, timeout: const Duration(seconds: 2));
//         await socket.close();
//         return true;
//       } catch (e) {
//         return false;
//       }
//     }
//   }

//   // Save configuration - محسنة
//   Future<void> saveConfiguration() async {
//     if (macAddressController.text.isEmpty || deviceNameController.text.isEmpty) {
//       EasyLoading.showError('يرجى ملء جميع الحقول المطلوبة');
//       return;
//     }

//     if (!_isValidMacAddress(macAddressController.text)) {
//       EasyLoading.showError('عنوان MAC غير صحيح');
//       return;
//     }

//     // Additional validation for WAN
//     if (connectionType == 'WAN' && ipAddressController.text.isEmpty) {
//       EasyLoading.showError('يرجى إدخال IP الطابعة لاتصال WAN');
//       return;
//     }

//     EasyLoading.show(status: 'جاري حفظ إعدادات $connectionType...');

//     try {
//       // حفظ جميع البيانات مع التأكد من الثبات
//       await Future.wait([
//         Preferences.setString('connection_type', connectionType),
//         Preferences.setString('printer_mac_address', macAddressController.text),
//         Preferences.setString('device_name', deviceNameController.text),
//         Preferences.setString('printer_ip', ipAddressController.text),
//         Preferences.setString('custom_subnet', customSubnetController.text),
//         Preferences.setString('current_network_name', currentNetworkName ?? ''),
//         Preferences.setString('current_network_ip', currentNetworkIP ?? ''),
//         Preferences.setString('current_gateway', currentGateway ?? ''),
//         Preferences.setBoolean('configuration_saved', true),
//         Preferences.setString('configuration_date', DateTime.now().toIso8601String()),
//       ]);

//       // التحقق من نجاح الحفظ
//       bool saveVerification = await _verifySavedConfiguration();

//       if (saveVerification) {
//         EasyLoading.showSuccess('تم حفظ إعدادات $connectionType بنجاح!\nالبيانات محفوظة بشكل دائم');

//         await Future.delayed(const Duration(milliseconds: 1500));
//         Get.offAllNamed(AppRoutes.login);
//       } else {
//         EasyLoading.showError('فشل في التحقق من حفظ البيانات، حاول مرة أخرى');
//       }
//     } catch (e) {
//       EasyLoading.showError('حدث خطأ أثناء الحفظ: ${e.toString()}');
//     }
//   }

//   // التحقق من نجاح حفظ الإعدادات
//   Future<bool> _verifySavedConfiguration() async {
//     try {
//       String savedConnectionType = Preferences.getString('connection_type');
//       String savedMac = Preferences.getString('printer_mac_address');
//       String savedDeviceName = Preferences.getString('device_name');
//       bool isConfigSaved = Preferences.getBoolean('configuration_saved');

//       return savedConnectionType == connectionType &&
//           savedMac == macAddressController.text &&
//           savedDeviceName == deviceNameController.text &&
//           isConfigSaved;
//     } catch (e) {
//       return false;
//     }
//   }

//   void resetScanningState() {
//     isScanning = false;
//     isLoading = false;
//     discoveredDevices.clear();
//     connectionStatus = connectionType == 'LAN'
//         ? 'سيتم البحث في الشبكة المحلية'
//         : 'سيتم البحث عبر الإنترنت (يتطلب IP محدد)';
//     update();
//   }

//   // Load saved configuration
//   void loadSavedConfiguration() {
//     connectionType = Preferences.getString('connection_type');
//     if (connectionType.isEmpty) connectionType = 'LAN';

//     macAddressController.text = Preferences.getString('printer_mac_address');
//     deviceNameController.text = Preferences.getString('device_name');
//     ipAddressController.text = Preferences.getString('printer_ip');
//     customSubnetController.text = Preferences.getString('custom_subnet');

//     // Update UI based on loaded connection type
//     _updateUIForConnectionType();

//     update();
//   }

//   // Validate MAC address format
//   bool _isValidMacAddress(String mac) {
//     RegExp macRegex = RegExp(
//         r'^[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}:[0-9A-Fa-f]{2}$');
//     return macRegex.hasMatch(mac);
//   }

//   // Select discovered device
//   void selectDiscoveredDevice(NetworkDevice device) {
//     macAddressController.text = device.macAddress;
//     deviceNameController.text = device.name;
//     ipAddressController.text = device.ip;
//     update();
//   }

//   // Clear configuration
//   void clearConfiguration() {
//     macAddressController.clear();
//     deviceNameController.clear();
//     ipAddressController.clear();
//     customSubnetController.clear();
//     connectionStatus = '';
//     isConnected = false;
//     discoveredDevices.clear();
//     update();
//   }

//   // في NetworkInfoCard - تحديث دالة getNetworkStatusInfo في الكونترولر
//   String getNetworkStatusInfo() {
//     if (connectionType == 'LAN') {
//       return 'اسم الشبكة: ${currentNetworkName ?? "غير معروف"}\n'
//           'IP الحالي: ${currentNetworkIP ?? "غير متصل"}\n'
//           'البوابة: ${currentGateway ?? "غير محددة"}\n'
//           'الشبكة الفرعية: ${currentSubnet ?? "غير محددة"}';
//     } else {
//       return 'الشبكة الواسعة (WAN)\n'
//           'يتطلب IP مباشر للطابعة\n'
//           'IP الطابعة: ${ipAddressController.text.isEmpty ? "غير محدد" : ipAddressController.text}';
//     }
//   }
// }
