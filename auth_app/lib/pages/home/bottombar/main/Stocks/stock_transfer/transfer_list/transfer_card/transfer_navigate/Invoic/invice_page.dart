import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/Invoic/controller/invoice_Controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/functions/status_request.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/models/transfer_stock_model.dart';
import 'widgets/invoice_content.dart';

class InvoicePage extends StatelessWidget {
  const InvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final InvoiceController controller = Get.find<InvoiceController>();
    controller.resetLoadingState();

    // الحصول على البيانات من arguments
    final TransferModel? transfer = Get.arguments?['transfer'];
    final int? transferId = Get.arguments?['transferId'];

    if (transfer == null || transferId == null) {
      return _buildErrorScreen();
    }

    // تحميل تفاصيل التحويل
    controller.loadTransferDetails(transferId);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        if (controller.statusRequest.value == StatusRequest.loading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2196F3)),
          );
        }

        if (controller.statusRequest.value == StatusRequest.failure) {
          return _buildErrorRetryScreen(controller, transferId);
        }

        if (controller.transferDetails.value == null) {
          return const Center(
            child: Text('لا توجد بيانات للعرض', style: TextStyle(fontSize: 18)),
          );
        }

        return SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: InvoiceContent(header: controller.transferDetails.value!.header),
          ),
        );
      }),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text('خطأ'), backgroundColor: Colors.red),
      body: const Center(
        child: Text('لم يتم العثور على بيانات التحويل', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildErrorRetryScreen(InvoiceController controller, int transferId) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'فشل في تحميل تفاصيل التحويل',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.loadTransferDetails(transferId),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}









// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/Invoic/controller/invoice_Controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:auth_app/functions/status_request.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/models/transfer_stock_model.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/models/details_model.dart';

// class InvoicePage extends StatelessWidget {
//   const InvoicePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final InvoiceController controller = Get.find<InvoiceController>();
//     controller.resetLoadingState();

//     // الحصول على البيانات من arguments
//     final TransferModel? transfer = Get.arguments?['transfer'];
//     final int? transferId = Get.arguments?['transferId'];

//     if (transfer == null || transferId == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('خطأ'),
//           backgroundColor: Colors.red,
//         ),
//         body: const Center(
//           child: Text(
//             'لم يتم العثور على بيانات التحويل',
//             style: TextStyle(fontSize: 18),
//           ),
//         ),
//       );
//     }

//     // تحميل تفاصيل التحويل
//     controller.loadTransferDetails(transferId);

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       // appBar: AppBar(
//       //   title: const Text(
//       //     'تفاصيل التحويل',
//       //     style: TextStyle(
//       //       fontSize: 20,
//       //       fontWeight: FontWeight.bold,
//       //       color: Colors.white,
//       //     ),
//       //   ),
//       //   backgroundColor: const Color(0xFF2196F3),
//       //   elevation: 0,
//       //   actions: [
//       //     IconButton(
//       //       icon: const Icon(Icons.refresh, color: Colors.white),
//       //       onPressed: () => controller.loadTransferDetails(transferId),
//       //     ),
//       //   ],
//       // ),
//       body: Obx(() {
//         if (controller.statusRequest.value == StatusRequest.loading) {
//           return const Center(
//             child: CircularProgressIndicator(
//               color: Color(0xFF2196F3),
//             ),
//           );
//         }

//         if (controller.statusRequest.value == StatusRequest.failure) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.error_outline,
//                   size: 80,
//                   color: Colors.grey[400],
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'فشل في تحميل تفاصيل التحويل',
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.grey[600],
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () => controller.loadTransferDetails(transferId),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF2196F3),
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text('إعادة المحاولة'),
//                 ),
//               ],
//             ),
//           );
//         }

//         if (controller.transferDetails.value == null) {
//           return const Center(
//             child: Text(
//               'لا توجد بيانات للعرض',
//               style: TextStyle(fontSize: 18),
//             ),
//           );
//         }

//         final transferDetails = controller.transferDetails.value!;

