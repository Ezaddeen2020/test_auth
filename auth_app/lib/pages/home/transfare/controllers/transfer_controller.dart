// // استيراد جميع الأجزاء
// import 'package:auth_app/pages/home/transfare/controllers/transfer_action_controller.dart';
// import 'package:auth_app/pages/home/transfare/controllers/transfer_data_operation_controller.dart';
// import 'package:auth_app/pages/home/transfare/controllers/transfer_filter_search_controller.dart';

// import 'transfer_controller_base.dart';

// import 'transfer_utilities.dart';

// /// الكنترولر الرئيسي للتحويلات - يجمع جميع الوظائف من الأجزاء المختلفة
// class TransferController extends TransferControllerBase
//     with TransferDataOperations, TransferFilterSearch, TransferActions, TransferUtilities {
//   // يمكن إضافة أي وظائف إضافية هنا إذا لزم الأمر
// }

import 'package:auth_app/pages/home/salse/invice_page.dart';
import 'package:auth_app/pages/home/salse/items_page.dart';
import 'package:auth_app/pages/home/salse/models/details_model.dart';
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

// إضافة هذه الدوال في TransferController

  // المتغيرات الموجودة...
  var selectedTransferDetails = Rxn<TransferDetailDto>();
  var isLoadingDetails = false.obs;

// دالة للانتقال إلى صفحة إدارة المنتجات
  void navigateToProductManagement(TransferModel transfer) {
    Get.to(() => const ProductManagementScreen(), arguments: {
      'transferId': transfer.id,
      'transfer': transfer,
    });
  }

  // الدوال الموجودة...

  // دالة جديدة لجلب تفاصيل التحويل الكاملة
  // Future<TransferDetailDto?> getTransferDetails(int transferId) async {
  //   try {
  //     isLoadingDetails.value = true;

  //     var response = await transferApi.getTransferDetails(transferId);

  //     if (response['status'] == 'success') {
  //       TransferDetailDto transferDetails = TransferDetailDto.fromJson(response['data']);
  //       selectedTransferDetails.value = transferDetails;

  //       return transferDetails;
  //     } else {
  //       Get.snackbar(
  //         'خطأ',
  //         response['message'] ?? 'فشل في جلب تفاصيل التحويل',
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //       );
  //       return null;
  //     }
  //   } catch (e) {
  //     Get.snackbar(
  //       'خطأ',
  //       'حدث خطأ غير متوقع في جلب التفاصيل',
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //     return null;
  //   } finally {
  //     isLoadingDetails.value = false;
  //   }
  // }

// تحديث دالة _navigateToInvoice في transfer_screen.dart
  void _navigateToInvoice(TransferModel transfer, TransferController controller) {
    // تحديد التحويل المحدد في الـ controller
    controller.selectTransfer(transfer);

    // استخدام الدالة المحدثة للانتقال مع جلب البيانات ديناميكياً
    controller.navigateToInvoiceWithDetails(transfer);
  }

// دالة مساعدة للتحقق من صحة transferId
  bool isValidTransferId(int? transferId) {
    return transferId != null && transferId > 0;
  }

// دالة للحصول على معلومات التحويل المختصرة
  String getTransferSummary(TransferModel transfer) {
    return 'التحويل رقم ${transfer.id} - ${transfer.ref ?? "غير محدد"} - من ${transfer.whsNameFrom.trim()} إلى ${transfer.whsNameTo.trim()}';
  }

  // دالة محدثة لجلب تفاصيل التحويل بشكل ديناميكي
  Future<TransferDetailDto?> getTransferDetails(int transferId) async {
    try {
      isLoadingDetails.value = true;

      // استخدام transferId المرسل بدلاً من القيمة الثابتة
      var response = await transferApi.getTransferDetails(transferId);

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

  // // دالة محدثة للانتقال إلى صفحة الفاتورة مع جلب التفاصيل
  // Future<void> navigateToInvoiceWithDetails(TransferModel transfer) async {
  //   // عرض مؤشر التحميل
  //   Get.dialog(
  //     const Center(
  //       child: CircularProgressIndicator(),
  //     ),
  //     barrierDismissible: false,
  //   );

  //   try {
  //     // جلب التفاصيل الكاملة من الباك إند
  //     TransferDetailDto? transferDetails = await getTransferDetails(transfer.id);

  //     // إغلاق مؤشر التحميل
  //     Get.back();

  //     if (transferDetails != null) {
  //       // الانتقال إلى صفحة الفاتورة مع التفاصيل الكاملة
  //       Get.to(() => const InvoicePage(), arguments: {
  //         'transfer': transfer,
  //         'transferDetails': transferDetails,
  //         'transferId': transfer.id,
  //       });
  //     }
  //   } catch (e) {
  //     // إغلاق مؤشر التحميل
  //     Get.back();

  //     Get.snackbar(
  //       'خطأ',
  //       'فشل في جلب تفاصيل التحويل',
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //   }
  // }

// دالة محدثة للانتقال إلى صفحة الفاتورة مع جلب التفاصيل الديناميكية
  Future<void> navigateToInvoiceWithDetails(TransferModel transfer) async {
    // عرض مؤشر التحميل
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      // جلب التفاصيل الكاملة من الباك إند باستخدام transferId ديناميكياً
      TransferDetailDto? transferDetails = await getTransferDetails(transfer.id);

      // إغلاق مؤشر التحميل
      Get.back();

      if (transferDetails != null) {
        // الانتقال إلى صفحة الفاتورة مع التفاصيل الكاملة
        Get.to(() => const InvoicePage(), arguments: {
          'transfer': transfer,
          'transferDetails': transferDetails,
          'transferId': transfer.id, // تمرير transferId بشكل ديناميكي
        });
      }
    } catch (e) {
      // إغلاق مؤشر التحميل
      Get.back();

      Get.snackbar(
        'خطأ',
        'فشل في جلب تفاصيل التحويل رقم ${transfer.id}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // دالة للحصول على إحصائيات الأصناف في التحويل
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

  // دالة للبحث في أسطر التحويل
  List<TransferLine> searchTransferLines(List<TransferLine> lines, String query) {
    if (query.isEmpty) return lines;

    return lines.where((line) {
      return line.itemCode?.toLowerCase().contains(query.toLowerCase()) == true ||
          line.description?.toLowerCase().contains(query.toLowerCase()) == true;
    }).toList();
  }
}
