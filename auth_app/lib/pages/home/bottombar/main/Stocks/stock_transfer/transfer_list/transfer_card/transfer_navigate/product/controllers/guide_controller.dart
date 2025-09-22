import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/controllers/product_controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/screen/widgets/unit_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/models/details_model.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/model/uom_model.dart';

class ProductManagementControllerWithUI extends ProductManagementController {
  /// Show unit selection dialog for item code
  Future<void> showUnitSelectionDialogFromCode(
    String itemCode,
    Function(ItemUnit) onSelected,
  ) async {
    try {
      List<ItemUnit> units = await getItemUnits(itemCode);
      if (units.isEmpty) return;

      await UnitSelectionDialogWidget.showUnitSelectionDialog(
        itemCode: itemCode,
        units: units,
        onUnitSelected: onSelected,
      );
    } catch (e) {
      logMessage('Transfer', 'Error in showUnitSelectionDialogFromCode: ${e.toString()}');
    }
  }

  /// Show unit selection for new product
  Future<String?> showUnitSelectionForNewProduct(String itemCode) async {
    if (itemCode.isEmpty) return null;

    try {
      List<ItemUnit> units = await getItemUnits(itemCode);
      if (units.isEmpty) return null;

      return await UnitSelectionDialogWidget.showNewProductUnitSelectionDialog(
        itemCode: itemCode,
        units: units,
      );
    } catch (e) {
      logMessage('Transfer', 'Error in showUnitSelectionForNewProduct: ${e.toString()}');
      return null;
    }
  }

  /// Show unit selection for transfer line
  Future<void> selectUnitForTransferLine(TransferLine line) async {
    if (line.itemCode == null || line.itemCode!.isEmpty) return;

    try {
      String itemCodeToUse = line.itemCode!;

      // Try to get units with the current item code
      List<ItemUnit> units = await getItemUnits(itemCodeToUse);

      // If no units found and code doesn't contain 'INV', try with INV prefix
      if (units.isEmpty && !itemCodeToUse.toUpperCase().contains('INV')) {
        itemCodeToUse = 'INV${line.itemCode}';
        units = await getItemUnits(itemCodeToUse);
      }

      if (units.isEmpty) return;

      await UnitSelectionDialogWidget.showTransferLineUnitSelectionDialog(
        line: line,
        units: units,
        onUnitUpdate: updateProductUnit,
      );
    } catch (e) {
      logMessage('Transfer', 'Error in selectUnitForTransferLine: ${e.toString()}');
    }
  }
}

/// Main Product Management Page
class ProductManagementPage extends StatelessWidget {
  const ProductManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductManagementControllerWithUI());

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المنتجات'),
        actions: [
          Obx(() => IconButton(
                onPressed: controller.canSave ? () => controller.saveAllChangesToServer() : null,
                icon: controller.isSaving.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
              )),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(controller),
          _buildProductsList(controller),
          _buildAddProductButton(controller),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ProductManagementControllerWithUI controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.updateSearch,
        decoration: InputDecoration(
          hintText: 'البحث في المنتجات...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(() => controller.hasActiveSearch
              ? IconButton(
                  onPressed: controller.clearSearch,
                  icon: const Icon(Icons.clear),
                )
              : const SizedBox()),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsList(ProductManagementControllerWithUI controller) {
    return Expanded(
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.hasData) {
          return const Center(child: Text('لا توجد منتجات'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.filteredLines.length,
          itemBuilder: (context, index) {
            final line = controller.filteredLines[index];
            final isDeleted = controller.deletedLines.contains(line.lineNum);

            return _buildProductCard(line, isDeleted, controller);
          },
        );
      }),
    );
  }

  Widget _buildProductCard(
      TransferLine line, bool isDeleted, ProductManagementControllerWithUI controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          line.description ?? 'بدون وصف',
          style: TextStyle(
            decoration: isDeleted ? TextDecoration.lineThrough : null,
            color: isDeleted ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          'الكود: ${line.itemCode} | الكمية: ${line.quantity} | الوحدة: ${line.uomCode}',
          style: TextStyle(color: isDeleted ? Colors.grey : null),
        ),
        trailing: isDeleted
            ? Chip(
                label: const Text('محذوف'),
                backgroundColor: Colors.red[100],
              )
            : _buildProductMenu(line, controller),
      ),
    );
  }

  Widget _buildProductMenu(TransferLine line, ProductManagementControllerWithUI controller) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit_quantity',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('تعديل الكمية'),
          ),
        ),
        const PopupMenuItem(
          value: 'change_unit',
          child: ListTile(
            leading: Icon(Icons.straighten),
            title: Text('تغيير الوحدة'),
          ),
        ),
        const PopupMenuItem(
          value: 'duplicate',
          child: ListTile(
            leading: Icon(Icons.copy),
            title: Text('نسخ'),
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ),
      ],
      onSelected: (value) => _handleMenuAction(value, line, controller),
    );
  }

  Widget _buildAddProductButton(ProductManagementControllerWithUI controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () => _showAddProductDialog(controller),
        icon: const Icon(Icons.add),
        label: const Text('إضافة منتج'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }

  void _handleMenuAction(
      String action, TransferLine line, ProductManagementControllerWithUI controller) {
    switch (action) {
      case 'edit_quantity':
        _showEditQuantityDialog(line, controller);
        break;
      case 'change_unit':
        controller.selectUnitForTransferLine(line);
        break;
      case 'duplicate':
        controller.duplicateProduct(line);
        break;
      case 'delete':
        _showDeleteConfirmation(line, controller);
        break;
    }
  }

  void _showEditQuantityDialog(TransferLine line, ProductManagementControllerWithUI controller) {
    final quantityController = TextEditingController(text: line.quantity?.toString() ?? '0');

    Get.dialog(
      AlertDialog(
        title: const Text('تعديل الكمية'),
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'الكمية الجديدة',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final newQuantity = double.tryParse(quantityController.text);
              if (newQuantity != null && newQuantity > 0) {
                controller.updateProductQuantity(line, newQuantity);
                Get.back();
              } else {
                Get.snackbar('خطأ', 'يرجى إدخال كمية صحيحة');
              }
            },
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(TransferLine line, ProductManagementControllerWithUI controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف المنتج "${line.description}"؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteProduct(line);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(ProductManagementControllerWithUI controller) {
    final itemCodeController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController(text: '0');
    final descriptionController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('إضافة منتج جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemCodeController,
                decoration: const InputDecoration(
                  labelText: 'كود المنتج',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'الوصف',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'الكمية',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'السعر',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final itemCode = itemCodeController.text.trim();
              final quantity = double.tryParse(quantityController.text);
              final price = double.tryParse(priceController.text);
              final description = descriptionController.text.trim();

              if (itemCode.isEmpty) {
                Get.snackbar('خطأ', 'كود المنتج مطلوب');
                return;
              }

              if (quantity == null || quantity <= 0) {
                Get.snackbar('خطأ', 'يرجى إدخال كمية صحيحة');
                return;
              }

              if (price == null || price < 0) {
                Get.snackbar('خطأ', 'يرجى إدخال سعر صحيح');
                return;
              }

              Get.back();

              await controller.addProductWithPull(
                itemCode,
                quantity: quantity,
                price: price,
                description: description.isNotEmpty ? description : null,
                pullData: true,
              );
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
