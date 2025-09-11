import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/controller/product_controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/screen/widgets/floating_add_btn.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/screen/widgets/product_card.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/screen/widgets/product_dialog.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/screen/widgets/product_status_bar.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/screen/widgets/save_changes_btn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/functions/status_request.dart';

class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductManagementController controller = Get.put(ProductManagementController());

    final int? transferId = Get.arguments?['transferId'];

    if (transferId != null) {
      controller.loadTransferLines(transferId);
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Obx(() {
        if (controller.statusRequest.value == StatusRequest.loading &&
            controller.transferLines.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.grey,
            ),
          );
        }

        if (controller.statusRequest.value == StatusRequest.failure) {
          return _buildErrorState(controller);
        }

        if (controller.filteredLines.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            // شريط الإحصائيات والأزرار
            ProductStatsBar(controller: controller),

            // زر الحفظ - يظهر عند وجود تغييرات غير محفوظة
            SaveChangesButton(controller: controller),

            // قائمة البطاقات
            Expanded(
              child: _buildProductCardsList(controller),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingAddButton(
        onPressed: () => ProductDialogs.showAddProductDialog(controller),
        isEnabled: controller.hasSelectedTransfer,
      ),
    );
  }

  Widget _buildErrorState(ProductManagementController controller) {
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
            onPressed: () {
              if (controller.transferId.value != null) {
                controller.loadTransferLines(controller.transferId.value!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              foregroundColor: Colors.white,
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد أصناف في هذا التحويل',
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

  Widget _buildProductCardsList(ProductManagementController controller) {
    return ListView.builder(
      key: const PageStorageKey<String>('products_list'),
      padding: const EdgeInsets.all(16),
      itemCount: controller.filteredLines.length,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      itemBuilder: (context, index) {
        final line = controller.filteredLines[index];
        return ProductCardWidget(
          line: line,
          rowNumber: index + 1,
          controller: controller,
        );
      },
    );
  }
}
