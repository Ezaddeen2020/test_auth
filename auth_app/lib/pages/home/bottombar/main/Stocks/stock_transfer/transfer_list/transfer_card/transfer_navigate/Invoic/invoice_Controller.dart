// ignore_for_file: file_names

import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/screen/product_page.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/services/transfer_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/functions/status_request.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/models/details_model.dart';
import 'package:auth_app/services/api/post_get_api.dart';

class InvoiceController extends GetxController {
  // Status States
  var statusRequest = StatusRequest.none.obs;
  var isLoading = false.obs;

  // Data - التركيز على الهيدر فقط
  var transferDetails = Rxn<TransferDetailDto>();

  // API
  late TransferApi transferApi;

  @override
  void onInit() {
    super.onInit();
    transferApi = TransferApi(PostGetPage());
    // إعادة تعيين الحالة عند بدء الكنترولر
    resetLoadingState();
  }

  // إضافة هذه الدالة الجديدة
  void resetLoadingState() {
    isLoading.value = false;
    statusRequest.value = StatusRequest.none;
  }

  // تحميل تفاصيل التحويل من الباك إند - التركيز على الهيدر
  Future<void> loadTransferDetails(int transferId) async {
    try {
      isLoading.value = true;
      statusRequest.value = StatusRequest.loading;

      var response = await transferApi.getTransferDetails(transferId);

      if (response['status'] == 'success') {
        TransferDetailDto details = TransferDetailDto.fromJson(response['data']);
        transferDetails.value = details;

        statusRequest.value = StatusRequest.success;

        // Get.snackbar(
        //   'نجح',
        //   'تم تحميل معلومات التحويل رقم $transferId بنجاح',
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        //   duration: const Duration(seconds: 2),
        // );
      } else {
        statusRequest.value = StatusRequest.failure;
        Get.snackbar(
          'خطأ',
          response['message'] ?? 'فشل في تحميل معلومات التحويل',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      statusRequest.value = StatusRequest.failure;
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // الانتقال إلى صفحة إدارة الأصناف
  void navigateToProductManagement() {
    if (transferDetails.value != null) {
      Get.to(() => const ProductManagementScreen(), arguments: {
        'transferId': transferDetails.value!.header.id,
        'header': transferDetails.value!.header,
      });
    } else {
      Get.snackbar(
        'خطأ',
        'لا توجد بيانات تحويل متاحة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // طباعة الفاتورة
  void printInvoice() {
    if (transferDetails.value != null) {
      // هنا يمكن إضافة منطق الطباعة الفعلي
      Get.snackbar(
        'طباعة',
        'سيتم إضافة وظيفة الطباعة قريباً',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'خطأ',
        'لا توجد بيانات للطباعة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // مشاركة بيانات الفاتورة
  void shareInvoice() {
    if (transferDetails.value != null) {
      // هنا يمكن إضافة منطق المشاركة
      // final headerData = exportHeaderData();

      Get.snackbar(
        'مشاركة',
        'تم تحضير بيانات الفاتورة للمشاركة',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'خطأ',
        'لا توجد بيانات للمشاركة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // تحديث حالة التحويل
  Future<void> updateTransferStatus(String action) async {
    if (transferDetails.value == null) return;

    try {
      isLoading.value = true;

      // هنا يمكن إضافة API calls لتحديث الحالة
      // مثل إرسال، استلام، أو ترحيل التحويل

      Get.snackbar(
        'نجح',
        'تم تحديث حالة التحويل بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // إعادة تحميل البيانات لعرض التحديث
      await loadTransferDetails(transferDetails.value!.header.id);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحديث حالة التحويل',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // إضافة ملاحظة للتحويل
  Future<void> addNote(String note) async {
    if (transferDetails.value == null || note.trim().isEmpty) return;

    try {
      isLoading.value = true;

      // هنا يمكن إضافة API call لإضافة الملاحظة

      Get.snackbar(
        'نجح',
        'تم إضافة الملاحظة بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // إعادة تحميل البيانات
      await loadTransferDetails(transferDetails.value!.header.id);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إضافة الملاحظة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // تحديث معلومات السائق
  Future<void> updateDriverInfo({
    String? driverName,
    String? driverCode,
    String? driverMobile,
    String? carNumber,
  }) async {
    if (transferDetails.value == null) return;

    try {
      isLoading.value = true;

      // هنا يمكن إضافة API call لتحديث معلومات السائق

      Get.snackbar(
        'نجح',
        'تم تحديث معلومات السائق بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // إعادة تحميل البيانات
      await loadTransferDetails(transferDetails.value!.header.id);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحديث معلومات السائق',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // الحصول على معلومات الهيدر
  TransferHeader? get headerInfo => transferDetails.value?.header;

  // التحقق من وجود بيانات
  bool get hasData => transferDetails.value != null;

  // التحقق من إمكانية تنفيذ العمليات المختلفة
  bool get canSendTransfer => hasData && !headerInfo!.isSended;

  bool get canReceiveTransfer => hasData && headerInfo!.isSended && !headerInfo!.aproveRecive;

  bool get canPostToSAP => hasData && headerInfo!.aproveRecive && !headerInfo!.sapPost;

  bool get isTransferCompleted => hasData && headerInfo!.sapPost;

  // الحصول على نسبة التقدم في التحويل
  double get transferProgress {
    if (!hasData) return 0.0;

    int completedSteps = 0;
    if (headerInfo!.isSended) completedSteps++;
    if (headerInfo!.aproveRecive) completedSteps++;
    if (headerInfo!.sapPost) completedSteps++;

    return completedSteps / 3.0;
  }

  // الحصول على الخطوة التالية المطلوبة
  String get nextRequiredStep {
    if (!hasData) return 'تحميل البيانات';

    if (!headerInfo!.isSended) return 'إرسال التحويل';
    if (!headerInfo!.aproveRecive) return 'استلام التحويل';
    if (!headerInfo!.sapPost) return 'ترحيل إلى SAP';

    return 'مكتمل';
  }

  // تصدير بيانات الهيدر
  Map<String, dynamic> exportHeaderData() {
    if (transferDetails.value == null) return {};

    return {
      'transferId': headerInfo!.id,
      'referenceNumber': headerInfo!.ref,
      'createDate': headerInfo!.createDate,
      'createdBy': headerInfo!.creatby,
      'fromWarehouse': {
        'code': headerInfo!.whscodeFrom,
        'name': headerInfo!.whsNameFrom,
      },
      'toWarehouse': {
        'code': headerInfo!.whscodeTo,
        'name': headerInfo!.whsNameTo,
      },
      'driver': {
        'name': headerInfo!.driverName,
        'code': headerInfo!.driverCode,
        'mobile': headerInfo!.driverMobil,
        'carNumber': headerInfo!.careNum,
      },
      'status': {
        'isSent': headerInfo!.isSended,
        'sentBy': headerInfo!.sendedBy,
        'isReceived': headerInfo!.aproveRecive,
        'receivedBy': headerInfo!.aproveReciveBy,
        'isPostedToSAP': headerInfo!.sapPost,
        'postedBy': headerInfo!.sapPostBy,
        'postedDate': headerInfo!.sapPostDate,
      },
      'note': headerInfo!.note,
      'progress': transferProgress,
      'nextStep': nextRequiredStep,
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  // البحث في سجل التحويلات المشابهة
  Future<List<Map<String, dynamic>>> findSimilarTransfers() async {
    if (!hasData) return [];

    try {
      // هنا يمكن إضافة API call للبحث عن التحويلات المشابهة
      // بناءً على المستودعات أو المنشئ

      return [
        // نتائج وهمية للمثال
        {
          'id': 97,
          'ref': '25104',
          'fromWarehouse': headerInfo!.whsNameFrom,
          'toWarehouse': headerInfo!.whsNameTo,
          'createDate': '2025-07-27',
        },
        {
          'id': 96,
          'ref': '25103',
          'fromWarehouse': headerInfo!.whsNameFrom,
          'toWarehouse': headerInfo!.whsNameTo,
          'createDate': '2025-07-26',
        },
      ];
    } catch (e) {
      return [];
    }
  }

  // التحقق من صحة البيانات
  bool validateTransferData() {
    if (!hasData) return false;

    final header = headerInfo!;

    // التحقق من وجود البيانات الأساسية
    if (header.id <= 0) return false;
    if (header.whscodeFrom.trim().isEmpty) return false;
    if (header.whscodeTo.trim().isEmpty) return false;
    if (header.creatby.trim().isEmpty) return false;

    return true;
  }

  // إعادة تعيين البيانات
  void resetData() {
    transferDetails.value = null;
    statusRequest.value = StatusRequest.none;
    isLoading.value = false;
  }

  // تحديث البيانات
  Future<void> refreshData() async {
    if (hasData) {
      await loadTransferDetails(headerInfo!.id);
    }
  }
}
