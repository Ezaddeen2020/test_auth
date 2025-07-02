// import 'dart:io';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:network_info_plus/network_info_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:auth_app/pages/configration/models/network_info_model.dart';

// class NetworkService {
//   final NetworkInfo _networkInfo = NetworkInfo();
//   final Connectivity _connectivity = Connectivity();

//   /// التحقق من جميع الأذونات المطلوبة
//   Future<bool> requestPermissions() async {
//     try {
//       // Android permissions
//       if (Platform.isAndroid) {
//         final permissions = [
//           Permission.location,
//           Permission.locationWhenInUse,
//           Permission.nearbyWifiDevices, // Android 13+
//         ];

//         Map<Permission, PermissionStatus> statuses = await permissions.request();

//         // التحقق من حالة الأذونات
//         bool allGranted = true;
//         for (var permission in permissions) {
//           final status = statuses[permission];
//           if (status != PermissionStatus.granted) {
//             print('Permission denied: $permission - Status: $status');
//             allGranted = false;
//           }
//         }

//         return allGranted;
//       }

//       // iOS permissions
//       else if (Platform.isIOS) {
//         final locationStatus = await Permission.location.request();
//         final locationWhenInUse = await Permission.locationWhenInUse.request();

//         return locationStatus == PermissionStatus.granted ||
//             locationWhenInUse == PermissionStatus.granted;
//       }

//       // Desktop platforms (Windows, macOS, Linux)
//       return true;
//     } catch (e) {
//       print('Error requesting permissions: $e');
//       return false;
//     }
//   }

//   /// التحقق من حالة الأذونات الحالية
//   /// التحقق من حالة الأذونات الحالية
//   Future<bool> hasRequiredPermissions() async {
//     try {
//       if (Platform.isAndroid) {
//         final locationStatus = await Permission.location.status;
//         // final nearbyWifiDevicesStatus = await Permission.nearbyWifiDevices.status;

//         return locationStatus == PermissionStatus.granted;
//         // nearbyWifiDevicesStatus == PermissionStatus.granted;
//       } else if (Platform.isIOS) {
//         final locationStatus = await Permission.location.status;
//         return locationStatus == PermissionStatus.granted;
//       }

//       return true; // Desktop platforms
//     } catch (e) {
//       print('Error checking permissions: $e');
//       return false;
//     }
//   }

//   /// الحصول على معلومات الشبكة مع التعامل مع الأذونات
//   Future<NetworkInfoModel> getNetworkInfo() async {
//     try {
//       // التحقق من الاتصال أولاً
//       final connectivityResults = await _connectivity.checkConnectivity();

//       if (connectivityResults.contains(ConnectivityResult.none)) {
//         return NetworkInfoModel.empty();
//       }

//       // محاولة الحصول على معلومات الشبكة
//       String? wifiName;
//       String? wifiBSSID;
//       String? wifiIP;
//       String? wifiGateway;
//       String? wifiSubmask;

//       // التحقق من الأذونات قبل الوصول لمعلومات WiFi
//       final hasPermissions = await hasRequiredPermissions();

//       if (hasPermissions) {
//         try {
//           wifiName = await _networkInfo.getWifiName();
//           wifiBSSID = await _networkInfo.getWifiBSSID();
//           wifiIP = await _networkInfo.getWifiIP();
//           wifiGateway = await _networkInfo.getWifiGatewayIP();
//           wifiSubmask = await _networkInfo.getWifiSubmask();
//         } catch (e) {
//           print('Error getting WiFi info: $e');
//           // في حالة فشل الحصول على معلومات WiFi، نحاول الحصول على IP فقط
//           try {
//             wifiIP = await _networkInfo.getWifiIP();
//           } catch (e2) {
//             print('Error getting WiFi IP: $e2');
//           }
//         }
//       } else {
//         print('No permissions to access WiFi information');
//       }

//       // تحديد نوع الاتصال
//       ConnectionType connectionType = ConnectionType.none;
//       if (connectivityResults.contains(ConnectivityResult.wifi)) {
//         connectionType = _isPrivateIP(wifiIP) ? ConnectionType.lan : ConnectionType.wan;
//       } else if (connectivityResults.contains(ConnectivityResult.mobile)) {
//         connectionType = ConnectionType.wan;
//       } else if (connectivityResults.contains(ConnectivityResult.ethernet)) {
//         connectionType = _isPrivateIP(wifiIP) ? ConnectionType.lan : ConnectionType.wan;
//       }

