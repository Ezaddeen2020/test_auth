// lib/widgets/internet_status_overlay.dart

import 'package:auth_app/check_internet/internet_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InternetStatusOverlay extends StatelessWidget {
  const InternetStatusOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InternetConnectionController>();

    return Obx(() {
      // إخفاء الـ overlay إذا كان متصل بشكل عادي
      if (controller.connectionStatus.value == ConnectionStatus.connected) {
        return const SizedBox.shrink();
      }

      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _getContainerHeight(controller.connectionStatus.value),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getBackgroundColor(controller.connectionStatus.value),
                  _getBackgroundColor(controller.connectionStatus.value).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // أيقونة أو progress indicator واحد فقط
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: controller.isSearchingForNetwork.value
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            _getIcon(controller.connectionStatus.value),
                            color: Colors.white,
                            size: 20,
                          ),
                  ),

                  const SizedBox(width: 16),

                  // النص
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getMainText(controller.connectionStatus.value,
                              controller.isSearchingForNetwork.value),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getSubText(controller.connectionStatus.value,
                              controller.isSearchingForNetwork.value),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            decoration: TextDecoration.none,
                            fontSize: 13,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // زر إعادة المحاولة (فقط عند انقطاع الاتصال وليس أثناء البحث)
                  if (controller.connectionStatus.value == ConnectionStatus.disconnected &&
                      !controller.isSearchingForNetwork.value)
                    GestureDetector(
                      onTap: () => controller.retryConnection(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  double _getContainerHeight(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.disconnected:
        return 70;
      case ConnectionStatus.reconnected:
        return 70;
      case ConnectionStatus.connected:
        return 0;
    }
  }

  Color _getBackgroundColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.disconnected:
        return const Color.fromARGB(255, 182, 20, 20); // أحمر أنيق
      case ConnectionStatus.reconnected:
        return const Color.fromARGB(255, 28, 145, 83); // أخضر أنيق
      case ConnectionStatus.connected:
        return Colors.transparent;
    }
  }

  IconData _getIcon(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.disconnected:
        return Icons.wifi_off_rounded;
      case ConnectionStatus.reconnected:
        return Icons.wifi_rounded;
      case ConnectionStatus.connected:
        return Icons.wifi_rounded;
    }
  }

  String _getMainText(ConnectionStatus status, bool isSearching) {
    if (isSearching) {
      return 'البحث عن شبكة...';
    }

    switch (status) {
      case ConnectionStatus.disconnected:
        return 'لا يوجد اتصال بالإنترنت';
      case ConnectionStatus.reconnected:
        return 'تم استعادة الاتصال بالإنترنت';
      case ConnectionStatus.connected:
        return '';
    }
  }

  String _getSubText(ConnectionStatus status, bool isSearching) {
    if (isSearching) {
      return 'جاري البحث عن شبكة متاحة...';
    }

    switch (status) {
      case ConnectionStatus.disconnected:
        return 'تحقق من إعدادات الشبكة';
      case ConnectionStatus.reconnected:
        return 'يمكنك الآن استخدام التطبيق';
      case ConnectionStatus.connected:
        return '';
    }
  }
}
