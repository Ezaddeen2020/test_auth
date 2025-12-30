import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/Invoic/controller/invoice_Controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/controllers/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/models/transfer_stock_model.dart';

class TransferNavigationController extends GetxController {
  final _currentIndex = 0.obs;
  final _isSearching = false.obs;
  final _searchController = TextEditingController();
  final _selectedSearchType = 'name'.obs;
  final _searchText = ''.obs;

  late TransferModel transfer;
  late int transferId;
  ProductManagementController? _productController;

  int get currentIndex => _currentIndex.value;
  bool get isSearching => _isSearching.value;
  TextEditingController get searchController => _searchController;
  String get selectedSearchType => _selectedSearchType.value;
  String get searchText => _searchText.value;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    transfer = args['transfer'] as TransferModel;
    transferId = args['transferId'] as int;

    print('TransferNavigationController initialized with transferId: $transferId');

    _searchController.addListener(() {
      _searchText.value = _searchController.text;
    });

    // إعداد ProductManagementController مع transferId
    _setupProductController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _setupProductController() {
    try {
      // محاولة العثور على controller موجود
      if (Get.isRegistered<ProductManagementController>()) {
        _productController = Get.find<ProductManagementController>();
        print('Found existing ProductManagementController');
      } else {
        // إنشاء controller جديد
        _productController = Get.put(ProductManagementController());
        print('Created new ProductManagementController');
      }

      // تحديد transferId
      if (_productController != null) {
        _productController!.setTransferId(transferId);
        print('Set transferId to ProductManagementController: $transferId');
      }
    } catch (e) {
      print('Error setting up ProductManagementController: $e');
    }
  }

  void _loadInitialData() {
    // تحميل بيانات الفاتورة
    try {
      final invoiceController = Get.find<InvoiceController>();
      invoiceController.loadTransferDetails(transferId);
      print('Loaded invoice data for transferId: $transferId');
    } catch (e) {
      print('Invoice Controller not found: $e');
    }

    // تحميل بيانات المنتجات
    try {
      if (_productController != null) {
        _productController!.loadTransferLines(transferId);
        print('Loaded product lines for transferId: $transferId');
      }
    } catch (e) {
      print('Error loading product lines: $e');
    }
  }

  void changeTab(int index) {
    if (index == _currentIndex.value) return;

    print('Changing tab from ${_currentIndex.value} to $index');
    _currentIndex.value = index;

    // عند الانتقال لصفحة المنتجات أو البحث، تأكد من وجود البيانات
    if (index == 1 || index == 2) {
      // البحث أو إدارة المنتجات
      _ensureProductControllerReady();
    }
  }

  void _ensureProductControllerReady() {
    if (_productController == null) {
      _setupProductController();
    }

    if (_productController != null && _productController!.transferId.value != transferId) {
      _productController!.setTransferId(transferId);
      _productController!.loadTransferLines(transferId);
    }
  }

  // دالة للحصول على ProductController (للاستخدام في الصفحات الأخرى)
  ProductManagementController? getProductController() {
    _ensureProductControllerReady();
    return _productController;
  }

  String getAppBarTitle() {
    switch (currentIndex) {
      case 0:
        return 'فاتورة التحويل';
      case 1:
        return 'بحث الأصناف';
      case 2:
        return 'إدارة الأصناف';
      default:
        return 'تفاصيل التحويل';
    }
  }

  void setSearchType(String type) {
    _selectedSearchType.value = type;
  }

  String getSearchTypeLabel() {
    switch (selectedSearchType) {
      case 'name':
        return 'اسم الصنف';
      case 'barcode':
        return 'باركود';
      case 'number':
        return 'رقم الصنف';
      default:
        return 'غير محدد';
    }
  }

  void performSearch(String query) {
    if (query.trim().isEmpty) return;

    _isSearching.value = true;

    Future.delayed(const Duration(seconds: 1), () {
      _isSearching.value = false;

      Get.snackbar(
        'نتائج البحث',
        'تم البحث عن: $query',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    });
  }

  void clearSearch() {
    _searchController.clear();
    _searchText.value = '';
  }

  @override
  void onClose() {
    _searchController.dispose();
    super.onClose();
  }
}
