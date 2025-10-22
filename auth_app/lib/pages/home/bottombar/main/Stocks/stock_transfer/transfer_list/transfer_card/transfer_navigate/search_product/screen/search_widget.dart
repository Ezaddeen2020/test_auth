import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/controllers/stock_controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/controllers/product_controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/screen/widgets/product_dialog.dart';

// قسم البحث
class SearchSection extends StatelessWidget {
  final StockController controller;

  const SearchSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              controller: controller.itemCodeController,
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
              onSubmitted: (value) => controller.searchStock(),
            ),
          ),
          const SizedBox(height: 15),
          // أزرار التحكم
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.searchStock(),
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
                  onPressed: () => controller.clearSearch(),
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
    );
  }
}

// شاشة الترحيب
class SearchWelcomeScreen extends StatelessWidget {
  const SearchWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
}

// شاشة لا توجد بيانات
class SearchNoDataScreen extends StatelessWidget {
  const SearchNoDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
}

// قسم النتائج
class SearchResultsSection extends StatelessWidget {
  final StockController stockController;
  final ProductManagementController productController;
  final int? transferId;

  const SearchResultsSection({
    super.key,
    required this.stockController,
    required this.productController,
    this.transferId,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchProductCard(
            stockController: stockController,
            productController: productController,
            transferId: transferId,
          ),
        ],
      ),
    );
  }
}

// بطاقة المنتج
class SearchProductCard extends StatelessWidget {
  final StockController stockController;
  final ProductManagementController productController;
  final int? transferId;

  const SearchProductCard({
    super.key,
    required this.stockController,
    required this.productController,
    this.transferId,
  });

  @override
  Widget build(BuildContext context) {
    if (stockController.stockItems.isEmpty) return const SizedBox();

    final firstItem = stockController.stockItems.first;

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
                onPressed: () => _onAddProduct(firstItem),
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

  void _onAddProduct(firstItem) {
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
