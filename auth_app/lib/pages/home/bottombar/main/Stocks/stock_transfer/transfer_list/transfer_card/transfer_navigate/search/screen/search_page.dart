// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/controllers/stock_controller.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/controllers/product_controller.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/screen/widgets/product_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class SearchPage extends StatelessWidget {
//   const SearchPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // final productController = Get.find<ProductManagementController>();
//     final productController = Get.put(ProductManagementController());

//     final controller2 = Get.find<StockController>();

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: Column(
//         children: [
//           // قسم البحث
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.blue[700],
//               borderRadius: const BorderRadius.only(
//                 bottomLeft: Radius.circular(30),
//                 bottomRight: Radius.circular(30),
//               ),
//             ),
//             padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
//             child: Column(
//               children: [
//                 // حقل البحث
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(15),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 10,
//                         offset: const Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: TextField(
//                     controller: controller2.itemCodeController,
//                     keyboardType: TextInputType.number,
//                     textAlign: TextAlign.right,
//                     decoration: const InputDecoration(
//                       hintText: 'ادخل رقم الصنف',
//                       hintStyle: TextStyle(color: Colors.grey),
//                       prefixIcon: Icon(Icons.search, color: Colors.blue),
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 15,
//                       ),
//                     ),
//                     onSubmitted: (value) => controller2.searchStock(),
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//                 // أزرار التحكم
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () => controller2.searchStock(),
//                         icon: const Icon(Icons.search, color: Colors.white),
//                         label: const Text(
//                           'بحث',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green[600],
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () => controller2.clearSearch(),
//                         icon: const Icon(Icons.clear, color: Colors.white),
//                         label: const Text(
//                           'مسح',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red[600],
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // محتوى الصفحة
//           Expanded(
//             child: Obx(() {
//               if (controller2.isLoading.value) {
//                 return const Center(
//                   child: CircularProgressIndicator(),
//                 );
//               }

//               if (!controller2.hasSearched.value) {
//                 return _buildWelcomeScreen();
//               }

//               if (controller2.stockItems.isEmpty) {
//                 return _buildNoDataScreen();
//               }

//               return _buildStockResults(controller2, productController);
//             }),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWelcomeScreen() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.inventory_2_outlined,
//             size: 80,
//             color: Colors.blue[300],
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'مرحباً بك في واجهة ادخال الاصناف',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[700],
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'أدخل رقم الصنف للبحث عن بيانات المخزون',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNoDataScreen() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.search_off,
//             size: 80,
//             color: Colors.orange[400],
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'لا توجد بيانات مخزون',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[700],
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'تأكد من رقم الصنف وحاول مرة أخرى',
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // تم إضافة productController كمعامل
//   Widget _buildStockResults(
//       StockController controller, ProductManagementController productController) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildCombinedCard(controller, productController),
//         ],
//       ),
//     );
//   }

//   // تم إضافة productController كمعامل
//   Widget _buildCombinedCard(
//       StockController controller, ProductManagementController productController) {
//     if (controller.stockItems.isEmpty) return const SizedBox();

//     final firstItem = controller.stockItems.first;

//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           gradient: LinearGradient(
//             colors: [Colors.blue[50]!, Colors.white],
//             begin: Alignment.topRight,
//             end: Alignment.bottomLeft,
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // قسم معلومات الصنف
//             Row(
//               children: [
//                 Icon(Icons.inventory, color: Colors.blue[700], size: 24),
//                 const SizedBox(width: 8),
//                 const Text(
//                   'معلومات الصنف',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const Divider(),
//             _buildInfoRow('كود الصنف:', firstItem.itemCode),
//             _buildInfoRow('اسم الصنف:', firstItem.itemName),

//             const SizedBox(height: 20),
//             const Divider(),
//             const SizedBox(height: 20),

//             // زر الحفظ - تم التصحيح
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   // التصحيح: استدعاء الدالة من ProductDialogs مباشرة
//                   ProductDialogs.showAddProductDialog(productController);
//                 },
//                 icon: const Icon(Icons.save, color: Colors.white),
//                 label: const Text(
//                   'اضافة صنف الى التحويل',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue[700],
//                   padding: const EdgeInsets.symmetric(vertical: 12),
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

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(fontSize: 14),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/controllers/stock_controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/controllers/product_controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/screen/widgets/product_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPage extends StatelessWidget {
  final int? transferId; // Add this parameter

  const SearchPage({super.key, this.transferId});

  @override
  Widget build(BuildContext context) {
    // Initialize or get the existing controller
    final productController = Get.put(ProductManagementController());
    final controller2 = Get.find<StockController>();

    // Set the transfer ID if provided
    if (transferId != null && transferId! > 0) {
      productController.setTransferId(transferId!);
      print('SearchPage: Transfer ID set to $transferId');
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // قسم البحث
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Column(
              children: [
                // حقل البحث
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller2.itemCodeController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      hintText: 'ادخل رقم الصنف',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.blue),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                    onSubmitted: (value) => controller2.searchStock(),
                  ),
                ),
                const SizedBox(height: 15),
                // أزرار التحكم
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => controller2.searchStock(),
                        icon: const Icon(Icons.search, color: Colors.white),
                        label: const Text(
                          'بحث',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => controller2.clearSearch(),
                        icon: const Icon(Icons.clear, color: Colors.white),
                        label: const Text(
                          'مسح',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // محتوى الصفحة
          Expanded(
            child: Obx(() {
              if (controller2.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!controller2.hasSearched.value) {
                return _buildWelcomeScreen();
              }

              if (controller2.stockItems.isEmpty) {
                return _buildNoDataScreen();
              }

              return _buildStockResults(controller2, productController);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.blue[300],
          ),
          const SizedBox(height: 20),
          Text(
            'مرحباً بك في واجهة ادخال الاصناف',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'أدخل رقم الصنف للبحث عن بيانات المخزون',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.orange[400],
          ),
          const SizedBox(height: 20),
          Text(
            'لا توجد بيانات مخزون',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'تأكد من رقم الصنف وحاول مرة أخرى',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockResults(
      StockController controller, ProductManagementController productController) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCombinedCard(controller, productController),
        ],
      ),
    );
  }

  Widget _buildCombinedCard(
      StockController controller, ProductManagementController productController) {
    if (controller.stockItems.isEmpty) return const SizedBox();

    final firstItem = controller.stockItems.first;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.white],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم معلومات الصنف
            Row(
              children: [
                Icon(Icons.inventory, color: Colors.blue[700], size: 24),
                const SizedBox(width: 8),
                const Text(
                  'معلومات الصنف',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('كود الصنف:', firstItem.itemCode),
            _buildInfoRow('اسم الصنف:', firstItem.itemName),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),

            // زر الحفظ - مع التحقق من Transfer ID
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // التحقق من وجود Transfer ID
                  if (productController.transferId.value == null) {
                    Get.snackbar(
                      'خطأ',
                      'يجب تحديد التحويل أولاً قبل إضافة الأصناف',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 3),
                    );
                    return;
                  }

                  // إضافة المنتج مع البيانات المسحوبة
                  ProductDialogs.showAddProductDialog(
                    productController,
                    prefilledItemCode: firstItem.itemCode,
                    prefilledDescription: firstItem.itemName,
                    prefilledUnit: firstItem.uomCode,
                    prefilledQuantity: firstItem.totalOnHand > 0 ? firstItem.totalOnHand : 1.0,
                    prefilledPrice: firstItem.avgPrice > 0 ? firstItem.avgPrice : 0.0,
                  );
                },
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'اضافة صنف الى التحويل',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            // Display current transfer ID for debugging
            if (transferId != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Transfer ID: $transferId',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/purchase_controller.dart';

// class SearchPage extends StatelessWidget {
//   const SearchPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<TransferNavigationController>();

//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(30),
//           topRight: Radius.circular(30),
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             const SizedBox(height: 20),

//             // Search Box
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: const Color.fromARGB(255, 26, 118, 193),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(
//                     Icons.search,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Obx(
//                     () => TextFormField(
//                       controller: controller.searchController,
//                       decoration: InputDecoration(
//                         hintText: 'بحث (اسم، باركود، رقم صنف)',
//                         hintStyle: const TextStyle(color: Colors.grey),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: const BorderSide(color: Colors.blueGrey),
//                         ),
//                         suffixIcon: controller.searchText.isNotEmpty
//                             ? IconButton(
//                                 icon: const Icon(Icons.clear),
//                                 onPressed: controller.clearSearch,
//                               )
//                             : null,
//                       ),
//                       onFieldSubmitted: controller.performSearch,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Obx(() => ElevatedButton(
//                       onPressed: controller.isSearching
//                           ? null
//                           : () => controller.performSearch(controller.searchController.text),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF2196F3),
//                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                       ),
//                       child: controller.isSearching
//                           ? const SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                           : const Text(
//                               'بحث',
//                               style: TextStyle(color: Colors.white),
//                             ),
//                     )),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // Search Type Filter Buttons
//             Row(
//               children: [
//                 Expanded(
//                   child: Obx(() {
//                     final bool isSelected = controller.selectedSearchType == 'name';
//                     return GestureDetector(
//                       onTap: () => controller.setSearchType('name'),
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//                         decoration: BoxDecoration(
//                           color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
//                           border: Border.all(
//                             color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade300,
//                             width: isSelected ? 2 : 1,
//                           ),
//                           borderRadius: BorderRadius.circular(20),
//                           boxShadow: isSelected
//                               ? [
//                                   BoxShadow(
//                                     color: const Color(0xFF2196F3).withOpacity(0.3),
//                                     spreadRadius: 1,
//                                     blurRadius: 4,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ]
//                               : null,
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.text_fields,
//                               size: 16,
//                               color: isSelected ? Colors.white : Colors.black87,
//                             ),
//                             const SizedBox(width: 4),
//                             Flexible(
//                               child: Text(
//                                 'اسم الصنف',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: isSelected ? Colors.white : Colors.black87,
//                                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Obx(() {
//                     final bool isSelected = controller.selectedSearchType == 'barcode';
//                     return GestureDetector(
//                       onTap: () => controller.setSearchType('barcode'),
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//                         decoration: BoxDecoration(
//                           color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
//                           border: Border.all(
//                             color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade300,
//                             width: isSelected ? 2 : 1,
//                           ),
//                           borderRadius: BorderRadius.circular(20),
//                           boxShadow: isSelected
//                               ? [
//                                   BoxShadow(
//                                     color: const Color(0xFF2196F3).withOpacity(0.3),
//                                     spreadRadius: 1,
//                                     blurRadius: 4,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ]
//                               : null,
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.qr_code,
//                               size: 16,
//                               color: isSelected ? Colors.white : Colors.black87,
//                             ),
//                             const SizedBox(width: 4),
//                             Flexible(
//                               child: Text(
//                                 'باركود',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: isSelected ? Colors.white : Colors.black87,
//                                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Obx(() {
//                     final bool isSelected = controller.selectedSearchType == 'number';
//                     return GestureDetector(
//                       onTap: () => controller.setSearchType('number'),
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//                         decoration: BoxDecoration(
//                           color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
//                           border: Border.all(
//                             color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade300,
//                             width: isSelected ? 2 : 1,
//                           ),
//                           borderRadius: BorderRadius.circular(20),
//                           boxShadow: isSelected
//                               ? [
//                                   BoxShadow(
//                                     color: const Color(0xFF2196F3).withOpacity(0.3),
//                                     spreadRadius: 1,
//                                     blurRadius: 4,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ]
//                               : null,
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.numbers,
//                               size: 16,
//                               color: isSelected ? Colors.white : Colors.black87,
//                             ),
//                             const SizedBox(width: 4),
//                             Flexible(
//                               child: Text(
//                                 'رقم الصنف',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: isSelected ? Colors.white : Colors.black87,
//                                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 30),

//             // Search Results
//             Expanded(
//               child: Obx(() => controller.isSearching
//                   ? const Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           CircularProgressIndicator(
//                             color: Color(0xFF2196F3),
//                           ),
//                           SizedBox(height: 16),
//                           Text(
//                             'جاري البحث...',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                   : Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.search_off,
//                             size: 80,
//                             color: Colors.grey[400],
//                           ),
//                           const SizedBox(height: 20),
//                           Text(
//                             'ابدأ البحث لعرض النتائج',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           Text(
//                             'نوع البحث الحالي: ${controller.getSearchTypeLabel()}',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[500],
//                             ),
//                           ),
//                         ],
//                       ),
//                     )),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
