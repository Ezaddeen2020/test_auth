import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'dart:async';

class InternetConnectionController extends GetxController {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  // متغيرات reactive
  var isConnected = true.obs;
  var connectionStatus = ConnectionStatus.connected.obs;
  var isSearchingForNetwork = false.obs; // ⬅️ إضافة هذا

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _startListening();
  }

  // فحص الاتصال الأولي
  Future<void> _checkInitialConnection() async {
    try {
      List<ConnectivityResult> result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('خطأ في فحص الاتصال: $e');
    }
  }

  // بدء الاستماع لتغييرات الاتصال
  void _startListening() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  // تحديث حالة الاتصال
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    bool hasConnection = results.any((result) => result != ConnectivityResult.none);

    if (isConnected.value != hasConnection) {
      if (!hasConnection) {
        // عند انقطاع الاتصال، بدء البحث
        isSearchingForNetwork.value = true;
        connectionStatus.value = ConnectionStatus.disconnected;
        isConnected.value = false;
      } else {
        // عند العثور على اتصال، إيقاف البحث
        isSearchingForNetwork.value = false;
        isConnected.value = true;
        connectionStatus.value = ConnectionStatus.reconnected;

        // بعد 3 ثواني، تغيير الحالة إلى متصل عادي
        Timer(Duration(seconds: 3), () {
          if (isConnected.value) {
            connectionStatus.value = ConnectionStatus.connected;
          }
        });
      }
    }
  }

  // إعادة فحص الاتصال يدوياً
  Future<void> retryConnection() async {
    isSearchingForNetwork.value = true; // ⬅️ بدء البحث عند الضغط على retry

    try {
      await Future.delayed(Duration(seconds: 1)); // محاكاة البحث
      List<ConnectivityResult> result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result);

      // إذا لم يتم العثور على اتصال، استمرار البحث لمدة قصيرة
      if (!isConnected.value) {
        Timer(Duration(seconds: 2), () {
          isSearchingForNetwork.value = false;
        });
      }
    } catch (e) {
      print('خطأ في إعادة فحص الاتصال: $e');
      isSearchingForNetwork.value = false;
    }
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}

// enum لحالات الاتصال
enum ConnectionStatus {
  connected, // متصل عادي
  disconnected, // منقطع
  reconnected // تم الاتصال مرة أخرى
}
