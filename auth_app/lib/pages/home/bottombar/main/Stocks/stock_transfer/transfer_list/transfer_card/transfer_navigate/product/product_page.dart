// pages/home/product/product_management_screen.dart

import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/show_transfer_card/product/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/functions/status_request.dart';

class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductManagementController controller = Get.put(ProductManagementController());

    // الحصول على transferId من arguments
    final int? transferId = Get.arguments?['transferId'];

    // إذا تم تمرير transferId، قم بتحميل البيانات
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

        if (controller.filteredLines.isEmpty) {
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

        return Column(
          children: [
            // قائمة البطاقات
            Expanded(
              child: _buildProductCardsList(controller),
            ),
          ],
        );
      }),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس البطاقة - رقم الصنف واسم الصنف
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.itemCode ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        line.description ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // خط فاصل مع لون مميز
            Container(
              height: 1,
              color: Colors.grey[300],
              margin: const EdgeInsets.symmetric(horizontal: 4),
            ),

            const SizedBox(height: 16),

            // معلومات الكمية والوحدة
            Row(
              children: [
                // الكمية
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
                      _buildEditableQuantityField(line, controller),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // الوحدة
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
                      _buildUnitSelectionField(line, controller),
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

  Widget _buildEditableQuantityField(dynamic line, ProductManagementController controller) {
    return Container(
      height: 48,
      child: TextField(
        controller: TextEditingController(
          text: line.quantity?.toStringAsFixed(0) ?? '0',
        ),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[50],
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          isDense: false,
        ),
        onChanged: (value) {
          // تحديث الكمية
          double? newQuantity = double.tryParse(value);
          if (newQuantity != null) {
            controller.updateProductQuantity(line, newQuantity);
          }
        },
      ),
    );
  }

  Widget _buildUnitSelectionField(dynamic line, ProductManagementController controller) {
    return Container(
      height: 48,
      child: InkWell(
        onTap: () => _showUnitSelectionDialog(line, controller),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[300]!, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                line.uomCode ?? 'كرتون',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.grey[600],
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
              // عنوان النافذة
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

              // قائمة الوحدات
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
            // إغلاق النافذة أولاً
            Get.back();

            // ثم تطبيق اختيار الوحدة
            await Future.delayed(const Duration(milliseconds: 100));
            controller.updateProductUnit(
                line, unitName, int.tryParse(baseQty) ?? 1, int.tryParse(uomEntry) ?? 1);
          } catch (e) {
            print('خطأ في تحديث الوحدة: $e');
            // في حالة حدوث خطأ، تأكد من إغلاق النافذة
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
              // أيقونة الاختيار
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

              // معلومات الوحدة
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

              // UomEntry
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
