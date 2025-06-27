import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:auth_app/models/printer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterService {
  static const String _savedPrintersKey = 'saved_printers';
  static const String _selectedPrinterKey = 'selected_printer';

  // البحث عن الطابعات في الشبكة
  Future<List<PrinterModel>> scanForPrinters(String networkRange) async {
    List<PrinterModel> foundPrinters = [];

    try {
      // استخراج النطاق الأساسي للشبكة (مثل 192.168.1.x)
      String baseRange = networkRange.substring(0, networkRange.lastIndexOf('.') + 1);

      // أولاً: تحديث ARP table بإرسال ping
      await _refreshArpTable(baseRange);

      List<Future<PrinterModel?>> futures = [];

      // فحص العناوين من 1 إلى 254
      for (int i = 1; i <= 254; i++) {
        String ip = '$baseRange$i';
        futures.add(_checkDevice(ip));
      }

      // انتظار جميع النتائج
      List<PrinterModel?> results = await Future.wait(futures);

      // تصفية النتائج الفارغة
      foundPrinters = results.where((printer) => printer != null).cast<PrinterModel>().toList();
    } catch (e) {
      print('خطأ في البحث عن الطابعات: $e');
    }

    return foundPrinters;
  }

  // تحديث ARP table عبر ping
  Future<void> _refreshArpTable(String baseRange) async {
    try {
      List<Future> pingFutures = [];

      for (int i = 1; i <= 254; i++) {
        String ip = '$baseRange$i';
        pingFutures.add(_pingHost(ip));
      }

      // انتظار انتهاء جميع عمليات ping (مع timeout)
      await Future.wait(pingFutures).timeout(const Duration(seconds: 10));
    } catch (e) {
      print('خطأ في تحديث ARP table: $e');
    }
  }

  // إرسال ping لـ IP معين
  Future<void> _pingHost(String ip) async {
    try {
      if (Platform.isWindows) {
        await Process.run('ping', ['-n', '1', '-w', '100', ip]);
      } else {
        await Process.run('ping', ['-c', '1', '-W', '100', ip]);
      }
    } catch (e) {
      // تجاهل أخطاء ping
    }
  }

  // فحص جهاز معين
  Future<PrinterModel?> _checkDevice(String ip) async {
    try {
      // فحص المنافذ الشائعة للطابعات
      List<int> commonPorts = [9100, 515, 631, 80, 443];

      for (int port in commonPorts) {
        try {
          Socket socket =
              await Socket.connect(ip, port, timeout: const Duration(milliseconds: 1000));

          // محاولة الحصول على معلومات الجهاز
          String deviceName = await _getDeviceName(ip, port);
          String macAddress = await _getMacAddress(ip);

          await socket.close();

          return PrinterModel(
            name: deviceName.isNotEmpty ? deviceName : 'جهاز على $ip',
            ipAddress: ip,
            macAddress: macAddress,
            port: port,
            isConnected: false,
            deviceType: _determineDeviceType(port, deviceName),
          );
        } catch (e) {
          // تجاهل الأخطاء والمتابعة للمنفذ التالي
          continue;
        }
      }
    } catch (e) {
      // تجاهل الأجهزة غير المتاحة
    }

    return null;
  }

  // محاولة الحصول على اسم الجهاز
  Future<String> _getDeviceName(String ip, int port) async {
    try {
      // طريقة 1: من خلال HTTP
      if (port == 80 || port == 443 || port == 631) {
        String deviceName = await _getDeviceNameFromHttp(ip, port);
        if (deviceName.isNotEmpty) return deviceName;
      }

      // طريقة 2: من خلال SNMP (اختيارية)
      String snmpName = await _getDeviceNameFromSnmp(ip);
      if (snmpName.isNotEmpty) return snmpName;

      // طريقة 3: من خلال NetBIOS
      String netbiosName = await _getDeviceNameFromNetBios(ip);
      if (netbiosName.isNotEmpty) return netbiosName;
    } catch (e) {
      print('خطأ في الحصول على اسم الجهاز: $e');
    }

    return '';
  }

  // الحصول على اسم الجهاز من HTTP
  Future<String> _getDeviceNameFromHttp(String ip, int port) async {
    try {
      HttpClient client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 3);

      String scheme = port == 443 ? 'https' : 'http';
      HttpClientRequest request = await client.getUrl(Uri.parse('$scheme://$ip:$port/'));
      request.headers.set('User-Agent', 'PrinterScanner/1.0');

      HttpClientResponse response = await request.close();

      if (response.statusCode == 200) {
        String content = await response.transform(utf8.decoder).join();

        // البحث في عدة مواقع محتملة
        List<RegExp> patterns = [
          RegExp(r'<title>(.*?)</title>', caseSensitive: false),
          RegExp(r'<h1[^>]*>(.*?)</h1>', caseSensitive: false),
          RegExp(r'printer[^>]*name[^>]*[":]\s*([^<>"]+)', caseSensitive: false),
          RegExp(r'device[^>]*name[^>]*[":]\s*([^<>"]+)', caseSensitive: false),
          RegExp(r'model[^>]*[":]\s*([^<>"]+)', caseSensitive: false),
        ];

        for (RegExp pattern in patterns) {
          Match? match = pattern.firstMatch(content);
          if (match != null) {
            String name = match.group(1)?.trim() ?? '';
            if (name.isNotEmpty && !name.toLowerCase().contains('error')) {
              return _cleanDeviceName(name);
            }
          }
        }
      }
      client.close();
    } catch (e) {
      print('خطأ في HTTP: $e');
    }

    return '';
  }

  // الحصول على اسم الجهاز من SNMP (مبسط)
  Future<String> _getDeviceNameFromSnmp(String ip) async {
    try {
      // يمكن استخدام مكتبة SNMP هنا
      // هذا مثال مبسط
      return '';
    } catch (e) {
      return '';
    }
  }

  // الحصول على اسم الجهاز من NetBIOS
  Future<String> _getDeviceNameFromNetBios(String ip) async {
    try {
      if (Platform.isWindows) {
        ProcessResult result = await Process.run('nbtstat', ['-A', ip]);
        if (result.exitCode == 0) {
          String output = result.stdout.toString();
          RegExp nameRegex = RegExp(r'^\s*([A-Z0-9\-_]+)\s+<00>\s+UNIQUE', multiLine: true);
          Match? match = nameRegex.firstMatch(output);
          if (match != null) {
            return match.group(1)?.trim() ?? '';
          }
        }
      }
    } catch (e) {
      print('خطأ في NetBIOS: $e');
    }

    return '';
  }

  // تنظيف اسم الجهاز
  String _cleanDeviceName(String name) {
    return name
        .replaceAll(RegExp(r'<[^>]*>'), '') // إزالة HTML tags
        .replaceAll(RegExp(r'[^\w\s\-_]'), '') // إزالة رموز غير مرغوبة
        .trim();
  }

  // محاولة الحصول على MAC Address (محسنة)
  Future<String> _getMacAddress(String ip) async {
    try {
      // طريقة 1: استخدام ARP table
      String macFromArp = await _getMacFromArp(ip);
      if (macFromArp.isNotEmpty) return macFromArp;

      // طريقة 2: استخدام ping ثم ARP
      await _pingHost(ip);
      await Future.delayed(const Duration(milliseconds: 100));
      macFromArp = await _getMacFromArp(ip);
      if (macFromArp.isNotEmpty) return macFromArp;

      // طريقة 3: من خلال network interface scanning
      String macFromInterface = await _getMacFromNetworkInterface(ip);
      if (macFromInterface.isNotEmpty) return macFromInterface;
    } catch (e) {
      print('خطأ في الحصول على MAC Address: $e');
    }

    return 'غير متوفر';
  }

  // الحصول على MAC من ARP table
  Future<String> _getMacFromArp(String ip) async {
    try {
      ProcessResult result;

      if (Platform.isWindows) {
        result = await Process.run('arp', ['-a', ip]);
      } else if (Platform.isMacOS) {
        result = await Process.run('arp', ['-n', ip]);
      } else {
        // Linux
        result = await Process.run('arp', ['-n', ip]);
      }

      if (result.exitCode == 0) {
        String output = result.stdout.toString();

        // أنماط مختلفة لـ MAC Address
        List<RegExp> macPatterns = [
          RegExp(r'([0-9a-f]{2}[:-]){5}[0-9a-f]{2}', caseSensitive: false),
          RegExp(r'([0-9a-f]{2}\.){2}[0-9a-f]{4}', caseSensitive: false),
          RegExp(r'([0-9a-f]{4}\.){2}[0-9a-f]{4}', caseSensitive: false),
        ];

        for (RegExp pattern in macPatterns) {
          Match? match = pattern.firstMatch(output);
          if (match != null) {
            String mac = match.group(0)?.toUpperCase() ?? '';
            return _formatMacAddress(mac);
          }
        }
      }
    } catch (e) {
      print('خطأ في ARP: $e');
    }

    return '';
  }

  // الحصول على MAC من network interface
  Future<String> _getMacFromNetworkInterface(String ip) async {
    try {
      // هذا يتطلب صلاحيات خاصة على بعض الأنظمة
      if (Platform.isLinux) {
        ProcessResult result = await Process.run('ip', ['neigh', 'show', ip]);
        if (result.exitCode == 0) {
          String output = result.stdout.toString();
          RegExp macRegex = RegExp(r'([0-9a-f]{2}:){5}[0-9a-f]{2}', caseSensitive: false);
          Match? match = macRegex.firstMatch(output);
          if (match != null) {
            return _formatMacAddress(match.group(0)?.toUpperCase() ?? '');
          }
        }
      }
    } catch (e) {
      print('خطأ في network interface: $e');
    }

    return '';
  }

  // تنسيق MAC Address
  String _formatMacAddress(String mac) {
    if (mac.isEmpty) return '';

    // توحيد التنسيق إلى XX:XX:XX:XX:XX:XX
    String cleanMac = mac.replaceAll(RegExp(r'[^0-9a-f]', caseSensitive: false), '');

    if (cleanMac.length == 12) {
      return cleanMac
          .toUpperCase()
          .replaceAllMapped(RegExp(r'(.{2})'), (match) => '${match.group(1)}:')
          .replaceAll(RegExp(r':$'), '');
    }

    return mac.toUpperCase();
  }

  // تحديد نوع الجهاز بناءً على المنفذ والاسم
  String _determineDeviceType(int port, String deviceName) {
    String lowerName = deviceName.toLowerCase();

    // التحقق من أسماء الشركات المشهورة
    Map<String, String> brandPatterns = {
      'hp': 'طابعة HP',
      'canon': 'طابعة Canon',
      'epson': 'طابعة Epson',
      'brother': 'طابعة Brother',
      'samsung': 'طابعة Samsung',
      'lexmark': 'طابعة Lexmark',
      'xerox': 'طابعة Xerox',
      'ricoh': 'طابعة Ricoh',
      'kyocera': 'طابعة Kyocera',
      'konica': 'طابعة Konica',
    };

    for (String brand in brandPatterns.keys) {
      if (lowerName.contains(brand)) {
        return brandPatterns[brand]!;
      }
    }

    // التحقق من كلمات دلالية
    if (lowerName.contains('printer') ||
        lowerName.contains('print') ||
        lowerName.contains('laserjet') ||
        lowerName.contains('inkjet')) {
      return 'طابعة';
    }

    // تحديد النوع بناءً على المنفذ
    switch (port) {
      case 9100:
        return 'طابعة (RAW)';
      case 515:
        return 'طابعة (LPD)';
      case 631:
        return 'طابعة (IPP)';
      case 80:
      case 443:
        return 'جهاز شبكة (HTTP)';
      default:
        return 'جهاز شبكة';
    }
  }

  // اختبار الاتصال بالطابعة
  Future<bool> testConnection(PrinterModel printer) async {
    try {
      Socket socket = await Socket.connect(printer.ipAddress, printer.port,
          timeout: const Duration(seconds: 5));
      await socket.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  // باقي الدوال كما هي...
  Future<void> savePrinters(List<PrinterModel> printers) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> printersJson = printers.map((p) => jsonEncode(p.toJson())).toList();
      await prefs.setStringList(_savedPrintersKey, printersJson);
    } catch (e) {
      print('خطأ في حفظ الطابعات: $e');
    }
  }

  Future<List<PrinterModel>> loadSavedPrinters() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? printersJson = prefs.getStringList(_savedPrintersKey);

      if (printersJson != null) {
        return printersJson.map((json) => PrinterModel.fromJson(jsonDecode(json))).toList();
      }
    } catch (e) {
      print('خطأ في تحميل الطابعات: $e');
    }

    return [];
  }

  Future<void> saveSelectedPrinter(PrinterModel printer) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedPrinterKey, jsonEncode(printer.toJson()));
    } catch (e) {
      print('خطأ في حفظ الطابعة المختارة: $e');
    }
  }

  Future<PrinterModel?> loadSelectedPrinter() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? printerJson = prefs.getString(_selectedPrinterKey);

      if (printerJson != null) {
        return PrinterModel.fromJson(jsonDecode(printerJson));
      }
    } catch (e) {
      print('خطأ في تحميل الطابعة المختارة: $e');
    }

    return null;
  }

  Future<void> clearSelectedPrinter() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_selectedPrinterKey);
    } catch (e) {
      print('خطأ في إزالة الطابعة المختارة: $e');
    }
  }

  Future<void> clearAllData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedPrintersKey);
      await prefs.remove(_selectedPrinterKey);
    } catch (e) {
      print('خطأ في مسح البيانات: $e');
    }
  }
}
