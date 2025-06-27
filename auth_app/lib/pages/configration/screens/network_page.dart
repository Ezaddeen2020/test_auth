import 'package:auth_app/pages/configration/controllers/network_controller.dart';
import 'package:auth_app/widgets/connection_type_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _cardsAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardsAnimation;

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );
    _cardsAnimation = CurvedAnimation(
      parent: _cardsAnimationController,
      curve: Curves.easeOutCubic,
    );

    // Start animations
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _cardsAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NetworkController controller = Get.find();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced App Bar
            _buildEnhancedAppBar(controller),

            // Main Content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && !controller.networkInfo.value.isConnected) {
                  return _buildLoadingState();
                }

                final info = controller.networkInfo.value;
                final bool isLocalNetwork = _isLocalNetwork(info.ipAddress);

                return RefreshIndicator(
                  onRefresh: controller.refreshNetworkInfo,
                  color: const Color(0xFF6366F1),
                  backgroundColor: Colors.white,
                  strokeWidth: 3,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        // Animated Status Header
                        AnimatedBuilder(
                          animation: _headerAnimation,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(0, 50 * (1 - _headerAnimation.value)),
                            child: Opacity(
                              opacity: _headerAnimation.value,
                              child: _buildStatusHeader(info, isLocalNetwork),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Animated Network Info Section
                        AnimatedBuilder(
                          animation: _cardsAnimation,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(0, 50 * (1 - _cardsAnimation.value)),
                            child: Opacity(
                              opacity: _cardsAnimation.value,
                              child: isLocalNetwork
                                  ? _buildLocalNetworkSection(info)
                                  : _buildServerNetworkSection(info),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedAppBar(NetworkController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button with Glass Effect
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              color: const Color(0xFF475569),
            ),
          ),

          const SizedBox(width: 16),

          // Title with Icon
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.network_check_rounded,
                    size: 20,
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'معلومات الشبكة',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // Enhanced Refresh Button
          Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: controller.isLoading.value
                    ? Container(
                        key: const ValueKey('loading'),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                          ),
                        ),
                      )
                    : Container(
                        key: const ValueKey('refresh'),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              offset: const Offset(0, 4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: controller.refreshNetworkInfo,
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          color: Colors.white,
                          tooltip: 'تحديث',
                        ),
                      ),
              )),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  offset: const Offset(0, 8),
                  blurRadius: 24,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'جاري تحميل معلومات الشبكة...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(dynamic info, bool isLocalNetwork) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLocalNetwork
              ? [const Color(0xFF10B981), const Color(0xFF059669)]
              : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isLocalNetwork ? const Color(0xFF10B981) : const Color(0xFF6366F1))
                .withOpacity(0.3),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: ConnectionTypeIndicator()),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
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
                      size: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isLocalNetwork ? 'شبكة محلية' : 'خادم خارجي',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Additional Status Info
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.signal_wifi_4_bar_rounded,
                  color: Colors.white.withOpacity(0.9),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اتصال نشط',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        info.wifiName ?? 'شبكة غير محددة',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    info.ipAddress ?? 'غير متاح',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalNetworkSection(dynamic info) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.home_rounded,
                    size: 24,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'معلومات الشبكة المحلية',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Network Cards
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildNetworkInfoGrid([
                  _NetworkCardData(
                    title: 'عنوان IP المحلي',
                    value: info.ipAddress,
                    icon: Icons.computer_rounded,
                    color: const Color(0xFF10B981),
                  ),
                  _NetworkCardData(
                    title: 'البوابة الافتراضية',
                    value: info.gateway,
                    icon: Icons.router_rounded,
                    color: const Color(0xFF8B5CF6),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildNetworkInfoGrid([
                  _NetworkCardData(
                    title: 'اسم الشبكة اللاسلكية',
                    value: info.wifiName,
                    icon: Icons.wifi_rounded,
                    color: const Color(0xFF6366F1),
                  ),
                  _NetworkCardData(
                    title: 'معرف الشبكة',
                    value: info.wifiBSSID,
                    icon: Icons.fingerprint_rounded,
                    color: const Color(0xFFF59E0B),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildNetworkInfoGrid([
                  _NetworkCardData(
                    title: 'قناع الشبكة الفرعية',
                    value: info.subnet ?? '255.255.255.0',
                    icon: Icons.hub_rounded,
                    color: const Color(0xFFEF4444),
                  ),
                  _NetworkCardData(
                    title: 'نوع الاتصال',
                    value: 'شبكة محلية',
                    icon: Icons.lan_rounded,
                    color: const Color(0xFF06B6D4),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerNetworkSection(dynamic info) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFFAFAFA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.cloud_rounded,
                    size: 24,
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'معلومات الخادم الخارجي',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Network Cards
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildNetworkInfoGrid([
                  _NetworkCardData(
                    title: 'عنوان IP العام',
                    value: info.ipAddress,
                    icon: Icons.public_rounded,
                    color: const Color(0xFF6366F1),
                  ),
                  _NetworkCardData(
                    title: 'خادم DNS',
                    value: info.gateway,
                    icon: Icons.dns_rounded,
                    color: const Color(0xFF8B5CF6),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildNetworkInfoGrid([
                  _NetworkCardData(
                    title: 'مزود الخدمة',
                    value: info.wifiName ?? 'غير محدد',
                    icon: Icons.business_rounded,
                    color: const Color(0xFF10B981),
                  ),
                  _NetworkCardData(
                    title: 'معرف الشبكة',
                    value: info.wifiBSSID,
                    icon: Icons.perm_identity_rounded,
                    color: const Color(0xFFF59E0B),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildNetworkInfoGrid([
                  _NetworkCardData(
                    title: 'نوع البروتوكول',
                    value: 'IPv4/IPv6',
                    icon: Icons.security_rounded,
                    color: const Color(0xFFEF4444),
                  ),
                  _NetworkCardData(
                    title: 'حالة الاتصال',
                    value: 'متصل عبر الإنترنت',
                    icon: Icons.cloud_done_rounded,
                    color: const Color(0xFF06B6D4),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkInfoGrid(List<_NetworkCardData> cards) {
    return Row(
      children: cards.map((card) {
        final isFirst = cards.indexOf(card) == 0;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: isFirst ? 8 : 0, right: isFirst ? 0 : 8),
            child: _buildEnhancedNetworkCard(
              title: card.title,
              value: card.value,
              icon: card.icon,
              color: card.color,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEnhancedNetworkCard({
    required String title,
    required String? value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            value ?? 'غير متاح',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: value != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  bool _isLocalNetwork(String? ipAddress) {
    if (ipAddress == null) return false;
    return ipAddress.startsWith('192.168.') ||
        ipAddress.startsWith('10.') ||
        ipAddress.startsWith('172.') ||
        ipAddress.startsWith('127.');
  }
}

class _NetworkCardData {
  final String title;
  final String? value;
  final IconData icon;
  final Color color;

  _NetworkCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}



// import 'package:auth_app/pages/configration/controllers/network_controller.dart';
// import 'package:auth_app/widgets/connection_type_indicator.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class NetworkPage extends StatelessWidget {
//   const NetworkPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final NetworkController controller = Get.find();

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       appBar: AppBar(
//         title: const Text(
//           'معلومات الشبكة',
//           style: TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 20,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         foregroundColor: const Color(0xFF1E293B),
//         elevation: 0,
//         shadowColor: Colors.black.withOpacity(0.1),
//         surfaceTintColor: Colors.transparent,
//         actions: [
//           Obx(
//             () => controller.isLoading.value
//                 ? Container(
//                     margin: const EdgeInsets.all(16),
//                     width: 24,
//                     height: 24,
//                     child: const CircularProgressIndicator(
//                       strokeWidth: 2.5,
//                       valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
//                     ),
//                   )
//                 : Container(
//                     margin: const EdgeInsets.only(left: 8),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF1F5F9),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: IconButton(
//                       onPressed: controller.refreshNetworkInfo,
//                       icon: const Icon(Icons.refresh_rounded, size: 22),
//                       tooltip: 'تحديث',
//                       color: const Color(0xFF475569),
//                     ),
//                   ),
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value && !controller.networkInfo.value.isConnected) {
//           return const Center(
//             child: CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
//             ),
//           );
//         }

//         final info = controller.networkInfo.value;

//         // تحديد نوع الشبكة بناءً على IP Address أو معايير أخرى
//         final bool isLocalNetwork = _isLocalNetwork(info.ipAddress);

//         return RefreshIndicator(
//           onRefresh: controller.refreshNetworkInfo,
//           color: const Color(0xFF3B82F6),
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Status Header Card
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: isLocalNetwork
//                           ? [const Color(0xFF10B981), const Color(0xFF059669)]
//                           : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: (isLocalNetwork ? const Color(0xFF10B981) : const Color(0xFF3B82F6))
//                             .withOpacity(0.2),
//                         offset: const Offset(0, 4),
//                         blurRadius: 12,
//                         spreadRadius: 0,
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(child: ConnectionTypeIndicator()),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                             color: Colors.white.withOpacity(0.3),
//                             width: 1,
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               isLocalNetwork ? Icons.home_rounded : Icons.cloud_rounded,
//                               size: 14,
//                               color: Colors.white.withOpacity(0.9),
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               isLocalNetwork ? 'شبكة محلية' : 'خادم خارجي',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.white.withOpacity(0.9),
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 24),

//                 // Network Info Section - يتغير حسب نوع الشبكة
//                 if (isLocalNetwork)
//                   _buildLocalNetworkSection(info)
//                 else
//                   _buildServerNetworkSection(info),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   // تحديد ما إذا كانت الشبكة محلية أم لا
//   bool _isLocalNetwork(String? ipAddress) {
//     if (ipAddress == null) return false;

//     // فحص عناوين IP المحلية
//     return ipAddress.startsWith('192.168.') ||
//         ipAddress.startsWith('10.') ||
//         ipAddress.startsWith('172.') ||
//         ipAddress.startsWith('127.');
//   }

//   // تصميم قسم الشبكة المحلية
//   Widget _buildLocalNetworkSection(dynamic info) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             offset: const Offset(0, 2),
//             blurRadius: 8,
//             spreadRadius: 0,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF10B981).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Icon(
//                   Icons.home_rounded,
//                   size: 20,
//                   color: Color(0xFF10B981),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               const Text(
//                 'معلومات الشبكة المحلية',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF1E293B),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),

//           // Local Network Cards Grid
//           Column(
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildEnhancedNetworkCard(
//                       title: 'عنوان IP المحلي',
//                       value: info.ipAddress,
//                       icon: Icons.computer_rounded,
//                       color: const Color(0xFF10B981),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _buildEnhancedNetworkCard(
//                       title: 'البوابة الافتراضية',
//                       value: info.gateway,
//                       icon: Icons.router_rounded,
//                       color: const Color(0xFF8B5CF6),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildEnhancedNetworkCard(
//                       title: 'اسم الشبكة اللاسلكية',
//                       value: info.wifiName,
//                       icon: Icons.wifi_rounded,
//                       color: const Color(0xFF3B82F6),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _buildEnhancedNetworkCard(
//                       title: 'معرف الشبكة',
//                       value: info.wifiBSSID,
//                       icon: Icons.fingerprint_rounded,
//                       color: const Color(0xFFF59E0B),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildEnhancedNetworkCard(
//                       title: 'قناع الشبكة الفرعية',
//                       value: info.subnet ?? '255.255.255.0',
//                       icon: Icons.hub_rounded,
//                       color: const Color(0xFFEF4444),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _buildEnhancedNetworkCard(
//                       title: 'نوع الاتصال',
//                       value: 'شبكة محلية',
//                       icon: Icons.lan_rounded,
//                       color: const Color(0xFF06B6D4),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // تصميم قسم شبكة الخادم
//   Widget _buildServerNetworkSection(dynamic info) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             offset: const Offset(0, 2),
//             blurRadius: 8,
//             spreadRadius: 0,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF3B82F6).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Icon(
//                   Icons.cloud_rounded,
//                   size: 20,
//                   color: Color(0xFF3B82F6),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               const Text(
//                 'معلومات الخادم الخارجي',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF1E293B),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),

//           // Server Network Cards Grid
//           Column(
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildEnhancedNetworkCard(
//                       title: 'عنوان IP العام',
//                       value: info.ipAddress,
//                       icon: Icons.public_rounded,
//                       color: const Color(0xFF3B82F6),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _buildEnhancedNetworkCard(
//                       title: 'خادم DNS',
//                       value: info.gateway,
//                       icon: Icons.dns_rounded,
//                       color: const Color(0xFF8B5CF6),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildEnhancedNetworkCard(
//                       title: 'مزود الخدمة',
//                       value: info.wifiName ?? 'غير محدد',
//                       icon: Icons.business_rounded,
//                       color: const Color(0xFF10B981),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _buildEnhancedNetworkCard(
//                       title: 'معرف الشبكة',
//                       value: info.wifiBSSID,
//                       icon: Icons.perm_identity_rounded,
//                       color: const Color(0xFFF59E0B),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _buildEnhancedNetworkCard(
//                       title: 'نوع البروتوكول',
//                       value: 'IPv4/IPv6',
//                       icon: Icons.security_rounded,
//                       color: const Color(0xFFEF4444),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: _buildEnhancedNetworkCard(
//                       title: 'حالة الاتصال',
//                       value: 'متصل عبر الإنترنت',
//                       icon: Icons.cloud_done_rounded,
//                       color: const Color(0xFF06B6D4),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEnhancedNetworkCard({
//     required String title,
//     required String? value,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: color.withOpacity(0.1),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 icon,
//                 size: 18,
//                 color: color,
//               ),
//               const SizedBox(width: 6),
//               Expanded(
//                 child: Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                     color: color,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             value ?? 'غير متاح',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: value != null ? const Color(0xFF1E293B) : Colors.grey[500],
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
// }
