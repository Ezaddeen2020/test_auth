import 'dart:io';
import 'package:auth_app/pages/configration/models/network_info_model.dart';
import 'package:auth_app/pages/configration/servicers/network_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final NetworkService _networkService = NetworkService();

  final Rx<NetworkInfoModel> networkInfo = NetworkInfoModel.empty().obs;
  final RxBool isLoading = false.obs;
  final RxBool hasPermission = false.obs;
  final RxBool showPermissionDialog = false.obs;
  final RxString permissionError = ''.obs;
  var connectionStatus = ConnectivityResult.none.obs;

  @override
  void onInit() {
    super.onInit();
    initializePermissions();
    listenToConnectivityChanges();
  }

  /// طلب الصلاحية من المستخدم مع معالجة أفضل للأخطاء
  Future<void> initializePermissions() async {
    try {
      isLoading.value = true;

      // التحقق من الأذونات الحالية أولاً
      final currentPermissions = await _networkService.hasRequiredPermissions();

      if (currentPermissions) {
        hasPermission.value = true;
        await refreshNetworkInfo();
      } else {
        // طلب الأذونات
        final granted = await _networkService.requestPermissions();
        hasPermission.value = granted;

        if (granted) {
          await refreshNetworkInfo();
        } else {
          _showPermissionExplanation();
        }
      }
    } catch (e) {
      permissionError.value = 'خطأ في التحقق من الأذونات: $e';
      _showPermissionExplanation();
    } finally {
      isLoading.value = false;
    }
  }

  /// عرض تفسير الأذونات للمستخدم
  void _showPermissionExplanation() {
    final explanation = _networkService.getPermissionExplanation();

    Get.defaultDialog(
      title: 'أذونات مطلوبة',
      middleText: explanation,
      textConfirm: 'فتح الإعدادات',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        await _networkService.openPermissionSettings();
        // إعادة التحقق من الأذونات بعد فترة
        Future.delayed(const Duration(seconds: 2), () {
          initializePermissions();
        });
      },
      onCancel: () {
        Get.back();
        // محاولة الحصول على المعلومات المتاحة فقط
        refreshNetworkInfo();
      },
    );
  }

  /// الاستماع لتغييرات الاتصال
  void listenToConnectivityChanges() {
    _networkService.connectivityStream.listen((results) {
      refreshNetworkInfo();
    });
  }

  /// تحديث معلومات الشبكة مع معالجة أفضل للأخطاء
  Future<void> refreshNetworkInfo() async {
    try {
      isLoading.value = true;
      permissionError.value = '';

      final info = await _networkService.getNetworkInfo();
      networkInfo.value = info;

      // إذا لم نحصل على معلومات كاملة، نتحقق من الأذونات
      if (!info.isConnected ||
          (info.isConnected && (info.wifiName == null || info.ipAddress == null))) {
        final hasPerms = await _networkService.hasRequiredPermissions();
        if (!hasPerms && Platform.isAndroid || Platform.isIOS) {
          permissionError.value = 'معلومات محدودة - الأذونات غير مكتملة';
        }
      }
    } catch (e) {
      permissionError.value = 'فشل في الحصول على معلومات الشبكة: $e';
      print('Error refreshing network info: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// الحصول على نص حالة الاتصال
  String getConnectionStatusText() {
    if (!networkInfo.value.isConnected) {
      return 'غير متصل بالإنترنت';
    }

    if (permissionError.value.isNotEmpty) {
      return 'متصل (معلومات محدودة)';
    }

    return 'متصل - ${networkInfo.value.connectionTypeString}';
  }

  /// الحصول على لون حالة الاتصال
  Color getConnectionStatusColor() {
    if (!networkInfo.value.isConnected) {
      return const Color(0xFFE53E3E); // أحمر
    }

    if (permissionError.value.isNotEmpty) {
      return const Color(0xFFF59E0B); // برتقالي للتحذير
    }

    return networkInfo.value.connectionType == ConnectionType.lan
        ? const Color(0xFF38A169) // أخضر للشبكة المحلية
        : const Color(0xFF3182CE); // أزرق للإنترنت
  }

  /// إعادة طلب الأذونات
  Future<void> retryPermissions() async {
    await initializePermissions();
  }

  /// فتح إعدادات الأذونات
  Future<void> openPermissionSettings() async {
    await _networkService.openPermissionSettings();
  }

  /// التحقق من كون الجهاز على شبكة محلية
  bool get isOnLocalNetwork {
    final ip = networkInfo.value.ipAddress;
    if (ip == null) return false;

    return ip.startsWith('192.168.') ||
        ip.startsWith('10.') ||
        ip.startsWith('172.') ||
        ip.startsWith('127.');
  }

  /// الحصول على معلومات تشخيصية
  Map<String, dynamic> getDiagnosticInfo() {
    return {
      'hasPermission': hasPermission.value,
      'isConnected': networkInfo.value.isConnected,
      'connectionType': networkInfo.value.connectionTypeString,
      'platform': Platform.operatingSystem,
      'permissionError': permissionError.value,
      'ipAddress': networkInfo.value.ipAddress,
      'wifiName': networkInfo.value.wifiName,
      'gateway': networkInfo.value.gateway,
    };
  }
}
