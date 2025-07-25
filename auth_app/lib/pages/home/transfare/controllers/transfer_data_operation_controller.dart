import 'package:auth_app/pages/home/transfare/models/transfer_stock.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:auth_app/functions/status_request.dart';
import 'transfer_controller_base.dart';

/// الجزء الخاص بعمليات جلب البيانات والتحديث
mixin TransferDataOperations on TransferControllerBase {
  // جلب قائمة التحويلات
  @override
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
  @override
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
  @override
  Future<void> refreshTransfers() async {
    await getTransfersList(isRefresh: true);
  }
}
