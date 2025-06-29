import 'package:auth_app/pages/configration/controllers/network_controller.dart';
import 'package:auth_app/pages/configration/screens/printer_setup_page.dart';
import 'package:auth_app/pages/configration/screens/network_page.dart';
import 'package:auth_app/widgets/connection_type_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ConfigrationPage extends StatefulWidget {
  const ConfigrationPage({super.key});

  @override
  State<ConfigrationPage> createState() => _ConfigrationPageState();
}

class _ConfigrationPageState extends State<ConfigrationPage> with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _cardsAnimationController;
  late AnimationController _fabAnimationController;

  late Animation<double> _headerSlideAnimation;
  late Animation<double> _cardsSlideAnimation;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Create animations
    _headerSlideAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );

    _cardsSlideAnimation = CurvedAnimation(
      parent: _cardsAnimationController,
      curve: Curves.easeOutCubic,
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    );

    // Start animations sequentially
    _startAnimations();
  }

  void _startAnimations() {
    _headerAnimationController.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      _cardsAnimationController.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardsAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NetworkController controller = Get.find();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('الإعدادات'),
        automaticallyImplyLeading: true, // يضيف زر الرجوع تلقائيًا
      ),
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
                          animation: _headerSlideAnimation,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(0, 50 * (1 - _headerSlideAnimation.value)),
                            child: Opacity(
                              opacity: _headerSlideAnimation.value,
                              child: _buildStatusHeader(info, isLocalNetwork),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Animated Action Cards
                        AnimatedBuilder(
                          animation: _cardsSlideAnimation,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(0, 50 * (1 - _cardsSlideAnimation.value)),
                            child: Opacity(
                              opacity: _cardsSlideAnimation.value,
                              child: _buildActionCardsGrid(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Animated Network Overview
                        AnimatedBuilder(
                          animation: _cardsSlideAnimation,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(0, 50 * (1 - _cardsSlideAnimation.value)),
                            child: Opacity(
                              opacity: _cardsSlideAnimation.value,
                              // child: _buildNetworkStatusOverview(info, isLocalNetwork),
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

      // Enhanced Floating Action Button
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) => Transform.scale(
          scale: _fabAnimation.value,
          child: FloatingActionButton.extended(
            onPressed: () => _showQuickActionsModal(),
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            elevation: 8,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'إجراءات سريعة',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedAppBar(NetworkController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 2),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          // App Icon with Gradient
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(
              Icons.home_rounded,
              size: 24,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 16),

          // Enhanced Title
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الصفحة الرئيسية',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'مرحباً بك في لوحة التحكم',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
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
                    : Hero(
                        tag: 'refresh_button',
                        child: Container(
                          key: const ValueKey('refresh'),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
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
                            onPressed: () async {
                              await controller.refreshNetworkInfo();
                              // Add haptic feedback
                              HapticFeedback.lightImpact();
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 20),
                            color: Colors.white,
                            tooltip: 'تحديث',
                          ),
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
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.15),
                  offset: const Offset(0, 8),
                  blurRadius: 32,
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'جاري تحميل البيانات...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'يرجى الانتظار بينما نحصل على أحدث المعلومات',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(dynamic info, bool isLocalNetwork) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLocalNetwork
              ? [
                  const Color(0xFF10B981),
                  const Color(0xFF059669),
                  const Color(0xFF047857),
                ]
              : [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                  const Color(0xFF4F46E5),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isLocalNetwork ? const Color(0xFF10B981) : const Color(0xFF6366F1))
                .withOpacity(0.3),
            offset: const Offset(0, 12),
            blurRadius: 32,
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
                  color: Colors.white.withOpacity(0.25),
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.white.withOpacity(0.8),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCardsGrid() {
    return Row(
      children: [
        // Network Info Card
        Expanded(
          child: _buildEnhancedActionCard(
            title: 'معلومات الشبكة',
            subtitle: 'عرض تفاصيل الشبكة والاتصال',
            icon: Icons.network_check_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              Get.to(
                () => const NetworkPage(),
                transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: 300),
              );
            },
          ),
        ),

        const SizedBox(width: 16),

        // Printer Setup Card
        Expanded(
          child: _buildEnhancedActionCard(
            title: 'إعدادات الطابعة',
            subtitle: 'إدارة وتكوين الطابعات',
            icon: Icons.print_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              Get.to(
                () => const PrinterSection(),
                transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: 300),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon with Gradient Background
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withOpacity(0.3),
                        offset: const Offset(0, 8),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Subtitle
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Arrow Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: gradient.colors.first.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: gradient.colors.first,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced Status Info
  // Container(
  //   padding: const EdgeInsets.all(20),
  //   decoration: BoxDecoration(
  //     color: Colors.white.withOpacity(0.15),
  //     borderRadius: BorderRadius.circular(20),
  //     border: Border.all(
  //       color: Colors.white.withOpacity(0.2),
  //       width: 1,
  //     ),
  //   ),
  //   child: Column(
  //     children: [
  //       Row(
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.all(8),
  //             decoration: BoxDecoration(
  //               color: Colors.white.withOpacity(0.2),
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //             child: Icon(
  //               Icons.signal_wifi_4_bar_rounded,
  //               color: Colors.white.withOpacity(0.9),
  //               size: 20,
  //             ),
  //           ),
  //           const SizedBox(width: 12),
  //           // Expanded(
  //           //   child: Column(
  //           //     crossAxisAlignment: CrossAxisAlignment.start,
  //           //     children: [
  //           //       Text(
  //           //         'اتصال نشط',
  //           //         style: TextStyle(
  //           //           color: Colors.white.withOpacity(0.9),
  //           //           fontSize: 14,
  //           //           fontWeight: FontWeight.w600,
  //           //         ),
  //           //       ),
  //           //       Text(
  //           //         info.wifiName ?? 'شبكة غير محددة',
  //           //         style: TextStyle(
  //           //           color: Colors.white.withOpacity(0.7),
  //           //           fontSize: 12,
  //           //         ),
  //           //       ),
  //           //     ],
  //           //   ),
  //           // ),
  //           Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //             decoration: BoxDecoration(
  //               color: Colors.white.withOpacity(0.2),
  //               borderRadius: BorderRadius.circular(15),
  //             ),
  //             child: Text(
  //               info.ipAddress ?? 'غير متاح',
  //               style: TextStyle(
  //                 color: Colors.white.withOpacity(0.9),
  //                 fontSize: 11,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),

  //       const SizedBox(height: 16),

  //       // Quick Stats Row
  //       Row(
  //         children: [
  //           Expanded(
  //             child: _buildQuickStat(
  //               icon: Icons.speed_rounded,
  //               label: 'السرعة',
  //               value: isLocalNetwork ? 'عالية' : 'متوسطة',
  //             ),
  //           ),
  //           Container(
  //             width: 1,
  //             height: 24,
  //             color: Colors.white.withOpacity(0.3),
  //             margin: const EdgeInsets.symmetric(horizontal: 16),
  //           ),
  //           Expanded(
  //             child: _buildQuickStat(
  //               icon: Icons.security_rounded,
  //               label: 'الأمان',
  //               value: 'محمية',
  //             ),
  //           ),
  //           Container(
  //             width: 1,
  //             height: 24,
  //             color: Colors.white.withOpacity(0.3),
  //             margin: const EdgeInsets.symmetric(horizontal: 16),
  //           ),
  //           Expanded(
  //             child: _buildQuickStat(
  //               icon: Icons.devices_rounded,
  //               label: 'النوع',
  //               value: isLocalNetwork ? 'محلي' : 'عام',
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   ),
  // ),

  // Widget _buildNetworkStatusOverview(dynamic info, bool isLocalNetwork) {
  //   return Container(
  //     padding: const EdgeInsets.all(24),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(20),
  //       border: Border.all(
  //         color: const Color(0xFFE2E8F0),
  //         width: 1,
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.06),
  //           offset: const Offset(0, 4),
  //           blurRadius: 16,
  //           spreadRadius: 0,
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.all(12),
  //               decoration: BoxDecoration(
  //                 gradient: const LinearGradient(
  //                   colors: [Color(0xFF64748B), Color(0xFF475569)],
  //                 ),
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: const Icon(
  //                 Icons.info_outline_rounded,
  //                 size: 20,
  //                 color: Colors.white,
  //               ),
  //             ),
  //             const SizedBox(width: 16),
  //             const Expanded(
  //               child: Text(
  //                 'نظرة عامة على الشبكة',
  //                 style: TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.w700,
  //                   color: Color(0xFF0F172A),
  //                 ),
  //               ),
  //             ),
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //               decoration: BoxDecoration(
  //                 color: info.isConnected
  //                     ? const Color(0xFF10B981).withOpacity(0.1)
  //                     : const Color(0xFFEF4444).withOpacity(0.1),
  //                 borderRadius: BorderRadius.circular(20),
  //               ),
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Icon(
  //                     info.isConnected ? Icons.check_circle_rounded : Icons.error_rounded,
  //                     size: 14,
  //                     color: info.isConnected ? const Color(0xFF10B981) : const Color(0xFFEF4444),
  //                   ),
  //                   const SizedBox(width: 4),
  //                   Text(
  //                     info.isConnected ? 'متصل' : 'غير متصل',
  //                     style: TextStyle(
  //                       fontSize: 11,
  //                       fontWeight: FontWeight.w600,
  //                       color: info.isConnected ? const Color(0xFF10B981) : const Color(0xFFEF4444),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),

  //         const SizedBox(height: 20),

  //         // Enhanced Info Grid
  //         Column(
  //           children: [
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: _buildInfoCard(
  //                     title: 'عنوان IP',
  //                     value: info.ipAddress ?? 'غير متاح',
  //                     icon: Icons.computer_rounded,
  //                     color: const Color(0xFF6366F1),
  //                   ),
  //                 ),
  //                 const SizedBox(width: 12),
  //                 Expanded(
  //                   child: _buildInfoCard(
  //                     title: 'نوع الشبكة',
  //                     value: isLocalNetwork ? 'محلية' : 'خارجية',
  //                     icon: isLocalNetwork ? Icons.home_rounded : Icons.cloud_rounded,
  //                     color: const Color(0xFF8B5CF6),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 12),
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: _buildInfoCard(
  //                     title: 'اسم الشبكة',
  //                     value: info.wifiName ?? 'غير متاح',
  //                     icon: Icons.wifi_rounded,
  //                     color: const Color(0xFF10B981),
  //                   ),
  //                 ),
  //                 const SizedBox(width: 12),
  //                 Expanded(
  //                   child: _buildInfoCard(
  //                     title: 'البوابة',
  //                     value: info.gateway ?? 'غير متاح',
  //                     icon: Icons.router_rounded,
  //                     color: const Color(0xFFF59E0B),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildInfoCard({
    required String title,
    required String value,
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showQuickActionsModal() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'إجراءات سريعة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    title: 'تحديث الشبكة',
                    icon: Icons.refresh_rounded,
                    color: const Color(0xFF6366F1),
                    onTap: () {
                      Get.back();
                      final controller = Get.find<NetworkController>();
                      controller.refreshNetworkInfo();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    title: 'إعدادات النظام',
                    icon: Icons.settings_rounded,
                    color: const Color(0xFF8B5CF6),
                    onTap: () {
                      Get.back();
                      // Navigate to settings
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildQuickActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(icon, size: 28, color: color),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
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
