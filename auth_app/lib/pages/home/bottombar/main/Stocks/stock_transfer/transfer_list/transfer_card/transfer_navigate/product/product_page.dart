import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/product_controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/widgets/floating_add_btn.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/widgets/product_card.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/widgets/product_dialog.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/widgets/product_status_bar.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/widgets/save_changes_btn.dart';
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















// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/product_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:auth_app/functions/status_request.dart';

// class ProductManagementScreen extends StatelessWidget {
//   const ProductManagementScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final ProductManagementController controller = Get.put(ProductManagementController());

//     final int? transferId = Get.arguments?['transferId'];

//     if (transferId != null) {
//       controller.loadTransferLines(transferId);
//     }

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
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
//           return _buildErrorState(controller);
//         }

//         if (controller.filteredLines.isEmpty) {
//           return _buildEmptyState();
//         }

//         return Column(
//           children: [
//             // شريط الإحصائيات والأزرار
//             _buildStatsAndActionsBar(controller),

//             // Save Button - يظهر عند وجود تغييرات غير محفوظة
//             Obx(() => controller.hasUnsavedChanges.value
//                 ? _buildSaveChangesButton(controller)
//                 : const SizedBox.shrink()),

//             // قائمة البطاقات
//             Expanded(
//               child: _buildProductCardsList(controller),
//             ),
//           ],
//         );
//       }),
//       floatingActionButton: _buildFloatingActionButton(controller),
//     );
//   }

//   // زر الحفظ الجديد - يظهر عند وجود تغييرات
//   Widget _buildSaveChangesButton(ProductManagementController controller) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.blue[600]!, Colors.blue[700]!],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.blue.withOpacity(0.3),
//             spreadRadius: 1,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: controller.canSave ? () => controller.saveAllChangesToServer() : null,
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 14),
//             child: Obx(() => Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     if (controller.isSaving.value) ...[
//                       const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       const Text(
//                         'جاري الحفظ...',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ] else ...[
//                       const Icon(
//                         Icons.save,
//                         color: Colors.white,
//                         size: 22,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         'حفظ التغييرات (${controller.unsavedChangesCount})',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ],
//                 )),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsAndActionsBar(ProductManagementController controller) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       color: Colors.white,
//       child: Column(
//         children: [
//           // شريط البحث
//           TextField(
//             controller: controller.searchController,
//             onChanged: controller.updateSearch,
//             decoration: InputDecoration(
//               hintText: 'بحث بكود الصنف أو الوصف...',
//               prefixIcon: const Icon(Icons.search, color: Colors.grey),
//               suffixIcon: Obx(() => controller.hasActiveSearch
//                   ? IconButton(
//                       icon: const Icon(Icons.clear, color: Colors.grey),
//                       onPressed: controller.clearSearch,
//                     )
//                   : const SizedBox.shrink()),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: Colors.grey[300]!),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: Colors.grey[300]!),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: const BorderSide(color: Colors.blue),
//               ),
//               filled: true,
//               fillColor: Colors.grey[50],
//             ),
//           ),

//           const SizedBox(height: 12),

//           // الإحصائيات مع مؤشر تحميل الوحدات
//           Row(
//             children: [
//               Obx(() {
//                 final stats = controller.getProductStats();
//                 return Expanded(
//                   flex: 3,
//                   child: Row(
//                     children: [
//                       _buildStatCard('إجمالي الأصناف', '${stats['totalItems']}', Icons.inventory),
//                       const SizedBox(width: 8),
//                       _buildStatCard('إجمالي الكمية',
//                           '${stats['totalQuantity'].toStringAsFixed(0)}', Icons.numbers),
//                       const SizedBox(width: 8),
//                       _buildStatCard('أصناف مختلفة', '${stats['uniqueItems']}', Icons.category),
//                     ],
//                   ),
//                 );
//               }),

