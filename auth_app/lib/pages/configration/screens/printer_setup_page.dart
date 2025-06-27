// widgets/printer_section.dart
import 'package:auth_app/models/printer_model.dart';
import 'package:auth_app/pages/configration/controllers/network_controller.dart';
import 'package:auth_app/pages/configration/controllers/printer_controller.dart';
import 'package:auth_app/widgets/printer_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrinterSection extends StatelessWidget {
  const PrinterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final PrinterController printerController = Get.find<PrinterController>();
    final NetworkController networkController = Get.find<NetworkController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'إعدادات الطابعة',
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
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            color: const Color(0xFF475569),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Main Printer Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                children: [
                  // Header with Scan Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              Icons.print_rounded,
                              size: 20,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'حالة الطابعة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      Obx(
                        () => printerController.isScanning.value
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF3B82F6),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'جاري البحث...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF3B82F6),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  onPressed: () => _showPrinterDialog(
                                      context, printerController, networkController),
                                  icon: const Icon(Icons.settings_rounded, size: 20),
                                  tooltip: 'إعدادات الطابعة',
                                  color: const Color(0xFF475569),
                                ),
                              ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Current Printer Status
                  Obx(() {
                    final selectedPrinter = printerController.selectedPrinter.value;

                    if (selectedPrinter == null) {
                      return _buildNoPrinterCard(context, printerController, networkController);
                    }

                    return _buildPrinterCard(selectedPrinter, printerController);
                  }),

                  const SizedBox(height: 20),

                  // Quick Actions
                  Obx(() {
                    if (printerController.selectedPrinter.value != null) {
                      return _buildQuickActions(printerController);
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPrinterCard(BuildContext context, PrinterController printerController,
      NetworkController networkController) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.print_disabled_rounded,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد طابعة محددة',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابحث عن الطابعات المتاحة في الشبكة واختر واحدة للاتصال بها',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showPrinterDialog(context, printerController, networkController),
              icon: const Icon(Icons.search_rounded, size: 20),
              label: const Text(
                'البحث عن طابعات',
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrinterCard(PrinterModel printer, PrinterController printerController) {
    final isConnected = printer.isConnected;
    final statusColor = isConnected ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final statusBgColor = isConnected
        ? const Color(0xFF10B981).withOpacity(0.1)
        : const Color(0xFFF59E0B).withOpacity(0.1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isConnected ? Icons.print_rounded : Icons.print_disabled_rounded,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      printer.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${printer.ipAddress}:${printer.port}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isConnected ? 'متصلة' : 'غير متصلة',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.device_hub_rounded,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'MAC Address',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      printer.macAddress,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (printer.lastConnected != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'آخر اتصال',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDateTime(printer.lastConnected!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(PrinterController printerController) {
    return Row(
      children: [
        Expanded(
          child: Obx(() => ElevatedButton.icon(
                onPressed: printerController.isTestingConnection.value
                    ? null
                    : printerController.testSelectedPrinterConnection,
                icon: printerController.isTestingConnection.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.wifi_tethering_rounded, size: 18),
                label: const Text(
                  'اختبار الاتصال',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              )),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Get.defaultDialog(
                title: 'قطع الاتصال',
                titleStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
                middleText: 'هل أنت متأكد من قطع الاتصال مع الطابعة؟',
                middleTextStyle: TextStyle(
                  color: Colors.grey[600],
                ),
                textConfirm: 'نعم',
                textCancel: 'إلغاء',
                confirmTextColor: Colors.white,
                cancelTextColor: const Color(0xFF475569),
                buttonColor: const Color(0xFFEF4444),
                onConfirm: () {
                  printerController.disconnectPrinter();
                  Get.back();
                },
              );
            },
            icon: const Icon(Icons.link_off_rounded, size: 18),
            label: const Text(
              'قطع الاتصال',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showPrinterDialog(BuildContext context, PrinterController printerController,
      NetworkController networkController) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: Get.width * 0.9,
          height: Get.height * 0.75,
          child: PrinterSettingsDialog(),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ساعة';
    } else {
      return '${difference.inDays} يوم';
    }
  }
}

class PrinterSettingsDialog extends StatefulWidget {
  @override
  _PrinterSettingsDialogState createState() => _PrinterSettingsDialogState();
}

class _PrinterSettingsDialogState extends State<PrinterSettingsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PrinterController printerController = Get.find<PrinterController>();
  final NetworkController networkController = Get.find<NetworkController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Enhanced Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Icons.settings_rounded,
                        size: 20,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'إعدادات الطابعة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),

          // Enhanced Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF3B82F6),
              indicatorWeight: 3,
              labelColor: const Color(0xFF3B82F6),
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.search_rounded, size: 18),
                  text: 'البحث عن طابعات',
                ),
                Tab(
                  icon: Icon(Icons.bookmark_rounded, size: 18),
                  text: 'الطابعات المحفوظة',
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildScanTab(),
                _buildSavedPrintersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Enhanced Scan Button
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton.icon(
                  onPressed: printerController.isScanning.value ? null : () => _startScan(),
                  icon: printerController.isScanning.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.search_rounded, size: 20),
                  label: Text(
                    printerController.isScanning.value ? 'جاري البحث...' : 'البحث عن طابعات',
                    style: const TextStyle(
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
                  ),
                )),
          ),

          const SizedBox(height: 20),

          // Enhanced Scan Progress
          Obx(() {
            if (printerController.isScanning.value) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: printerController.scanProgress.value,
                      backgroundColor: const Color(0xFFE2E8F0),
                      color: const Color(0xFF3B82F6),
                      minHeight: 6,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      printerController.scanStatus.value,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          const SizedBox(height: 20),

          // Enhanced Discovered Printers List
          Expanded(
            child: Obx(() {
              if (printerController.discoveredPrinters.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.print_disabled_rounded,
                  title: 'لم يتم العثور على طابعات',
                  subtitle: 'تأكد من أن الطابعة متصلة بنفس الشبكة واضغط على البحث مرة أخرى',
                );
              }

              return ListView.builder(
                itemCount: printerController.discoveredPrinters.length,
                itemBuilder: (context, index) {
                  final printer = printerController.discoveredPrinters[index];
                  return _buildEnhancedPrinterListItem(printer, true);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPrintersTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Enhanced Header with clear button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Row(
                      children: [
                        const Icon(
                          Icons.bookmark_rounded,
                          size: 18,
                          color: Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'الطابعات المحفوظة (${printerController.savedPrintersCount})',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    )),
                OutlinedButton.icon(
                  onPressed: () {
                    Get.defaultDialog(
                      title: 'مسح البيانات',
                      titleStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                      middleText: 'هل أنت متأكد من مسح جميع الطابعات المحفوظة؟',
                      middleTextStyle: TextStyle(color: Colors.grey[600]),
                      textConfirm: 'نعم',
                      textCancel: 'إلغاء',
                      confirmTextColor: Colors.white,
                      cancelTextColor: const Color(0xFF475569),
                      buttonColor: const Color(0xFFEF4444),
                      onConfirm: () {
                        printerController.clearAllData();
                        Get.back();
                      },
                    );
                  },
                  icon: const Icon(Icons.clear_all_rounded, size: 16),
                  label: const Text('مسح الكل'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Enhanced Saved Printers List
          Expanded(
            child: Obx(() {
              if (printerController.savedPrinters.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.bookmark_border_rounded,
                  title: 'لا توجد طابعات محفوظة',
                  subtitle: 'ابحث عن طابعات واحفظها لاستخدامها لاحقاً',
                );
              }

              return ListView.builder(
                itemCount: printerController.savedPrinters.length,
                itemBuilder: (context, index) {
                  final printer = printerController.savedPrinters[index];
                  return _buildEnhancedPrinterListItem(printer, false);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPrinterListItem(PrinterModel printer, bool isFromScan) {
    final isSelected = printerController.selectedPrinter.value == printer;
    final isConnected = printer.isConnected;
    final statusColor = isConnected ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            printerController.selectPrinter(printer);
            Get.back();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Printer Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isConnected ? Icons.print_rounded : Icons.print_disabled_rounded,
                    color: statusColor,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                // Printer Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              printer.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: const Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'مختارة',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF3B82F6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${printer.ipAddress}:${printer.port}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'MAC: ${printer.macAddress}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      if (printer.lastConnected != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'آخر اتصال: ${_formatDateTime(printer.lastConnected!)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Action Button
                if (!isFromScan)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete_rounded, size: 18),
                      color: const Color(0xFFEF4444),
                      onPressed: () {
                        Get.defaultDialog(
                          title: 'حذف الطابعة',
                          titleStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                          middleText: 'هل أنت متأكد من حذف هذه الطابعة؟',
                          middleTextStyle: TextStyle(color: Colors.grey[600]),
                          textConfirm: 'نعم',
                          textCancel: 'إلغاء',
                          confirmTextColor: Colors.white,
                          cancelTextColor: const Color(0xFF475569),
                          buttonColor: const Color(0xFFEF4444),
                          onConfirm: () {
                            printerController.removeSavedPrinter(printer);
                            Get.back();
                          },
                        );
                      },
                    ),
                  ),
                TextButton(
                    onPressed: () {
                      Get.to(() => const UniversalPrinter());
                    },
                    child: const Text('test'))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startScan() {
    final networkInfo = networkController.networkInfo.value;
    if (networkInfo.ipAddress != null) {
      printerController.scanForPrinters(networkInfo.ipAddress!);
    } else {
      Get.snackbar(
        'خطأ',
        'لا يمكن تحديد نطاق الشبكة. تأكد من الاتصال بالشبكة.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        icon: const Icon(Icons.error_rounded, color: Colors.white),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ساعة';
    } else {
      return '${difference.inDays} يوم';
    }
  }
}
