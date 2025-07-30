// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class Product {
//   final int id;
//   final String name;
//   final String unit;
//   final int basicQuantity;
//   final int uomEntry;
//   final int quantity;
//   final int classNumber;

//   Product({
//     required this.id,
//     required this.name,
//     required this.unit,
//     required this.basicQuantity,
//     required this.uomEntry,
//     required this.quantity,
//     required this.classNumber,
//   });
// }

// class ProductController extends GetxController {
//   RxList<Product> products = <Product>[].obs;
//   RxBool isLoading = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     loadProducts();
//   }

//   void loadProducts() {
//     isLoading.value = true;

//     // محاكاة تحميل البيانات
//     Future.delayed(Duration(milliseconds: 500), () {
//       products.value = [
//         Product(
//           id: 04964,
//           name: 'دجاج أسترا مجمد 1000*10 جرام',
//           unit: 'كرتون',
//           basicQuantity: 10,
//           uomEntry: 6,
//           quantity: 150,
//           classNumber: 2,
//         ),
//         Product(
//           id: 05611,
//           name: 'دجاج أسترا مجمد 1200*10 جرام',
//           unit: 'كرتون',
//           basicQuantity: 10,
//           uomEntry: 6,
//           quantity: 50,
//           classNumber: 3,
//         ),
//         Product(
//           id: 04963,
//           name: 'دجاج أسترا مجمد 1100*10 جرام',
//           unit: 'كرتون',
//           basicQuantity: 10,
//           uomEntry: 6,
//           quantity: 50,
//           classNumber: 4,
//         ),
//         Product(
//           id: 15231,
//           name: 'دجاج أنتاج طازج 1000 جم',
//           unit: 'حبة',
//           basicQuantity: 1,
//           uomEntry: 5,
//           quantity: 1,
//           classNumber: 6,
//         ),
//         Product(
//           id: 15232,
//           name: 'دجاج أنتاج طازج 1100 جم',
//           unit: 'حبة',
//           basicQuantity: 1,
//           uomEntry: 5,
//           quantity: 1,
//           classNumber: 7,
//         ),
//         Product(
//           id: 16096,
//           name: 'لبدوءة دجاج طازج 900 جم',
//           unit: 'حبة',
//           basicQuantity: 1,
//           uomEntry: 5,
//           quantity: 3,
//           classNumber: 8,
//         ),
//       ];
//       isLoading.value = false;
//     });
//   }

//   void addProduct() {
//     // محاكاة إضافة منتج جديد
//     Get.snackbar(
//       'إضافة منتج',
//       'تم إضافة منتج جديد بنجاح',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//     );
//   }

//   void editProduct(Product product) {
//     Get.snackbar(
//       'تعديل منتج',
//       'تعديل المنتج: ${product.name}',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.orange,
//       colorText: Colors.white,
//     );
//   }

//   void deleteProduct(Product product) {
//     products.removeWhere((p) => p.id == product.id);
//     Get.snackbar(
//       'حذف منتج',
//       'تم حذف المنتج بنجاح',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//     );
//   }
// }
