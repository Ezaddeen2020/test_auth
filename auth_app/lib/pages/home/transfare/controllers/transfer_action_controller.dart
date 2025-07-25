import 'package:auth_app/pages/home/transfare/models/transfer_stock.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'transfer_controller_base.dart';

/// الجزء الخاص بعمليات التحويل (إرسال، استلام، ترحيل إلى SAP)
mixin TransferActions on TransferControllerBase {
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
