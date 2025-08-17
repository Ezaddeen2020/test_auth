import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      // appBar: _buildAppBar(controller),
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
            _buildStatsAndActionsBar(controller),

            // Save Button - يظهر عند وجود تغييرات غير محفوظة
            Obx(() => controller.hasUnsavedChanges.value
                ? _buildSaveChangesButton(controller)
                : const SizedBox.shrink()),

            // قائمة البطاقات
            Expanded(
              child: _buildProductCardsList(controller),
            ),
          ],
        );
      }),
      floatingActionButton: _buildFloatingActionButton(controller),
    );
  }

  // PreferredSizeWidget _buildAppBar(ProductManagementController controller) {
  //   return AppBar(
  //     backgroundColor: Colors.white,
  //     elevation: 1,
  //     title: const Text(
  //       'إدارة أصناف التحويل',
  //       style: TextStyle(
  //         color: Colors.black87,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //     leading: IconButton(
  //       icon: const Icon(Icons.arrow_back, color: Colors.black87),
  //       onPressed: () => _handleBackPress(controller),
  //     ),
  //     actions: [
  //       // عدد التغييرات غير المحفوظة
  //       Obx(() => controller.hasUnsavedChanges.value
  //           ? Container(
  //               margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
  //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //               decoration: BoxDecoration(
  //                 color: Colors.orange,
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: Text(
  //                 '${controller.unsavedChangesCount}',
  //                 style: const TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 12,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             )
  //           : const SizedBox.shrink()),
  //     ],
  //   );
  // }

  // زر الحفظ الجديد - يظهر عند وجود تغييرات
  Widget _buildSaveChangesButton(ProductManagementController controller) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[700]!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.canSave ? () => controller.saveAllChangesToServer() : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (controller.isSaving.value) ...[
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'جاري الحفظ...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.save,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'حفظ التغييرات (${controller.unsavedChangesCount})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                )),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsAndActionsBar(ProductManagementController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // شريط البحث
          TextField(
            controller: controller.searchController,
            onChanged: controller.updateSearch,
            decoration: InputDecoration(
              hintText: 'بحث بكود الصنف أو الوصف...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: Obx(() => controller.hasActiveSearch
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: controller.clearSearch,
                    )
                  : const SizedBox.shrink()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),

          const SizedBox(height: 12),

          // الإحصائيات
          Obx(() {
            final stats = controller.getProductStats();
            return Row(
              children: [
                _buildStatCard('إجمالي الأصناف', '${stats['totalItems']}', Icons.inventory),
                const SizedBox(width: 8),
                _buildStatCard(
                    'إجمالي الكمية', '${stats['totalQuantity'].toStringAsFixed(0)}', Icons.numbers),
                const SizedBox(width: 8),
                _buildStatCard('أصناف مختلفة', '${stats['uniqueItems']}', Icons.category),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[100]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.blue[700]),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.all(16),
      itemCount: controller.filteredLines.length,
      itemBuilder: (context, index) {
        final line = controller.filteredLines[index];
        return _buildProductCard(line, index + 1, controller);
      },
    );
  }

  Widget _buildProductCard(dynamic line, int rowNumber, ProductManagementController controller) {
    // تحديد حالة السطر (جديد، معدل، أو عادي)
    bool isNewLine = line.lineNum != null && line.lineNum! < 0;
    bool isModifiedLine = controller.modifiedLines.containsKey(line.lineNum);
    bool isDeletedLine = controller.deletedLines.contains(line.lineNum);

    Color borderColor = Colors.grey[200]!;
    Color statusColor = Colors.transparent;
    String statusText = '';

    if (isDeletedLine) {
      borderColor = Colors.red[300]!;
      statusColor = Colors.red[50]!;
      statusText = 'محذوف';
    } else if (isNewLine) {
      borderColor = Colors.green[300]!;
      statusColor = Colors.green[50]!;
      statusText = 'جديد';
    } else if (isModifiedLine) {
      borderColor = Colors.orange[300]!;
      statusColor = Colors.orange[50]!;
      statusText = 'معدل';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: statusColor.alpha == 0 ? Colors.white : statusColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس البطاقة مع حالة السطر
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$rowNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),

                if (statusText.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          isDeletedLine ? Colors.red : (isNewLine ? Colors.green : Colors.orange),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],

                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.itemCode ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDeletedLine ? Colors.red[700] : Colors.black87,
                          decoration: isDeletedLine ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        line.description ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDeletedLine ? Colors.red[600] : Colors.grey[600],
                          decoration: isDeletedLine ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // زر الحذف
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'delete':
                        _showDeleteConfirmation(line, controller);
                        break;
                      case 'duplicate':
                        controller.duplicateProduct(line);
                        break;
                      case 'edit':
                        _showEditDialog(line, controller);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('تعديل'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Row(
                        children: [
                          Icon(Icons.copy, size: 18, color: Colors.green),
                          SizedBox(width: 8),
                          Text('نسخ'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('حذف'),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // خط فاصل
            Container(
              height: 1,
              color: Colors.grey[300],
              margin: const EdgeInsets.symmetric(horizontal: 4),
            ),

            const SizedBox(height: 16),

            // معلومات الكمية والوحدة
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الكمية',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildEditableQuantityField(line, controller, isDeletedLine),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الوحدة',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildUnitSelectionField(line, controller, isDeletedLine),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // معلومات إضافية
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue[100]!, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoColumn(
                      'الكمية الأساسية',
                      line.baseQty1?.toString() ?? '0',
                      Colors.blue[700]!,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.blue[200],
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                      'UomEntry',
                      line.uomEntry?.toString() ?? '0',
                      Colors.blue[700]!,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(ProductManagementController controller) {
    return Obx(() => FloatingActionButton(
          onPressed:
              controller.hasSelectedTransfer ? () => _showAddProductDialog(controller) : null,
          backgroundColor: controller.hasSelectedTransfer ? Colors.blue : Colors.grey,
          child: const Icon(Icons.add, color: Colors.white),
          tooltip: 'إضافة منتج جديد',
        ));
  }

  // تم تبسيط دالة الرجوع - فقط للعودة دون dialog
  void _handleBackPress(ProductManagementController controller) {
    Get.back();
  }

  void _showDeleteConfirmation(dynamic line, ProductManagementController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف المنتج "${line.itemCode}"؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteProduct(line);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(ProductManagementController controller) {
    // مثال بسيط - يمكن توسيعه لاحقاً
    Get.dialog(
      AlertDialog(
        title: const Text('إضافة منتج جديد'),
        content: const Text('سيتم إضافة واجهة إدخال المنتج هنا'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // مثال على إضافة منتج
              controller.addProduct({
                'itemCode': 'ITEM001',
                'description': 'منتج تجريبي',
                'quantity': 1.0,
                'price': 100.0,
                'uomCode': 'حبة',
                'baseQty1': 1,
                'uomEntry': 5,
              });
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(dynamic line, ProductManagementController controller) {
    // مثال بسيط - يمكن توسيعه لاحقاً
    Get.dialog(
      AlertDialog(
        title: Text('تعديل المنتج ${line.itemCode}'),
        content: const Text('سيتم إضافة واجهة تعديل المنتج هنا'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, Color textColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textColor.withOpacity(0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  // الحل النهائي لحقل الكمية - منع عكس الأرقام
  Widget _buildEditableQuantityField(
      dynamic line, ProductManagementController controller, bool isDisabled) {
    return Container(
      height: 48,
      child: TextFormField(
        // استخدام initialValue بدلاً من controller لتجنب مشكلة عكس الأرقام
        initialValue: line.quantity?.toStringAsFixed(0) ?? '0',
        enabled: !isDisabled,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly, // السماح بالأرقام فقط
          LengthLimitingTextInputFormatter(10), // تحديد طول أقصى
        ],
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDisabled ? Colors.grey : Colors.black87,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: isDisabled ? Colors.grey[200] : Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[400]!, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        onChanged: (value) {
          if (!isDisabled && value.isNotEmpty) {
            double? newQuantity = double.tryParse(value);
            if (newQuantity != null && newQuantity >= 0) {
              controller.updateProductQuantity(line, newQuantity);
            }
          }
        },
        onFieldSubmitted: (value) {
          if (!isDisabled) {
            if (value.isNotEmpty) {
              double? newQuantity = double.tryParse(value);
              if (newQuantity != null && newQuantity >= 0) {
                controller.updateProductQuantity(line, newQuantity);
              } else {
                // في حالة القيمة غير الصالحة، سيتم إعادة بناء الواجهة بالقيمة الأصلية
                controller.update();
              }
            } else {
              // إذا كان الحقل فارغاً، تعيين قيمة 0
              controller.updateProductQuantity(line, 0);
            }
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return null; // السماح بالقيم الفارغة مؤقتاً
          }
          double? quantity = double.tryParse(value);
          if (quantity == null || quantity < 0) {
            return 'يرجى إدخال رقم صحيح';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildUnitSelectionField(
      dynamic line, ProductManagementController controller, bool isDisabled) {
    return Container(
      height: 48,
      child: InkWell(
        onTap: isDisabled ? null : () => _showUnitSelectionDialog(line, controller),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isDisabled ? Colors.grey[200] : Colors.grey[50],
            border:
                Border.all(color: isDisabled ? Colors.grey[400]! : Colors.grey[300]!, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                line.uomCode ?? 'كرتون',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDisabled ? Colors.grey : Colors.black87,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDisabled ? Colors.grey : Colors.grey[600],
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnitSelectionDialog(dynamic line, ProductManagementController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'اختيار الوحدة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  _buildUnitSelectionCard('1', 'حبة', '5', line, controller),
                  _buildUnitSelectionCard('10', 'كرتون', '6', line, controller),
                  _buildUnitSelectionCard('12', 'شد 12', '25', line, controller),
                  _buildUnitSelectionCard('50', 'شد 50', '44', line, controller),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitSelectionCard(String baseQty, String unitName, String uomEntry, dynamic line,
      ProductManagementController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          try {
            Get.back();
            await Future.delayed(const Duration(milliseconds: 100));
            controller.updateProductUnit(
                line, unitName, int.tryParse(baseQty) ?? 1, int.tryParse(uomEntry) ?? 1);
          } catch (e) {
            print('خطأ في تحديث الوحدة: $e');
            if (Get.isDialogOpen ?? false) {
              Get.back();
            }
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: Colors.green[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unitName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'الكمية الأساسية: $baseQty',
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
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  uomEntry,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// pages/home/product/product_management_screen.dart

// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/show_transfer_card/product/product_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:auth_app/functions/status_request.dart';

// class ProductManagementScreen extends StatelessWidget {
//   const ProductManagementScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final ProductManagementController controller = Get.put(ProductManagementController());

//     // الحصول على transferId من arguments
//     final int? transferId = Get.arguments?['transferId'];

//     // إذا تم تمرير transferId، قم بتحميل البيانات
//     if (transferId != null) {
//       controller.loadTransferLines(transferId);
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       // appBar: AppBar(
//       //   title: const Text(
//       //     'سجل الاصناف',
//       //     style: TextStyle(
//       //       fontSize: 20,
//       //       fontWeight: FontWeight.bold,
//       //       color: Colors.white,
//       //     ),
//       //   ),
//       //   backgroundColor: Colors.grey[800],
//       //   elevation: 0,
//       //   actions: [
//       //     IconButton(
//       //       icon: const Icon(Icons.save, color: Colors.white),
//       //       onPressed: () => controller.saveChangesToServer(),
//       //     ),
//       //   ],
//       // ),
//       body: Obx(() {
//         if (controller.statusRequest.value == StatusRequest.loading &&
//             controller.transferLines.isEmpty) {
//           return const Center(
//             child: CircularProgressIndicator(
//               color: Colors.grey,
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
//                   'فشل في تحميل البيانات',
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.grey[600],
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (controller.transferId.value != null) {
//                       controller.loadTransferLines(controller.transferId.value!);
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey[800],
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text('إعادة المحاولة'),
//                 ),
//               ],
//             ),
//           );
//         }

//         if (controller.filteredLines.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.inventory_2_outlined,
//                   size: 80,
//                   color: Colors.grey[400],
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'لا توجد أصناف في هذا التحويل',
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.grey[600],
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         return Column(
//           children: [
//             // جدول الأصناف
//             Expanded(
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: SingleChildScrollView(
//                   child: _buildProductsTable(controller),
//                 ),
//               ),
//             ),
//           ],
//         );
//       }),
//     );
//   }

//   Widget _buildProductsTable(ProductManagementController controller) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey[300]!),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         children: [
//           // رأس الجدول
//           _buildTableHeader(),

//           // صفوف البيانات
//           ...controller.filteredLines.asMap().entries.map((entry) {
//             int index = entry.key;
//             var line = entry.value;
//             return _buildTableRow(line, index + 1, controller);
//           }).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildTableHeader() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey[800],
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(8),
//           topRight: Radius.circular(8),
//         ),
//       ),
//       child: const Row(
//         children: [
//           SizedBox(
//             width: 60,
//             child: _TableHeaderCell('#'),
//           ),
//           SizedBox(
//             width: 120,
//             child: _TableHeaderCell('رقم الصنف'),
//           ),
//           SizedBox(
//             width: 300,
//             child: _TableHeaderCell('اسم الصنف'),
//           ),
//           SizedBox(
//             width: 100,
//             child: _TableHeaderCell('الكمية'),
//           ),
//           SizedBox(
//             width: 120,
//             child: _TableHeaderCell('الوحدة'),
//           ),
//           SizedBox(
//             width: 120,
//             child: _TableHeaderCell('الكمية الأساسية'),
//           ),
//           SizedBox(
//             width: 100,
//             child: _TableHeaderCell('UomEntry'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTableRow(dynamic line, int rowNumber, ProductManagementController controller) {
//     return Container(
//       decoration: BoxDecoration(
//         color: rowNumber % 2 == 0 ? Colors.grey[50] : Colors.white,
//         border: Border(
//           bottom: BorderSide(color: Colors.grey[300]!),
//         ),
//       ),
//       child: Row(
//         children: [
//           // رقم الصف
//           SizedBox(
//             width: 60,
//             child: _TableDataCell(rowNumber.toString()),
//           ),

//           // رقم الصنف
//           SizedBox(
//             width: 120,
//             child: _TableDataCell(line.itemCode ?? ''),
//           ),

//           // اسم الصنف
//           SizedBox(
//             width: 300,
//             child: _TableDataCell(line.description ?? '', isLongText: true),
//           ),

//           // الكمية (قابلة للتعديل)
//           SizedBox(
//             width: 100,
//             child: _buildEditableQuantityCell(line, controller),
//           ),

//           // الوحدة
//           SizedBox(
//             width: 120,
//             child: _buildUnitSelectionCell(line, controller),
//           ),

//           // الكمية الأساسية
//           SizedBox(
//             width: 120,
//             child: _TableDataCell(line.baseQty1?.toString() ?? ''),
//           ),

//           // UomEntry
//           SizedBox(
//             width: 100,
//             child: _TableDataCell(line.uomEntry?.toString() ?? ''),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEditableQuantityCell(dynamic line, ProductManagementController controller) {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       child: TextField(
//         controller: TextEditingController(
//           text: line.quantity?.toStringAsFixed(0) ?? '0',
//         ),
//         keyboardType: TextInputType.number,
//         textAlign: TextAlign.center,
//         style: const TextStyle(fontSize: 14),
//         decoration: InputDecoration(
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(4),
//             borderSide: BorderSide(color: Colors.grey[300]!),
//           ),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           isDense: true,
//         ),
//         onChanged: (value) {
//           // تحديث الكمية
//           double? newQuantity = double.tryParse(value);
//           if (newQuantity != null) {
//             controller.updateProductQuantity(line, newQuantity);
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildUnitSelectionCell(dynamic line, ProductManagementController controller) {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       child: InkWell(
//         onTap: () => _showUnitSelectionDialog(line, controller),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           decoration: BoxDecoration(
//             color: Colors.grey[100],
//             border: Border.all(color: Colors.grey[300]!),
//             borderRadius: BorderRadius.circular(4),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 line.uomCode ?? 'كرتون',
//                 style: const TextStyle(fontSize: 14),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(width: 4),
//               const Icon(
//                 Icons.search,
//                 size: 16,
//                 color: Colors.grey,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showUnitSelectionDialog(dynamic line, ProductManagementController controller) {
//     Get.dialog(
//       Dialog(
//         child: Container(
//           width: 600,
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // عنوان النافذة
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'اختيار الوحدة',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () => Get.back(),
//                     icon: const Icon(Icons.close),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 20),

//               // جدول الوحدات
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey[300]!),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   children: [
//                     // رأس الجدول
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.grey[200],
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(8),
//                           topRight: Radius.circular(8),
//                         ),
//                       ),
//                       child: const Row(
//                         children: [
//                           Expanded(
//                               child: _TableHeaderCell('اختر', isSmall: true, color: Colors.black)),
//                           Expanded(
//                               child: _TableHeaderCell('الكمية الأساسية',
//                                   isSmall: true, color: Colors.black)),
//                           Expanded(
//                               child: _TableHeaderCell('اسم الوحدة',
//                                   isSmall: true, color: Colors.black)),
//                           Expanded(
//                               child:
//                                   _TableHeaderCell('UomEntry', isSmall: true, color: Colors.black)),
//                         ],
//                       ),
//                     ),

//                     // صفوف الوحدات المتاحة
//                     _buildUnitRow('اختيار', '1', 'حبة', '5', line, controller),
//                     _buildUnitRow('اختيار', '10', 'كرتون', '6', line, controller),
//                     _buildUnitRow('اختيار', '12', 'شد 12', '25', line, controller),
//                     _buildUnitRow('اختيار', '50', 'شد 50', '44', line, controller),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUnitRow(String buttonText, String baseQty, String unitName, String uomEntry,
//       dynamic line, ProductManagementController controller) {
//     return Container(
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(color: Colors.grey[300]!),
//         ),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               child: ElevatedButton(
//                 onPressed: () {
//                   // تطبيق اختيار الوحدة
//                   controller.updateProductUnit(
//                       line, unitName, int.tryParse(baseQty) ?? 1, int.tryParse(uomEntry) ?? 1);
//                   Get.back();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 8),
//                 ),
//                 child: Text(
//                   buttonText,
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: _TableDataCell(baseQty, isSmall: true),
//           ),
//           Expanded(
//             child: _TableDataCell(unitName, isSmall: true),
//           ),
//           Expanded(
//             child: _TableDataCell(uomEntry, isSmall: true),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _TableHeaderCell extends StatelessWidget {
//   final String text;
//   final bool isSmall;
//   final Color? color;

//   const _TableHeaderCell(this.text, {this.isSmall = false, this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(isSmall ? 8 : 12),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: color ?? Colors.white,
//           fontWeight: FontWeight.bold,
//           fontSize: isSmall ? 12 : 14,
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }

// class _TableDataCell extends StatelessWidget {
//   final String text;
//   final bool isSmall;
//   final bool isLongText;

//   const _TableDataCell(this.text, {this.isSmall = false, this.isLongText = false});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(isSmall ? 8 : 12),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: isSmall ? 12 : 14,
//         ),
//         textAlign: isLongText ? TextAlign.start : TextAlign.center,
//         maxLines: isLongText ? 2 : 1,
//         overflow: TextOverflow.ellipsis,
//       ),
//     );
//   }
// }