//       return NetworkInfoModel(
//         connectionType: connectionType,
//         ipAddress: wifiIP,
//         gateway: wifiGateway,
//         wifiName: _cleanWifiName(wifiName),
//         wifiBSSID: wifiBSSID,
//         subnet: wifiSubmask,
//         isConnected: connectivityResults.isNotEmpty &&
//             !connectivityResults.contains(ConnectivityResult.none),
//       );
//     } catch (e) {
//       print('Error in getNetworkInfo: $e');
//       return NetworkInfoModel.empty();
//     }
//   }

//   /// تنظيف اسم WiFi (إزالة الأقواس إن وجدت)
//   String? _cleanWifiName(String? wifiName) {
//     if (wifiName == null) return null;

//     // إزالة الأقواس المزدوجة
//     if (wifiName.startsWith('"') && wifiName.endsWith('"')) {
//       return wifiName.substring(1, wifiName.length - 1);
//     }

//     return wifiName;
//   }

//   /// التحقق من كون IP خاص (محلي)
//   bool _isPrivateIP(String? ipAddress) {
//     if (ipAddress == null) return false;

//     return ipAddress.startsWith('192.168.') ||
//         ipAddress.startsWith('10.') ||
//         ipAddress.startsWith('172.') ||
//         ipAddress.startsWith('127.') ||
//         ipAddress == 'localhost';
//   }

//   /// الاستماع لتغييرات الاتصال
//   Stream<List<ConnectivityResult>> get connectivityStream => _connectivity.onConnectivityChanged;

//   /// فتح إعدادات الأذونات
//   Future<void> openPermissionSettings() async {
//     await openAppSettings();
//   }

//   /// طلب إذن محدد
//   Future<bool> requestSpecificPermission(Permission permission) async {
//     final status = await permission.request();
//     return status == PermissionStatus.granted;
//   }

//   /// عرض رسالة توضيحية للمستخدم
//   String getPermissionExplanation() {
//     if (Platform.isAndroid) {
//       return 'يتطلب التطبيق أذونات الموقع والوصول لحالة WiFi للحصول على معلومات الشبكة المحلية. هذه الأذونات ضرورية لعرض تفاصيل الشبكة مثل اسم WiFi وعنوان IP.';
//     } else if (Platform.isIOS) {
//       return 'يتطلب التطبيق إذن الموقع للحصول على معلومات الشبكة اللاسلكية. يرجى السماح بالوصول للموقع في إعدادات التطبيق.';
//     }
//     return 'يتطلب التطبيق أذونات للوصول لمعلومات الشبكة.';
//   }
// }

import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:auth_app/pages/configration/models/network_info_model.dart';

class NetworkService {
  final NetworkInfo _networkInfo = NetworkInfo();
  final Connectivity _connectivity = Connectivity();

  /// طلب الأذونات اللازمة حسب النظام
  Future<bool> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final permissions = [
          Permission.location,
          Permission.locationWhenInUse,
          Permission.nearbyWifiDevices, // للأندرويد 13+
        ];

        Map<Permission, PermissionStatus> statuses = await permissions.request();

        bool allGranted = true;
        for (var permission in permissions) {
          final status = statuses[permission];
          if (status != PermissionStatus.granted) {
            print('Permission denied: $permission - Status: $status');
            allGranted = false;
          }
        }

