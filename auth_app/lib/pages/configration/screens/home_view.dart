import 'package:auth_app/pages/configration/controllers/network_controller.dart';
import 'package:auth_app/pages/configration/screens/printer_setup_page.dart';
import 'package:auth_app/widgets/connection_type_indicator.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final NetworkController controller = Get.find();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'معلومات الشبكة',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        surfaceTintColor: Colors.transparent,
        actions: [
          Obx(
            () => controller.isLoading.value
                ? Container(
                    margin: const EdgeInsets.all(16),
                    width: 24,
                    height: 24,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: controller.refreshNetworkInfo,
                      icon: const Icon(Icons.refresh_rounded, size: 22),
                      tooltip: 'تحديث',
                      color: const Color(0xFF475569),
                    ),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && !controller.networkInfo.value.isConnected) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            ),
          );
        }

        final info = controller.networkInfo.value;

        // تحديد نوع الشبكة بناءً على IP Address أو معايير أخرى
        final bool isLocalNetwork = _isLocalNetwork(info.ipAddress);

        return RefreshIndicator(
          onRefresh: controller.refreshNetworkInfo,
          color: const Color(0xFF3B82F6),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isLocalNetwork
                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                          : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (isLocalNetwork ? const Color(0xFF10B981) : const Color(0xFF3B82F6))
                            .withOpacity(0.2),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: ConnectionTypeIndicator()),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isLocalNetwork ? Icons.home_rounded : Icons.cloud_rounded,
                              size: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isLocalNetwork ? 'شبكة محلية' : 'خادم خارجي',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Network Info Section - يتغير حسب نوع الشبكة
                if (isLocalNetwork)
                  _buildLocalNetworkSection(info)
                else
                  _buildServerNetworkSection(info),

                const SizedBox(height: 24),

                // Printer Section Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Printer Icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.print_rounded,
                          size: 32,
                          color: Color(0xFF3B82F6),
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'إعدادات الطابعة',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'إدارة وتكوين طابعات الشبكة المتاحة',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.to(() => const PrinterSection());
                          },
                          icon: const Icon(Icons.settings_rounded, size: 20),
                          label: const Text(
                            'فتح إعدادات الطابعة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            shadowColor: const Color(0xFF3B82F6).withOpacity(0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // تحديد ما إذا كانت الشبكة محلية أم لا
  bool _isLocalNetwork(String? ipAddress) {
    if (ipAddress == null) return false;

    // فحص عناوين IP المحلية
    return ipAddress.startsWith('192.168.') ||
        ipAddress.startsWith('10.') ||
        ipAddress.startsWith('172.') ||
        ipAddress.startsWith('127.');
  }

  // تصميم قسم الشبكة المحلية
  Widget _buildLocalNetworkSection(dynamic info) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.home_rounded,
                  size: 20,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'معلومات الشبكة المحلية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Local Network Cards Grid
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildEnhancedNetworkCard(
                      title: 'عنوان IP المحلي',
                      value: info.ipAddress,
                      icon: Icons.computer_rounded,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildEnhancedNetworkCard(
                      title: 'البوابة الافتراضية',
                      value: info.gateway,
                      icon: Icons.router_rounded,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildEnhancedNetworkCard(
                      title: 'اسم الشبكة اللاسلكية',
                      value: info.wifiName,
                      icon: Icons.wifi_rounded,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildEnhancedNetworkCard(
                      title: 'معرف الشبكة',
                      value: info.wifiBSSID,
                      icon: Icons.fingerprint_rounded,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildEnhancedNetworkCard(
                      title: 'قناع الشبكة الفرعية',
                      value: info.subnet ?? '255.255.255.0',
                      icon: Icons.hub_rounded,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildEnhancedNetworkCard(
                      title: 'نوع الاتصال',
                      value: 'شبكة محلية',
                      icon: Icons.lan_rounded,
                      color: const Color(0xFF06B6D4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // تصميم قسم شبكة الخادم
  Widget _buildServerNetworkSection(dynamic info) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.cloud_rounded,
                  size: 20,
                  color: Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'معلومات الخادم الخارجي',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Server Network Cards Grid
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildEnhancedNetworkCard(
                      title: 'عنوان IP العام',
                      value: info.ipAddress,
                      icon: Icons.public_rounded,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildEnhancedNetworkCard(
                      title: 'خادم DNS',
                      value: info.gateway,
                      icon: Icons.dns_rounded,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildEnhancedNetworkCard(
                      title: 'مزود الخدمة',
                      value: info.wifiName ?? 'غير محدد',
                      icon: Icons.business_rounded,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildEnhancedNetworkCard(
                      title: 'معرف الشبكة',
                      value: info.wifiBSSID,
                      icon: Icons.perm_identity_rounded,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildEnhancedNetworkCard(
                      title: 'نوع البروتوكول',
                      value: 'IPv4/IPv6',
                      icon: Icons.security_rounded,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildEnhancedNetworkCard(
                      title: 'حالة الاتصال',
                      value: 'متصل عبر الإنترنت',
                      icon: Icons.cloud_done_rounded,
                      color: const Color(0xFF06B6D4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedNetworkCard({
    required String title,
    required String? value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value ?? 'غير متاح',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: value != null ? const Color(0xFF1E293B) : Colors.grey[500],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
