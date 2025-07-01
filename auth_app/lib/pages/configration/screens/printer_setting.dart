// import 'package:auth_app/pages/configration/models/printer_model.dart';
// import 'package:auth_app/pages/configration/controllers/network_controller.dart';
// import 'package:auth_app/pages/configration/controllers/printer_controller.dart';
// import 'package:auth_app/widgets/printer_test.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// // Enhanced PrinterSettingsDialog with improved design
// class PrinterSettingsDialog extends StatefulWidget {
//   @override
//   _PrinterSettingsDialogState createState() => _PrinterSettingsDialogState();
// }

// class _PrinterSettingsDialogState extends State<PrinterSettingsDialog>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//   late AnimationController _slideController;
//   late Animation<Offset> _slideAnimation;
//   final PrinterController printerController = Get.find<PrinterController>();
//   final NetworkController networkController = Get.find<NetworkController>();

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

//     _slideController.forward();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _slideController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SlideTransition(
//       position: _slideAnimation,
//       child: Container(
//         decoration: BoxDecoration(
//           color: const Color(0xFFF8FAFC),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               offset: const Offset(0, 8),
//               blurRadius: 32,
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             // Enhanced Header with Glassmorphism
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//                       ),
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFF6366F1).withOpacity(0.3),
//                           offset: const Offset(0, 4),
//                           blurRadius: 12,
//                         ),
//                       ],
//                     ),
//                     child: const Icon(
//                       Icons.settings_rounded,
//                       size: 24,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(width: 15),
//                   const Expanded(
//                     child: Text(
//                       'إعدادات الطابعة',
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF0F172A),
//                       ),
//                     ),
//                   ),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF1F5F9),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: const Color(0xFFE2E8F0)),
//                     ),
//                     child: IconButton(
//                       onPressed: () => Get.back(),
//                       icon: const Icon(Icons.close_rounded, size: 20),
//                       color: const Color(0xFF475569),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Enhanced Modern Tabs
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 10),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF1F5F9),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: TabBar(
//                 controller: _tabController,
//                 indicator: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       offset: const Offset(0, 2),
//                       blurRadius: 8,
//                     ),
//                   ],
//                 ),
//                 indicatorPadding: const EdgeInsets.all(4),
//                 labelColor: const Color(0xFF6366F1),
//                 unselectedLabelColor: const Color(0xFF64748B),
//                 labelStyle: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                 ),
//                 unselectedLabelStyle: const TextStyle(
//                   fontWeight: FontWeight.w500,
//                   fontSize: 14,
//                 ),
//                 tabs: const [
//                   Tab(
//                     icon: Icon(Icons.search_rounded, size: 18),
//                     text: 'البحث عن طابعات',
//                   ),
//                   Tab(
//                     icon: Icon(Icons.bookmark_rounded, size: 18),
//                     text: 'الطابعات المحفوظة',
//                   ),
//                 ],
//               ),
//             ),

//             // Tab Content
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _buildScanTab(),
//                   _buildSavedPrintersTab(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildScanTab() {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         children: [
//           // Enhanced Scan Button with Gradient
//           SizedBox(
//             width: double.infinity,
//             child: Obx(() => AnimatedContainer(
//                   duration: const Duration(milliseconds: 300),
//                   child: ElevatedButton.icon(
//                     onPressed: printerController.isScanning.value ? null : () => _startScan(),
//                     icon: printerController.isScanning.value
//                         ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           )
//                         : const Icon(Icons.search_rounded, size: 20),
//                     label: Text(
//                       printerController.isScanning.value ? 'جاري البحث...' : 'البحث عن طابعات',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF6366F1),
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       elevation: 0,
//                       shadowColor: const Color(0xFF6366F1).withOpacity(0.3),
//                     ),
//                   ),
//                 )),
//           ),

//           const SizedBox(height: 24),

//           // Enhanced Scan Progress with Modern Design
//           Obx(() {
//             if (printerController.isScanning.value) {
//               return Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: const Color(0xFFE2E8F0)),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.04),
//                       offset: const Offset(0, 2),
//                       blurRadius: 8,
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF6366F1).withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Icon(
//                             Icons.radar_rounded,
//                             size: 16,
//                             color: Color(0xFF6366F1),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         const Expanded(
//                           child: Text(
//                             'جاري البحث في الشبكة',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF0F172A),
//                             ),
//                           ),
//                         ),
//                         Text(
//                           '${(printerController.scanProgress.value * 100).toInt()}%',
//                           style: const TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF6366F1),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     LinearProgressIndicator(
//                       value: printerController.scanProgress.value,
//                       backgroundColor: const Color(0xFFF1F5F9),
//                       color: const Color(0xFF6366F1),
//                       minHeight: 8,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       printerController.scanStatus.value,
//                       style: const TextStyle(
//                         color: Color(0xFF64748B),
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               );
//             }
//             return const SizedBox.shrink();
//           }),

