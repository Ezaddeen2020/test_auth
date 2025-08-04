import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/controllers/transfer_controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/models/transfer_stock_model.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/screens/widgets/transfer_bottom_details_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransferDialogs {
  // ==========================================================================
  // نوافذ التأكيد والرسائل
  // ==========================================================================

  /// عرض نافذة تأكيد للعمليات
  static void confirmAction(String title, String message, VoidCallback onConfirm) {
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

  /// عرض تفاصيل التحويل
  static void showTransferDetails(TransferModel transfer, TransferController controller) {
    controller.selectTransfer(transfer);
    Get.bottomSheet(
      TransferDetailsBottomSheet(transfer: transfer),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// عرض نافذة الفلترة
  static void showFilterDialog(TransferController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('فلترة التحويلات'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusFilter(controller),
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

  static Widget _buildStatusFilter(TransferController controller) {
    return Obx(() => DropdownButtonFormField<String>(
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
        ));
  }

  // ==========================================================================
  // رسائل التنبيه
  // ==========================================================================

  /// عرض رسالة نجاح
  static void showSuccessMessage(String message) {
    Get.snackbar(
      'نجح',
      message,
      backgroundColor: Colors.green[100],
      colorText: Colors.green[800],
      icon: const Icon(Icons.check_circle, color: Colors.green),
      duration: const Duration(seconds: 3),
    );
  }

  /// عرض رسالة خطأ
  static void showErrorMessage(String message) {
    Get.snackbar(
      'خطأ',
      message,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[800],
      icon: const Icon(Icons.error, color: Colors.red),
      duration: const Duration(seconds: 4),
    );
  }

  /// عرض رسالة تحذير
  static void showWarningMessage(String message) {
    Get.snackbar(
      'تحذير',
      message,
      backgroundColor: Colors.orange[100],
      colorText: Colors.orange[800],
      icon: const Icon(Icons.warning, color: Colors.orange),
      duration: const Duration(seconds: 3),
    );
  }

  /// عرض رسالة معلومات
  static void showInfoMessage(String message) {
    Get.snackbar(
      'معلومات',
      message,
      backgroundColor: Colors.blue[100],
      colorText: Colors.blue[800],
      icon: const Icon(Icons.info, color: Colors.blue),
      duration: const Duration(seconds: 3),
    );
  }
}
