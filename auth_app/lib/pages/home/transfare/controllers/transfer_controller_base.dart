import 'package:auth_app/pages/home/transfare/models/transfer_stock.dart';
import 'package:auth_app/pages/home/transfare/services/transfer_api.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:auth_app/functions/status_request.dart';
import 'package:auth_app/services/api/post_get_api.dart';

/// الجزء الأساسي من TransferController - يحتوي على المتغيرات والإعدادات الأساسية
abstract class TransferControllerBase extends GetxController {
  // Status and Loading States
  var statusRequest = StatusRequest.none.obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var isRefreshing = false.obs;

  // Data
  var transfers = <TransferModel>[].obs;
  var filteredTransfers = <TransferModel>[].obs;
  var selectedTransfer = Rxn<TransferModel>();

  // Pagination
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasMoreData = true.obs;

  // Search and Filter
  var searchQuery = ''.obs;
  var selectedStatusFilter = 'all'.obs;
  var selectedWarehouseFromFilter = 'all'.obs;
  var selectedWarehouseToFilter = 'all'.obs;

  // Controllers
  late TextEditingController searchController;
  late ScrollController scrollController;

  // API
  late TransferApi transferApi;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    scrollController = ScrollController();
    transferApi = TransferApi(PostGetPage());

    // Setup scroll listener for pagination
    scrollController.addListener(_onScroll);

    // Load initial data
    getTransfersList();
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // Scroll listener for pagination
  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 &&
        hasMoreData.value &&
        !isLoadingMore.value) {
      loadMoreTransfers();
    }
  }

  // Abstract methods to be implemented in other parts
  Future<void> getTransfersList({bool isRefresh = false});
  Future<void> loadMoreTransfers();
  Future<void> refreshTransfers();
  void applyFilters();
}
