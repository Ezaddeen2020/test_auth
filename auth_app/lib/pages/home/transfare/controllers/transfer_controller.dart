import 'package:auth_app/pages/home/transfare/models/transfer_stock.dart';
import 'package:auth_app/pages/home/transfare/services/transfer_api.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:auth_app/functions/status_request.dart';
import 'package:auth_app/services/api/post_get_api.dart';

class TransferController extends GetxController {
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

  // جلب قائمة التحويلات
  Future<void> getTransfersList({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        isRefreshing.value = true;
        currentPage.value = 1;
        hasMoreData.value = true;
      } else {
        isLoading.value = true;
      }

      statusRequest.value = StatusRequest.loading;

      var response = await transferApi.getTransfersList(
        page: currentPage.value,
        pageSize: 20,
      );

      if (response['status'] == 'success') {
        TransferResponse transferResponse = TransferResponse.fromJson(response['data']);

        if (isRefresh) {
          transfers.value = transferResponse.data;
        } else {
          transfers.addAll(transferResponse.data);
        }

        currentPage.value = transferResponse.currentPage;
        totalPages.value = transferResponse.totalPages;
        hasMoreData.value = currentPage.value < totalPages.value;

        applyFilters();
        statusRequest.value = StatusRequest.success;

        Get.snackbar(
          'نجح',
          'تم جلب البيانات بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        statusRequest.value = StatusRequest.failure;
        Get.snackbar(
          'خطأ',
          response['message'] ?? 'فشل في جلب البيانات',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      statusRequest.value = StatusRequest.failure;
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  // تحميل المزيد من البيانات
  Future<void> loadMoreTransfers() async {
    if (!hasMoreData.value || isLoadingMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      var response = await transferApi.getTransfersList(
        page: currentPage.value,
        pageSize: 20,
      );

      if (response['status'] == 'success') {
        TransferResponse transferResponse = TransferResponse.fromJson(response['data']);

        transfers.addAll(transferResponse.data);
        hasMoreData.value = currentPage.value < totalPages.value;
        applyFilters();
      }
    } catch (e) {
      currentPage.value--; // إرجاع رقم الصفحة في حالة الخطأ
      Get.snackbar(
        'خطأ',
        'فشل في تحميل المزيد من البيانات',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  // تحديث البيانات
  Future<void> refreshTransfers() async {
    await getTransfersList(isRefresh: true);
  }

  // البحث والفلترة
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

  // إرسال التحويل
  Future<void> sendTransfer(int transferId) async {
    try {
      isLoading.value = true;

      var response = await transferApi.sendTransfer(transferId);

      if (response['status'] == 'success') {
        // تحديث البيانات محلياً
        int index = transfers.indexWhere((t) => t.id == transferId);
        if (index != -1) {
          var updatedTransfer = TransferModel(
            id: transfers[index].id,
            whscodeFrom: transfers[index].whscodeFrom,
            whsNameFrom: transfers[index].whsNameFrom,
            whscodeTo: transfers[index].whscodeTo,
            whsNameTo: transfers[index].whsNameTo,
            creatby: transfers[index].creatby,
            isSended: true,
            sendedBy: 'Current User', // يمكن الحصول عليه من الـ response
            aproveRecive: transfers[index].aproveRecive,
            aproveReciveBy: transfers[index].aproveReciveBy,
            sapPost: transfers[index].sapPost,
            sapPostBy: transfers[index].sapPostBy,
            sapPostDate: transfers[index].sapPostDate,
            createDate: transfers[index].createDate,
            driverName: transfers[index].driverName,
            driverCode: transfers[index].driverCode,
            driverMobil: transfers[index].driverMobil,
            careNum: transfers[index].careNum,
            note: transfers[index].note,
            ref: transfers[index].ref,
          );
          transfers[index] = updatedTransfer;
          applyFilters();
        }

        Get.snackbar(
          'نجح',
          'تم إرسال التحويل بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'خطأ',
          response['message'] ?? 'فشل في إرسال التحويل',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // استلام التحويل
  Future<void> receiveTransfer(int transferId) async {
    try {
      isLoading.value = true;

      var response = await transferApi.receiveTransfer(transferId);

      if (response['status'] == 'success') {
        // تحديث البيانات محلياً
        int index = transfers.indexWhere((t) => t.id == transferId);
        if (index != -1) {
          var updatedTransfer = TransferModel(
            id: transfers[index].id,
            whscodeFrom: transfers[index].whscodeFrom,
            whsNameFrom: transfers[index].whsNameFrom,
            whscodeTo: transfers[index].whscodeTo,
            whsNameTo: transfers[index].whsNameTo,
            creatby: transfers[index].creatby,
            isSended: transfers[index].isSended,
            sendedBy: transfers[index].sendedBy,
            aproveRecive: true,
            aproveReciveBy: 'Current User',
            sapPost: transfers[index].sapPost,
            sapPostBy: transfers[index].sapPostBy,
            sapPostDate: transfers[index].sapPostDate,
            createDate: transfers[index].createDate,
            driverName: transfers[index].driverName,
            driverCode: transfers[index].driverCode,
            driverMobil: transfers[index].driverMobil,
            careNum: transfers[index].careNum,
            note: transfers[index].note,
            ref: transfers[index].ref,
          );
          transfers[index] = updatedTransfer;
          applyFilters();
        }

        Get.snackbar(
          'نجح',
          'تم استلام التحويل بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'خطأ',
          response['message'] ?? 'فشل في استلام التحويل',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ترحيل إلى SAP
  Future<void> postToSAP(int transferId) async {
    try {
      isLoading.value = true;

      var response = await transferApi.postToSAP(transferId);

      if (response['status'] == 'success') {
        // تحديث البيانات محلياً
        int index = transfers.indexWhere((t) => t.id == transferId);
        if (index != -1) {
          var updatedTransfer = TransferModel(
            id: transfers[index].id,
            whscodeFrom: transfers[index].whscodeFrom,
            whsNameFrom: transfers[index].whsNameFrom,
            whscodeTo: transfers[index].whscodeTo,
            whsNameTo: transfers[index].whsNameTo,
            creatby: transfers[index].creatby,
            isSended: transfers[index].isSended,
            sendedBy: transfers[index].sendedBy,
            aproveRecive: transfers[index].aproveRecive,
            aproveReciveBy: transfers[index].aproveReciveBy,
            sapPost: true,
            sapPostBy: 'Current User',
            sapPostDate: DateTime.now().toIso8601String(),
            createDate: transfers[index].createDate,
            driverName: transfers[index].driverName,
            driverCode: transfers[index].driverCode,
            driverMobil: transfers[index].driverMobil,
            careNum: transfers[index].careNum,
            note: transfers[index].note,
            ref: transfers[index].ref,
          );
          transfers[index] = updatedTransfer;
          applyFilters();
        }

        Get.snackbar(
          'نجح',
          'تم ترحيل التحويل إلى SAP بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'خطأ',
          response['message'] ?? 'فشل في ترحيل التحويل إلى SAP',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // تحديد التحويل المحدد
  void selectTransfer(TransferModel transfer) {
    selectedTransfer.value = transfer;
  }

  // مسح التحديد
  void clearSelection() {
    selectedTransfer.value = null;
  }

  // الحصول على قائمة المستودعات الفريدة (للفلاتر)
  List<String> getUniqueWarehouses() {
    Set<String> warehouses = {};
    for (var transfer in transfers) {
      warehouses.add(transfer.whscodeFrom.trim());
      warehouses.add(transfer.whscodeTo.trim());
    }
    return warehouses.toList()..sort();
  }

  // الحصول على إحصائيات التحويلات
  Map<String, int> getTransferStats() {
    int pending = transfers.where((t) => !t.isSended).length;
    int sent = transfers.where((t) => t.isSended && !t.aproveRecive).length;
    int received = transfers.where((t) => t.aproveRecive && !t.sapPost).length;
    int posted = transfers.where((t) => t.sapPost).length;

    return {
      'pending': pending,
      'sent': sent,
      'received': received,
      'posted': posted,
      'total': transfers.length,
    };
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

  // التحقق من إمكانية تنفيذ العمليات
  bool canSendTransfer(TransferModel transfer) {
    return !transfer.isSended;
  }

  bool canReceiveTransfer(TransferModel transfer) {
    return transfer.isSended && !transfer.aproveRecive;
  }

  bool canPostToSAP(TransferModel transfer) {
    return transfer.aproveRecive && !transfer.sapPost;
  }
}

// import 'package:auth_app/pages/home/transfare/models/transfer_stock.dart';
// import 'package:auth_app/pages/home/transfare/services/transfer_api.dart';
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';

// import 'package:auth_app/services/api/post_get_api.dart';
// import 'package:auth_app/functions/status_request.dart';
// import 'package:auth_app/functions/handling_data.dart';

// class TransferController extends GetxController {
//   // حالة الطلب
//   var statusRequest = StatusRequest.none.obs;
  
//   // بيانات التحويلات
//   var transfersList = <TransferModel>[].obs;
//   var currentTransfer = Rxn<TransferModel>();
  
//   // بيانات الصفحات
//   var currentPage = 1.obs;
//   var totalPages = 1.obs;
//   var pageSize = 20.obs;
  
//   // بيانات البحث والتصفية
//   var searchController = TextEditingController();
//   var selectedFromWarehouse = Rxn<String>();
//   var selectedToWarehouse = Rxn<String>();
//   var selectedStatus = Rxn<String>();
//   var selectedDateFrom = Rxn<DateTime>();
//   var selectedDateTo = Rxn<DateTime>();
  
//   // قائمة المستودعات
//   var warehousesList = <Map<String, String>>[].obs;
  
//   // قوائم الحالات
//   final statusOptions = [
//     {'value': 'all', 'label': 'جميع الحالات'},
//     {'value': 'created', 'label': 'قيد الإنشاء'},
//     {'value': 'sent', 'label': 'تم الإرسال'},
//     {'value': 'received', 'label': 'تم الاستلام'},
//     {'value': 'posted', 'label': 'مرحل إلى SAP'},
//   ];
  
//   // API Instance
//   late TransferApi transferApi;
  
//   @override
//   void onInit() {
//     super.onInit();
//     transferApi = TransferApi(PostGetPage());
//     loadInitialData();
//   }
  
//   @override
//   void onClose() {
//     searchController.dispose();
//     super.onClose();
//   }
  
//   /// تحميل البيانات الأولية
//   Future<void> loadInitialData() async {
//     await getWarehouses();
//     await getTransfersList();
//   }
  
//   /// جلب قائمة التحويلات
//   Future<void> getTransfersList({bool isRefresh = false}) async {
//     if (isRefresh) {
//       currentPage.value = 1;
//     }
    
//     statusRequest.value = StatusRequest.loading;
    
//     var response = await transferApi.getTransfersList(
//       page: currentPage.value,
//       pageSize: pageSize.value,
//       fromWarehouse: selectedFromWarehouse.value,
//       toWarehouse: selectedToWarehouse.value,
//       status: selectedStatus.value,
//       dateFrom: selectedDateFrom.value?.toIso8601String(),
//       dateTo: selectedDateTo.value?.toIso8601String(),
//     );
    
//     statusRequest.value = handleResult(response);
    
//     if (statusRequest.value == StatusRequest.success) {
//       var transferResponse = TransferListResponse.fromJson(response['data']);
      
//       if (isRefresh || currentPage.value == 1) {
//         transfersList.clear();
//       }
      
//       transfersList.addAll(transferResponse.data);
//       currentPage.value = transferResponse.currentPage;
//       totalPages.value = transferResponse.totalPages;
//     } else {
//       Get.snackbar(
//         'خطأ',
//         response['message'] ?? 'فشل في جلب قائمة التحويلات',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
  
//   /// تحميل المزيد من التحويلات (للصفحات التالية)
//   Future<void> loadMoreTransfers() async {
//     if (currentPage.value < totalPages.value && statusRequest.value != StatusRequest.loading) {
//       currentPage.value++;
//       await getTransfersList();
//     }
//   }
  
//   /// البحث في التحويلات
//   Future<void> searchTransfers(String searchTerm) async {
//     if (searchTerm.trim().isEmpty) {
//       await getTransfersList(isRefresh: true);
//       return;
//     }
    
//     statusRequest.value = StatusRequest.loading;
    
//     var response = await transferApi.searchTransfers(searchTerm);
    
//     statusRequest.value = handleResult(response);
    
//     if (statusRequest.value == StatusRequest.success) {
//       var transferResponse = TransferListResponse.fromJson(response['data']);
//       transfersList.value = transferResponse.data;
//       currentPage.value = 1;
//       totalPages.value = transferResponse.totalPages;
//     } else {
//       Get.snackbar(
//         'خطأ',
//         response['message'] ?? 'فشل في البحث',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
  
//   /// تطبيق التصفية
//   Future<void> applyFilters() async {
//     await getTransfersList(isRefresh: true);
//   }
  
//   /// إعادة تعيين التصفية
//   Future<void> resetFilters() async {
//     selectedFromWarehouse.value = null;
//     selectedToWarehouse.value = null;
//     selectedStatus.value = null;
//     selectedDateFrom.value = null;
//     selectedDateTo.value = null;
//     searchController.clear();
//     await getTransfersList(isRefresh: true);
//   }
  
//   /// جلب تفاصيل تحويل معين
//   Future<void> getTransferDetails(int transferId) async {
//     statusRequest.value = StatusRequest.loading;
    
//     var response = await transferApi.getTransferDetails(transferId);
    
//     statusRequest.value = handleResult(response);
    
//     if (statusRequest.value == StatusRequest.success) {
//       currentTransfer.value = TransferModel.fromJson(response['data']);
//     } else {
//       Get.snackbar(
//         'خطأ',
//         response['message'] ?? 'فشل في جلب تفاصيل التحويل',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }
  
//   /// إنشاء تحويل جديد
//   Future<bool> createTransfer(Map<String, dynamic> transferData) async {
//     statusRequest.value = StatusRequest.loading;
    
//     var response = await transferApi.createTransfer(transferData);
    
//     statusRequest.value = handleResult(response);
    
//     if (statusRequest.value == StatusRequest.success) {
//       Get.snackbar(
//         'نجح',
//         'تم إنشاء التحويل بنجاح',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//       await getTransfersList(isRefresh: true);
//       return true;
//     } else {
//       Get.snackbar(
//         'خطأ',
//         response['message'] ?? 'فشل في إنشاء التحويل',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return false;
//     }
//   }
  
//   /// تحديث تحويل موجود
//   Future<bool> updateTransfer(int transferId, Map<String, dynamic> transferData) async {
//     statusRequest.value = StatusRequest.loading;
    
//     var response = await transferApi.updateTransfer(transferId, transferData);
    
//     statusRequest.value = handleResult(response);
    
//     if (statusRequest.value == StatusRequest.success) {
//       Get.snackbar(
//         'نجح',
//         'تم تحديث التحويل بنجاح',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//       await getTransfersList(isRefresh: true);
//       return true;
//     } else {
//       Get.snackbar(
//         'خطأ',
//         response['message'] ?? 'فشل في تحديث التحويل',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return false;
//     }
//   }
  
//   /// حذف تحويل
//   Future<bool> deleteTransfer(int transferId) async {
//     statusRequest.value = StatusRequest.loading;
    
//     var response = await transferApi.deleteTransfer(transferId);
    
//     statusRequest.value = handleResult(response);
    
//     if (statusRequest.value == StatusRequest.success) {
//       Get.snackbar(
//         'نجح',
//         'تم حذف التحويل بنجاح',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//       transfersList.removeWhere((transfer) => transfer.id == transferId);
//       return true;
//     } else {
//       Get.snackbar(
//         'خطأ',
//         response['message'] ?? 'فشل في حذف التحويل',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return false;
//     }
//   }
  
//   /// تأكيد الإرسال
//   Future<bool> confirmSend(int transferId, Map<String, dynamic> confirmData) async {
//     statusRequest.value = StatusRequest.loading;
    
//     var response = await transferApi.confirmSend(transferId, confirmData);
    
//     statusRequest.value = handleResult(response);
    
//     if (statusRequest.value == StatusRequest.success) {
//       Get.snackbar(
//         'نجح',
//         'تم تأكيد الإرسال بنجاح',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//       await getTransfersList(isRefresh: true);
//       return true;
//     } else {
//       Get.snackbar(
//         'خطأ',
//         response['message'] ?? 'فشل في تأكيد الإرسال',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return false;
//     }
//   }
  
//   /// تأكيد الاستلام
//   Future<bool> confirmReceive(int transferId, Map<String, dynamic> confirmData) async {
//     statusRequest.value = StatusRequest.loading;
    
//     var response = await transferApi.confirmReceive(transferId, confirmData);
    
//     statusRequest.value = handleResult(response);
    
//     if (statusRequest.value == StatusRequest.success) {
//       Get.snackbar(
//         'نجح',
//         'تم تأكيد الاستلام بنجاح',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//       await getTransfersList(isRefresh: true);
//       return true;
//     } else {
//       Get.snackbar(
//         'خطأ',
//         response['message'] ?? 'فشل في تأكيد الاستلام',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return false;
//     }
//   }
  
//   /// ترحيل إلى SAP
//   Future<bool> postToSap(int transferId) async {
//     statusRequest.value = StatusRequest.loading;
    
//     var response = await transferApi.postToSap(transferId);
    
//     statusRequest.value = handleResult(response);
    
//     if (statusRequest.value == StatusRequest.success) {
//       Get.snackbar(
//         'نجح',
//         'تم ترحيل التحويل إلى SAP بنجاح',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//       await getTransfersList(isRefresh: true);
//       return true;
//     } else {
//       Get.snackbar(
//         'خطأ',
//         response['message'] ?? 'فشل في ترحيل التحويل إلى SAP',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return false;
//     }
//   }
  
//   /// جلب قائمة المستودعات
//   Future<void> getWarehouses() async {
//     var response = await transferApi.getWarehouses();
    
//     if (handleResult(response) == StatusRequest.success) {
//       warehousesList.value = List<Map<String, String>>.from(
//         response['data'].map((warehouse) => {
//           'code': warehouse['code'].toString(),
//           'name': warehouse['name'].toString(),
//         }),
//       );
//     }
//   }
  
//   /// فتح نافذة تأكيد الحذف
//   Future<void> showDeleteConfirmation(int transferId, String transferRef) async {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('تأكيد الحذف'),
//         content: Text('هل أنت متأكد من حذف التحويل رقم: $transferRef؟'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               deleteTransfer(transferId);
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('حذف', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
  
//   /// تحديث التاريخ من
//   void setDateFrom(DateTime? date) {
//     selectedDateFrom.value = date;
//   }
  
//   /// تحديث التاريخ إلى
//   void setDateTo(DateTime? date) {
//     selectedDateTo.value = date;
//   }
  
//   /// تحديد المستودع المصدر
//   void setFromWarehouse(String? warehouseCode) {
//     selectedFromWarehouse.value = warehouseCode;
//   }
  
//   /// تحديد المستودع الهدف
//   void setToWarehouse(String? warehouseCode) {
//     selectedToWarehouse.value = warehouseCode;
//   }
  
//   /// تحديد الحالة
//   void setStatus(String? status) {
//     selectedStatus.value = status;
//   }
  
//   /// الحصول على اسم المستودع من الكود
//   String getWarehouseName(String code) {
//     final warehouse = warehousesList.firstWhereOrNull(
//       (w) => w['code'] == code,
//     );
//     return warehouse?['name'] ?? code;
//   }
  
//   /// فلترة التحويلات حسب الحالة
//   List<TransferModel> getFilteredTransfers(String status) {
//     switch (status) {
//       case 'created':
//         return transfersList.where((t) => !t.isSended && !t.aproveRecive && !t.sapPost).toList();
//       case 'sent':
//         return transfersList.where((t) => t.isSended && !t.aproveRecive && !t.sapPost).toList();
//       case 'received':
//         return transfersList.where((t) => t.isSended && t.aproveRecive && !t.sapPost).toList();
//       case 'posted':
//         return transfersList.where((t) => t.sapPost).toList();
//       default:
//         return transfersList.toList();
//     }
//   }
// }