import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BarcodeController extends GetxController {
  final productNameController = TextEditingController();
  final productCodeController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();

  var selectedBarcodeType = Rx<Barcode>(Barcode.code128());
  var barcodeValue = ''.obs;
  var showBarcode = false.obs;

  final barcodeTypes = {
    'Code 128': Barcode.code128(),
    'Code 39': Barcode.code39(),
    'EAN 13': Barcode.ean13(),
    'EAN 8': Barcode.ean8(),
    'QR Code': Barcode.qrCode(),
  };

  void onBarcodeTypeChanged(Barcode newType) {
    selectedBarcodeType.value = newType;
    // Hide barcode when type changes to prevent encoding errors
    if (showBarcode.value) {
      showBarcode.value = false;
      Get.snackbar(
        'تنبيه',
        'تم تغيير نوع الباركود. يرجى إعادة إنشاء الباركود',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.7),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  void onInit() {
    selectedBarcodeType.value = barcodeTypes.values.first;
    super.onInit();
  }

  void generateBarcode() {
    if (productCodeController.text.isEmpty) {
      _showSnackbar('خطأ', 'الرجاء إدخال كود المنتج', Colors.red);
      return;
    }

    if (!_validateBarcodeData(productCodeController.text)) return;
    if (!_validatePrice()) return;
    if (!_validateQuantity()) return;

    barcodeValue.value = productCodeController.text;
    showBarcode.value = true;
    _showSnackbar('نجح', 'تم إنشاء الباركود بنجاح', Colors.green, Icons.check_circle_outline);
  }

  bool _validateBarcodeData(String data) {
    String? typeName =
        barcodeTypes.entries.firstWhere((e) => e.value == selectedBarcodeType.value).key;

    if (typeName == 'EAN 13' && data.length != 12 && data.length != 13) {
      _showSnackbar('خطأ', 'EAN 13 يتطلب 12 أو 13 رقم', Colors.red);
      return false;
    }

    if (typeName == 'EAN 8' && data.length != 7 && data.length != 8) {
      _showSnackbar('خطأ', 'EAN 8 يتطلب 7 أو 8 أرقام', Colors.red);
      return false;
    }

    return true;
  }

  bool _validatePrice() {
    if (priceController.text.isEmpty) return true;

    try {
      double price = double.parse(priceController.text);
      if (price < 0) {
        _showSnackbar('خطأ', 'السعر يجب أن يكون قيمة موجبة', Colors.red);
        return false;
      }
    } catch (e) {
      _showSnackbar('خطأ', 'الرجاء إدخال سعر صحيح', Colors.red);
      return false;
    }
    return true;
  }

  bool _validateQuantity() {
    if (quantityController.text.isEmpty) return true;

    try {
      int quantity = int.parse(quantityController.text);
      if (quantity < 0) {
        _showSnackbar('خطأ', 'الكمية يجب أن تكون قيمة موجبة', Colors.red);
        return false;
      }
    } catch (e) {
      _showSnackbar('خطأ', 'الرجاء إدخال كمية صحيحة', Colors.red);
      return false;
    }
    return true;
  }

  void cancelBarcodeDisplay() {
    showBarcode.value = false;
    _showSnackbar('إلغاء', 'تم إلغاء عرض الباركود', Colors.orange, Icons.cancel_outlined);
  }

  void clearForm() {
    productNameController.clear();
    productCodeController.clear();
    priceController.clear();
    quantityController.clear();
    showBarcode.value = false;
    barcodeValue.value = '';
    _showSnackbar('تم', 'تم مسح جميع الحقول', Colors.blue);
  }

  Future<void> saveBarcode() async {
    if (!showBarcode.value) {
      _showSnackbar('تنبيه', 'الرجاء إنشاء الباركود أولاً', Colors.orange);
      return;
    }
    _showSnackbar('حفظ', 'تم حفظ الباركود بنجاح', Colors.green, Icons.save_outlined);
  }

  Future<void> printBarcode() async {
    if (!showBarcode.value) {
      _showSnackbar('تنبيه', 'الرجاء إنشاء الباركود أولاً', Colors.orange);
      return;
    }
    _showSnackbar('طباعة', 'جاري طباعة الباركود...', Colors.blue, Icons.print_outlined);
  }

  void _showSnackbar(String title, String message, Color color,
      [IconData? icon, int duration = 2]) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color.withOpacity(0.7),
      colorText: Colors.white,
      icon: icon != null ? Icon(icon, color: Colors.white) : null,
      duration: Duration(seconds: duration),
    );
  }

  @override
  void onClose() {
    productNameController.dispose();
    productCodeController.dispose();
    priceController.dispose();
    quantityController.dispose();
    super.onClose();
  }
}