//           // const SizedBox(height: 20),

//           // Enhanced Discovered Printers List
//           Expanded(
//             child: Obx(() {
//               if (printerController.discoveredPrinters.isEmpty) {
//                 return _buildEmptyState(
//                   icon: Icons.print_disabled_rounded,
//                   title: "انقر على زر البحث  ",
//                   subtitle: 'تأكد من أن الطابعة متصلة بنفس الشبكة واضغط على البحث مرة أخرى',
//                 );
//               }

//               return ListView.builder(
//                 itemCount: printerController.discoveredPrinters.length,
//                 itemBuilder: (context, index) {
//                   final printer = printerController.discoveredPrinters[index];
//                   return AnimatedContainer(
//                     duration: Duration(milliseconds: 300 + (index * 100)),
//                     curve: Curves.easeOutCubic,
//                     child: _buildEnhancedPrinterListItem(printer, true),
//                   );
//                 },
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSavedPrintersTab() {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         children: [
//           // Enhanced Header with Statistics
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: const Color(0xFFE2E8F0)),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.04),
//                   offset: const Offset(0, 2),
//                   blurRadius: 8,
//                 ),
//               ],
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Obx(() => Row(
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//                             ),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Icon(
//                             Icons.bookmark_rounded,
//                             size: 16,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'الطابعات المحفوظة',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 16,
//                                 color: Color(0xFF0F172A),
//                               ),
//                             ),
//                             Text(
//                               '${printerController.savedPrintersCount} طابعة محفوظة',
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: Color(0xFF64748B),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     )),
//                 OutlinedButton.icon(
//                   onPressed: () => _showClearAllDialog(),
//                   icon: const Icon(Icons.clear_all_rounded, size: 16),
//                   label: const Text('مسح الكل'),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: const Color(0xFFEF4444),
//                     side: const BorderSide(color: Color(0xFFEF4444)),
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 24),

//           // Enhanced Saved Printers List
//           Expanded(
//             child: Obx(() {
//               if (printerController.savedPrinters.isEmpty) {
//                 return _buildEmptyState(
//                   icon: Icons.bookmark_border_rounded,
//                   title: 'لا توجد طابعات محفوظة',
//                   subtitle: 'ابحث عن طابعات واحفظها لاستخدامها لاحقاً',
//                 );
//               }