        return allGranted;
      } else if (Platform.isIOS) {
        final locationStatus = await Permission.location.request();
        final locationWhenInUse = await Permission.locationWhenInUse.request();

        return locationStatus == PermissionStatus.granted ||
            locationWhenInUse == PermissionStatus.granted;
      }

      // للأنظمة المكتبية لا يحتاج إذن
      return true;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  /// التحقق من الأذونات الحالية
  Future<bool> hasRequiredPermissions() async {
    try {
      if (Platform.isAndroid) {
        final locationStatus = await Permission.location.status;
        return locationStatus == PermissionStatus.granted;
      } else if (Platform.isIOS) {
        final locationStatus = await Permission.location.status;
        return locationStatus == PermissionStatus.granted;
      }
      return true;
    } catch (e) {
      print('Error checking permissions: $e');
      return false;
    }
  }

  /// الحصول على معلومات الشبكة
  Future<NetworkInfoModel> getNetworkInfo() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();

      print('Connectivity results: $connectivityResults');

      if (connectivityResults == ConnectivityResult.none) {
        return NetworkInfoModel.empty();
      }

      String? wifiName;
      String? wifiBSSID;
      String? wifiIP;
      String? wifiGateway;
      String? wifiSubmask;

      final hasPermissions = await hasRequiredPermissions();

      if (hasPermissions) {
        try {
          wifiName = await _networkInfo.getWifiName();
          wifiBSSID = await _networkInfo.getWifiBSSID();
          wifiIP = await _networkInfo.getWifiIP();
          wifiGateway = await _networkInfo.getWifiGatewayIP();
          wifiSubmask = await _networkInfo.getWifiSubmask();
        } catch (e) {
          print('Error getting WiFi info: $e');
          try {
            wifiIP = await _networkInfo.getWifiIP();
          } catch (e2) {
            print('Error getting WiFi IP: $e2');
          }
        }
      } else {
        print('No permissions to access WiFi information');
      }

      print('WiFi Name: $wifiName');
      print('WiFi IP: $wifiIP');

      // تحديد نوع الاتصال بشكل دقيق
      ConnectionType connectionType = ConnectionType.none;

      if (connectivityResults == ConnectivityResult.mobile) {
        connectionType = ConnectionType.wan;
      } else if (connectivityResults == ConnectivityResult.wifi) {
        connectionType =
            (wifiIP != null && _isPrivateIP(wifiIP)) ? ConnectionType.lan : ConnectionType.wan;
      } else if (connectivityResults == ConnectivityResult.ethernet) {
        connectionType =
            (wifiIP != null && _isPrivateIP(wifiIP)) ? ConnectionType.lan : ConnectionType.wan;
      }

      return NetworkInfoModel(
        connectionType: connectionType,
        ipAddress: wifiIP,
        gateway: wifiGateway,
        wifiName: _cleanWifiName(wifiName),
        wifiBSSID: wifiBSSID,
        subnet: wifiSubmask,
        isConnected: connectivityResults != ConnectivityResult.none,
      );
    } catch (e) {
      print('Error in getNetworkInfo: $e');
      return NetworkInfoModel.empty();
    }
  }

  /// إزالة علامات الاقتباس من اسم WiFi إن وجدت
  String? _cleanWifiName(String? wifiName) {
    if (wifiName == null) return null;
    if (wifiName.startsWith('"') && wifiName.endsWith('"')) {
      return wifiName.substring(1, wifiName.length - 1);
    }
    return wifiName;
  }

  /// التحقق من كون IP خاص (محلي)
  bool _isPrivateIP(String ip) {
    return ip.startsWith('192.168.') ||
        ip.startsWith('10.') ||
        (ip.startsWith('172.') &&
            int.tryParse(ip.split('.')[1]) != null &&
            int.parse(ip.split('.')[1]) >= 16 &&
            int.parse(ip.split('.')[1]) <= 31) ||
        ip.startsWith('127.') ||
        ip == 'localhost';
  }

  /// الاستماع لتغييرات الاتصال
  Stream<ConnectivityResult> get connectivityStream => _connectivity.onConnectivityChanged.map(
        (List<ConnectivityResult> results) =>
            results.isNotEmpty ? results.first : ConnectivityResult.none,
      );

  /// فتح إعدادات الأذونات
  Future<void> openPermissionSettings() async {
    await openAppSettings();
  }

  /// طلب إذن محدد
  Future<bool> requestSpecificPermission(Permission permission) async {
    final status = await permission.request();
    return status == PermissionStatus.granted;
  }

  /// رسالة توضيحية لأهمية الأذونات
  String getPermissionExplanation() {
    if (Platform.isAndroid) {
      return 'يتطلب التطبيق أذونات الموقع للوصول لمعلومات الشبكة المحلية مثل اسم WiFi وعنوان IP.';
    } else if (Platform.isIOS) {
      return 'يتطلب التطبيق إذن الموقع للحصول على معلومات الشبكة اللاسلكية. يرجى السماح بالوصول للموقع في إعدادات التطبيق.';
    }
    return 'يتطلب التطبيق أذونات للوصول لمعلومات الشبكة.';
  }
}



