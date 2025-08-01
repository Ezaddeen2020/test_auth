import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/services/stock_api.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/model/stock_model.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StockController extends GetxController {
  final StockApi stockApi = StockApi(PostGetPage());

  // المتغيرات التفاعلية
  var stockItems = <StockModel>[].obs;
  var isLoading = false.obs;
  var itemCodeController = TextEditingController();
  var hasSearched = false.obs;

  @override
  void onClose() {
    itemCodeController.dispose();
    super.onClose();
  }

  // // البحث عن المخزون
  Future<void> searchStock() async {
    String itemCode = itemCodeController.text.trim();

    if (itemCode.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال رقم الصنف',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    isLoading.value = true;
    EasyLoading.show(status: 'جاري البحث...');

    try {
      var response = await stockApi.getStockByItemCode(itemCode);

      if (response['status'] == 'success') {
        List<dynamic> data = response['data'] ?? [];
        stockItems.value = data.map((item) => StockModel.fromJson(item)).toList();
        hasSearched.value = true;

        if (stockItems.isEmpty) {
          Get.snackbar(
            'نتيجة البحث',
            'لا توجد بيانات مخزون لهذا الصنف',
            backgroundColor: Colors.orange.withOpacity(0.8),
            colorText: Colors.white,
            icon: const Icon(Icons.info, color: Colors.white),
          );
        }
      } else {
        Get.snackbar(
          'خطأ',
          response['message'] ?? 'حدث خطأ أثناء البحث',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
        stockItems.clear();
        hasSearched.value = false;
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ في الاتصال بالخادم',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      stockItems.clear();
      hasSearched.value = false;
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  // مسح البحث
  void clearSearch() {
    itemCodeController.clear();
    stockItems.clear();
    hasSearched.value = false;
  }

  // حساب إجمالي المخزون
  double get totalStock {
    return stockItems.fold(0.0, (sum, item) => sum + item.totalOnHand);
  }

  // حساب متوسط السعر
  double get averagePrice {
    if (stockItems.isEmpty) return 0.0;
    double totalPrice = stockItems.fold(0.0, (sum, item) => sum + item.avgPrice);
    return totalPrice / stockItems.length;
  }
}
