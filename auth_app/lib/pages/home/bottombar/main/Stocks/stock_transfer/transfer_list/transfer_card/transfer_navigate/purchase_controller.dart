// ignore_for_file: avoid_print

import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/Invoic/invoice_Controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:get/get.dart';

// استيراد الصفحات المطلوبة
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/Invoic/invice_page.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/product_page.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/models/transfer_stock_model.dart';

// GetX Controller

// GetX Controller
class TransferNavigationController extends GetxController {
  final _currentIndex = 0.obs;
  final _isSearching = false.obs;
  final _searchController = TextEditingController();
  final _selectedSearchType = 'name'.obs;
  final _searchText = ''.obs; // متغير observable للنص

  late TransferModel transfer;
  late int transferId;

  int get currentIndex => _currentIndex.value;
  bool get isSearching => _isSearching.value;
  TextEditingController get searchController => _searchController;
  String get selectedSearchType => _selectedSearchType.value;
  String get searchText => _searchText.value;
  RxString get searchTextRx => _searchText; // إضافة getter للوصول إلى RxString

  @override
  void onInit() {
    super.onInit();
    _initializeTransferData();
    _passDataToPages();

    // مراقبة تغييرات النص
    _searchController.addListener(() {
      _searchText.value = _searchController.text;
    });
  }

  void _initializeTransferData() {
    final args = Get.arguments as Map<String, dynamic>;
    transfer = args['transfer'] as TransferModel;
    transferId = args['transferId'] as int;
  }

  void _passDataToPages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final invoiceController = Get.find<InvoiceController>();
        invoiceController.loadTransferDetails(transferId);
      } catch (e) {
        print('Invoice Controller not found: $e');
      }

      try {
        if (Get.isRegistered<ProductManagementController>()) {
          final productController = Get.find<ProductManagementController>();
          productController.loadTransferLines(transferId);
        }
      } catch (e) {
        print('Product Controller not found: $e');
      }
    });
  }

  void changeTab(int index) {
    _currentIndex.value = index;
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
    _searchText.value = ''; // تحديث المتغير Observable
  }

  @override
  void onClose() {
    _searchController.dispose();
    super.onClose();
  }
}

class TransferDetailsNavigationScreen extends StatelessWidget {
  const TransferDetailsNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransferNavigationController());

    final List<Widget> pages = [
      InvoicePage(
        key: ValueKey('invoice_${controller.transferId}'),
      ),
      const SearchPage(),
      ProductManagementScreen(
        key: ValueKey('products_${controller.transferId}'),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Obx(() => Text(
              controller.getAppBarTitle(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              'رقم التحويل: ${controller.transferId}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() => IndexedStack(
            index: controller.currentIndex,
            children: pages,
          )),
      bottomNavigationBar: Obx(() => CurvedNavigationBar(
            index: controller.currentIndex,
            height: 60,
            items: const [
              Icon(Icons.receipt_long, size: 30, color: Colors.white),
              Icon(Icons.search, size: 30, color: Colors.white),
              Icon(Icons.inventory_2, size: 30, color: Colors.white),
            ],
            color: const Color(0xFF2196F3),
            buttonBackgroundColor: const Color(0xFF1976D2),
            backgroundColor: Colors.white,
            animationCurve: Curves.easeInOut,
            animationDuration: const Duration(milliseconds: 300),
            onTap: controller.changeTab,
          )),
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransferNavigationController>();

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Search Box
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 26, 118, 193),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Obx(() => TextFormField(
                                controller: controller.searchController,
                                decoration: InputDecoration(
                                  hintText: 'بحث (اسم، باركود، رقم صنف)',
                                  hintStyle: const TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(color: Colors.blueGrey),
                                  ),
                                  // الحل: استخدام searchText بدلاً من searchController.text
                                  suffixIcon: controller.searchText.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: controller.clearSearch,
                                        )
                                      : null,
                                ),
                                onFieldSubmitted: controller.performSearch,
                              )),
                        ),
                        const SizedBox(width: 10),
                        Obx(() => ElevatedButton(
                              onPressed: controller.isSearching
                                  ? null
                                  : () =>
                                      controller.performSearch(controller.searchController.text),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2196F3),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              child: controller.isSearching
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'بحث',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            )),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Search Type Filter Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildFilterButton(
                            controller,
                            'اسم الصنف',
                            'name',
                            Icons.text_fields,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildFilterButton(
                            controller,
                            'باركود',
                            'barcode',
                            Icons.qr_code,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildFilterButton(
                            controller,
                            'رقم الصنف',
                            'number',
                            Icons.numbers,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Search Results or Empty State
                    Expanded(
                      child: Obx(() => controller.isSearching
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Color(0xFF2196F3),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'جاري البحث...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'ابدأ البحث لعرض النتائج',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'نوع البحث الحالي: ${controller.getSearchTypeLabel()}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
    TransferNavigationController controller,
    String label,
    String type,
    IconData icon,
  ) {
    return Obx(() {
      final bool isSelected = controller.selectedSearchType == type;

      return GestureDetector(
        onTap: () => controller.setSearchType(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
            border: Border.all(
              color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF2196F3).withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