//               return ListView.builder(
//                 itemCount: printerController.savedPrinters.length,
//                 itemBuilder: (context, index) {
//                   final printer = printerController.savedPrinters[index];
//                   return AnimatedContainer(
//                     duration: Duration(milliseconds: 300 + (index * 100)),
//                     curve: Curves.easeOutCubic,
//                     child: _buildEnhancedPrinterListItem(printer, false),
//                   );
//                 },
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//   }) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF8FAFC),
//               shape: BoxShape.circle,
//               border: Border.all(color: const Color(0xFFE2E8F0), width: 5),
//             ),
//             child: Icon(icon, size: 48, color: const Color(0xFF94A3B8)),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF0F172A),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             subtitle,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Color(0xFF64748B),
//               height: 1.5,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEnhancedPrinterListItem(PrinterModel printer, bool isFromScan) {
//     final isSelected = printerController.selectedPrinter.value == printer;
//     final isConnected = printer.isConnected;
//     final statusColor = isConnected ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
//           width: isSelected ? 2 : 1,
//         ),
//         boxShadow: isSelected
//             ? [
//                 BoxShadow(
//                   color: const Color(0xFF6366F1).withOpacity(0.15),
//                   offset: const Offset(0, 4),
//                   blurRadius: 16,
//                 ),
//               ]
//             : [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.04),
//                   offset: const Offset(0, 2),
//                   blurRadius: 8,
//                 ),
//               ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(16),
//           onTap: () {
//             printerController.selectPrinter(printer);
//             Get.back();
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Row(
//               children: [
//                 // Enhanced Printer Icon
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: isSelected
//                           ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
//                           : [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: isSelected ? Colors.transparent : statusColor.withOpacity(0.2),
//                       width: 1,
//                     ),
//                   ),
//                   child: Icon(
//                     isConnected ? Icons.print_rounded : Icons.print_disabled_rounded,
//                     color: isSelected ? Colors.white : statusColor,
//                     size: 20,
//                   ),
//                 ),

//                 const SizedBox(width: 16),

//                 // Enhanced Printer Info
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               printer.name,
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
//                                 color: const Color(0xFF0F172A),
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           if (isSelected)
//                             Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                               decoration: BoxDecoration(
//                                 gradient: const LinearGradient(
//                                   colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//                                 ),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: const Text(
//                                 'مختارة',
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '${printer.ipAddress}:${printer.port}',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Color(0xFF64748B),
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Row(
//                         children: [
//                           Text(
//                             'MAC: ${printer.macAddress}',
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Color(0xFF94A3B8),
//                             ),
//                           ),
//                           const Spacer(),
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                             decoration: BoxDecoration(
//                               color: statusColor.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               isConnected ? 'متصلة' : 'غير متصلة',
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 color: statusColor,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       if (printer.lastConnected != null) ...[
//                         const SizedBox(height: 4),
//                         Text(
//                           'آخر اتصال: ${_formatDateTime(printer.lastConnected!)}',
//                           style: const TextStyle(
//                             fontSize: 11,
//                             color: Color(0xFF94A3B8),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),

//                 // Enhanced Action Button
//                 if (!isFromScan)
//                   Container(
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFEF4444).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: IconButton(
//                       icon: const Icon(Icons.delete_rounded, size: 18),
//                       color: const Color(0xFFEF4444),
//                       onPressed: () => _showDeleteDialog(printer),
//                     ),
//                   ),
//                 if (isFromScan)
//                   TextButton(
//                     onPressed: () {
//                       Get.to(() => const UniversalPrinter());
//                     },
//                     child: const Text(
//                       'اختبار',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showClearAllDialog() {
//     Get.dialog(
//       Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFEF4444).withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.clear_all_rounded,
//                   size: 32,
//                   color: Color(0xFFEF4444),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'مسح البيانات',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 20,
//                   color: Color(0xFF0F172A),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'هل أنت متأكد من مسح جميع الطابعات المحفوظة؟',
//                 style: TextStyle(
//                   color: Color(0xFF64748B),
//                   fontSize: 14,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Get.back(),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text('إلغاء'),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         printerController.clearAllData();
//                         Get.back();
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFEF4444),
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text('نعم'),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showDeleteDialog(PrinterModel printer) {
//     Get.dialog(
//       Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFEF4444).withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.delete_rounded,
//                   size: 32,
//                   color: Color(0xFFEF4444),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'حذف الطابعة',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 20,
//                   color: Color(0xFF0F172A),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'هل أنت متأكد من حذف هذه الطابعة؟',
//                 style: TextStyle(
//                   color: Color(0xFF64748B),
//                   fontSize: 14,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Get.back(),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text('إلغاء'),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         printerController.removeSavedPrinter(printer);
//                         Get.back();
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFEF4444),
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text('نعم'),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _startScan() {
//     final networkInfo = networkController.networkInfo.value;
//     if (networkInfo.ipAddress != null) {
//       printerController.scanForPrinters(networkInfo.ipAddress!);
//     } else {
//       Get.snackbar(
//         'خطأ',
//         'لا يمكن تحديد نطاق الشبكة. تأكد من الاتصال بالشبكة.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: const Color(0xFFEF4444),
//         colorText: Colors.white,
//         icon: const Icon(Icons.error_rounded, color: Colors.white),
//         borderRadius: 12,
//         margin: const EdgeInsets.all(16),
//       );
//     }
//   }

//   String _formatDateTime(DateTime dateTime) {
//     final now = DateTime.now();
//     final difference = now.difference(dateTime);

//     if (difference.inMinutes < 1) {
//       return 'الآن';
//     } else if (difference.inMinutes < 60) {
//       return '${difference.inMinutes} دقيقة';
//     } else if (difference.inHours < 24) {
//       return '${difference.inHours} ساعة';
//     } else {
//       return '${difference.inDays} يوم';
//     }
//   }
// }

import 'package:auth_app/pages/configration/models/printer_model.dart';
import 'package:auth_app/pages/configration/controllers/network_controller.dart';
import 'package:auth_app/pages/configration/controllers/printer_controller.dart';
import 'package:auth_app/widgets/printer_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Enhanced PrinterSettingsDialog with improved design
class PrinterSettingsDialog extends StatefulWidget {
  @override
  _PrinterSettingsDialogState createState() => _PrinterSettingsDialogState();
}

class _PrinterSettingsDialogState extends State<PrinterSettingsDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  final PrinterController printerController = Get.find<PrinterController>();
  final NetworkController networkController = Get.find<NetworkController>();

  // Helper للتحقق من حجم الشاشة
  bool get isMobile => Get.width < 600;
  bool get isSmallMobile => Get.width < 400;
  double get dialogPadding => isSmallMobile
      ? 8
      : isMobile
          ? 12
          : 16;
  double get fontSize => isSmallMobile ? 12 : 14;
  double get titleSize => isSmallMobile ? 16 : 18;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _slideController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 8),
              blurRadius: 32,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // مهم جداً لمنع overflow
          children: [
            // Enhanced Header - responsive
            _buildResponsiveHeader(),

            // Enhanced Modern Tabs - responsive
            _buildResponsiveTabs(),

            // Tab Content - flexible height
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: isSmallMobile ? 200 : 250,
                  maxHeight: Get.height * 0.6, // الحد الأقصى للارتفاع
                ),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildScanTab(),
                    _buildSavedPrintersTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveHeader() {
    return Container(
      padding: EdgeInsets.all(dialogPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallMobile ? 8 : 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Icon(
              Icons.settings_rounded,
              size: isSmallMobile ? 20 : 24,
              color: Colors.white,
            ),
          ),
          SizedBox(width: isSmallMobile ? 8 : 15),
          Expanded(
            child: Text(
              'إعدادات الطابعة',
              style: TextStyle(
                fontSize: isSmallMobile ? 16 : 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: IconButton(
              onPressed: () => Get.back(),
              icon: Icon(
                Icons.close_rounded,
                size: isSmallMobile ? 18 : 20,
              ),
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: dialogPadding),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: const Color(0xFF6366F1),
        unselectedLabelColor: const Color(0xFF64748B),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: isSmallMobile ? 11 : 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: isSmallMobile ? 11 : 14,
        ),
        tabs: [
          Tab(
            icon: Icon(Icons.search_rounded, size: isSmallMobile ? 16 : 18),
            text: isSmallMobile ? 'البحث' : 'البحث عن طابعات',
          ),
          Tab(
            icon: Icon(Icons.bookmark_rounded, size: isSmallMobile ? 16 : 18),
            text: isSmallMobile ? 'المحفوظة' : 'الطابعات المحفوظة',
          ),
        ],
      ),
    );
  }

  // Widget _buildScanTab() {
  //   return Padding(
  //     padding: EdgeInsets.all(dialogPadding),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         // Enhanced Scan Button - responsive
  //         SizedBox(
  //           width: double.infinity,
  //           child: Obx(() => ElevatedButton.icon(
  //                 onPressed: printerController.isScanning.value ? null : () => _startScan(),
  //                 icon: printerController.isScanning.value
  //                     ? SizedBox(
  //                         width: isSmallMobile ? 16 : 20,
  //                         height: isSmallMobile ? 16 : 20,
  //                         child: const CircularProgressIndicator(
  //                           strokeWidth: 2,
  //                           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
  //                         ),
  //                       )
  //                     : Icon(Icons.search_rounded, size: isSmallMobile ? 18 : 20),
  //                 label: Text(
  //                   printerController.isScanning.value ? 'جاري البحث...' : 'البحث عن طابعات',
  //                   style: TextStyle(
  //                     fontSize: fontSize,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: const Color(0xFF6366F1),
  //                   foregroundColor: Colors.white,
  //                   padding: EdgeInsets.symmetric(vertical: isSmallMobile ? 12 : 16),
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(16),
  //                   ),
  //                   elevation: 0,
  //                 ),
  //               )),
  //         ),

  //         SizedBox(height: isSmallMobile ? 16 : 24),

  //         // Enhanced Scan Progress - responsive
  //         Obx(() {
  //           if (printerController.isScanning.value) {
  //             return Container(
  //               padding: EdgeInsets.all(isSmallMobile ? 8 : 10),
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(16),
  //                 border: Border.all(color: const Color(0xFFE2E8F0)),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withOpacity(0.04),
  //                     offset: const Offset(0, 2),
  //                     blurRadius: 8,
  //                   ),
  //                 ],
  //               ),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Container(
  //                         padding: EdgeInsets.all(isSmallMobile ? 6 : 8),
  //                         decoration: BoxDecoration(
  //                           color: const Color(0xFF6366F1).withOpacity(0.1),
  //                           borderRadius: BorderRadius.circular(8),
  //                         ),
  //                         child: Icon(
  //                           Icons.radar_rounded,
  //                           size: isSmallMobile ? 14 : 16,
  //                           color: const Color(0xFF6366F1),
  //                         ),
  //                       ),
  //                       SizedBox(width: isSmallMobile ? 8 : 12),
  //                       Expanded(
  //                         child: Text(
  //                           'جاري البحث في الشبكة',
  //                           style: TextStyle(
  //                             fontSize: fontSize,
  //                             fontWeight: FontWeight.w600,
  //                             color: const Color(0xFF0F172A),
  //                           ),
  //                           overflow: TextOverflow.ellipsis,
  //                           maxLines: 1,
  //                         ),
  //                       ),
  //                       Text(
  //                         '${(printerController.scanProgress.value * 100).toInt()}%',
  //                         style: TextStyle(
  //                           fontSize: isSmallMobile ? 10 : 12,
  //                           fontWeight: FontWeight.w600,
  //                           color: const Color(0xFF6366F1),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: isSmallMobile ? 12 : 16),
  //                   LinearProgressIndicator(
  //                     value: printerController.scanProgress.value,
  //                     backgroundColor: const Color(0xFFF1F5F9),
  //                     color: const Color(0xFF6366F1),
  //                     minHeight: isSmallMobile ? 6 : 8,
  //                     borderRadius: BorderRadius.circular(4),
  //                   ),
  //                   SizedBox(height: isSmallMobile ? 8 : 12),
  //                   Text(
  //                     printerController.scanStatus.value,
  //                     style: TextStyle(
  //                       color: const Color(0xFF64748B),
  //                       fontSize: isSmallMobile ? 11 : 14,
  //                       fontWeight: FontWeight.w500,
  //                     ),
  //                     textAlign: TextAlign.center,
  //                     maxLines: 2,
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                 ],
  //               ),
  //             );
  //           }
  //           return const SizedBox.shrink();
  //         }),

  //         SizedBox(height: isSmallMobile ? 12 : 16),

  //         // Enhanced Discovered Printers List - responsive
  //         Expanded(
  //           child: Obx(() {
  //             if (printerController.discoveredPrinters.isEmpty) {
  //               return _buildEmptyState(
  //                 icon: Icons.print_disabled_rounded,
  //                 title: "انقر على زر البحث",
  //                 subtitle: 'تأكد من أن الطابعة متصلة بنفس الشبكة',
  //               );
  //             }

  //             return ListView.builder(
  //               itemCount: printerController.discoveredPrinters.length,
  //               itemBuilder: (context, index) {
  //                 final printer = printerController.discoveredPrinters[index];
  //                 return _buildResponsivePrinterListItem(printer, true);
  //               },
  //             );
  //           }),
  //         ),
  //       ],
  //     ),
  //   );
  // }

// في ملف printer_setting.dart - تعديل دالة _buildScanTab
  Widget _buildScanTab() {
    return Padding(
      padding: EdgeInsets.all(dialogPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // زر البحث
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton.icon(
                  onPressed: printerController.isScanning.value ? null : () => _startScan(),
                  icon: printerController.isScanning.value
                      ? SizedBox(
                          width: isSmallMobile ? 16 : 20,
                          height: isSmallMobile ? 16 : 20,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(Icons.search_rounded, size: isSmallMobile ? 18 : 20),
                  label: Text(
                    printerController.isScanning.value ? 'جاري البحث...' : 'البحث عن طابعات',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isSmallMobile ? 12 : 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                )),
          ),

          SizedBox(height: isSmallMobile ? 16 : 24),

          // شريط التقدم - مع تحسين العرض
          Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 200), // تسريع الانيميشن
                height: printerController.isScanning.value ||
                        printerController.scanStatus.value.isNotEmpty
                    ? null
                    : 0,
                child: printerController.isScanning.value ||
                        printerController.scanStatus.value.isNotEmpty
                    ? Container(
                        padding: EdgeInsets.all(isSmallMobile ? 8 : 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(isSmallMobile ? 6 : 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.radar_rounded,
                                    size: isSmallMobile ? 14 : 16,
                                    color: const Color(0xFF6366F1),
                                  ),
                                ),
                                SizedBox(width: isSmallMobile ? 8 : 12),
                                Expanded(
                                  child: Text(
                                    'جاري البحث في الشبكة',
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F172A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                Text(
                                  '${(printerController.scanProgress.value * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: isSmallMobile ? 10 : 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF6366F1),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmallMobile ? 12 : 16),
                            LinearProgressIndicator(
                              value: printerController.scanProgress.value,
                              backgroundColor: const Color(0xFFF1F5F9),
                              color: const Color(0xFF6366F1),
                              minHeight: isSmallMobile ? 6 : 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            SizedBox(height: isSmallMobile ? 8 : 12),
                            Text(
                              printerController.scanStatus.value,
                              style: TextStyle(
                                color: const Color(0xFF64748B),
                                fontSize: isSmallMobile ? 11 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              )),

          SizedBox(height: isSmallMobile ? 8 : 12),

          // قائمة النتائج مع Scrollbar محسن
          Expanded(
            child: Obx(() {
              if (printerController.discoveredPrinters.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.print_disabled_rounded,
                  title: "انقر على زر البحث",
                  subtitle: 'تأكد من أن الطابعة متصلة بنفس الشبكة',
                );
              }

              // Scrollbar محسن مع ظهور فوري
              return Scrollbar(
                thumbVisibility: true, // إظهار دائم
                thickness: isSmallMobile ? 4 : 6,
                radius: Radius.circular(isSmallMobile ? 2 : 3),
                trackVisibility: true, // إظهار المسار أيضاً
                interactive: true, // تفاعل مباشر
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(), // تحسين الفيزياء
                  padding: EdgeInsets.only(right: isSmallMobile ? 8 : 12), // مساحة للـ scrollbar
                  itemCount: printerController.discoveredPrinters.length,
                  itemBuilder: (context, index) {
                    final printer = printerController.discoveredPrinters[index];
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 150 + (index * 50)), // تسريع الانيميشن
                      curve: Curves.easeOut, // تغيير منحنى الانيميشن
                      child: _buildResponsivePrinterListItem(printer, true),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPrintersTab() {
    return Padding(
      padding: EdgeInsets.all(dialogPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Enhanced Header - responsive
          _buildSavedPrintersHeader(),

          SizedBox(height: isSmallMobile ? 16 : 24),

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
                  return _buildResponsivePrinterListItem(printer, false);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPrintersHeader() {
    return Container(
      padding: EdgeInsets.all(isSmallMobile ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: isSmallMobile ? _buildCompactHeader() : _buildNormalHeader(),
    );
  }

  Widget _buildCompactHeader() {
    return Column(
      children: [
        Obx(() => Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.bookmark_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الطابعات المحفوظة',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: fontSize,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${printerController.savedPrintersCount} طابعة',
                        style: TextStyle(
                          fontSize: isSmallMobile ? 10 : 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showClearAllDialog(),
            icon: const Icon(Icons.clear_all_rounded, size: 14),
            label: const Text('مسح الكل'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFEF4444)),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: isSmallMobile ? 6 : 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNormalHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(() => Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bookmark_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الطابعات المحفوظة',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: titleSize,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '${printerController.savedPrintersCount} طابعة محفوظة',
                      style: TextStyle(
                        fontSize: fontSize,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            )),
        OutlinedButton.icon(
          onPressed: () => _showClearAllDialog(),
          icon: const Icon(Icons.clear_all_rounded, size: 16),
          label: const Text('مسح الكل'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFEF4444),
            side: const BorderSide(color: Color(0xFFEF4444)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Padding(
              padding: EdgeInsets.all(isSmallMobile ? 16 : 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallMobile ? 16 : 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: isSmallMobile ? 3 : 5,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: isSmallMobile ? 32 : 48,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  SizedBox(height: isSmallMobile ? 12 : 20),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallMobile ? 6 : 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: const Color(0xFF64748B),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: isSmallMobile ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponsivePrinterListItem(PrinterModel printer, bool isFromScan) {
    final isSelected = printerController.selectedPrinter.value == printer;
    final isConnected = printer.isConnected;
    final statusColor = isConnected ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

    return Container(
      margin: EdgeInsets.only(bottom: isSmallMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.15),
                  offset: const Offset(0, 4),
                  blurRadius: 16,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            printerController.selectPrinter(printer);
            Get.back();
          },
          child: Padding(
            padding: EdgeInsets.all(isSmallMobile ? 12 : 20),
            child: Row(
              children: [
                // Enhanced Printer Icon - responsive
                Container(
                  padding: EdgeInsets.all(isSmallMobile ? 8 : 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSelected
                          ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                          : [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : statusColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    isConnected ? Icons.print_rounded : Icons.print_disabled_rounded,
                    color: isSelected ? Colors.white : statusColor,
                    size: isSmallMobile ? 16 : 20,
                  ),
                ),

                SizedBox(width: isSmallMobile ? 8 : 16),

                // Enhanced Printer Info - responsive
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
                                fontSize: fontSize,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected && !isSmallMobile)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'مختارة',
                                style: TextStyle(
                                  fontSize: isSmallMobile ? 8 : 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: isSmallMobile ? 2 : 4),
                      Text(
                        '${printer.ipAddress}:${printer.port}',
                        style: TextStyle(
                          fontSize: isSmallMobile ? 11 : 14,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isSmallMobile) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'MAC: ${printer.macAddress}',
                                style: TextStyle(
                                  fontSize: isSmallMobile ? 9 : 12,
                                  color: const Color(0xFF94A3B8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isConnected ? 'متصلة' : 'غير متصلة',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Enhanced Action Button - responsive
                if (!isFromScan)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.delete_rounded,
                        size: isSmallMobile ? 16 : 18,
                      ),
                      color: const Color(0xFFEF4444),
                      onPressed: () => _showDeleteDialog(printer),
                      constraints: BoxConstraints(
                        minWidth: isSmallMobile ? 32 : 40,
                        minHeight: isSmallMobile ? 32 : 40,
                      ),
                    ),
                  ),
                if (isFromScan)
                  TextButton(
                    onPressed: () {
                      Get.to(() => const UniversalPrinter());
                    },
                    child: Text(
                      'اختبار',
                      style: TextStyle(
                        fontSize: isSmallMobile ? 10 : 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showClearAllDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isSmallMobile ? Get.width * 0.9 : 400,
          ),
          padding: EdgeInsets.all(isSmallMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.clear_all_rounded,
                  size: isSmallMobile ? 24 : 32,
                  color: const Color(0xFFEF4444),
                ),
              ),
              SizedBox(height: isSmallMobile ? 12 : 16),
              Text(
                'مسح البيانات',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: isSmallMobile ? 16 : 20,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: isSmallMobile ? 6 : 8),
              Text(
                'هل أنت متأكد من مسح جميع الطابعات المحفوظة؟',
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: fontSize,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallMobile ? 16 : 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: isSmallMobile ? 10 : 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(fontSize: fontSize),
                      ),
                    ),
                  ),
                  SizedBox(width: isSmallMobile ? 8 : 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        printerController.clearAllData();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: isSmallMobile ? 10 : 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'نعم',
                        style: TextStyle(fontSize: fontSize),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(PrinterModel printer) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isSmallMobile ? Get.width * 0.9 : 400,
          ),
          padding: EdgeInsets.all(isSmallMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_rounded,
                  size: isSmallMobile ? 24 : 32,
                  color: const Color(0xFFEF4444),
                ),
              ),
              SizedBox(height: isSmallMobile ? 12 : 16),
              Text(
                'حذف الطابعة',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: isSmallMobile ? 16 : 20,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: isSmallMobile ? 6 : 8),
              Text(
                'هل أنت متأكد من حذف هذه الطابعة؟',
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: fontSize,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallMobile ? 16 : 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: isSmallMobile ? 10 : 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(fontSize: fontSize),
                      ),
                    ),
                  ),
                  SizedBox(width: isSmallMobile ? 8 : 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        printerController.removeSavedPrinter(printer);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: isSmallMobile ? 10 : 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'نعم',
                        style: TextStyle(fontSize: fontSize),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void _startScan() {
  //   final networkInfo = networkController.networkInfo.value;
  //   if (networkInfo.ipAddress != null) {
  //     printerController.scanForPrinters(networkInfo.ipAddress!);
  //   } else {
  //     Get.snackbar(
  //       'خطأ',
  //       'لا يمكن تحديد نطاق الشبكة. تأكد من الاتصال بالشبكة.',
  //       snackPosition: SnackPosition.BOTTOM,
  //       backgroundColor: const Color(0xFFEF4444),
  //       colorText: Colors.white,
  //       icon: const Icon(Icons.error_rounded, color: Colors.white),
  //       borderRadius: 12,
  //       margin: const EdgeInsets.all(16),
  //     );
  //   }
  // }

// تعديل دالة _startScan لاستجابة أسرع
  void _startScan() async {
    final networkInfo = networkController.networkInfo.value;

    if (networkInfo.ipAddress == null) {
      Get.snackbar(
        'خطأ',
        'لا يمكن تحديد نطاق الشبكة. تأكد من الاتصال بالشبكة.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        icon: const Icon(Icons.error_rounded, color: Colors.white),
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // مسح النتائج السابقة فوراً
    printerController.discoveredPrinters.clear();

    // تعيين حالة البحث فوراً
    printerController.scanProgress.value = 0.0;
    printerController.scanStatus.value = 'بدء البحث...';

    // التأكد من تحديث الواجهة
    await Future.delayed(const Duration(milliseconds: 50));

    // بدء البحث الفعلي
    printerController.scanForPrinters(networkInfo.ipAddress!);
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
