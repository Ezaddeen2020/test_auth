// import 'package:auth_app/pages/home/transfare/controllers/transfer_controller.dart';
// import 'package:auth_app/pages/home/transfare/screens/widgets/transfer_filter.dart';
// import 'package:auth_app/pages/home/transfare/screens/widgets/transfer_status_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import 'package:auth_app/functions/status_request.dart';
// import 'widgets/transfer_search_bar.dart';
// // import 'widgets/transfer_card.dart';

// class TransferScreen extends StatelessWidget {
//   const TransferScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final TransferController controller = Get.find<TransferController>();

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text(
//           'إدارة التحويلات',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         // backgroundColor: const Color(0xFF2196F3),
//         backgroundColor: Colors.blue.shade900,

//         elevation: 0,
//         iconTheme:
//         const IconThemeData(color: Colors.white),

//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh, color: Colors.white),
//             onPressed: () => controller.refreshTransfers(),
//           ),
//           IconButton(
//             icon: const Icon(Icons.filter_list, color: Colors.white),
//             onPressed: () => TransferFilterDialog.show(context, controller),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // شريط الإحصائيات
//           TransferStatsBar(controller: controller),

//           // شريط البحث
//           TransferSearchBar(controller: controller),

//           // قائمة التحويلات
//           Expanded(
//             child: Obx(() {
//               if (controller.statusRequest.value == StatusRequest.loading &&
//                   controller.transfers.isEmpty) {
//                 return const Center(
//                   child: CircularProgressIndicator(
//                     color: Color(0xFF2196F3),
//                   ),
//                 );
//               }

//               if (controller.statusRequest.value == StatusRequest.failure) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.error_outline,
//                         size: 80,
//                         color: Colors.grey[400],
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'فشل في تحميل البيانات',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.grey[600],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: () => controller.getTransfersList(),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF2196F3),
//                           foregroundColor: Colors.white,
//                         ),
//                         child: const Text('إعادة المحاولة'),
//                       ),
//                     ],
//                   ),
//                 );
//               }

//               if (controller.filteredTransfers.isEmpty) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.inbox_outlined,
//                         size: 80,
//                         color: Colors.grey[400],
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'لا توجد تحويلات',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.grey[600],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }

//               return RefreshIndicator(
//                 onRefresh: () => controller.refreshTransfers(),
//                 color: const Color(0xFF2196F3),
//                 child: ListView.builder(
//                   controller: controller.scrollController,
//                   padding: const EdgeInsets.all(16),
//                   itemCount: controller.filteredTransfers.length +
//                       (controller.isLoadingMore.value ? 1 : 0),
//                   itemBuilder: (context, index) {
//                     if (index == controller.filteredTransfers.length) {
//                       return Obx(() {
//                         if (controller.isLoadingMore.value) {
//                           return const Center(
//                             child: Padding(
//                               padding: EdgeInsets.all(16),
//                               child: CircularProgressIndicator(
//                                 color: Color(0xFF2196F3),
//                               ),
//                             ),
//                           );
//                         }
//                         return const SizedBox.shrink();
//                       });
//                     }

//                     return TransferCard(
//                       transfer: controller.filteredTransfers[index],
//                       controller: controller,
//                     );
//                   },
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           // Get.to(() => CreateTransferScreen());
//         },
//         backgroundColor: const Color(0xFF2196F3),
//         icon: const Icon(Icons.add, color: Colors.white),
//         label: const Text(
//           ' اضافة تحويل',
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//     );
//   }
// }

