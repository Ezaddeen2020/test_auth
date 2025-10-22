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
  late TextEditingController itemCodeController;
  var hasSearched = false.obs;
  var textFieldValue = ''.obs; // متغير تفاعلي لحقل النص

  @override
  void onInit() {
    super.onInit();
    // تهيئة TextEditingController في onInit
    itemCodeController = TextEditingController();

    // إضافة listener لتحديث المتغير التفاعلي عند تغيير النص
    itemCodeController.addListener(() {
      textFieldValue.value = itemCodeController.text;
    });
  }

  @override
  void onClose() {
    // التأكد من تنظيف الموارد بشكل صحيح
    itemCodeController.dispose();
    super.onClose();
  }

  // البحث عن المخزون - محسّن
  Future<void> searchStock() async {
    String itemCode = itemCodeController.text.trim();

    if (itemCode.isEmpty) {
      _showErrorSnackbar('خطأ', 'يرجى إدخال رقم الصنف');
      return;
    }

    // تجنب البحث المتكرر إذا كان نفس الرقم
    if (hasSearched.value && stockItems.isNotEmpty && stockItems.first.itemCode == itemCode) {
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
          _showWarningSnackbar('نتيجة البحث', 'لا توجد بيانات مخزون لهذا الصنف');
        } else {
          _showSuccessSnackbar('نجح البحث', 'تم العثور على ${stockItems.length} عنصر');
        }
      } else {
        _handleApiError(response['message'] ?? 'حدث خطأ أثناء البحث');
      }
    } catch (e) {
      print('Stock search error: $e'); // للتشخيص
      _handleNetworkError();
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  Future<void> searchProduct() async {
    String itemCode = itemCodeController.text.trim();

    if (itemCode.isEmpty) {
      _showErrorSnackbar('خطأ', 'يرجى إدخال رقم الصنف');
      return;
    }

    // تجنب البحث المتكرر إذا كان نفس الرقم
    if (hasSearched.value && stockItems.isNotEmpty && stockItems.first.itemCode == itemCode) {
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
          _showWarningSnackbar('نتيجة البحث', 'لا توجد بيانات مخزون لهذا الصنف');
        } else {
          _showSuccessSnackbar('نجح البحث', 'تم العثور على ${stockItems.length} عنصر');
        }
      } else {
        _handleApiError(response['message'] ?? 'حدث خطأ أثناء البحث');
      }
    } catch (e) {
      print('Stock search error: $e'); // للتشخيص
      _handleNetworkError();
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  // مسح البحث - محسّن
  void clearSearch() {
    itemCodeController.clear();
    textFieldValue.value = '';
    stockItems.clear();
    hasSearched.value = false;
  }

  // دالة إعادة تعيين كاملة للصفحة
  void resetPage() {
    clearSearch();
    isLoading.value = false;
  }

  // دالة للتنظيف عند مغادرة الصفحة
  void onPageExit() {
    // إيقاف أي عمليات تحميل قائمة
    if (isLoading.value) {
      EasyLoading.dismiss();
      isLoading.value = false;
    }
    // الاحتفاظ بالبيانات للعودة السريعة أو مسحها حسب الحاجة
    // resetPage(); // إلغي التعليق إذا كنت تريد مسح البيانات عند المغادرة
  }

  // دالة للتحقق من صحة البيانات عند العودة للصفحة
  void onPageReturn() {
    // التحقق من وجود بيانات صالحة
    if (hasSearched.value && stockItems.isEmpty) {
      hasSearched.value = false;
    }
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

  // التحقق من حالة المخزون
  bool get hasLowStock {
    return stockItems.any((item) => item.totalOnHand < 10); // يمكن تعديل الحد الأدنى
  }

  // الحصول على عدد الأصناف
  int get itemCount => stockItems.length;

  // الحصول على حالة الصفحة
  bool get isPageEmpty => !hasSearched.value && stockItems.isEmpty;
  bool get isSearchResultEmpty => hasSearched.value && stockItems.isEmpty;
  bool get hasResults => hasSearched.value && stockItems.isNotEmpty;

  // دوال مساعدة للرسائل
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  void _showWarningSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.orange.withOpacity(0.8),
      colorText: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _handleApiError(String message) {
    _showErrorSnackbar('خطأ', message);
    stockItems.clear();
    hasSearched.value = false;
  }

  void _handleNetworkError() {
    _showErrorSnackbar('خطأ في الاتصال', 'حدث خطأ في الاتصال بالخادم');
    stockItems.clear();
    hasSearched.value = false;
  }

  // دالة للبحث بالباركود (إضافة مستقبلية)
  Future<void> searchByBarcode(String barcode) async {
    itemCodeController.text = barcode;
    textFieldValue.value = barcode;
    await searchStock();
  }

  // دالة لتحديث عنصر معين
  void updateStockItem(int index, StockModel updatedItem) {
    if (index >= 0 && index < stockItems.length) {
      stockItems[index] = updatedItem;
      stockItems.refresh(); // إجبار التحديث
    }
  }

  // دالة للتصفية (إذا كان لديك أكثر من نتيجة)
  List<StockModel> filterStockItems(String query) {
    if (query.isEmpty) return stockItems.toList();

    return stockItems
        .where((item) =>
            item.itemName.toLowerCase().contains(query.toLowerCase()) ||
            item.itemCode.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
