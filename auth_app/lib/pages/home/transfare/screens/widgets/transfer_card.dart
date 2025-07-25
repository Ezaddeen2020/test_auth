// import 'package:auth_app/pages/home/transfare/screens/widgets/transfer_bottom_details_sheet.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:auth_app/pages/home/transfare/controllers/transfer_controller.dart';
// import 'package:auth_app/pages/home/transfare/models/transfer_stock.dart';

// class TransferCard extends StatelessWidget {
//   final TransferModel transfer;
//   final TransferController controller;

//   const TransferCard({
//     super.key,
//     required this.transfer,
//     required this.controller,
//   });

//   // دالة مساعدة لتحويل التاريخ إلى نظام 12 ساعة
//   String _formatDateTo12Hour(String? dateString) {
//     if (dateString == null || dateString.isEmpty) return 'غير محدد';

//     try {
//       DateTime? dateTime;

//       // محاولة تحليل التاريخ بصيغ مختلفة
//       try {
//         dateTime = DateTime.parse(dateString);
//       } catch (e) {
//         try {
//           dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateString);
//         } catch (e2) {
//           try {
//             dateTime = DateFormat('dd/MM/yyyy HH:mm:ss').parse(dateString);
//           } catch (e3) {
//             return dateString; // إرجاع النص الأصلي إذا فشل التحليل
//           }
//         }
//       }

//       // تنسيق التاريخ بنظام 12 ساعة
//       final formatter = DateFormat('dd/MM/yyyy hh:mm a');
//       return formatter.format(dateTime);
//     } catch (e) {
//       return dateString; // إرجاع النص الأصلي في حالة الخطأ
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl, // هذا السطر يجعل التصميم من اليمين لليسار
//       child: Card(
//         margin: const EdgeInsets.only(bottom: 12),
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: InkWell(
//           onTap: () => _showTransferDetails(transfer, controller),
//           borderRadius: BorderRadius.circular(12),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // الرأس
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     _buildStatusChip(transfer),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.end, // تغيير إلى end
//                         children: [
//                           Text(
//                             'رقم التحويل: ${transfer.ref ?? 'غير محدد'}',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF2196F3),
//                             ),
//                             textAlign: TextAlign.right, // محاذاة النص لليمين
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'تاريخ الإنشاء: ${_formatDateTo12Hour(transfer.formattedCreateDate)}',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600]),
//                             textAlign: TextAlign.right, // محاذاة النص لليمين
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),

//                 const Divider(height: 20),

//                 // معلومات المستودعات
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.end, // تغيير إلى end
//                         children: [
//                           Text(
//                             'إلى:',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600]),
//                           ),
//                           Text(
//                             transfer.whsNameTo.trim(),
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             textAlign: TextAlign.right, // محاذاة النص لليمين
//                           ),
//                         ],
//                       ),
//                     ),
//                     const Icon(
//                       Icons.arrow_back, // تغيير السهم ليتجه للاتجاه المعاكس
//                       color: Color(0xFF2196F3),
//                       size: 20,
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.end, // تغيير إلى end
//                         children: [
//                           Text(
//                             'من:',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600]),
//                           ),
//                           Text(
//                             transfer.whsNameFrom.trim(),
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             textAlign: TextAlign.right, // محاذاة النص لليمين
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 12),

//                 // معلومات المنشئ
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end, // تغيير إلى end
//                   children: [
//                     Text(
//                       'المنشئ: ${transfer.creatby.trim()}',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[600]),
//                       textAlign: TextAlign.right, // محاذاة النص لليمين
//                     ),
//                     const SizedBox(width: 4),
//                     Icon(
//                       Icons.person,
//                       size: 16,
//                       color: Colors.grey[600],
//                     ),
//                   ],
//                 ),

//                 // أزرار العمليات
//                 const SizedBox(height: 12),
//                 _buildActionButtons(transfer, controller),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusChip(TransferModel transfer) {
//     Color backgroundColor;
//     Color textColor;
//     String text = transfer.statusText;

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
//         text,
//         style: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w500,
//           color: textColor,
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButtons(TransferModel transfer, TransferController controller) {
//     List<Widget> buttons = [];

//     if (controller.canSendTransfer(transfer)) {
//       buttons.add(
//         Obx(() => ElevatedButton.icon(
//               onPressed: controller.isLoading.value
//                   ? null
//                   : () => _confirmAction(
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
//                   : () => _confirmAction(
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
//                   : () => _confirmAction(
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
//       alignment: WrapAlignment.end, // تغيير المحاذاة إلى النهاية
//       children: buttons,
//     );
//   }

//   void _confirmAction(String title, String message, VoidCallback onConfirm) {
//     Get.dialog(
//       Directionality( // إضافة Directionality للديالوج
//         textDirection: TextDirection.rtl,
//         child: AlertDialog(
//           title: Text(title),
//           content: Text(message),
//           actions: [
//             ElevatedButton(
//               onPressed: () {
//                 Get.back();
//                 onConfirm();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF2196F3),
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('تأكيد'),
//             ),
//             TextButton(
//               onPressed: () => Get.back(),
//               child: const Text('إلغاء'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showTransferDetails(TransferModel transfer, TransferController controller) {
//     controller.selectTransfer(transfer);
//     Get.bottomSheet(
//       Directionality( // إضافة Directionality للبوتوم شيت
//         textDirection: TextDirection.rtl,
//         // textDirection: TextDirection.RTL, // بحروف كبيرة
//         child: TransferDetailsBottomSheet(transfer: transfer),
//       ),
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//     );
//   }
// }

import 'package:auth_app/pages/home/transfare/screens/widgets/transfer_bottom_details_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:auth_app/pages/home/transfare/controllers/transfer_controller.dart';
import 'package:auth_app/pages/home/transfare/models/transfer_stock.dart';

class TransferCard extends StatelessWidget {
  final TransferModel transfer;
  final TransferController controller;

  const TransferCard({
    super.key,
    required this.transfer,
    required this.controller,
  });

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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showTransferDetails(transfer, controller),
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
                          'رقم التحويل: ${transfer.ref ?? 'غير محدد'}',
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
                ],
              ),

              // أزرار العمليات
              const SizedBox(height: 12),
              _buildActionButtons(transfer, controller),
            ],
          ),
        ),
      ),
    );
  }

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
}