// // ignore_for_file: avoid_print

// import 'dart:io';
// import 'package:auth_app/pages/configration/models/network_info_model.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:network_info_plus/network_info_plus.dart';
// import 'package:permission_handler/permission_handler.dart';

// class NetworkService {
//   //========================= Parameters =================================//
//   final Connectivity _connectivity = Connectivity();
//   final NetworkInfo _networkInfo = NetworkInfo();

//   //======================================================================//
//     /// التحقق من جميع الأذونات المطلوبة

//   Future<bool> requestPermissions() async {
//     if (Platform.isAndroid) {
//       final status = await Permission.location.request();
//       return status == PermissionStatus.granted;
//     }
//     return true;
//   }

//   //=======================================================================//
//   Future<NetworkInfoModel> getNetworkInfo() async {
//     try {
//       final connectivityResults = await _connectivity.checkConnectivity();

//       //  التحقق من وجود أي اتصال اذا لم يكن هناك اتصال يتم ارجاع نموذج فارغ
//       if (connectivityResults.isEmpty ||
//           connectivityResults.every((result) => result == ConnectivityResult.none)) {
//         return NetworkInfoModel.empty();
//       }

//       //جلب معلومات الشبكة
//       final wifiName = await _networkInfo.getWifiName();
//       final wifiBSSID = await _networkInfo.getWifiBSSID();
//       final wifiIP = await _networkInfo.getWifiIP();
//       final wifiGateway = await _networkInfo.getWifiGatewayIP();
//       final wifiSubmask = await _networkInfo.getWifiSubmask();

//       // تحديد نوع الاتصال باستخدام أول نتيجة اتصال متاحة
//       ConnectionType connectionType = _determineConnectionType(
//         connectivityResults.first,
//         wifiIP,
//       );

//       return NetworkInfoModel(
//         connectionType: connectionType,
//         ipAddress: wifiIP,
//         gateway: wifiGateway,
//         wifiName: wifiName?.replaceAll('"', ''), // إزالة علامات الاقتباس
//         wifiBSSID: wifiBSSID,
//         subnet: wifiSubmask,
//         isConnected: true,
//       );
//     } catch (e) {
//       print('خطأ في الحصول على معلومات الشبكة: $e');
//       return NetworkInfoModel.empty();
//     }
//   }

//   ConnectionType _determineConnectionType(
//     ConnectivityResult connectivityResult,
//     String? ipAddress,
//   ) {
//     if (connectivityResult == ConnectivityResult.none) {
//       return ConnectionType.none;
//     }

//     if (ipAddress != null) {
//       // تحقق من كون العنوان محلي (LAN) أم عام (WAN)
//       if (_isPrivateIP(ipAddress)) {
//         return ConnectionType.lan;
//       } else {
//         return ConnectionType.wan;
//       }
//     }

//     // إذا كان الاتصال عبر WiFi أو Ethernet فهو عادة LAN
//     if (connectivityResult == ConnectivityResult.wifi ||
//         connectivityResult == ConnectivityResult.ethernet) {
//       return ConnectionType.lan;
//     }

//     // إذا كان الاتصال عبر بيانات الهاتف فهو WAN
//     if (connectivityResult == ConnectivityResult.mobile) {
//       return ConnectionType.wan;
//     }

//     return ConnectionType.none;
//   }

//   bool _isPrivateIP(String ip) {
//     return ip.startsWith('192.168.') ||
//         ip.startsWith('10.') ||
//         (ip.startsWith('172.') &&
//             int.tryParse(ip.split('.')[1]) != null &&
//             int.parse(ip.split('.')[1]) >= 16 &&
//             int.parse(ip.split('.')[1]) <= 31) ||
//         ip.startsWith('127.');
//   }

//   Stream<List<ConnectivityResult>> get connectivityStream => _connectivity.onConnectivityChanged;
// }
