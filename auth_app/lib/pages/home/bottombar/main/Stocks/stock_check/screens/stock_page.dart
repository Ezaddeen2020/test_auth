import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/controllers/stock_controller.dart';
import 'stock_widgets.dart';

class StockPage extends StatelessWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    final StockController controller = Get.find<StockController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'الاستعلام عن المخزون',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          StockSearchSection(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!controller.hasSearched.value) {
                return const StockWelcomeScreen();
              }
              if (controller.stockItems.isEmpty) {
                return const StockNoDataScreen();
              }
              return StockResultsSection(controller: controller);
            }),
          ),
        ],
      ),
    );
  }
}