//         return SingleChildScrollView(
//           child: Container(
//             color: Colors.white,
//             child: Column(
//               children: [
//                 // محتوى الفاتورة
//                 _buildInvoiceContent(transferDetails.header),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildInvoiceContent(TransferHeader header) {
//     return Container(
//       margin: const EdgeInsets.all(20),
//       padding: const EdgeInsets.all(30),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border.all(color: Colors.grey[300]!),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // رأس الفاتورة مع حالة التحويل
//           _buildInvoiceHeader(header),

//           const SizedBox(height: 30),

//           // معلومات التحويل الأساسية
//           Row(
//             children: [
//               // من المخزن
//               Expanded(
//                 child: _buildInfoCard(
//                   title: 'من المخزن',
//                   content: header.whsNameFrom.trim(),
//                   icon: Icons.outbox,
//                   color: Colors.orange,
//                 ),
//               ),

//               const SizedBox(width: 15),

//               // سهم التحويل
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[50],
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Icon(
//                   Icons.arrow_forward,
//                   color: Colors.blue[600],
//                   size: 20,
//                 ),
//               ),

//               const SizedBox(width: 15),

//               // إلى المخزن
//               Expanded(
//                 child: _buildInfoCard(
//                   title: 'إلى المخزن',
//                   content: header.whsNameTo.trim(),
//                   icon: Icons.inbox,
//                   color: Colors.green,
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           // تاريخ المستند في كارد منفصل
//           _buildInfoCard(
//             title: 'تاريخ المستند',
//             content: _formatDate(header.createDate),
//             icon: Icons.calendar_today,
//             color: Colors.blue,
//             fullWidth: true,
//           ),

//           const SizedBox(height: 30),

//           // صف معلومات السائق
//           Row(
//             children: [
//               // اسم السائق
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'اسم السائق',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     TextFormField(
//                       initialValue: header.driverName?.trim() ?? '',
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: Colors.white,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(4),
//                           borderSide: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         contentPadding: const EdgeInsets.all(12),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(width: 20),

//               // رقم الجوال
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'رقم السائق',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     TextFormField(
//                       initialValue: header.driverMobil?.trim() ?? '',
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: Colors.white,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(4),
//                           borderSide: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         contentPadding: const EdgeInsets.all(12),
//                       ),
//                       keyboardType: TextInputType.phone,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 30),

//           // صف رقم الاستلام ومعلومات إضافية
//           Row(
//             children: [
//               // رقم الاستلام
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'رقم الاستلام',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[100],
//                         border: Border.all(color: Colors.grey[300]!),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         header.ref ?? '25105',
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(width: 20),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'رقم السيارة',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     TextFormField(
//                       initialValue: header.careNum?.trim() ?? '',
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: Colors.white,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(4),
//                           borderSide: BorderSide(color: Colors.grey[300]!),
//                         ),
//                         contentPadding: const EdgeInsets.all(12),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 30),

//           // زر عرض سجل التعديلات
//           // Center(
//           //   child: ElevatedButton.icon(
//           //     onPressed: () {
//           //       Get.to(() => const ProductManagementScreen(), arguments: {
//           //         'transferId': header.id,
//           //         'header': header,
//           //       });
//           //     },
//           //     icon: const Icon(Icons.edit_note, color: Colors.white),
//           //     label: const Text(
//           //       'عرض قائمة اصناف التحويل',
//           //       style: TextStyle(
//           //         fontSize: 16,
//           //         fontWeight: FontWeight.bold,
//           //         color: Colors.white,
//           //       ),
//           //     ),
//           //     style: ElevatedButton.styleFrom(
//           //       backgroundColor: const Color(0xFF2196F3),
//           //       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//           //       shape: RoundedRectangleBorder(
//           //         borderRadius: BorderRadius.circular(8),
//           //       ),
//           //     ),
//           //   ),
//           // ),

//           const SizedBox(height: 30),

//           // ملاحظات
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'ملاحظات',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               TextFormField(
//                 // controller: noteController, // تأكد من إنشاء TextEditingController
//                 maxLines: 5,
//                 minLines: 5,
//                 decoration: InputDecoration(
//                   hintText: 'أدخل الملاحظات هنا...',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(4),
//                     borderSide: BorderSide(color: Colors.grey[300]!),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(4),
//                     borderSide: BorderSide(color: Colors.grey[300]!),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(4),
//                     borderSide: const BorderSide(color: Colors.blue, width: 2),
//                   ),
//                   filled: true,
//                   fillColor: Colors.white,
//                   contentPadding: const EdgeInsets.all(12),
//                 ),
//                 style: const TextStyle(fontSize: 14),
//                 onChanged: (value) {
//                   // يمكنك إضافة منطق لحفظ التغييرات هنا
//                   // مثال: header.note = value;
//                 },
//                 validator: (value) {
//                   // يمكنك إضافة تحقق من صحة البيانات هنا إذا لزم الأمر
//                   return null;
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // رأس الفاتورة مع حالة التحويل المدمجة
//   Widget _buildInvoiceHeader(TransferHeader header) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.blue[50]!, Colors.white],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         border: Border.all(color: Colors.blue[200]!),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // عنوان مع رقم التحويل
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'فاتورة التحويل',
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF2196F3),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'رقم التحويل: ${header.id}',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//               // حالة التحويل الإجمالية
//               _buildOverallStatus(header),
//             ],
//           ),

//           const SizedBox(height: 20),

//           // مؤشرات الحالة المدمجة
//           Row(
//             children: [
//               _buildStatusIndicator(
//                 'إرسال',
//                 header.isSended,
//                 Icons.send,
//                 flex: 1,
//               ),
//               _buildStatusIndicator(
//                 'استلام',
//                 header.aproveRecive,
//                 Icons.download_done,
//                 flex: 1,
//               ),
//               _buildStatusIndicator(
//                 'ترحيل',
//                 header.sapPost,
//                 Icons.cloud_upload,
//                 flex: 1,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // مؤشر حالة صغير ومدمج
//   Widget _buildStatusIndicator(String title, bool isCompleted, IconData icon, {int flex = 1}) {
//     return Expanded(
//       flex: flex,
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 4),
//         padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//         decoration: BoxDecoration(
//           color: isCompleted ? Colors.green[100] : Colors.grey[100],
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: isCompleted ? Colors.green[300]! : Colors.grey[300]!,
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
//               size: 16,
//               color: isCompleted ? Colors.green[700] : Colors.grey[600],
//             ),
//             const SizedBox(width: 6),
//             Flexible(
//               child: Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                   color: isCompleted ? Colors.green[700] : Colors.grey[600],
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // حالة التحويل الإجمالية
//   Widget _buildOverallStatus(TransferHeader header) {
//     String statusText;
//     Color statusColor;
//     IconData statusIcon;

//     if (header.sapPost) {
//       statusText = 'مكتمل';
//       statusColor = Colors.green;
//       statusIcon = Icons.check_circle;
//     } else if (header.aproveRecive) {
//       statusText = 'مستلم';
//       statusColor = Colors.blue;
//       statusIcon = Icons.download_done;
//     } else if (header.isSended) {
//       statusText = 'مُرسل';
//       statusColor = Colors.orange;
//       statusIcon = Icons.send;
//     } else {
//       statusText = 'قيد التحضير';
//       statusColor = Colors.grey;
//       statusIcon = Icons.pending;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: statusColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: statusColor.withOpacity(0.3)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             statusIcon,
//             size: 18,
//             color: statusColor,
//           ),
//           const SizedBox(width: 6),
//           Text(
//             statusText,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: statusColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // كارد معلومات مُحسَّن
//   Widget _buildInfoCard({
//     required String title,
//     required String content,
//     required IconData icon,
//     required Color color,
//     bool fullWidth = false,
//   }) {
//     return Container(
//       width: fullWidth ? double.infinity : null,
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border.all(color: color.withOpacity(0.3)),
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // العنوان مع الأيقونة
//           Row(
//             children: [
//               Icon(
//                 icon,
//                 color: color,
//                 size: 16,
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 title,
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 8),

//           // المحتوى
//           Text(
//             content,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//             softWrap: true,
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(String? dateString) {
//     if (dateString == null || dateString.isEmpty) return '';

//     try {
//       DateTime dateTime = DateTime.parse(dateString);
//       return DateFormat('MM/dd/yyyy hh:mm:ss a').format(dateTime);
//     } catch (e) {
//       return dateString;
//     }
//   }
// }
