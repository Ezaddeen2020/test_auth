import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/search_product/screen/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/controllers/stock_controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/controllers/product_controller.dart';

class SearchPage extends StatelessWidget {
  final int? transferId;

  const SearchPage({super.key, this.transferId});

  @override
  Widget build(BuildContext context) {
    final stockController = Get.find<StockController>();
    final productController = Get.find<ProductManagementController>();

    // Set the transfer ID if provided
    if (transferId != null && transferId! > 0) {
      productController.setTransferId(transferId!);
      print('SearchPage: Transfer ID set to $transferId');
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          SearchSection(controller: stockController),
          Expanded(
            child: Obx(() {
              if (stockController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!stockController.hasSearched.value) {
                return const SearchWelcomeScreen();
              }
              if (stockController.stockItems.isEmpty) {
                return const SearchNoDataScreen();
              }
              return SearchResultsSection(
                stockController: stockController,
                productController: productController,
                transferId: transferId,
              );
            }),
          ),
        ],
      ),
    );
  }
}
