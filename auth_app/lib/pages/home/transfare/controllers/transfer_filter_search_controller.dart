import 'package:auth_app/pages/home/transfare/models/transfer_stock.dart';
import 'transfer_controller_base.dart';

/// الجزء الخاص بعمليات البحث والفلترة
mixin TransferFilterSearch on TransferControllerBase {
  // البحث والفلترة
  @override
  void applyFilters() {
    var filtered = transfers.where((transfer) {
      // البحث النصي
      bool matchesSearch = searchQuery.value.isEmpty ||
          transfer.ref?.toLowerCase().contains(searchQuery.value.toLowerCase()) == true ||
          transfer.whsNameFrom.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          transfer.whsNameTo.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          transfer.creatby.toLowerCase().contains(searchQuery.value.toLowerCase());

      // فلتر الحالة
      bool matchesStatus = selectedStatusFilter.value == 'all' ||
          (selectedStatusFilter.value == 'pending' && !transfer.isSended) ||
          (selectedStatusFilter.value == 'sent' && transfer.isSended && !transfer.aproveRecive) ||
          (selectedStatusFilter.value == 'received' &&
              transfer.aproveRecive &&
              !transfer.sapPost) ||
          (selectedStatusFilter.value == 'posted' && transfer.sapPost);

      // فلتر المستودع المرسل
      bool matchesFromWarehouse = selectedWarehouseFromFilter.value == 'all' ||
          transfer.whscodeFrom.trim() == selectedWarehouseFromFilter.value;

      // فلتر المستودع المستقبل
      bool matchesToWarehouse = selectedWarehouseToFilter.value == 'all' ||
          transfer.whscodeTo.trim() == selectedWarehouseToFilter.value;

      return matchesSearch && matchesStatus && matchesFromWarehouse && matchesToWarehouse;
    }).toList();

    filteredTransfers.value = filtered;
  }

  // تحديث البحث
  void updateSearch(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  // تحديث فلتر الحالة
  void updateStatusFilter(String status) {
    selectedStatusFilter.value = status;
    applyFilters();
  }

  // تحديث فلتر المستودع المرسل
  void updateFromWarehouseFilter(String warehouse) {
    selectedWarehouseFromFilter.value = warehouse;
    applyFilters();
  }

  // تحديث فلتر المستودع المستقبل
  void updateToWarehouseFilter(String warehouse) {
    selectedWarehouseToFilter.value = warehouse;
    applyFilters();
  }

  // إعادة تعيين الفلاتر
  void resetFilters() {
    searchQuery.value = '';
    selectedStatusFilter.value = 'all';
    selectedWarehouseFromFilter.value = 'all';
    selectedWarehouseToFilter.value = 'all';
    searchController.clear();
    applyFilters();
  }
}
