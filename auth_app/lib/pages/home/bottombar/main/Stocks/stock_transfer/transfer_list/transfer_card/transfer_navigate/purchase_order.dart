import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/purchase_controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/search_product/screen/search_page.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:get/get.dart';

// استيراد الصفحات المطلوبة
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/Invoic/invice_page.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/screen/product_page.dart';

class TransferDetailsNavigationScreen extends StatelessWidget {
  const TransferDetailsNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TransferNavigationController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          title: Obx(() => Text(
                controller.getAppBarTitle(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )),
          backgroundColor: Colors.blue.shade900,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
            onPressed: () => Get.back(),
          ),
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'رقم التحويل: ${controller.transferId}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          toolbarHeight: 70,
        ),
      ),
      body: Obx(() {
        switch (controller.currentIndex) {
          case 0:
            return InvoicePage(
              key: ValueKey('invoice_${controller.transferId}'),
            );
          case 1:
            return const SearchPage();
          case 2:
            return ProductManagementScreen(
              key: ValueKey('products_${controller.transferId}'),
            );
          default:
            return const Center(
              child: Text('صفحة غير متوفرة'),
            );
        }
      }),
      bottomNavigationBar: Obx(() => CurvedNavigationBar(
            index: controller.currentIndex,
            height: 60,
            items: const [
              Icon(Icons.receipt_long, size: 30, color: Colors.white),
              Icon(Icons.search, size: 30, color: Colors.white),
              Icon(Icons.inventory_2, size: 30, color: Colors.white),
            ],
            color: Colors.blue.shade900,
            buttonBackgroundColor: const Color(0xFF1976D2),
            backgroundColor: Colors.white,
            animationCurve: Curves.easeInOut,
            animationDuration: const Duration(milliseconds: 300),
            onTap: controller.changeTab,
          )),
    );
  }
}
