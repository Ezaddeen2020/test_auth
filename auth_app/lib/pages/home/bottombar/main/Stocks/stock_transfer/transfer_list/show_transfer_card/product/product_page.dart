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
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: const Text(
      //     'سجل الاصناف',
      //     style: TextStyle(
      //       fontSize: 20,
      //       fontWeight: FontWeight.bold,
      //       color: Colors.white,
      //     ),
      //   ),
      //   backgroundColor: Colors.grey[800],
      //   elevation: 0,
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.save, color: Colors.white),
      //       onPressed: () => controller.saveChangesToServer(),
      //     ),
      //   ],
      // ),
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
            // جدول الأصناف
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: _buildProductsTable(controller),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildProductsTable(ProductManagementController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // رأس الجدول
          _buildTableHeader(),

          // صفوف البيانات
          ...controller.filteredLines.asMap().entries.map((entry) {
            int index = entry.key;
            var line = entry.value;
            return _buildTableRow(line, index + 1, controller);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 60,
            child: _TableHeaderCell('#'),
          ),
          SizedBox(
            width: 120,
            child: _TableHeaderCell('رقم الصنف'),
          ),
          SizedBox(
            width: 300,
            child: _TableHeaderCell('اسم الصنف'),
          ),
          SizedBox(
            width: 100,
            child: _TableHeaderCell('الكمية'),
          ),
          SizedBox(
            width: 120,
            child: _TableHeaderCell('الوحدة'),
          ),
          SizedBox(
            width: 120,
            child: _TableHeaderCell('الكمية الأساسية'),
          ),
          SizedBox(
            width: 100,
            child: _TableHeaderCell('UomEntry'),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(dynamic line, int rowNumber, ProductManagementController controller) {
    return Container(
      decoration: BoxDecoration(
        color: rowNumber % 2 == 0 ? Colors.grey[50] : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          // رقم الصف
          SizedBox(
            width: 60,
            child: _TableDataCell(rowNumber.toString()),
          ),

          // رقم الصنف
          SizedBox(
            width: 120,
            child: _TableDataCell(line.itemCode ?? ''),
          ),

          // اسم الصنف
          SizedBox(
            width: 300,
            child: _TableDataCell(line.description ?? '', isLongText: true),
          ),

          // الكمية (قابلة للتعديل)
          SizedBox(
            width: 100,
            child: _buildEditableQuantityCell(line, controller),
          ),

          // الوحدة
          SizedBox(
            width: 120,
            child: _buildUnitSelectionCell(line, controller),
          ),

          // الكمية الأساسية
          SizedBox(
            width: 120,
            child: _TableDataCell(line.baseQty1?.toString() ?? ''),
          ),

          // UomEntry
          SizedBox(
            width: 100,
            child: _TableDataCell(line.uomEntry?.toString() ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableQuantityCell(dynamic line, ProductManagementController controller) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: TextEditingController(
          text: line.quantity?.toStringAsFixed(0) ?? '0',
        ),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          isDense: true,
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

  Widget _buildUnitSelectionCell(dynamic line, ProductManagementController controller) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () => _showUnitSelectionDialog(line, controller),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                line.uomCode ?? 'كرتون',
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.search,
                size: 16,
                color: Colors.grey,
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
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(20),
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // جدول الوحدات
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // رأس الجدول
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                              child: _TableHeaderCell('اختر', isSmall: true, color: Colors.black)),
                          Expanded(
                              child: _TableHeaderCell('الكمية الأساسية',
                                  isSmall: true, color: Colors.black)),
                          Expanded(
                              child: _TableHeaderCell('اسم الوحدة',
                                  isSmall: true, color: Colors.black)),
                          Expanded(
                              child:
                                  _TableHeaderCell('UomEntry', isSmall: true, color: Colors.black)),
                        ],
                      ),
                    ),

                    // صفوف الوحدات المتاحة
                    _buildUnitRow('اختيار', '1', 'حبة', '5', line, controller),
                    _buildUnitRow('اختيار', '10', 'كرتون', '6', line, controller),
                    _buildUnitRow('اختيار', '12', 'شدة12', '25', line, controller),
                    _buildUnitRow('اختيار', '50', 'شدة50', '44', line, controller),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitRow(String buttonText, String baseQty, String unitName, String uomEntry,
      dynamic line, ProductManagementController controller) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () {
                  // تطبيق اختيار الوحدة
                  controller.updateProductUnit(
                      line, unitName, int.tryParse(baseQty) ?? 1, int.tryParse(uomEntry) ?? 1);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _TableDataCell(baseQty, isSmall: true),
          ),
          Expanded(
            child: _TableDataCell(unitName, isSmall: true),
          ),
          Expanded(
            child: _TableDataCell(uomEntry, isSmall: true),
          ),
        ],
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String text;
  final bool isSmall;
  final Color? color;

  const _TableHeaderCell(this.text, {this.isSmall = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 8 : 12),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: isSmall ? 12 : 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TableDataCell extends StatelessWidget {
  final String text;
  final bool isSmall;
  final bool isLongText;

  const _TableDataCell(this.text, {this.isSmall = false, this.isLongText = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 8 : 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isSmall ? 12 : 14,
        ),
        textAlign: isLongText ? TextAlign.start : TextAlign.center,
        maxLines: isLongText ? 2 : 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}









// // pages/home/product/product_management_screen.dart

// import 'package:auth_app/pages/home/salse/invice_page.dart';
// import 'package:auth_app/pages/home/salse/product_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:auth_app/functions/status_request.dart';

// class ProductManagementScreen extends StatelessWidget {
//   const ProductManagementScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final ProductManagementController controller = Get.put(ProductManagementController());

//     // الحصول على transferId من arguments إذا تم تمريره
//     final int? transferId = Get.arguments?['transferId'];

//     // إذا تم تمرير transferId، قم بتحميل البيانات
//     if (transferId != null) {
//       controller.loadTransferLines(transferId);
//     }

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Obx(() => Text(
//               controller.transferId.value != null
//                   ? 'أصناف التحويل رقم ${controller.transferId.value}'
//                   : 'إدارة الأصناف',
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             )),
//         backgroundColor: const Color(0xFF4CAF50), // لون مختلف عن InvoicePage
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh, color: Colors.white),
//             onPressed: () {
//               if (controller.transferId.value != null) {
//                 controller.loadTransferLines(controller.transferId.value!);
//               }
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.receipt_long, color: Colors.white),
//             onPressed: () {
//               if (controller.transferId.value != null) {
//                 // الانتقال إلى صفحة الهيدر (InvoicePage)
//                 Get.to(() => const InvoicePage(), arguments: {
//                   'transferId': controller.transferId.value,
//                 });
//               }
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.add, color: Colors.white),
//             onPressed: () => _showAddProductDialog(controller),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // معلومات التحويل المبسطة (من الهيدر)
//           _buildTransferHeaderInfo(controller),

//           // شريط البحث
//           _buildSearchSection(controller),

//           // إحصائيات سريعة
//           _buildStatsSection(controller),

//           // قائمة الأصناف
//           Expanded(
//             child: Obx(() {
//               if (controller.statusRequest.value == StatusRequest.loading &&
//                   controller.transferLines.isEmpty) {
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
//                         onPressed: () {
//                           if (controller.transferId.value != null) {
//                             controller.loadTransferLines(controller.transferId.value!);
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF4CAF50),
//                           foregroundColor: Colors.white,
//                         ),
//                         child: const Text('إعادة المحاولة'),
//                       ),
//                     ],
//                   ),
//                 );
//               }

//               if (controller.filteredLines.isEmpty) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.inventory_2_outlined,
//                         size: 80,
//                         color: Colors.grey[400],
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         controller.searchQuery.value.isNotEmpty
//                             ? 'لا توجد أصناف تطابق البحث'
//                             : 'لا توجد أصناف في هذا التحويل',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.grey[600],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       if (controller.transferId.value == null) ...[
//                         const SizedBox(height: 16),
//                         ElevatedButton.icon(
//                           onPressed: () => _showTransferSelectionDialog(controller),
//                           icon: const Icon(Icons.search),
//                           label: const Text('اختيار تحويل'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF2196F3),
//                             foregroundColor: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 );
//               }

//               return RefreshIndicator(
//                 onRefresh: () async {
//                   if (controller.transferId.value != null) {
//                     await controller.loadTransferLines(controller.transferId.value!);
//                   }
//                 },
//                 color: const Color(0xFF2196F3),
//                 child: ListView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: controller.filteredLines.length,
//                   itemBuilder: (context, index) {
//                     return _buildProductCard(
//                       controller.filteredLines[index],
//                       controller,
//                       index,
//                     );
//                   },
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//       floatingActionButton: Obx(() {
//         if (controller.transferId.value == null) {
//           return FloatingActionButton.extended(
//             onPressed: () => _showTransferSelectionDialog(controller),
//             backgroundColor: const Color(0xFF4CAF50),
//             icon: const Icon(Icons.search, color: Colors.white),
//             label: const Text('اختيار تحويل', style: TextStyle(color: Colors.white)),
//           );
//         }

//         return FloatingActionButton.extended(
//           onPressed: () => _showAddProductDialog(controller),
//           backgroundColor: const Color(0xFF4CAF50),
//           icon: const Icon(Icons.add, color: Colors.white),
//           label: const Text('إضافة صنف', style: TextStyle(color: Colors.white)),
//         );
//       }),
//     );
//   }

//   Widget _buildTransferHeaderInfo(ProductManagementController controller) {
//     return Obx(() {
//       if (controller.transferDetails.value?.header == null) {
//         return const SizedBox.shrink();
//       }

//       final header = controller.transferDetails.value!.header;

//       return Container(
//         margin: const EdgeInsets.all(16),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.green[50]!, Colors.green[100]!],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.green[200]!),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // عنوان القسم
//             Row(
//               children: [
//                 Icon(
//                   Icons.info_outline,
//                   color: Colors.green[700],
//                   size: 20,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   'معلومات التحويل',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green[700],
//                   ),
//                 ),
//                 const Spacer(),
//                 TextButton.icon(
//                   onPressed: () {
//                     Get.to(() => const InvoicePage(), arguments: {
//                       'transferId': header.id,
//                     });
//                   },
//                   icon: Icon(Icons.receipt_long, size: 16, color: Colors.green[700]),
//                   label: Text(
//                     'عرض التفاصيل الكاملة',
//                     style: TextStyle(fontSize: 12, color: Colors.green[700]),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 12),

//             // معلومات مختصرة
//             Row(
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildQuickInfo(
//                         'رقم المرجع',
//                         header.ref ?? 'غير محدد',
//                         Icons.tag,
//                       ),
//                       const SizedBox(height: 4),
//                       _buildQuickInfo(
//                         'المنشئ',
//                         header.creatby.trim(),
//                         Icons.person,
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   flex: 3,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildQuickInfo(
//                         'من',
//                         header.whsNameFrom.trim(),
//                         Icons.warehouse,
//                       ),
//                       const SizedBox(height: 4),
//                       _buildQuickInfo(
//                         'إلى',
//                         header.whsNameTo.trim(),
//                         Icons.warehouse,
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: _getStatusColor(header),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     _getStatusText(header),
//                     style: const TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildQuickInfo(String label, String value, IconData icon) {
//     return Row(
//       children: [
//         Icon(icon, size: 12, color: Colors.green[600]),
//         const SizedBox(width: 4),
//         Text(
//           '$label: ',
//           style: TextStyle(
//             fontSize: 11,
//             color: Colors.green[600],
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         Expanded(
//           child: Text(
//             value,
//             style: const TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.bold,
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }

//   Color _getStatusColor(dynamic header) {
//     if (header.sapPost) return Colors.green;
//     if (header.aproveRecive) return Colors.blue;
//     if (header.isSended) return Colors.orange;
//     return Colors.grey;
//   }

//   String _getStatusText(dynamic header) {
//     if (header.sapPost) return 'مرحل';
//     if (header.aproveRecive) return 'مستلم';
//     if (header.isSended) return 'مرسل';
//     return 'قيد التحضير';
//   }

//   Widget _buildSearchSection(ProductManagementController controller) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: const BoxDecoration(
//         color: Color(0xFF2196F3),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(20),
//           bottomRight: Radius.circular(20),
//         ),
//       ),
//       child: Column(
//         children: [
//           // شريط البحث
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   spreadRadius: 1,
//                   blurRadius: 5,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: TextField(
//               controller: controller.searchController,
//               onChanged: controller.updateSearch,
//               decoration: InputDecoration(
//                 hintText: 'البحث في الأصناف (كود الصنف أو الوصف)...',
//                 prefixIcon: const Icon(Icons.search, color: Color(0xFF4CAF50)),
//                 suffixIcon: Obx(() {
//                   if (controller.searchQuery.value.isNotEmpty) {
//                     return IconButton(
//                       icon: const Icon(Icons.clear),
//                       onPressed: () {
//                         controller.searchController.clear();
//                         controller.updateSearch('');
//                       },
//                     );
//                   }
//                   return const SizedBox.shrink();
//                 }),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide.none,
//                 ),
//                 filled: true,
//                 fillColor: Colors.white,
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               ),
//             ),
//           ),

//           // معلومات التحويل الحالي
//           Obx(() {
//             if (controller.transferId.value != null) {
//               return Container(
//                 margin: const EdgeInsets.only(top: 12),
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.info_outline, color: Colors.white, size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       'التحويل رقم: ${controller.transferId.value}',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const Spacer(),
//                     TextButton(
//                       onPressed: () => _showTransferSelectionDialog(controller),
//                       child: const Text(
//                         'تغيير',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }
//             return const SizedBox.shrink();
//           }),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatsSection(ProductManagementController controller) {
//     return Obx(() {
//       final stats = controller.getProductStats();

//       return Container(
//         margin: const EdgeInsets.all(16),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               spreadRadius: 1,
//               blurRadius: 5,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Expanded(
//               child: _buildStatItem(
//                 'إجمالي الأصناف',
//                 stats['totalItems'].toString(),
//                 Icons.inventory,
//                 Colors.blue,
//               ),
//             ),
//             Container(
//               width: 1,
//               height: 40,
//               color: Colors.grey[300],
//             ),
//             Expanded(
//               child: _buildStatItem(
//                 'إجمالي الكمية',
//                 stats['totalQuantity'].toStringAsFixed(2),
//                 Icons.shopping_cart,
//                 Colors.green,
//               ),
//             ),
//             Container(
//               width: 1,
//               height: 40,
//               color: Colors.grey[300],
//             ),
//             Expanded(
//               child: _buildStatItem(
//                 'إجمالي المبلغ',
//                 '${stats['totalAmount'].toStringAsFixed(2)} ر.س',
//                 Icons.monetization_on,
//                 Colors.orange,
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildStatItem(String title, String value, IconData icon, Color color) {
//     return Column(
//       children: [
//         Icon(icon, color: color, size: 24),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[600],
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildProductCard(dynamic line, ProductManagementController controller, int index) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // رأس البطاقة
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF4CAF50),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     '#${index + 1}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         line.itemCode ?? 'غير محدد',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF2196F3),
//                         ),
//                       ),
//                       if (line.description != null && line.description!.isNotEmpty)
//                         Text(
//                           line.description!,
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[600],
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                     ],
//                   ),
//                 ),
//                 PopupMenuButton<String>(
//                   onSelected: (value) => _handleProductAction(value, line, controller),
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
//                       value: 'delete',
//                       child: Row(
//                         children: [
//                           Icon(Icons.delete, size: 18, color: Colors.red),
//                           SizedBox(width: 8),
//                           Text('حذف'),
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
//                   ],
//                 ),
//               ],
//             ),

//             const SizedBox(height: 12),

//             // تفاصيل المنتج
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.grey[50],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildProductDetailItem(
//                           'الكمية',
//                           line.quantity?.toStringAsFixed(3) ?? '0',
//                           line.uomCode ?? '',
//                           Icons.shopping_cart,
//                           Colors.blue,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: _buildProductDetailItem(
//                           'السعر',
//                           '${line.price?.toStringAsFixed(2) ?? '0'} ر.س',
//                           'للوحدة',
//                           Icons.monetization_on,
//                           Colors.green,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildProductDetailItem(
//                           'المخزون',
//                           line.invQty?.toStringAsFixed(3) ?? '0',
//                           line.uomCode2 ?? '',
//                           Icons.inventory,
//                           Colors.orange,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: _buildProductDetailItem(
//                           'إجمالي السطر',
//                           '${line.lineTotal?.toStringAsFixed(2) ?? '0'} ر.س',
//                           '',
//                           Icons.calculate,
//                           Colors.purple,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // أزرار العمليات
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () => _editProduct(line, controller),
//                     icon: const Icon(Icons.edit, size: 16),
//                     label: const Text('تعديل'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: ElevatedButton.icon(
//                     onPressed: () => _duplicateProduct(line, controller),
//                     icon: const Icon(Icons.copy, size: 16),
//                     label: const Text('نسخ'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton.icon(
//                   onPressed: () => _deleteProduct(line, controller),
//                   icon: const Icon(Icons.delete, size: 16),
//                   label: const Text('حذف'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProductDetailItem(
//       String label, String value, String unit, IconData icon, Color color) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Icon(icon, size: 14, color: color),
//             const SizedBox(width: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: color,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 2),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         if (unit.isNotEmpty)
//           Text(
//             unit,
//             style: TextStyle(
//               fontSize: 11,
//               color: Colors.grey[600],
//             ),
//           ),
//       ],
//     );
//   }

//   void _handleProductAction(String action, dynamic line, ProductManagementController controller) {
//     switch (action) {
//       case 'edit':
//         _editProduct(line, controller);
//         break;
//       case 'delete':
//         _deleteProduct(line, controller);
//         break;
//       case 'duplicate':
//         _duplicateProduct(line, controller);
//         break;
//     }
//   }

//   void _editProduct(dynamic line, ProductManagementController controller) {
//     _showProductDialog(controller, line: line);
//   }

//   void _duplicateProduct(dynamic line, ProductManagementController controller) {
//     controller.duplicateProduct(line);
//   }

//   void _deleteProduct(dynamic line, ProductManagementController controller) {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('تأكيد الحذف'),
//         content: Text('هل تريد حذف الصنف "${line.itemCode ?? 'غير محدد'}"؟'),
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
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('حذف'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAddProductDialog(ProductManagementController controller) {
//     _showProductDialog(controller);
//   }

//   void _showProductDialog(ProductManagementController controller, {dynamic line}) {
//     // هنا يمكن إنشاء dialog لإضافة/تعديل المنتج
//     Get.dialog(
//       AlertDialog(
//         title: Text(line == null ? 'إضافة صنف جديد' : 'تعديل الصنف'),
//         content: const Text('سيتم إضافة نموذج إدخال البيانات هنا'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               // إضافة منطق الحفظ هنا
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF2196F3),
//               foregroundColor: Colors.white,
//             ),
//             child: Text(line == null ? 'إضافة' : 'حفظ'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showTransferSelectionDialog(ProductManagementController controller) {
//     final TextEditingController transferIdController = TextEditingController();

//     Get.dialog(
//       AlertDialog(
//         title: const Text('اختيار التحويل'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('أدخل رقم التحويل المراد إدارة أصنافه:'),
//             const SizedBox(height: 16),
//             TextField(
//               controller: transferIdController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: 'رقم التحويل',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.numbers),
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
//               String transferIdText = transferIdController.text.trim();
//               if (transferIdText.isNotEmpty) {
//                 int? transferId = int.tryParse(transferIdText);
//                 if (transferId != null) {
//                   Get.back();
//                   controller.loadTransferLines(transferId);
//                 } else {
//                   Get.snackbar(
//                     'خطأ',
//                     'يرجى إدخال رقم صحيح للتحويل',
//                     backgroundColor: Colors.red,
//                     colorText: Colors.white,
//                   );
//                 }
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF2196F3),
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('تحميل'),
//           ),
//         ],
//       ),
//     );
//   }
// }
