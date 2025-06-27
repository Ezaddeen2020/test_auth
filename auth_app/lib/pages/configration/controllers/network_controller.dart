import 'dart:ui';

import 'package:auth_app/models/network_info_model.dart';
import 'package:auth_app/pages/configration/servicers/network_service.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final NetworkService _networkService = NetworkService();

  final Rx<NetworkInfoModel> networkInfo = NetworkInfoModel.empty().obs;
  final RxBool isLoading = false.obs;
  final RxBool hasPermission = false.obs;

  @override
  void onInit() {
    super.onInit();
    initializePermissions();
    listenToConnectivityChanges();
    refreshNetworkInfo();
  }

  //=================  طلب الصلاحية من المستخدم، وتخزين النتيجة
  Future<void> initializePermissions() async {
    hasPermission.value = await _networkService.requestPermissions();
    if (!hasPermission.value) {
      Get.snackbar(
        'تنبيه',
        'يتطلب التطبيق إذن الموقع للحصول على معلومات WiFi',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  //=================================================================//
  void listenToConnectivityChanges() {
    _networkService.connectivityStream.listen((results) {
      // تحديث معلومات الشبكة عند تغيير الاتصال
      refreshNetworkInfo();
    });
  }

  Future<void> refreshNetworkInfo() async {
    isLoading.value = true;
    try {
      final info = await _networkService.getNetworkInfo();
      networkInfo.value = info;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في الحصول على معلومات الشبكة: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String getConnectionStatusText() {
    if (!networkInfo.value.isConnected) {
      return 'غير متصل بالإنترنت';
    }
    return 'متصل - ${networkInfo.value.connectionTypeString}';
  }

  Color getConnectionStatusColor() {
    if (!networkInfo.value.isConnected) {
      return const Color(0xFFE53E3E);
    }
    return networkInfo.value.connectionType == ConnectionType.lan
        ? const Color(0xFF38A169)
        : const Color(0xFF3182CE);
  }
}
