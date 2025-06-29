// ignore_for_file: avoid_print

import 'dart:io';
import 'package:auth_app/pages/configration/models/network_info_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class NetworkService {
  //========================= Parameters =================================//
  final Connectivity _connectivity = Connectivity();
  final NetworkInfo _networkInfo = NetworkInfo();

  //======================================================================//
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.location.request();
      return status == PermissionStatus.granted;
    }
    return true;
  }

  //=======================================================================//
  Future<NetworkInfoModel> getNetworkInfo() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();

      //  التحقق من وجود أي اتصال اذا لم يكن هناك اتصال يتم ارجاع نموذج فارغ
      if (connectivityResults.isEmpty ||
          connectivityResults.every((result) => result == ConnectivityResult.none)) {
        return NetworkInfoModel.empty();
      }

      //جلب معلومات الشبكة
      final wifiName = await _networkInfo.getWifiName();
      final wifiBSSID = await _networkInfo.getWifiBSSID();
      final wifiIP = await _networkInfo.getWifiIP();
      final wifiGateway = await _networkInfo.getWifiGatewayIP();
      final wifiSubmask = await _networkInfo.getWifiSubmask();

      // تحديد نوع الاتصال باستخدام أول نتيجة اتصال متاحة
      ConnectionType connectionType = _determineConnectionType(
        connectivityResults.first,
        wifiIP,
      );

      return NetworkInfoModel(
        connectionType: connectionType,
        ipAddress: wifiIP,
        gateway: wifiGateway,
        wifiName: wifiName?.replaceAll('"', ''), // إزالة علامات الاقتباس
        wifiBSSID: wifiBSSID,
        subnet: wifiSubmask,
        isConnected: true,
      );
    } catch (e) {
      print('خطأ في الحصول على معلومات الشبكة: $e');
      return NetworkInfoModel.empty();
    }
  }

  ConnectionType _determineConnectionType(
    ConnectivityResult connectivityResult,
    String? ipAddress,
  ) {
    if (connectivityResult == ConnectivityResult.none) {
      return ConnectionType.none;
    }

    if (ipAddress != null) {
      // تحقق من كون العنوان محلي (LAN) أم عام (WAN)
      if (_isPrivateIP(ipAddress)) {
        return ConnectionType.lan;
      } else {
        return ConnectionType.wan;
      }
    }

    // إذا كان الاتصال عبر WiFi أو Ethernet فهو عادة LAN
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.ethernet) {
      return ConnectionType.lan;
    }

    // إذا كان الاتصال عبر بيانات الهاتف فهو WAN
    if (connectivityResult == ConnectivityResult.mobile) {
      return ConnectionType.wan;
    }

    return ConnectionType.none;
  }

  bool _isPrivateIP(String ip) {
    return ip.startsWith('192.168.') ||
        ip.startsWith('10.') ||
        (ip.startsWith('172.') &&
            int.tryParse(ip.split('.')[1]) != null &&
            int.parse(ip.split('.')[1]) >= 16 &&
            int.parse(ip.split('.')[1]) <= 31) ||
        ip.startsWith('127.');
  }

  Stream<List<ConnectivityResult>> get connectivityStream => _connectivity.onConnectivityChanged;
}