import 'package:auth_app/pages/home/salse/invice_page.dart';
import 'package:auth_app/pages/home/transfare/controllers/transfer_controller.dart';
import 'package:auth_app/pages/home/transfare/models/transfer_stock.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:auth_app/functions/status_request.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  // دالة مساعدة لتحويل التاريخ إلى نظام 12 ساعة
  String _formatDateTo12Hour(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'غير محدد';

    try {
      DateTime? dateTime;

      // محاولة تحليل التاريخ بصيغ مختلفة
      try {
        dateTime = DateTime.parse(dateString);
      } catch (e) {
        try {
          dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateString);
        } catch (e2) {
          try {
            dateTime = DateFormat('dd/MM/yyyy HH:mm:ss').parse(dateString);
          } catch (e3) {
            return dateString; // إرجاع النص الأصلي إذا فشل التحليل
          }
        }
      }

      // تنسيق التاريخ بنظام 12 ساعة
      final formatter = DateFormat('dd/MM/yyyy hh:mm a');
      return formatter.format(dateTime);
    } catch (e) {
      return dateString; // إرجاع النص الأصلي في حالة الخطأ
    }
  }

  @override
  Widget build(BuildContext context) {
    final TransferController controller = Get.put(TransferController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'إدارة التحويلات',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.refreshTransfers(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _showFilterDialog(context, controller),
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط الإحصائيات
          _buildStatsBar(controller),

          // شريط البحث
          _buildSearchBar(controller),

          // قائمة التحويلات
          Expanded(
            child: Obx(() {
              if (controller.statusRequest.value == StatusRequest.loading &&
                  controller.transfers.isEmpty) {
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
                        'فشل في تحميل البيانات',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => controller.getTransfersList(),
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

              if (controller.filteredTransfers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد تحويلات',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.refreshTransfers(),
                color: const Color(0xFF2196F3),
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredTransfers.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.filteredTransfers.length) {
                      return Obx(() {
                        if (controller.isLoadingMore.value) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                color: Color(0xFF2196F3),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      });
                    }

                    return _buildTransferCard(
                      controller.filteredTransfers[index],
                      controller,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // الانتقال إلى صفحة إنشاء تحويل جديد
          // Get.to(() => CreateTransferScreen());
        },
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsBar(TransferController controller) {
    return Obx(() {
      final stats = controller.getTransferStats();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF2196F3),
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

  Widget _buildSearchBar(TransferController controller) {
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
// في ملف transfer_screen.dart
// تعديل دالة _buildTransferCard

  Widget _buildTransferCard(TransferModel transfer, TransferController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        // تغيير وظيفة الضغط للانتقال إلى InvoicePage
        onTap: () => _navigateToInvoice(transfer, controller),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الرأس
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'رقم المرجع: ${transfer.ref ?? 'غير محدد'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'تاريخ الإنشاء: ${transfer.formattedCreateDate}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(transfer),
                ],
              ),

              const Divider(height: 20),

              // معلومات المستودعات
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'من:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          transfer.whsNameFrom.trim(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    color: Color(0xFF2196F3),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إلى:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          transfer.whsNameTo.trim(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // معلومات المنشئ
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'المنشئ: ${transfer.creatby.trim()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  // إضافة أيقونة تشير للانتقال للفاتورة
                  Icon(
                    Icons.receipt_long,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'عرض الفاتورة',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),

              // يمكن الاحتفاظ بأزرار العمليات إذا كانت مطلوبة
              const SizedBox(height: 12),
              _buildActionButtons(transfer, controller),
            ],
          ),
        ),
      ),
    );
  }

// دالة جديدة للانتقال إلى صفحة الفاتورة
  void _navigateToInvoice(TransferModel transfer, TransferController controller) {
    // تحديد التحويل المحدد في الـ controller
    controller.selectTransfer(transfer);

    // الانتقال إلى صفحة الفاتورة مع تمرير بيانات التحويل
    Get.to(() => InvoicePage(), arguments: {
      'transfer': transfer,
      'transferId': transfer.id,
    });
  }

// حذف أو تعديل دالة _showTransferDetails لأنها لم تعد مطلوبة
// void _showTransferDetails(TransferModel transfer, TransferController controller) {
//   // تم إلغاء هذه الدالة
// }

  Widget _buildStatusChip(TransferModel transfer) {
    Color backgroundColor;
    Color textColor;
    String text = transfer.statusText;

    if (transfer.sapPost) {
      backgroundColor = Colors.green[100]!;
      textColor = Colors.green[800]!;
    } else if (transfer.aproveRecive) {
      backgroundColor = Colors.blue[100]!;
      textColor = Colors.blue[800]!;
    } else if (transfer.isSended) {
      backgroundColor = Colors.orange[100]!;
      textColor = Colors.orange[800]!;
    } else {
      backgroundColor = Colors.grey[100]!;
      textColor = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildActionButtons(TransferModel transfer, TransferController controller) {
    List<Widget> buttons = [];

    if (controller.canSendTransfer(transfer)) {
      buttons.add(
        Obx(() => ElevatedButton.icon(
              onPressed: controller.isLoading.value
                  ? null
                  : () => _confirmAction(
                        'إرسال التحويل',
                        'هل تريد إرسال هذا التحويل؟',
                        () => controller.sendTransfer(transfer.id),
                      ),
              icon: const Icon(Icons.send, size: 16),
              label: const Text('إرسال'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            )),
      );
    }

    if (controller.canReceiveTransfer(transfer)) {
      buttons.add(
        Obx(() => ElevatedButton.icon(
              onPressed: controller.isLoading.value
                  ? null
                  : () => _confirmAction(
                        'استلام التحويل',
                        'هل تريد استلام هذا التحويل؟',
                        () => controller.receiveTransfer(transfer.id),
                      ),
              icon: const Icon(Icons.download, size: 16),
              label: const Text('استلام'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            )),
      );
    }

    if (controller.canPostToSAP(transfer)) {
      buttons.add(
        Obx(() => ElevatedButton.icon(
              onPressed: controller.isLoading.value
                  ? null
                  : () => _confirmAction(
                        'ترحيل إلى SAP',
                        'هل تريد ترحيل هذا التحويل إلى SAP؟',
                        () => controller.postToSAP(transfer.id),
                      ),
              icon: const Icon(Icons.cloud_upload, size: 16),
              label: const Text('ترحيل'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            )),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: buttons,
    );
  }

  void _confirmAction(String title, String message, VoidCallback onConfirm) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showTransferDetails(TransferModel transfer, TransferController controller) {
    controller.selectTransfer(transfer);
    Get.bottomSheet(
      TransferDetailsBottomSheet(transfer: transfer),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showFilterDialog(BuildContext context, TransferController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('فلترة التحويلات'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // فلتر الحالة
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.selectedStatusFilter.value,
                    decoration: const InputDecoration(
                      labelText: 'الحالة',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('جميع الحالات')),
                      DropdownMenuItem(value: 'pending', child: Text('قيد التحضير')),
                      DropdownMenuItem(value: 'sent', child: Text('تم الإرسال')),
                      DropdownMenuItem(value: 'received', child: Text('تم الاستلام')),
                      DropdownMenuItem(value: 'posted', child: Text('مُرحّل إلى SAP')),
                    ],
                    onChanged: (value) => controller.updateStatusFilter(value!),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.resetFilters();
              Get.back();
            },
            child: const Text('إعادة تعيين'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
            ),
            child: const Text('تطبيق'),
          ),
        ],
      ),
    );
  }
}

// BottomSheet لتفاصيل التحويل
class TransferDetailsBottomSheet extends StatelessWidget {
  final TransferModel transfer;

  const TransferDetailsBottomSheet({
    super.key,
    required this.transfer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // العنوان
            const Text(
              'تفاصيل التحويل',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),

            const SizedBox(height: 20),

            // التفاصيل
            _buildDetailRow('رقم المرجع', transfer.ref ?? 'غير محدد'),
            _buildDetailRow('رقم التحويل', transfer.id.toString()),
            _buildDetailRow('تاريخ الإنشاء', transfer.formattedCreateDate),
            _buildDetailRow('المنشئ', transfer.creatby.trim()),

            const Divider(height: 30),

            _buildDetailRow('من المستودع', transfer.whsNameFrom.trim()),
            _buildDetailRow('رمز المستودع المرسل', transfer.whscodeFrom.trim()),
            _buildDetailRow('إلى المستودع', transfer.whsNameTo.trim()),
            _buildDetailRow('رمز المستودع المستقبل', transfer.whscodeTo.trim()),

            const Divider(height: 30),

            _buildDetailRow('حالة الإرسال', transfer.isSended ? 'تم الإرسال' : 'لم يتم الإرسال'),
            if (transfer.sendedBy != null)
              _buildDetailRow('المرسل بواسطة', transfer.sendedBy!.trim()),

            _buildDetailRow(
                'حالة الاستلام', transfer.aproveRecive ? 'تم الاستلام' : 'لم يتم الاستلام'),
            if (transfer.aproveReciveBy != null)
              _buildDetailRow('المستلم بواسطة', transfer.aproveReciveBy!.trim()),

            _buildDetailRow('حالة الترحيل', transfer.sapPost ? 'تم الترحيل' : 'لم يتم الترحيل'),
            if (transfer.sapPostBy != null)
              _buildDetailRow('المرحل بواسطة', transfer.sapPostBy!.trim()),
            if (transfer.sapPostDate != null)
              _buildDetailRow('تاريخ الترحيل', transfer.formattedSapPostDate),

            if (transfer.note != null && transfer.note!.isNotEmpty) ...[
              const Divider(height: 30),
              _buildDetailRow('ملاحظات', transfer.note!),
            ],

            const SizedBox(height: 30),

            // إغلاق
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'إغلاق',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
