import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/controllers/transfer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// =============================================================================
// شريط الإحصائيات
// =============================================================================
class TransferStatsBar extends StatelessWidget {
  final TransferController controller;

  const TransferStatsBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = controller.getTransferStats();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF0D47A1),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'الإجمالي',
                stats['total'].toString(),
                Icons.all_inbox,
                Colors.white,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'قيد التحضير',
                stats['pending'].toString(),
                Icons.pending_actions,
                Colors.orange[200]!,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'تم الإرسال',
                stats['sent'].toString(),
                Icons.send,
                Colors.blue[200]!,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                'مكتمل',
                stats['posted'].toString(),
                Icons.check_circle,
                Colors.green[200]!,
              ),
            ),
          ],
        ),
      );
    });
  }

  /// بناء عنصر الإحصائية الواحد
  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// =============================================================================
// شريط البحث
// =============================================================================
class TransferSearchBar extends StatelessWidget {
  final TransferController controller;

  const TransferSearchBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.updateSearch,
        decoration: InputDecoration(
          hintText: 'البحث في التحويلات...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF2196F3)),
          suffixIcon: Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.searchController.clear();
                  controller.updateSearch('');
                },
              );
            }
            return const SizedBox.shrink();
          }),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2196F3)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}






// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/controllers/transfer_controller.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/models/transfer_stock.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/screens/widgets/transfer_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// // =============================================================================
// // شريط الإحصائيات
// // =============================================================================
// class TransferStatsBar extends StatelessWidget {
//   final TransferController controller;

//   const TransferStatsBar({
//     super.key,
//     required this.controller,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final stats = controller.getTransferStats();

