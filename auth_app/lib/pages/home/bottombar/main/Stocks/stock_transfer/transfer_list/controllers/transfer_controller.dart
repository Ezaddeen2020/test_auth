import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/screens/widgets/delete_diaglog.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/services/get_transfer_api.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/services/get_transfer_detailsApi.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/services/send_recive_transfer_api.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/screen/product_page.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/models/details_model.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/purchase_order.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/models/transfer_stock_model.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/services/transfer_api.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:auth_app/functions/status_request.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'dart:async';

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
  var totalItems = 0.obs;
  var itemsPerPage = 20.obs;
  var hasMoreData = true.obs;

  // Search and Filter
  var searchQuery = ''.obs; // النص الذي يكتبه المستخدم في البحث
  var selectedStatusFilter = 'all'.obs; // فلتر الحالة (الكل، pending، sent...)
  var selectedWarehouseFromFilter = 'all'.obs; // فلتر المستودع المرسل
  var selectedWarehouseToFilter = 'all'.obs; // فلتر المستودع المستقبل

  // Controllers
  late TextEditingController searchController;
  late ScrollController scrollController;

  // API
  late TransferApi transferApi;
  late GetTransferApi gettransferApi;
  late GetTransferDetailsApi gettransferdetailsApi;
  late SendReciveTransferApi sendreciveTransfeApi;

  // Search debounce timer
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    scrollController = ScrollController();
    transferApi = TransferApi(PostGetPage());
    gettransferApi = GetTransferApi(PostGetPage());
    gettransferdetailsApi = GetTransferDetailsApi(PostGetPage());
    sendreciveTransfeApi = SendReciveTransferApi(PostGetPage());

    // تحميل البيانات الأولية
    getTransfersList();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  //===============================     جلب قائمة التحويلات للصفحة المحددة    =================================///
  Future<void> getTransfersList({bool isRefresh = false, int? pageNumber}) async {
    try {
      // تحديد الصفحة المطلوبة
      int targetPage = pageNumber ?? (isRefresh ? 1 : currentPage.value);

      if (isRefresh) {
        isRefreshing.value = true;
        // إعادة تعيين البيانات عند التحديث
        transfers.clear();
        filteredTransfers.clear();
      } else {
        isLoading.value = true;
      }

      statusRequest.value = StatusRequest.loading;

      var response = await gettransferApi.getTransfersList(
        page: targetPage,
        pageSize: itemsPerPage.value,
      );

      if (response['status'] == 'success') {
        TransferResponse transferResponse = TransferResponse.fromJson(response['data']);

        // استبدال البيانات بدلاً من الإضافة (نظام الصفحات الجديد)
        transfers.value = transferResponse.data;

        // تحديث معلومات الصفحات
        currentPage.value = transferResponse.currentPage;
        totalPages.value = transferResponse.totalPages;
        totalItems.value =
            transferResponse.totalItems ?? (transferResponse.totalPages * itemsPerPage.value);
        hasMoreData.value = currentPage.value < totalPages.value;

        // تطبيق الفلاتر
        applyFilters();
        statusRequest.value = StatusRequest.success;

        // عرض رسالة نجاح فقط عند التحديث اليدوي
        if (isRefresh) {
          Get.snackbar(
            'نجح',
            'تم تحديث البيانات بنجاح',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        }
      } else if (response['status'] == 'unauthorized') {
        // إذا انتهت صلاحية التوكن، إعادة توجيه المستخدم لتسجيل الدخول
        statusRequest.value = StatusRequest.failure;
        Get.snackbar(
          'انتهت صلاحية الجلسة ',
          'يرجى تسجيل الدخول مرة أخرى',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // إعادة توجيه المستخدم إلى صفحة تسجيل الدخول
        Get.offAllNamed('/login');
      } else {
        statusRequest.value = StatusRequest.failure;
        Get.snackbar(
          'خطأ',
          response['message'] ?? 'فشل في جلب البيانات',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      statusRequest.value = StatusRequest.failure;
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  //========================= الانتقال إلى صفحة معينة =========================
  Future<void> goToPage(int page) async {
    if (page < 1 || page > totalPages.value || page == currentPage.value || isLoading.value) {
      return;
    }

    // تحديث الصفحة الحالية مباشرة لتحديث UI
    currentPage.value = page;

    // جلب البيانات للصفحة الجديدة
    await getTransfersList(pageNumber: page);

    // التمرير إلى الأعلى عند تغيير الصفحة
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  //========================= تحديث البيانات =========================
  Future<void> refreshTransfers() async {
    await getTransfersList(isRefresh: true);
  }

  //========================= البحث والفلترة مع debouncing =========================
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

  // تحديث البحث مع debouncing
  void updateSearch(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      searchQuery.value = query;
      applyFilters();
    });
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

  //========================= العمليات الأصلية بدون تغيير =========================

  // إرسال التحويل
  Future<void> sendTransfer(int transferId) async {
    try {
      isLoading.value = true;

      var response = await sendreciveTransfeApi.sendTransfer(transferId);

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
            sendedBy: 'Current User',
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

      var response = await sendreciveTransfeApi.receiveTransfer(transferId);

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

// Add this method to your TransferController class

  /// حذف التحويل
  Future<void> deleteTransfer(int transferId) async {
    try {
      isLoading.value = true;

      var response = await transferApi.cancelTransfer(transferId);

      if (response['status'] == 'success') {
        // إزالة التحويل من القائمة محلياً
        transfers.removeWhere((t) => t.id == transferId);

        // تطبيق الفلاتر مرة أخرى
        applyFilters();

        // إذا كانت الصفحة الحالية فارغة وليست الصفحة الأولى، انتقل للصفحة السابقة
        if (filteredTransfers.isEmpty && currentPage.value > 1) {
          await goToPage(currentPage.value - 1);
        } else {
          // إعادة تحميل البيانات للتأكد من التزامن
          await getTransfersList(pageNumber: currentPage.value);
        }

        Get.snackbar(
          'نجح',
          'تم حذف التحويل بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'خطأ',
          response['message'] ?? 'فشل في حذف التحويل',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// التحقق من إمكانية حذف التحويل
  bool canDeleteTransfer(TransferModel transfer) {
    // يمكن حذف التحويل فقط إذا لم يتم إرساله أو ترحيله إلى SAP
    return !transfer.isSended && !transfer.sapPost;
  }

  /// عرض نافذة تأكيد الحذف
  void showDeleteConfirmation(TransferModel transfer) {
    if (!canDeleteTransfer(transfer)) {
      Get.snackbar(
        'تنبيه',
        'لا يمكن حذف هذا التحويل لأنه تم إرساله أو ترحيله إلى SAP',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    Get.dialog(
      DeleteConfirmationDialog(
        transfer: transfer,
        onConfirm: () => deleteTransfer(transfer.id),
      ),
      barrierDismissible: false,
    );
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

  //========================= الدوال المساعدة بدون تغيير =========================

  // تحديد التحويل المحدد
  void selectTransfer(TransferModel transfer) {
    selectedTransfer.value = transfer;
  }

  // مسح التحديد
  void clearSelection() {
    selectedTransfer.value = null;
  }

  // الحصول على قائمة المستودعات الفريدة
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

  //========================= الدوال الإضافية بدون تغيير =========================

  var selectedTransferDetails = Rxn<TransferDetailDto>();
  var isLoadingDetails = false.obs;

  void navigateToProductManagement(TransferModel transfer) {
    Get.to(() => const ProductManagementScreen(), arguments: {
      'transferId': transfer.id,
      'transfer': transfer,
    });
  }

  bool isValidTransferId(int? transferId) {
    return transferId != null && transferId > 0;
  }

  String getTransferSummary(TransferModel transfer) {
    return 'التحويل رقم ${transfer.id} - ${transfer.ref ?? "غير محدد"} - من ${transfer.whsNameFrom.trim()} إلى ${transfer.whsNameTo.trim()}';
  }

  Future<TransferDetailDto?> getTransferDetails(int transferId) async {
    try {
      isLoadingDetails.value = true;

      var response = await gettransferdetailsApi.getTransferDetails(transferId);

      if (response['status'] == 'success') {
        TransferDetailDto transferDetails = TransferDetailDto.fromJson(response['data']);
        selectedTransferDetails.value = transferDetails;
        return transferDetails;
      } else {
        Get.snackbar(
          'خطأ',
          response['message'] ?? 'فشل في جلب تفاصيل التحويل رقم $transferId',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع في جلب تفاصيل التحويل رقم $transferId',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isLoadingDetails.value = false;
    }
  }

  void navigateToInvoiceWithDetails(TransferModel transfer) {
    Get.to(
      () => const TransferDetailsNavigationScreen(),
      arguments: {
        'transfer': transfer,
        'transferId': transfer.id,
      },
      preventDuplicates: true,
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 250),
    );
  }

  Map<String, dynamic> getTransferLinesStats(List<TransferLine> lines) {
    if (lines.isEmpty) {
      return {
        'totalItems': 0,
        'totalQuantity': 0.0,
        'totalAmount': 0.0,
        'uniqueItems': 0,
      };
    }

    double totalQuantity = lines.fold(0.0, (sum, line) => sum + (line.quantity ?? 0.0));
    double totalAmount = lines.fold(0.0, (sum, line) => sum + (line.lineTotal ?? 0.0));
    Set<String> uniqueItems =
        lines.map((line) => line.itemCode ?? '').where((code) => code.isNotEmpty).toSet();

    return {
      'totalItems': lines.length,
      'totalQuantity': totalQuantity,
      'totalAmount': totalAmount,
      'uniqueItems': uniqueItems.length,
    };
  }

  List<TransferLine> searchTransferLines(List<TransferLine> lines, String query) {
    if (query.isEmpty) return lines;

    return lines.where((line) {
      return line.itemCode?.toLowerCase().contains(query.toLowerCase()) == true ||
          line.description?.toLowerCase().contains(query.toLowerCase()) == true;
    }).toList();
  }
}








// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/screen/product_page.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/models/details_model.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/purchase_order.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/models/transfer_stock_model.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/services/transfer_api.dart';
// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:auth_app/functions/status_request.dart';
// import 'package:auth_app/services/api/post_get_api.dart';
// import 'dart:async';

// class TransferController extends GetxController {
//   // Status and Loading States
//   var statusRequest = StatusRequest.none.obs;
//   var isLoading = false.obs;
//   var isLoadingMore = false.obs;
//   var isRefreshing = false.obs;

//   // Data
//   var transfers = <TransferModel>[].obs;
//   var filteredTransfers = <TransferModel>[].obs;
//   var selectedTransfer = Rxn<TransferModel>();

//   // Pagination
//   var currentPage = 1.obs;
//   var totalPages = 1.obs;
//   var totalItems = 0.obs;
//   var itemsPerPage = 20.obs;
//   var hasMoreData = true.obs;

//   // Search and Filter
//   var searchQuery = ''.obs; // النص الذي يكتبه المستخدم في البحث
//   var selectedStatusFilter = 'all'.obs; // فلتر الحالة (الكل، pending، sent...)
//   var selectedWarehouseFromFilter = 'all'.obs; // فلتر المستودع المرسل
//   var selectedWarehouseToFilter = 'all'.obs; // فلتر المستودع المستقبل

//   // Controllers
//   late TextEditingController searchController;
//   late ScrollController scrollController;

//   // API
//   late TransferApi transferApi;

//   // Search debounce timer
//   Timer? _searchDebounce;

//   @override
//   void onInit() {
//     super.onInit();
//     searchController = TextEditingController();
//     scrollController = ScrollController();
//     transferApi = TransferApi(PostGetPage());

//     // تحميل البيانات الأولية
//     getTransfersList();
//   }

//   @override
//   void onClose() {
//     _searchDebounce?.cancel();
//     searchController.dispose();
//     scrollController.dispose();
//     super.onClose();
//   }

//   //===============================     جلب قائمة التحويلات للصفحة المحددة    =================================///
//   Future<void> getTransfersList({bool isRefresh = false, int? pageNumber}) async {
//     try {
//       // تحديد الصفحة المطلوبة
//       int targetPage = pageNumber ?? (isRefresh ? 1 : currentPage.value);

//       if (isRefresh) {
//         isRefreshing.value = true;
//         // إعادة تعيين البيانات عند التحديث
//         transfers.clear();
//         filteredTransfers.clear();
//       } else {
//         isLoading.value = true;
//       }

//       statusRequest.value = StatusRequest.loading;

//       var response = await transferApi.getTransfersList(
//         page: targetPage,
//         pageSize: itemsPerPage.value,
//       );

//       if (response['status'] == 'success') {
//         TransferResponse transferResponse = TransferResponse.fromJson(response['data']);

//         // استبدال البيانات بدلاً من الإضافة (نظام الصفحات الجديد)
//         transfers.value = transferResponse.data;

//         // تحديث معلومات الصفحات
//         currentPage.value = transferResponse.currentPage;
//         totalPages.value = transferResponse.totalPages;
//         totalItems.value =
//             transferResponse.totalItems ?? (transferResponse.totalPages * itemsPerPage.value);
//         hasMoreData.value = currentPage.value < totalPages.value;

//         // تطبيق الفلاتر
//         applyFilters();
//         statusRequest.value = StatusRequest.success;

//         // عرض رسالة نجاح فقط عند التحديث اليدوي
//         if (isRefresh) {
//           Get.snackbar(
//             'نجح',
//             'تم تحديث البيانات بنجاح',
//             backgroundColor: Colors.green,
//             colorText: Colors.white,
//             duration: const Duration(seconds: 2),
//           );
//         }
//       } else {
//         statusRequest.value = StatusRequest.failure;
//         Get.snackbar(
//           'خطأ',
//           response['message'] ?? 'فشل في جلب البيانات',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 3),
//         );
//       }
//     } catch (e) {
//       statusRequest.value = StatusRequest.failure;
//       Get.snackbar(
//         'خطأ',
//         'حدث خطأ غير متوقع',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//     } finally {
//       isLoading.value = false;
//       isRefreshing.value = false;
//     }
//   }

//   //========================= الانتقال إلى صفحة معينة =========================
//   Future<void> goToPage(int page) async {
//     if (page < 1 || page > totalPages.value || page == currentPage.value || isLoading.value) {
//       return;
//     }

//     // تحديث الصفحة الحالية مباشرة لتحديث UI
//     currentPage.value = page;

//     // جلب البيانات للصفحة الجديدة
//     await getTransfersList(pageNumber: page);

//     // التمرير إلى الأعلى عند تغيير الصفحة
//     if (scrollController.hasClients) {
//       scrollController.animateTo(
//         0,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   //========================= تحديث البيانات =========================
//   Future<void> refreshTransfers() async {
//     await getTransfersList(isRefresh: true);
//   }

//   //========================= البحث والفلترة مع debouncing =========================
//   void applyFilters() {
//     var filtered = transfers.where((transfer) {
//       // البحث النصي
//       bool matchesSearch = searchQuery.value.isEmpty ||
//           transfer.ref?.toLowerCase().contains(searchQuery.value.toLowerCase()) == true ||
//           transfer.whsNameFrom.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
//           transfer.whsNameTo.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
//           transfer.creatby.toLowerCase().contains(searchQuery.value.toLowerCase());

//       // فلتر الحالة
//       bool matchesStatus = selectedStatusFilter.value == 'all' ||
//           (selectedStatusFilter.value == 'pending' && !transfer.isSended) ||
//           (selectedStatusFilter.value == 'sent' && transfer.isSended && !transfer.aproveRecive) ||
//           (selectedStatusFilter.value == 'received' &&
//               transfer.aproveRecive &&
//               !transfer.sapPost) ||
//           (selectedStatusFilter.value == 'posted' && transfer.sapPost);

//       // فلتر المستودع المرسل
//       bool matchesFromWarehouse = selectedWarehouseFromFilter.value == 'all' ||
//           transfer.whscodeFrom.trim() == selectedWarehouseFromFilter.value;

//       // فلتر المستودع المستقبل
//       bool matchesToWarehouse = selectedWarehouseToFilter.value == 'all' ||
//           transfer.whscodeTo.trim() == selectedWarehouseToFilter.value;

//       return matchesSearch && matchesStatus && matchesFromWarehouse && matchesToWarehouse;
//     }).toList();

//     filteredTransfers.value = filtered;
//   }

//   // تحديث البحث مع debouncing
//   void updateSearch(String query) {
//     _searchDebounce?.cancel();
//     _searchDebounce = Timer(const Duration(milliseconds: 500), () {
//       searchQuery.value = query;
//       applyFilters();
//     });
//   }

//   // تحديث فلتر الحالة
//   void updateStatusFilter(String status) {
//     selectedStatusFilter.value = status;
//     applyFilters();
//   }

//   // تحديث فلتر المستودع المرسل
//   void updateFromWarehouseFilter(String warehouse) {
//     selectedWarehouseFromFilter.value = warehouse;
//     applyFilters();
//   }

//   // تحديث فلتر المستودع المستقبل
//   void updateToWarehouseFilter(String warehouse) {
//     selectedWarehouseToFilter.value = warehouse;
//     applyFilters();
//   }

//   //========================= العمليات الأصلية بدون تغيير =========================

//   // إرسال التحويل
//   Future<void> sendTransfer(int transferId) async {
//     try {
//       isLoading.value = true;

//       var response = await transferApi.sendTransfer(transferId);

//       if (response['status'] == 'success') {
//         // تحديث البيانات محلياً
//         int index = transfers.indexWhere((t) => t.id == transferId);
//         if (index != -1) {
//           var updatedTransfer = TransferModel(
//             id: transfers[index].id,
//             whscodeFrom: transfers[index].whscodeFrom,
//             whsNameFrom: transfers[index].whsNameFrom,
//             whscodeTo: transfers[index].whscodeTo,
//             whsNameTo: transfers[index].whsNameTo,
//             creatby: transfers[index].creatby,
//             isSended: true,
//             sendedBy: 'Current User',
//             aproveRecive: transfers[index].aproveRecive,
//             aproveReciveBy: transfers[index].aproveReciveBy,
//             sapPost: transfers[index].sapPost,
//             sapPostBy: transfers[index].sapPostBy,
//             sapPostDate: transfers[index].sapPostDate,
//             createDate: transfers[index].createDate,
//             driverName: transfers[index].driverName,
//             driverCode: transfers[index].driverCode,
//             driverMobil: transfers[index].driverMobil,
//             careNum: transfers[index].careNum,
//             note: transfers[index].note,
//             ref: transfers[index].ref,
//           );
//           transfers[index] = updatedTransfer;
//           applyFilters();
//         }

//         Get.snackbar(
//           'نجح',
//           'تم إرسال التحويل بنجاح',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
//       } else {
//         Get.snackbar(
//           'خطأ',
//           response['message'] ?? 'فشل في إرسال التحويل',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'حدث خطأ غير متوقع',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // استلام التحويل
//   Future<void> receiveTransfer(int transferId) async {
//     try {
//       isLoading.value = true;

//       var response = await transferApi.receiveTransfer(transferId);

//       if (response['status'] == 'success') {
//         // تحديث البيانات محلياً
//         int index = transfers.indexWhere((t) => t.id == transferId);
//         if (index != -1) {
//           var updatedTransfer = TransferModel(
//             id: transfers[index].id,
//             whscodeFrom: transfers[index].whscodeFrom,
//             whsNameFrom: transfers[index].whsNameFrom,
//             whscodeTo: transfers[index].whscodeTo,
//             whsNameTo: transfers[index].whsNameTo,
//             creatby: transfers[index].creatby,
//             isSended: transfers[index].isSended,
//             sendedBy: transfers[index].sendedBy,
//             aproveRecive: true,
//             aproveReciveBy: 'Current User',
//             sapPost: transfers[index].sapPost,
//             sapPostBy: transfers[index].sapPostBy,
//             sapPostDate: transfers[index].sapPostDate,
//             createDate: transfers[index].createDate,
//             driverName: transfers[index].driverName,
//             driverCode: transfers[index].driverCode,
//             driverMobil: transfers[index].driverMobil,
//             careNum: transfers[index].careNum,
//             note: transfers[index].note,
//             ref: transfers[index].ref,
//           );
//           transfers[index] = updatedTransfer;
//           applyFilters();
//         }

//         Get.snackbar(
//           'نجح',
//           'تم استلام التحويل بنجاح',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
//       } else {
//         Get.snackbar(
//           'خطأ',
//           response['message'] ?? 'فشل في استلام التحويل',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'حدث خطأ غير متوقع',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // ترحيل إلى SAP
//   Future<void> postToSAP(int transferId) async {
//     try {
//       isLoading.value = true;

//       var response = await transferApi.postToSAP(transferId);

//       if (response['status'] == 'success') {
//         // تحديث البيانات محلياً
//         int index = transfers.indexWhere((t) => t.id == transferId);
//         if (index != -1) {
//           var updatedTransfer = TransferModel(
//             id: transfers[index].id,
//             whscodeFrom: transfers[index].whscodeFrom,
//             whsNameFrom: transfers[index].whsNameFrom,
//             whscodeTo: transfers[index].whscodeTo,
//             whsNameTo: transfers[index].whsNameTo,
//             creatby: transfers[index].creatby,
//             isSended: transfers[index].isSended,
//             sendedBy: transfers[index].sendedBy,
//             aproveRecive: transfers[index].aproveRecive,
//             aproveReciveBy: transfers[index].aproveReciveBy,
//             sapPost: true,
//             sapPostBy: 'Current User',
//             sapPostDate: DateTime.now().toIso8601String(),
//             createDate: transfers[index].createDate,
//             driverName: transfers[index].driverName,
//             driverCode: transfers[index].driverCode,
//             driverMobil: transfers[index].driverMobil,
//             careNum: transfers[index].careNum,
//             note: transfers[index].note,
//             ref: transfers[index].ref,
//           );
//           transfers[index] = updatedTransfer;
//           applyFilters();
//         }

//         Get.snackbar(
//           'نجح',
//           'تم ترحيل التحويل إلى SAP بنجاح',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
//       } else {
//         Get.snackbar(
//           'خطأ',
//           response['message'] ?? 'فشل في ترحيل التحويل إلى SAP',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'حدث خطأ غير متوقع',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   //========================= الدوال المساعدة بدون تغيير =========================

//   // تحديد التحويل المحدد
//   void selectTransfer(TransferModel transfer) {
//     selectedTransfer.value = transfer;
//   }

//   // مسح التحديد
//   void clearSelection() {
//     selectedTransfer.value = null;
//   }

//   // الحصول على قائمة المستودعات الفريدة
//   List<String> getUniqueWarehouses() {
//     Set<String> warehouses = {};
//     for (var transfer in transfers) {
//       warehouses.add(transfer.whscodeFrom.trim());
//       warehouses.add(transfer.whscodeTo.trim());
//     }
//     return warehouses.toList()..sort();
//   }

//   // الحصول على إحصائيات التحويلات
//   Map<String, int> getTransferStats() {
//     int pending = transfers.where((t) => !t.isSended).length;
//     int sent = transfers.where((t) => t.isSended && !t.aproveRecive).length;
//     int received = transfers.where((t) => t.aproveRecive && !t.sapPost).length;
//     int posted = transfers.where((t) => t.sapPost).length;

//     return {
//       'pending': pending,
//       'sent': sent,
//       'received': received,
//       'posted': posted,
//       'total': transfers.length,
//     };
//   }

//   // إعادة تعيين الفلاتر
//   void resetFilters() {
//     searchQuery.value = '';
//     selectedStatusFilter.value = 'all';
//     selectedWarehouseFromFilter.value = 'all';
//     selectedWarehouseToFilter.value = 'all';
//     searchController.clear();
//     applyFilters();
//   }

//   // التحقق من إمكانية تنفيذ العمليات
//   bool canSendTransfer(TransferModel transfer) {
//     return !transfer.isSended;
//   }

//   bool canReceiveTransfer(TransferModel transfer) {
//     return transfer.isSended && !transfer.aproveRecive;
//   }

//   bool canPostToSAP(TransferModel transfer) {
//     return transfer.aproveRecive && !transfer.sapPost;
//   }

//   //========================= الدوال الإضافية بدون تغيير =========================

//   var selectedTransferDetails = Rxn<TransferDetailDto>();
//   var isLoadingDetails = false.obs;

//   void navigateToProductManagement(TransferModel transfer) {
//     Get.to(() => const ProductManagementScreen(), arguments: {
//       'transferId': transfer.id,
//       'transfer': transfer,
//     });
//   }

//   bool isValidTransferId(int? transferId) {
//     return transferId != null && transferId > 0;
//   }

//   String getTransferSummary(TransferModel transfer) {
//     return 'التحويل رقم ${transfer.id} - ${transfer.ref ?? "غير محدد"} - من ${transfer.whsNameFrom.trim()} إلى ${transfer.whsNameTo.trim()}';
//   }

//   Future<TransferDetailDto?> getTransferDetails(int transferId) async {
//     try {
//       isLoadingDetails.value = true;

//       var response = await transferApi.getTransferDetails(transferId);

//       if (response['status'] == 'success') {
//         TransferDetailDto transferDetails = TransferDetailDto.fromJson(response['data']);
//         selectedTransferDetails.value = transferDetails;
//         return transferDetails;
//       } else {
//         Get.snackbar(
//           'خطأ',
//           response['message'] ?? 'فشل في جلب تفاصيل التحويل رقم $transferId',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//         return null;
//       }
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'حدث خطأ غير متوقع في جلب تفاصيل التحويل رقم $transferId',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return null;
//     } finally {
//       isLoadingDetails.value = false;
//     }
//   }

//   void navigateToInvoiceWithDetails(TransferModel transfer) {
//     Get.to(
//       () => const TransferDetailsNavigationScreen(),
//       arguments: {
//         'transfer': transfer,
//         'transferId': transfer.id,
//       },
//       preventDuplicates: true,
//       transition: Transition.cupertino,
//       duration: const Duration(milliseconds: 250),
//     );
//   }

//   Map<String, dynamic> getTransferLinesStats(List<TransferLine> lines) {
//     if (lines.isEmpty) {
//       return {
//         'totalItems': 0,
//         'totalQuantity': 0.0,
//         'totalAmount': 0.0,
//         'uniqueItems': 0,
//       };
//     }

//     double totalQuantity = lines.fold(0.0, (sum, line) => sum + (line.quantity ?? 0.0));
//     double totalAmount = lines.fold(0.0, (sum, line) => sum + (line.lineTotal ?? 0.0));
//     Set<String> uniqueItems =
//         lines.map((line) => line.itemCode ?? '').where((code) => code.isNotEmpty).toSet();

//     return {
//       'totalItems': lines.length,
//       'totalQuantity': totalQuantity,
//       'totalAmount': totalAmount,
//       'uniqueItems': uniqueItems.length,
//     };
//   }

//   List<TransferLine> searchTransferLines(List<TransferLine> lines, String query) {
//     if (query.isEmpty) return lines;

//     return lines.where((line) {
//       return line.itemCode?.toLowerCase().contains(query.toLowerCase()) == true ||
//           line.description?.toLowerCase().contains(query.toLowerCase()) == true;
//     }).toList();
//   }
// }