//               // مؤشر تحميل الوحدات - محدث
//               Obx(() => controller.isLoadingUnits.value
//                   ? Container(
//                       margin: const EdgeInsets.only(left: 12),
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.blue[200]!),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.blue[600],
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             'تحميل الوحدات...',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.blue[700],
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   : const SizedBox.shrink()),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(String title, String value, IconData icon) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color: Colors.blue[50],
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.blue[100]!),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 16, color: Colors.blue[700]),
//             const SizedBox(width: 6),
//             Flexible(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: Colors.blue[700],
//                       fontWeight: FontWeight.w500,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   Text(
//                     value,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue[800],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorState(ProductManagementController controller) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.error_outline,
//             size: 80,
//             color: Colors.grey[400],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'فشل في تحميل البيانات',
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () {
//               if (controller.transferId.value != null) {
//                 controller.loadTransferLines(controller.transferId.value!);
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.grey[800],
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('إعادة المحاولة'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.inventory_2_outlined,
//             size: 80,
//             color: Colors.grey[400],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'لا توجد أصناف في هذا التحويل',
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProductCardsList(ProductManagementController controller) {
//     return ListView.builder(
//       key: const PageStorageKey<String>('products_list'), // للاحتفاظ بالـ scroll position

//       padding: const EdgeInsets.all(16),
//       itemCount: controller.filteredLines.length,
//       addAutomaticKeepAlives: false, // توفير ذاكرة
//       addRepaintBoundaries: true, // تحسين الرسم
//       itemBuilder: (context, index) {
//         final line = controller.filteredLines[index];
//         return _buildProductCard(line, index + 1, controller);
//       },
//     );
//   }

//   Widget _buildProductCard(dynamic line, int rowNumber, ProductManagementController controller) {
//     // تحديد حالة السطر (جديد، معدل، أو عادي)
//     bool isNewLine = line.lineNum != null && line.lineNum! < 0;
//     bool isModifiedLine = controller.modifiedLines.containsKey(line.lineNum);
//     bool isDeletedLine = controller.deletedLines.contains(line.lineNum);

//     Color borderColor = Colors.grey[200]!;
//     Color statusColor = Colors.transparent;
//     String statusText = '';

//     if (isDeletedLine) {
//       borderColor = Colors.red[300]!;
//       statusColor = Colors.red[50]!;
//       statusText = 'محذوف';
//     } else if (isNewLine) {
//       borderColor = Colors.green[300]!;
//       statusColor = Colors.green[50]!;
//       statusText = 'جديد';
//     } else if (isModifiedLine) {
//       borderColor = Colors.orange[300]!;
//       statusColor = Colors.orange[50]!;
//       statusText = 'معدل';
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: statusColor.alpha == 0 ? Colors.white : statusColor,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//         border: Border.all(color: borderColor, width: 1.5),
//       ),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // رأس البطاقة مع حالة السطر
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[800],
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     '$rowNumber',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),

//                 if (statusText.isNotEmpty) ...[
//                   const SizedBox(width: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color:
//                           isDeletedLine ? Colors.red : (isNewLine ? Colors.green : Colors.orange),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       statusText,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],

//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         line.itemCode ?? '',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: isDeletedLine ? Colors.red[700] : Colors.black87,
//                           decoration: isDeletedLine ? TextDecoration.lineThrough : null,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         line.description ?? '',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: isDeletedLine ? Colors.red[600] : Colors.grey[600],
//                           decoration: isDeletedLine ? TextDecoration.lineThrough : null,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),

//                 // قائمة الخيارات
//                 PopupMenuButton<String>(
//                   onSelected: (value) {
//                     switch (value) {
//                       case 'delete':
//                         _showDeleteConfirmation(line, controller);
//                         break;
//                       case 'duplicate':
//                         controller.duplicateProduct(line);
//                         break;
//                       case 'edit':
//                         _showEditDialog(line, controller);
//                         break;
//                     }
//                   },
//                   itemBuilder: (context) => [
//                     const PopupMenuItem(
//                       value: 'edit',
//                       child: Row(
//                         children: [
//                           Icon(Icons.edit, size: 18, color: Colors.blue),
//                           SizedBox(width: 8),
//                           Text('تعديل'),
//                         ],
//                       ),
//                     ),
//                     const PopupMenuItem(
//                       value: 'duplicate',
//                       child: Row(
//                         children: [
//                           Icon(Icons.copy, size: 18, color: Colors.green),
//                           SizedBox(width: 8),
//                           Text('نسخ'),
//                         ],
//                       ),
//                     ),
//                     const PopupMenuItem(
//                       value: 'delete',
//                       child: Row(
//                         children: [
//                           Icon(Icons.delete, size: 18, color: Colors.red),
//                           SizedBox(width: 8),
//                           Text('حذف'),
//                         ],
//                       ),
//                     ),
//                   ],
//                   child: Icon(
//                     Icons.more_vert,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             // خط فاصل
//             Container(
//               height: 1,
//               color: Colors.grey[300],
//               margin: const EdgeInsets.symmetric(horizontal: 4),
//             ),

//             const SizedBox(height: 16),

//             // معلومات الكمية والوحدة
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'الكمية',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey[700],
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       _buildEditableQuantityField(line, controller, isDeletedLine),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'الوحدة',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey[700],
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       _buildUnitSelectionField(line, controller, isDeletedLine),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             // معلومات إضافية
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
//               decoration: BoxDecoration(
//                 color: Colors.blue[50],
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: Colors.blue[100]!, width: 1),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: _buildInfoColumn(
//                       'الكمية الأساسية',
//                       line.baseQty1?.toString() ?? '0',
//                       Colors.blue[700]!,
//                     ),
//                   ),
//                   Container(
//                     width: 2,
//                     height: 35,
//                     decoration: BoxDecoration(
//                       color: Colors.blue[200],
//                       borderRadius: BorderRadius.circular(1),
//                     ),
//                   ),
//                   Expanded(
//                     child: _buildInfoColumn(
//                       'UomEntry',
//                       line.uomEntry?.toString() ?? '0',
//                       Colors.blue[700]!,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // الحل النهائي لحقل الكمية - منع عكس الأرقام
//   Widget _buildEditableQuantityField(
//       dynamic line, ProductManagementController controller, bool isDisabled) {
//     // إنشاء controller محلي مع قيمة محدثة
//     // final TextEditingController quantityController =
//     //     TextEditingController(text: line.quantity?.toStringAsFixed(0) ?? '0');

//     // التنظيف عند إعادة البناء
//     // WidgetsBinding.instance.addPostFrameCallback((_) {
//     //   if (!quantityController.hasListeners) {
//     //     quantityController.addListener(() {
//     //       // منع الحلقة اللا نهائية
//     //     });
//     //   }
//     // });
//     return Container(
//       height: 48,
//       child: TextFormField(
//         // استخدام initialValue بدلاً من controller لتجنب مشكلة عكس الأرقام
//         initialValue: line.quantity?.toStringAsFixed(0) ?? '0',
//         // controller: quantityController, // استخدام controller بدلاً من initialValue

//         enabled: !isDisabled,
//         keyboardType: TextInputType.number,
//         textAlign: TextAlign.center,
//         inputFormatters: [
//           FilteringTextInputFormatter.digitsOnly, // السماح بالأرقام فقط
//           LengthLimitingTextInputFormatter(10), // تحديد طول أقصى
//         ],
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: isDisabled ? Colors.grey : Colors.black87,
//         ),
//         decoration: InputDecoration(
//           filled: true,
//           fillColor: isDisabled ? Colors.grey[200] : Colors.grey[50],
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
//           ),
//           disabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: BorderSide(color: Colors.grey[400]!, width: 1),
//           ),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//         ),
//         onChanged: (value) {
//           if (!isDisabled && value.isNotEmpty) {
//             double? newQuantity = double.tryParse(value);
//             if (newQuantity != null && newQuantity >= 0) {
//               controller.updateProductQuantity(line, newQuantity);
//             }
//           }
//         },
//         onFieldSubmitted: (value) {
//           if (!isDisabled) {
//             if (value.isNotEmpty) {
//               double? newQuantity = double.tryParse(value);
//               if (newQuantity != null && newQuantity >= 0) {
//                 controller.updateProductQuantity(line, newQuantity);
//               } else {
//                 // في حالة القيمة غير الصالحة، سيتم إعادة بناء الواجهة بالقيمة الأصلية
//                 controller.update();
//               }
//             } else {
//               // إذا كان الحقل فارغاً، تعيين قيمة 0
//               controller.updateProductQuantity(line, 0);
//             }
//           }
//         },
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return null; // السماح بالقيم الفارغة مؤقتاً
//           }
//           double? quantity = double.tryParse(value);
//           if (quantity == null || quantity < 0) {
//             return 'يرجى إدخال رقم صحيح';
//           }
//           return null;
//         },
//       ),
//     );
//   }

//   // حقل اختيار الوحدة - محدث مع تحسينات
//   Widget _buildUnitSelectionField(
//       dynamic line, ProductManagementController controller, bool isDisabled) {
//     return SizedBox(
//       height: 48,
//       child: InkWell(
//         onTap: isDisabled
//             ? null
//             : () {
//                 // التحقق من وجود كود الصنف قبل عرض الوحدات
//                 if (line.itemCode != null && line.itemCode!.isNotEmpty) {
//                   controller.showUnitSelectionDialog(line);
//                 } else {
//                   Get.snackbar(
//                     'خطأ',
//                     'كود الصنف غير متوفر',
//                     backgroundColor: Colors.red,
//                     colorText: Colors.white,
//                   );
//                 }
//               },
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//           decoration: BoxDecoration(
//             color: isDisabled ? Colors.grey[200] : Colors.grey[50],
//             border:
//                 Border.all(color: isDisabled ? Colors.grey[400]! : Colors.grey[300]!, width: 1.5),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // عرض اسم الوحدة مع حالة التحميل
//               Expanded(
//                 child: Obx(() {
//                   // التحقق من حالة تحميل الوحدات للصنف الحالي
//                   bool isLoadingCurrentItem = controller.isLoadingUnits.value;

//                   if (isLoadingCurrentItem) {
//                     return Row(
//                       children: [
//                         const SizedBox(
//                           width: 16,
//                           height: 16,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: Color.fromARGB(255, 0, 13, 23),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           'جاري التحميل...',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.blue[600],
//                           ),
//                         ),
//                       ],
//                     );
//                   }

//                   return Text(
//                     line.uomCode?.isNotEmpty == true ? line.uomCode! : 'اختر الوحدة',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: isDisabled ? Colors.grey : Colors.black87,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   );
//                 }),
//               ),
//               Icon(
//                 Icons.keyboard_arrow_down_rounded,
//                 color: isDisabled ? Colors.grey : Colors.grey[600],
//                 size: 24,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFloatingActionButton(ProductManagementController controller) {
//     return Obx(() => FloatingActionButton(
//           onPressed:
//               controller.hasSelectedTransfer ? () => _showAddProductDialog(controller) : null,
//           backgroundColor: controller.hasSelectedTransfer ? Colors.blue : Colors.grey,
//           tooltip: 'إضافة منتج جديد',
//           child: const Icon(Icons.add, color: Colors.white),
//         ));
//   }

//   void _showDeleteConfirmation(dynamic line, ProductManagementController controller) {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('تأكيد الحذف'),
//         content: Text('هل تريد حذف المنتج "${line.itemCode}"؟'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               controller.deleteProduct(line);
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('حذف', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAddProductDialog(ProductManagementController controller) {
//     final TextEditingController itemCodeController = TextEditingController();
//     final TextEditingController descriptionController = TextEditingController();
//     final TextEditingController quantityController = TextEditingController();
//     final TextEditingController priceController = TextEditingController();

//     Get.dialog(
//       AlertDialog(
//         title: const Text('إضافة منتج جديد'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: itemCodeController,
//                 decoration: const InputDecoration(
//                   labelText: 'كود الصنف',
//                   hintText: 'أدخل كود الصنف',
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: descriptionController,
//                 decoration: const InputDecoration(
//                   labelText: 'وصف الصنف',
//                   hintText: 'أدخل وصف الصنف',
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: quantityController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: 'الكمية',
//                   hintText: 'أدخل الكمية',
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: priceController,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(
//                   labelText: 'السعر',
//                   hintText: 'أدخل السعر',
//                 ),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (itemCodeController.text.trim().isEmpty ||
//                   quantityController.text.trim().isEmpty) {
//                 Get.snackbar(
//                   'خطأ',
//                   'يرجى إدخال كود الصنف والكمية',
//                   backgroundColor: Colors.red,
//                   colorText: Colors.white,
//                 );
//                 return;
//               }

//               double? quantity = double.tryParse(quantityController.text.trim());
//               double? price = double.tryParse(priceController.text.trim());

//               if (quantity == null || quantity <= 0) {
//                 Get.snackbar(
//                   'خطأ',
//                   'يرجى إدخال كمية صحيحة',
//                   backgroundColor: Colors.red,
//                   colorText: Colors.white,
//                 );
//                 return;
//               }

//               if (price == null || price < 0) {
//                 price = 0.0;
//               }

//               Get.back();

//               // إضافة المنتج الجديد
//               controller.addProduct({
//                 'itemCode': itemCodeController.text.trim(),
//                 'description': descriptionController.text.trim(),
//                 'quantity': quantity,
//                 'price': price,
//                 'uomCode': 'حبة',
//                 'baseQty1': 1,
//                 'uomEntry': 1,
//               });
//             },
//             child: const Text('إضافة'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showEditDialog(dynamic line, ProductManagementController controller) {
//     final TextEditingController quantityController =
//         TextEditingController(text: line.quantity?.toString() ?? '0');
//     final TextEditingController priceController =
//         TextEditingController(text: line.price?.toString() ?? '0');

//     Get.dialog(
//       AlertDialog(
//         title: Text('تعديل المنتج ${line.itemCode}'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               line.description ?? '',
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: quantityController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: 'الكمية',
//                 hintText: 'أدخل الكمية',
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: priceController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: 'السعر',
//                 hintText: 'أدخل السعر',
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               double? quantity = double.tryParse(quantityController.text.trim());
//               double? price = double.tryParse(priceController.text.trim());

//               if (quantity == null || quantity < 0) {
//                 Get.snackbar(
//                   'خطأ',
//                   'يرجى إدخال كمية صحيحة',
//                   backgroundColor: Colors.red,
//                   colorText: Colors.white,
//                 );
//                 return;
//               }

//               if (price == null || price < 0) {
//                 price = 0.0;
//               }

//               Get.back();

//               // تحديث الكمية والسعر
//               controller.updateProductQuantity(line, quantity);
//               if (price != line.price) {
//                 controller.updateProduct(line, {
//                   'quantity': quantity,
//                   'price': price,
//                 });
//               }
//             },
//             child: const Text('حفظ'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoColumn(String label, String value, Color textColor) {
//     return Column(
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: textColor.withOpacity(0.7),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const SizedBox(height: 6),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: textColor,
//           ),
//         ),
//       ],
//     );
//   }
// }

