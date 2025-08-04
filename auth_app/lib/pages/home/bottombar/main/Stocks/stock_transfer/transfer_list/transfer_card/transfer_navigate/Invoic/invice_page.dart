import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/show_transfer_card/Invoic/invoice_Controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:auth_app/functions/status_request.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/models/transfer_stock_model.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/show_transfer_card/models/details_model.dart';

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
      return Scaffold(
        appBar: AppBar(
          title: const Text('خطأ'),
          backgroundColor: Colors.red,
        ),
        body: const Center(
          child: Text(
            'لم يتم العثور على بيانات التحويل',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    // تحميل تفاصيل التحويل
    controller.loadTransferDetails(transferId);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      // appBar: AppBar(
      //   title: const Text(
      //     'تفاصيل التحويل',
      //     style: TextStyle(
      //       fontSize: 20,
      //       fontWeight: FontWeight.bold,
      //       color: Colors.white,
      //     ),
      //   ),
      //   backgroundColor: const Color(0xFF2196F3),
      //   elevation: 0,
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.refresh, color: Colors.white),
      //       onPressed: () => controller.loadTransferDetails(transferId),
      //     ),
      //   ],
      // ),
      body: Obx(() {
        if (controller.statusRequest.value == StatusRequest.loading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF2196F3),
            ),
          );
        }

        if (controller.statusRequest.value == StatusRequest.failure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'فشل في تحميل تفاصيل التحويل',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
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

        if (controller.transferDetails.value == null) {
          return const Center(
            child: Text(
              'لا توجد بيانات للعرض',
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        final transferDetails = controller.transferDetails.value!;

        return SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                // محتوى الفاتورة
                _buildInvoiceContent(transferDetails.header),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInvoiceContent(TransferHeader header) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس الفاتورة مع حالة التحويل
          _buildInvoiceHeader(header),

          const SizedBox(height: 30),

          // معلومات التحويل الأساسية
          Row(
            children: [
              // من المخزن
              Expanded(
                child: _buildInfoCard(
                  title: 'من المخزن',
                  content: header.whsNameFrom.trim(),
                  icon: Icons.outbox,
                  color: Colors.orange,
                ),
              ),

              const SizedBox(width: 15),

              // سهم التحويل
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.blue[600],
                  size: 20,
                ),
              ),

              const SizedBox(width: 15),

              // إلى المخزن
              Expanded(
                child: _buildInfoCard(
                  title: 'إلى المخزن',
                  content: header.whsNameTo.trim(),
                  icon: Icons.inbox,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // تاريخ المستند في كارد منفصل
          _buildInfoCard(
            title: 'تاريخ المستند',
            content: _formatDate(header.createDate),
            icon: Icons.calendar_today,
            color: Colors.blue,
            fullWidth: true,
          ),

          const SizedBox(height: 30),

          // صف معلومات السائق
          Row(
            children: [
              // اسم السائق
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'اسم السائق',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: header.driverName?.trim() ?? '',
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              // رقم الجوال
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'رقم السائق',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: header.driverMobil?.trim() ?? '',
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // صف رقم الاستلام ومعلومات إضافية
          Row(
            children: [
              // رقم الاستلام
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'رقم الاستلام',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        header.ref ?? '25105',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'رقم السيارة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: header.careNum?.trim() ?? '',
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // زر عرض سجل التعديلات
          // Center(
          //   child: ElevatedButton.icon(
          //     onPressed: () {
          //       Get.to(() => const ProductManagementScreen(), arguments: {
          //         'transferId': header.id,
          //         'header': header,
          //       });
          //     },
          //     icon: const Icon(Icons.edit_note, color: Colors.white),
          //     label: const Text(
          //       'عرض قائمة اصناف التحويل',
          //       style: TextStyle(
          //         fontSize: 16,
          //         fontWeight: FontWeight.bold,
          //         color: Colors.white,
          //       ),
          //     ),
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: const Color(0xFF2196F3),
          //       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //     ),
          //   ),
          // ),

          const SizedBox(height: 30),

          // ملاحظات
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ملاحظات',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                // controller: noteController, // تأكد من إنشاء TextEditingController
                maxLines: 5,
                minLines: 5,
                decoration: InputDecoration(
                  hintText: 'أدخل الملاحظات هنا...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: const TextStyle(fontSize: 14),
                onChanged: (value) {
                  // يمكنك إضافة منطق لحفظ التغييرات هنا
                  // مثال: header.note = value;
                },
                validator: (value) {
                  // يمكنك إضافة تحقق من صحة البيانات هنا إذا لزم الأمر
                  return null;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // رأس الفاتورة مع حالة التحويل المدمجة
  Widget _buildInvoiceHeader(TransferHeader header) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.blue[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان مع رقم التحويل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'فاتورة التحويل',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'رقم التحويل: ${header.id}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              // حالة التحويل الإجمالية
              _buildOverallStatus(header),
            ],
          ),

          const SizedBox(height: 20),

          // مؤشرات الحالة المدمجة
          Row(
            children: [
              _buildStatusIndicator(
                'إرسال',
                header.isSended,
                Icons.send,
                flex: 1,
              ),
              _buildStatusIndicator(
                'استلام',
                header.aproveRecive,
                Icons.download_done,
                flex: 1,
              ),
              _buildStatusIndicator(
                'ترحيل',
                header.sapPost,
                Icons.cloud_upload,
                flex: 1,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // مؤشر حالة صغير ومدمج
  Widget _buildStatusIndicator(String title, bool isCompleted, IconData icon, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.green[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCompleted ? Colors.green[300]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: isCompleted ? Colors.green[700] : Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isCompleted ? Colors.green[700] : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // حالة التحويل الإجمالية
  Widget _buildOverallStatus(TransferHeader header) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (header.sapPost) {
      statusText = 'مكتمل';
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (header.aproveRecive) {
      statusText = 'مستلم';
      statusColor = Colors.blue;
      statusIcon = Icons.download_done;
    } else if (header.isSended) {
      statusText = 'مُرسل';
      statusColor = Colors.orange;
      statusIcon = Icons.send;
    } else {
      statusText = 'قيد التحضير';
      statusColor = Colors.grey;
      statusIcon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 18,
            color: statusColor,
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  // كارد معلومات مُحسَّن
  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان مع الأيقونة
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // المحتوى
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';

    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('MM/dd/yyyy hh:mm:ss a').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }
}















// // pages/home/salse/invoice_page.dart

// import 'package:auth_app/pages/home/salse/Invoic/invoice_Controller.dart';
// import 'package:auth_app/pages/home/salse/items_page.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:auth_app/functions/status_request.dart';
// import 'package:auth_app/pages/home/transfare/models/transfer_stock.dart';
// import 'package:auth_app/pages/home/salse/models/details_model.dart';

// class InvoicePage extends StatelessWidget {
//   const InvoicePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // final InvoiceController controller = Get.put(InvoiceController());
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
//       appBar: AppBar(
//         title: const Text(
//           'تفاصيل التحويل',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: const Color(0xFF2196F3),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh, color: Colors.white),
//             onPressed: () => controller.loadTransferDetails(transferId),
//           ),
//         ],
//       ),
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
//           // صف المستودعات
//           Row(
//             children: [
//               // من المخزن
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'من المخزن',
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
//                         header.whsNameFrom.trim(),
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(width: 20),

//               // إلى المخزن
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'إلى المخزن',
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
//                         header.whsNameTo.trim(),
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(width: 20),

//               // تاريخ المستند
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'تاريخ المستند',
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
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               _formatDate(header.createDate),
//                               style: const TextStyle(fontSize: 14),
//                             ),
//                           ),
//                           const Icon(
//                             Icons.calendar_today,
//                             size: 16,
//                             color: Colors.grey,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 30),

//           // صف معلومات السائق
//           Row(
//             children: [
//               // اسم السائق
//               // السائق
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

//           // حالة التحويل
//           _buildStatusSection(header),

//           const SizedBox(height: 30),

//           // زر عرض سجل التعديلات
//           Center(
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 Get.to(() => const ProductManagementScreen(), arguments: {
//                   'transferId': header.id,
//                   'header': header,
//                 });
//               },
//               icon: const Icon(Icons.edit_note, color: Colors.white),
//               label: const Text(
//                 'عرض سجل التعديلات',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF2196F3),
//                 padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ),

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
//               Container(
//                 width: double.infinity,
//                 height: 120,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   border: Border.all(color: Colors.grey[300]!),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Text(
//                   header.note?.trim() ?? '',
//                   style: const TextStyle(fontSize: 14),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusSection(TransferHeader header) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.blue[50],
//         border: Border.all(color: Colors.blue[200]!),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'حالة التحويل',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 15),
//           Row(
//             children: [
//               // مستلم
//               Expanded(
//                 child: Row(
//                   children: [
//                     Text(
//                       'مستلم',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Text(
//                       header.aproveRecive ? '(تم الاستلام)' : 'مرحل (حسابات)',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: header.aproveRecive ? Colors.green : Colors.red,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // تم التحميل
//               Expanded(
//                 child: Row(
//                   children: [
//                     Text(
//                       'تم التحميل',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Text(
//                       header.isSended ? '(تم الإرسال)' : '',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: header.isSended ? Colors.green : Colors.red,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
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

// pages/home/salse/invoice_page.dart

// pages/home/salse/invoice_page.dart
// pages/home/salse/invoice_page.dart

// pages/home/salse/invoice_page.dart

// pages/home/salse/invoice_page.dart







// import 'package:auth_app/pages/home/salse/invoice_Controller.dart';
// import 'package:auth_app/pages/home/salse/items_page.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:auth_app/functions/status_request.dart';
// import 'package:auth_app/pages/home/transfare/models/transfer_stock.dart';
// import 'package:auth_app/pages/home/salse/models/details_model.dart';

// class InvoicePage extends StatelessWidget {
//   const InvoicePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final InvoiceController controller = Get.put(InvoiceController());

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
//       appBar: AppBar(
//         title: Text(
//           'فاتورة التحويل - ${transfer.ref ?? 'غير محدد'}',
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: const Color(0xFF2196F3),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh, color: Colors.white),
//             onPressed: () => controller.loadTransferDetails(transferId),
//           ),
//           IconButton(
//             icon: const Icon(Icons.print, color: Colors.white),
//             onPressed: () => _printInvoice(controller),
//           ),
//         ],
//       ),
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
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // معلومات الهيدر
//               _buildHeaderSection(transferDetails.header),

//               const SizedBox(height: 20),

//               // معلومات إضافية من الهيدر
//               _buildAdditionalHeaderInfo(transferDetails.header),
//             ],
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildHeaderSection(TransferHeader header) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // العنوان الرئيسي
//             Row(
//               children: [
//                 const Icon(
//                   Icons.receipt_long,
//                   size: 28,
//                   color: Color(0xFF2196F3),
//                 ),
//                 const SizedBox(width: 8),
//                 const Text(
//                   'معلومات التحويل',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2196F3),
//                   ),
//                 ),
//                 const Spacer(),
//                 _buildStatusChip(header),
//               ],
//             ),

//             const Divider(height: 30),

//             // معلومات أساسية
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildInfoCard(
//                     'رقم المرجع',
//                     header.ref ?? 'غير محدد',
//                     Icons.tag,
//                     Colors.blue,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildInfoCard(
//                     'رقم التحويل',
//                     header.id.toString(),
//                     Icons.numbers,
//                     Colors.green,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 12),

//             // تواريخ
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildInfoCard(
//                     'تاريخ الإنشاء',
//                     _formatDate(header.createDate),
//                     Icons.calendar_today,
//                     Colors.orange,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildInfoCard(
//                     'المنشئ',
//                     header.creatby.trim(),
//                     Icons.person,
//                     Colors.purple,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // معلومات المستودعات
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[50],
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey[200]!),
//               ),
//               child: Row(
//                 children: [
//                   // مستودع المرسل
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(6),
//                               decoration: const BoxDecoration(
//                                 color: Color(0xFF2196F3),
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(
//                                 Icons.warehouse,
//                                 color: Colors.white,
//                                 size: 16,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             const Text(
//                               'من المستودع',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           header.whsNameFrom.trim(),
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           'كود: ${header.whscodeFrom.trim()}',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // سهم الانتقال
//                   Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 16),
//                     child: const Icon(
//                       Icons.arrow_forward,
//                       color: Color(0xFF2196F3),
//                       size: 24,
//                     ),
//                   ),

//                   // مستودع المستقبل
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.end,
//                           children: [
//                             const Text(
//                               'إلى المستودع',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Container(
//                               padding: const EdgeInsets.all(6),
//                               decoration: const BoxDecoration(
//                                 color: Colors.green,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(
//                                 Icons.warehouse,
//                                 color: Colors.white,
//                                 size: 16,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           header.whsNameTo.trim(),
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                           ),
//                           textAlign: TextAlign.end,
//                         ),
//                         Text(
//                           'كود: ${header.whscodeTo.trim()}',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                           ),
//                           textAlign: TextAlign.end,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // معلومات إضافية إذا وجدت
//             if (header.note != null && header.note!.isNotEmpty) ...[
//               const SizedBox(height: 16),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.amber[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.amber[200]!),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.note,
//                           size: 16,
//                           color: Colors.amber[700],
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           'ملاحظات:',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.amber[700],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       header.note!,
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: 16, color: color),
//               const SizedBox(width: 4),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: color,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusChip(TransferHeader header) {
//     Color backgroundColor;
//     Color textColor;
//     String text;
//     IconData icon;

//     if (header.sapPost) {
//       backgroundColor = Colors.green[100]!;
//       textColor = Colors.green[800]!;
//       text = 'مُرحّل إلى SAP';
//       icon = Icons.cloud_done;
//     } else if (header.aproveRecive) {
//       backgroundColor = Colors.blue[100]!;
//       textColor = Colors.blue[800]!;
//       text = 'تم الاستلام';
//       icon = Icons.download_done;
//     } else if (header.isSended) {
//       backgroundColor = Colors.orange[100]!;
//       textColor = Colors.orange[800]!;
//       text = 'تم الإرسال';
//       icon = Icons.send;
//     } else {
//       backgroundColor = Colors.grey[100]!;
//       textColor = Colors.grey[800]!;
//       text = 'قيد التحضير';
//       icon = Icons.pending;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 16, color: textColor),
//           const SizedBox(width: 4),
//           Text(
//             text,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//               color: textColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAdditionalHeaderInfo(TransferHeader header) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Row(
//               children: [
//                 Icon(
//                   Icons.info_outline,
//                   color: Color(0xFF2196F3),
//                   size: 24,
//                 ),
//                 SizedBox(width: 8),
//                 Text(
//                   'معلومات إضافية',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2196F3),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             // معلومات السائق والسيارة
//             if (header.driverName != null ||
//                 header.driverCode != null ||
//                 header.driverMobil != null ||
//                 header.careNum != null) ...[
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.blue[200]!),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.local_shipping,
//                           color: Colors.blue[700],
//                           size: 20,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           'معلومات النقل',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue[700],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     if (header.driverName != null && header.driverName!.isNotEmpty)
//                       _buildDetailRowInCard(
//                         'اسم السائق',
//                         header.driverName!,
//                         Icons.person,
//                         Colors.blue[600]!,
//                       ),
//                     if (header.driverCode != null && header.driverCode!.isNotEmpty)
//                       _buildDetailRowInCard(
//                         'كود السائق',
//                         header.driverCode!,
//                         Icons.badge,
//                         Colors.blue[600]!,
//                       ),
//                     if (header.driverMobil != null && header.driverMobil!.isNotEmpty)
//                       _buildDetailRowInCard(
//                         'جوال السائق',
//                         header.driverMobil!,
//                         Icons.phone,
//                         Colors.blue[600]!,
//                       ),
//                     if (header.careNum != null && header.careNum!.isNotEmpty)
//                       _buildDetailRowInCard(
//                         'رقم السيارة',
//                         header.careNum!,
//                         Icons.directions_car,
//                         Colors.blue[600]!,
//                       ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],

//             // معلومات حالة التحويل التفصيلية
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey[50],
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey[200]!),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.timeline,
//                         color: Colors.grey[700],
//                         size: 20,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         'تتبع حالة التحويل',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.grey[700],
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 16),

//                   // حالة الإرسال
//                   _buildStatusStep(
//                     'الإرسال',
//                     header.isSended,
//                     header.sendedBy,
//                     null,
//                     Icons.send,
//                     Colors.orange,
//                     isFirst: true,
//                   ),

//                   // حالة الاستلام
//                   _buildStatusStep(
//                     'الاستلام',
//                     header.aproveRecive,
//                     header.aproveReciveBy,
//                     null,
//                     Icons.download_done,
//                     Colors.blue,
//                   ),

//                   // حالة الترحيل إلى SAP
//                   _buildStatusStep(
//                     'الترحيل إلى SAP',
//                     header.sapPost,
//                     header.sapPostBy,
//                     header.sapPostDate,
//                     Icons.cloud_upload,
//                     Colors.green,
//                     isLast: true,
//                   ),
//                 ],
//               ),
//             ),

//             // زر للانتقال إلى إدارة الأصناف
//             const SizedBox(height: 20),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   Get.to(() => const ProductManagementScreen(), arguments: {
//                     'transferId': header.id,
//                     'header': header,
//                   });
//                 },
//                 icon: const Icon(Icons.inventory_2, color: Colors.white),
//                 label: const Text(
//                   'إدارة أصناف التحويل',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF4CAF50),
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRowInCard(String label, String value, IconData icon, Color color) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         children: [
//           Icon(icon, size: 16, color: color),
//           const SizedBox(width: 8),
//           SizedBox(
//             width: 120,
//             child: Text(
//               '$label:',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: color,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusStep(
//     String title,
//     bool isCompleted,
//     String? completedBy,
//     String? completedDate,
//     IconData icon,
//     Color color, {
//     bool isFirst = false,
//     bool isLast = false,
//   }) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             // أيقونة الحالة
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: isCompleted ? color : Colors.grey[300],
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 isCompleted ? Icons.check : icon,
//                 color: isCompleted ? Colors.white : Colors.grey[600],
//                 size: 20,
//               ),
//             ),

//             const SizedBox(width: 16),

//             // معلومات الحالة
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: isCompleted ? color : Colors.grey[600],
//                     ),
//                   ),
//                   if (isCompleted) ...[
//                     if (completedBy != null && completedBy.isNotEmpty)
//                       Text(
//                         'بواسطة: ${completedBy.trim()}',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     if (completedDate != null && completedDate.isNotEmpty)
//                       Text(
//                         'في: ${_formatDate(completedDate)}',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                   ] else ...[
//                     Text(
//                       'لم يتم بعد',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[500],
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),

//             // أيقونة الحالة الإضافية
//             Icon(
//               isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
//               color: isCompleted ? color : Colors.grey[400],
//               size: 20,
//             ),
//           ],
//         ),

//         // خط الاتصال للخطوة التالية
//         if (!isLast)
//           Container(
//             margin: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
//             width: 2,
//             height: 30,
//             color: Colors.grey[300],
//           ),
//       ],
//     );
//   }

//   String _formatDate(String? dateString) {
//     if (dateString == null || dateString.isEmpty) return 'غير محدد';

//     try {
//       DateTime dateTime = DateTime.parse(dateString);
//       return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
//     } catch (e) {
//       return dateString;
//     }
//   }

//   void _printInvoice(InvoiceController controller) {
//     // هنا يمكن إضافة منطق الطباعة
//     Get.snackbar(
//       'طباعة',
//       'سيتم إضافة وظيفة الطباعة قريباً',
//       backgroundColor: Colors.blue,
//       colorText: Colors.white,
//     );
//   }
// }