//       return Container(
//         padding: const EdgeInsets.all(16),
//         decoration: const BoxDecoration(
//           color: Color(0xFF0D47A1),
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(20),
//             bottomRight: Radius.circular(20),
//           ),
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: _buildStatItem(
//                 'الإجمالي',
//                 stats['total'].toString(),
//                 Icons.all_inbox,
//                 Colors.white,
//               ),
//             ),
//             Expanded(
//               child: _buildStatItem(
//                 'قيد التحضير',
//                 stats['pending'].toString(),
//                 Icons.pending_actions,
//                 Colors.orange[200]!,
//               ),
//             ),
//             Expanded(
//               child: _buildStatItem(
//                 'تم الإرسال',
//                 stats['sent'].toString(),
//                 Icons.send,
//                 Colors.blue[200]!,
//               ),
//             ),
//             Expanded(
//               child: _buildStatItem(
//                 'مكتمل',
//                 stats['posted'].toString(),
//                 Icons.check_circle,
//                 Colors.green[200]!,
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildStatItem(String title, String value, IconData icon, Color color) {
//     return Column(
//       children: [
//         Icon(icon, color: color, size: 24),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.white.withOpacity(0.8),
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }
// }

// // =============================================================================
// // شريط البحث
// // =============================================================================
// class TransferSearchBar extends StatelessWidget {
//   final TransferController controller;

//   const TransferSearchBar({
//     super.key,
//     required this.controller,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: TextField(
//         controller: controller.searchController,
//         onChanged: controller.updateSearch,
//         decoration: InputDecoration(
//           hintText: 'البحث في التحويلات...',
//           prefixIcon: const Icon(Icons.search, color: Color(0xFF2196F3)),
//           suffixIcon: Obx(() {
//             if (controller.searchQuery.value.isNotEmpty) {
//               return IconButton(
//                 icon: const Icon(Icons.clear),
//                 onPressed: () {
//                   controller.searchController.clear();
//                   controller.updateSearch('');
//                 },
//               );
//             }
//             return const SizedBox.shrink();
//           }),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey[300]!),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Color(0xFF2196F3)),
//           ),
//           filled: true,
//           fillColor: Colors.white,
//         ),
//       ),
//     );
//   }
// }

// // =============================================================================
// // بطاقة التحويل
// // =============================================================================
// class TransferCard extends StatelessWidget {
//   final TransferModel transfer;
//   final TransferController controller;

//   const TransferCard({
//     super.key,
//     required this.transfer,
//     required this.controller,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         onTap: () => controller.navigateToInvoiceWithDetails(transfer),
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildHeader(),
//               const Divider(height: 20),
//               _buildWarehouseInfo(),
//               const SizedBox(height: 12),
//               _buildCreatorInfo(),
//               const SizedBox(height: 12),
//               _buildActionButtons(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'رقم المرجع: ${transfer.ref ?? 'غير محدد'}',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2196F3),
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'رقم التحويل: ${transfer.id}',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                 ),
//               ),
//               Text(
//                 'تاريخ الإنشاء: ${transfer.formattedCreateDate}',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Column(
//           children: [
//             _buildStatusChip(),
//             const SizedBox(height: 8),
//             TextButton.icon(
//               onPressed: () => controller.navigateToProductManagement(transfer),
//               icon: const Icon(Icons.inventory_2, size: 16),
//               label: const Text('إدارة الأصناف', style: TextStyle(fontSize: 12)),
//               style: TextButton.styleFrom(
//                 foregroundColor: Colors.blue[700],
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildStatusChip() {
//     Color backgroundColor;
//     Color textColor;

//     if (transfer.sapPost) {
//       backgroundColor = Colors.green[100]!;
//       textColor = Colors.green[800]!;
//     } else if (transfer.aproveRecive) {
//       backgroundColor = Colors.blue[100]!;
//       textColor = Colors.blue[800]!;
//     } else if (transfer.isSended) {
//       backgroundColor = Colors.orange[100]!;
//       textColor = Colors.orange[800]!;
//     } else {
//       backgroundColor = Colors.grey[100]!;
//       textColor = Colors.grey[800]!;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         transfer.statusText,
//         style: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w500,
//           color: textColor,
//         ),
//       ),
//     );
//   }

//   Widget _buildWarehouseInfo() {
//     return Row(
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'من:',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                 ),
//               ),
//               Text(
//                 transfer.whsNameFrom.trim(),
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//         const Icon(
//           Icons.arrow_forward,
//           color: Color(0xFF2196F3),
//           size: 20,
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'إلى:',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                 ),
//               ),
//               Text(
//                 transfer.whsNameTo.trim(),
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCreatorInfo() {
//     return Row(
//       children: [
//         Icon(
//           Icons.person,
//           size: 16,
//           color: Colors.grey[600],
//         ),
//         const SizedBox(width: 4),
//         Text(
//           'المنشئ: ${transfer.creatby.trim()}',
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[600],
//           ),
//         ),
//         const Spacer(),
//         Row(
//           children: [
//             Icon(
//               Icons.receipt_long,
//               size: 16,
//               color: Colors.grey[600],
//             ),
//             const SizedBox(width: 4),
//             Text(
//               'عرض الفاتورة',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey[600],
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButtons() {
//     List<Widget> buttons = [];

//     if (controller.canSendTransfer(transfer)) {
//       buttons.add(
//         Obx(() => ElevatedButton.icon(
//               onPressed: controller.isLoading.value
//                   ? null
//                   : () => TransferDialogs.confirmAction(
//                         'إرسال التحويل',
//                         'هل تريد إرسال هذا التحويل؟',
//                         () => controller.sendTransfer(transfer.id),
//                       ),
//               icon: const Icon(Icons.send, size: 16),
//               label: const Text('إرسال'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               ),
//             )),
//       );
//     }

//     if (controller.canReceiveTransfer(transfer)) {
//       buttons.add(
//         Obx(() => ElevatedButton.icon(
//               onPressed: controller.isLoading.value
//                   ? null
//                   : () => TransferDialogs.confirmAction(
//                         'استلام التحويل',
//                         'هل تريد استلام هذا التحويل؟',
//                         () => controller.receiveTransfer(transfer.id),
//                       ),
//               icon: const Icon(Icons.download, size: 16),
//               label: const Text('استلام'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               ),
//             )),
//       );
//     }

//     if (controller.canPostToSAP(transfer)) {
//       buttons.add(
//         Obx(() => ElevatedButton.icon(
//               onPressed: controller.isLoading.value
//                   ? null
//                   : () => TransferDialogs.confirmAction(
//                         'ترحيل إلى SAP',
//                         'هل تريد ترحيل هذا التحويل إلى SAP؟',
//                         () => controller.postToSAP(transfer.id),
//                       ),
//               icon: const Icon(Icons.cloud_upload, size: 16),
//               label: const Text('ترحيل'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               ),
//             )),
//       );
//     }

//     if (buttons.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return Wrap(
//       spacing: 8,
//       runSpacing: 4,
//       children: buttons,
//     );
//   }
// }
