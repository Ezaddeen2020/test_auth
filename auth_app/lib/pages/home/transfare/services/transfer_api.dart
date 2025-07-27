// import 'package:auth_app/functions/handling_data.dart';
// import 'package:auth_app/services/api/post_get_api.dart';
// import 'package:auth_app/services/api_service.dart';
// import 'package:auth_app/classes/shared_preference.dart';

// class TransferApi {
//   final PostGetPage postGetPage;

//   TransferApi(this.postGetPage);

//   // جلب قائمة التحويلات مع Pagination
//   Future<Map<String, dynamic>> getTransfersList({
//     int page = 1,
//     int pageSize = 20,
//   }) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer', 'Getting transfers list - Page: $page, PageSize: $pageSize');

//     return handleEitherResult(
//       postGetPage.getDataWithToken(
//         ApiServices.getTransfersList(page, pageSize),
//         token,
//       ),
//       'Transfers List Retrieved Successfully',
//       'فشل في جلب قائمة التحويلات',
//     );
//   }

//   // جلب تفاصيل تحويل محدد
//   Future<Map<String, dynamic>> getTransferDetails(int transferId) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer', 'Getting transfer details for ID: $transferId');

//     return handleEitherResult(
//       postGetPage.getDataWithToken(
//         ApiServices.getTransferDetails(transferId),
//         token,
//       ),
//       'Transfer Details Retrieved Successfully',
//       'فشل في جلب تفاصيل التحويل',
//     );
//   }

//   // إرسال التحويل
//   Future<Map<String, dynamic>> sendTransfer(int transferId) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer', 'Sending transfer with ID: $transferId');

//     return handleEitherResult(
//       postGetPage.postData(
//         ApiServices.sendTransfer(),
//         {'transferId': transferId},
//       ),
//       'Transfer Sent Successfully',
//       'فشل في إرسال التحويل',
//     );
//   }

//   // استلام التحويل
//   Future<Map<String, dynamic>> receiveTransfer(int transferId) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer', 'Receiving transfer with ID: $transferId');

//     return handleEitherResult(
//       postGetPage.postData(
//         ApiServices.receiveTransfer(),
//         {'transferId': transferId},
//       ),
//       'Transfer Received Successfully',
//       'فشل في استلام التحويل',
//     );
//   }

//   // ترحيل إلى SAP
//   Future<Map<String, dynamic>> postToSAP(int transferId) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer', 'Posting transfer to SAP with ID: $transferId');

//     return handleEitherResult(
//       postGetPage.postData(
//         ApiServices.postTransferToSAP(),
//         {'transferId': transferId},
//       ),
//       'Transfer Posted to SAP Successfully',
//       'فشل في ترحيل التحويل إلى SAP',
//     );
//   }

//   // البحث في التحويلات
//   Future<Map<String, dynamic>> searchTransfers({
//     String? ref,
//     String? whscodeFrom,
//     String? whscodeTo,
//     String? creatby,
//     bool? isSended,
//     bool? aproveRecive,
//     bool? sapPost,
//     int page = 1,
//     int pageSize = 20,
//   }) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     Map<String, dynamic> searchParams = {
//       'page': page,
//       'pageSize': pageSize,
//     };

//     if (ref != null && ref.isNotEmpty) searchParams['ref'] = ref;
//     if (whscodeFrom != null && whscodeFrom.isNotEmpty) searchParams['whscodeFrom'] = whscodeFrom;
//     if (whscodeTo != null && whscodeTo.isNotEmpty) searchParams['whscodeTo'] = whscodeTo;
//     if (creatby != null && creatby.isNotEmpty) searchParams['creatby'] = creatby;
//     if (isSended != null) searchParams['isSended'] = isSended;
//     if (aproveRecive != null) searchParams['aproveRecive'] = aproveRecive;
//     if (sapPost != null) searchParams['sapPost'] = sapPost;

//     logMessage('Transfer', 'Searching transfers with params: $searchParams');

//     return handleEitherResult(
//       postGetPage.getDataWithToken(
//         ApiServices.searchTransfers(searchParams),
//         token,
//       ),
//       'Transfer Search Results Retrieved Successfully',
//       'فشل في البحث عن التحويلات',
//     );
//   }

//   // إنشاء تحويل جديد
//   Future<Map<String, dynamic>> createTransfer({
//     required String whscodeFrom,
//     required String whscodeTo,
//     String? driverName,
//     String? driverCode,
//     String? driverMobil,
//     String? careNum,
//     String? note,
//   }) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     Map<String, dynamic> transferData = {
//       'whscodeFrom': whscodeFrom,
//       'whscodeTo': whscodeTo,
//     };

//     if (driverName != null && driverName.isNotEmpty) transferData['driverName'] = driverName;
//     if (driverCode != null && driverCode.isNotEmpty) transferData['driverCode'] = driverCode;
//     if (driverMobil != null && driverMobil.isNotEmpty) transferData['driverMobil'] = driverMobil;
//     if (careNum != null && careNum.isNotEmpty) transferData['careNum'] = careNum;
//     if (note != null && note.isNotEmpty) transferData['note'] = note;

//     logMessage('Transfer', 'Creating new transfer: $transferData');

//     return handleEitherResult(
//       postGetPage.postData(
//         ApiServices.createTransfer(),
//         transferData,
//       ),
//       'Transfer Created Successfully',
//       'فشل في إنشاء التحويل',
//     );
//   }

//    // دالة جديدة لجلب تفاصيل التحويل الكاملة
//   Future<Map<String, dynamic>> getTransferDetails(int transferId) async {
//     try {
//       var response = await postGetPage.getData(
//         "/api/TransferApi/transfer-details?id=$transferId",
//         {},
//       );

//       return response;
//     } catch (e) {
//       return {
//         'status': 'error',
//         'message': 'فشل في جلب تفاصيل التحويل',
//         'error': e.toString(),
//       };
//     }
//   }
// }

import 'package:auth_app/functions/handling_data.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:auth_app/services/api_service.dart';
import 'package:auth_app/classes/shared_preference.dart';

class TransferApi {
  final PostGetPage postGetPage;

  TransferApi(this.postGetPage);

  // جلب قائمة التحويلات مع Pagination
  Future<Map<String, dynamic>> getTransfersList({
    int page = 1,
    int pageSize = 20,
  }) async {
    String token = Preferences.getString('auth_token');

    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    logMessage('Transfer', 'Getting transfers list - Page: $page, PageSize: $pageSize');

    return handleEitherResult(
      postGetPage.getDataWithToken(
        ApiServices.getTransfersList(page, pageSize),
        token,
      ),
      'Transfers List Retrieved Successfully',
      'فشل في جلب قائمة التحويلات',
    );
  }

  // جلب تفاصيل تحويل محدد - محدثة للعمل مع الباك إند
  Future<Map<String, dynamic>> getTransferDetails(int transferId) async {
    String token = Preferences.getString('auth_token');

    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    logMessage('Transfer', 'Getting transfer details for ID: $transferId');

    return handleEitherResult(
      postGetPage.getDataWithToken(
        ApiServices.getTransferDetails(transferId), // استخدام ApiServices
        token,
      ),
      'Transfer Details Retrieved Successfully',
      'فشل في جلب تفاصيل التحويل',
    );
  }

  // إرسال التحويل
  Future<Map<String, dynamic>> sendTransfer(int transferId) async {
    String token = Preferences.getString('auth_token');

    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    logMessage('Transfer', 'Sending transfer with ID: $transferId');

    return handleEitherResult(
      postGetPage.postData(
        ApiServices.sendTransfer(),
        {'transferId': transferId},
      ),
      'Transfer Sent Successfully',
      'فشل في إرسال التحويل',
    );
  }

  // استلام التحويل
  Future<Map<String, dynamic>> receiveTransfer(int transferId) async {
    String token = Preferences.getString('auth_token');

    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    logMessage('Transfer', 'Receiving transfer with ID: $transferId');

    return handleEitherResult(
      postGetPage.postData(
        ApiServices.receiveTransfer(),
        {'transferId': transferId},
      ),
      'Transfer Received Successfully',
      'فشل في استلام التحويل',
    );
  }

  // ترحيل إلى SAP
  Future<Map<String, dynamic>> postToSAP(int transferId) async {
    String token = Preferences.getString('auth_token');

    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    logMessage('Transfer', 'Posting transfer to SAP with ID: $transferId');

    return handleEitherResult(
      postGetPage.postData(
        ApiServices.postTransferToSAP(),
        {'transferId': transferId},
      ),
      'Transfer Posted to SAP Successfully',
      'فشل في ترحيل التحويل إلى SAP',
    );
  }

  // البحث في التحويلات
  Future<Map<String, dynamic>> searchTransfers({
    String? ref,
    String? whscodeFrom,
    String? whscodeTo,
    String? creatby,
    bool? isSended,
    bool? aproveRecive,
    bool? sapPost,
    int page = 1,
    int pageSize = 20,
  }) async {
    String token = Preferences.getString('auth_token');

    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    Map<String, dynamic> searchParams = {
      'page': page,
      'pageSize': pageSize,
    };

    if (ref != null && ref.isNotEmpty) searchParams['ref'] = ref;
    if (whscodeFrom != null && whscodeFrom.isNotEmpty) searchParams['whscodeFrom'] = whscodeFrom;
    if (whscodeTo != null && whscodeTo.isNotEmpty) searchParams['whscodeTo'] = whscodeTo;
    if (creatby != null && creatby.isNotEmpty) searchParams['creatby'] = creatby;
    if (isSended != null) searchParams['isSended'] = isSended;
    if (aproveRecive != null) searchParams['aproveRecive'] = aproveRecive;
    if (sapPost != null) searchParams['sapPost'] = sapPost;

    logMessage('Transfer', 'Searching transfers with params: $searchParams');

    return handleEitherResult(
      postGetPage.getDataWithToken(
        ApiServices.searchTransfers(searchParams),
        token,
      ),
      'Transfer Search Results Retrieved Successfully',
      'فشل في البحث عن التحويلات',
    );
  }

  // إنشاء تحويل جديد
  Future<Map<String, dynamic>> createTransfer({
    required String whscodeFrom,
    required String whscodeTo,
    String? driverName,
    String? driverCode,
    String? driverMobil,
    String? careNum,
    String? note,
  }) async {
    String token = Preferences.getString('auth_token');

    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    Map<String, dynamic> transferData = {
      'whscodeFrom': whscodeFrom,
      'whscodeTo': whscodeTo,
    };

    if (driverName != null && driverName.isNotEmpty) transferData['driverName'] = driverName;
    if (driverCode != null && driverCode.isNotEmpty) transferData['driverCode'] = driverCode;
    if (driverMobil != null && driverMobil.isNotEmpty) transferData['driverMobil'] = driverMobil;
    if (careNum != null && careNum.isNotEmpty) transferData['careNum'] = careNum;
    if (note != null && note.isNotEmpty) transferData['note'] = note;

    logMessage('Transfer', 'Creating new transfer: $transferData');

    return handleEitherResult(
      postGetPage.postData(
        ApiServices.createTransfer(),
        transferData,
      ),
      'Transfer Created Successfully',
      'فشل في إنشاء التحويل',
    );
  }
}

// ملاحظات مهمة:
// 1. تم حذف الدالة المكررة getTransferDetails
// 2. تم تحديث الدالة الأصلية لاستخدام URL الباك إند الصحيح
// 3. احتفظنا بنظام المصادقة والـ token
// 4. الدالة الآن تعمل مع endpoint: /api/TransferApi/transfer-details?id=$transferId
// ملاحظات مهمة:
// 1. تم حذف الدالة المكررة getTransferDetails
// 2. تم تحديث الدالة الأصلية لاستخدام URL الباك إند الصحيح
// 3. احتفظنا بنظام المصادقة والـ token
// 4. الدالة الآن تعمل مع endpoint: /api/TransferApi/transfer-details?id=$transferId
// ملاحظات مهمة:
// 1. تم حذف الدالة المكررة getTransferDetails
// 2. تم تحديث الدالة الأصلية لاستخدام URL الباك إند الصحيح
// 3. احتفظنا بنظام المصادقة والـ token
// 4. الدالة الآن تعمل مع endpoint: /api/TransferApi/transfer-details?id=$transferId


// import 'package:auth_app/functions/handling_data.dart';
// import 'package:auth_app/services/api/post_get_api.dart';
// import 'package:auth_app/services/api_service.dart';
// import 'package:auth_app/classes/shared_preference.dart';

// class TransferApi {
//   final PostGetPage postGetPage;

//   TransferApi(this.postGetPage);

//   /// جلب قائمة التحويلات مع إمكانية التصفية والصفحات
//   Future<Map<String, dynamic>> getTransfersList({
//     int page = 1,
//     int pageSize = 20,
//     String? fromWarehouse,
//     String? toWarehouse,
//     String? status,
//     String? dateFrom,
//     String? dateTo,
//   }) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer API', 'Getting transfers list - Page: $page, PageSize: $pageSize');

//     // بناء URL مع المعاملات
//     String url = ApiServices.getTransfersList(
//       page: page,
//       pageSize: pageSize,
//       fromWarehouse: fromWarehouse,
//       toWarehouse: toWarehouse,
//       status: status,
//       dateFrom: dateFrom,
//       dateTo: dateTo,
//     );

//     return handleEitherResult(
//       postGetPage.getDataWithToken(url, token),
//       'Transfers List Retrieved Successfully',
//       'فشل في جلب قائمة التحويلات',
//     );
//   }

//   /// جلب تفاصيل تحويل معين
//   Future<Map<String, dynamic>> getTransferDetails(int transferId) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer API', 'Getting transfer details for ID: $transferId');

//     return handleEitherResult(
//       postGetPage.getDataWithToken(ApiServices.getTransferDetails(transferId), token),
//       'Transfer Details Retrieved Successfully',
//       'فشل في جلب تفاصيل التحويل',
//     );
//   }

//   /// إنشاء تحويل جديد
//   Future<Map<String, dynamic>> createTransfer(Map<String, dynamic> transferData) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer API', 'Creating new transfer: $transferData');

//     return handleEitherResult(
//       postGetPage.postDataWithToken(ApiServices.createTransfer, transferData, token),
//       'Transfer Created Successfully',
//       'فشل في إنشاء التحويل',
//     );
//   }

//   /// تحديث تحويل موجود
//   Future<Map<String, dynamic>> updateTransfer(int transferId, Map<String, dynamic> transferData) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer API', 'Updating transfer ID: $transferId with data: $transferData');

//     return handleEitherResult(
//       postGetPage.putDataWithToken(ApiServices.updateTransfer(transferId), transferData, token),
//       'Transfer Updated Successfully',
//       'فشل في تحديث التحويل',
//     );
//   }

//   /// حذف تحويل
//   Future<Map<String, dynamic>> deleteTransfer(int transferId) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer API', 'Deleting transfer ID: $transferId');

//     return handleEitherResult(
//       postGetPage.deleteDataWithToken(ApiServices.deleteTransfer(transferId), token),
//       'Transfer Deleted Successfully',
//       'فشل في حذف التحويل',
//     );
//   }

//   /// تأكيد الإرسال
//   Future<Map<String, dynamic>> confirmSend(int transferId, Map<String, dynamic> confirmData) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer API', 'Confirming send for transfer ID: $transferId');

//     return handleEitherResult(
//       postGetPage.postDataWithToken(ApiServices.confirmTransferSend(transferId), confirmData, token),
//       'Transfer Send Confirmed Successfully',
//       'فشل في تأكيد الإرسال',
//     );
//   }

//   /// تأكيد الاستلام
//   Future<Map<String, dynamic>> confirmReceive(int transferId, Map<String, dynamic> confirmData) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer API', 'Confirming receive for transfer ID: $transferId');

//     return handleEitherResult(
//       postGetPage.postDataWithToken(ApiServices.confirmTransferReceive(transferId), confirmData, token),
//       'Transfer Receive Confirmed Successfully',
//       'فشل في تأكيد الاستلام',
//     );
//   }

//   /// ترحيل إلى SAP
//   Future<Map<String, dynamic>> postToSap(int transferId) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer API', 'Posting to SAP for transfer ID: $transferId');

//     return handleEitherResult(
//       postGetPage.postDataWithToken(ApiServices.postTransferToSap(transferId), {}, token),
//       'Transfer Posted to SAP Successfully',
//       'فشل في ترحيل التحويل إلى SAP',
//     );
//   }

//   /// جلب قائمة المستودعات
//   Future<Map<String, dynamic>> getWarehouses() async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer API', 'Getting warehouses list');

//     return handleEitherResult(
//       postGetPage.getDataWithToken(ApiServices.getWarehouses, token),
//       'Warehouses List Retrieved Successfully',
//       'فشل في جلب قائمة المستودعات',
//     );
//   }

//   /// البحث في التحويلات
//   Future<Map<String, dynamic>> searchTransfers(String searchTerm) async {
//     String token = Preferences.getString('auth_token');

//     if (token.isEmpty) {
//       return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//     }

//     logMessage('Transfer API', 'Searching transfers with term: $searchTerm');

//     return handleEitherResult(
//       postGetPage.getDataWithToken(ApiServices.searchTransfers(searchTerm), token),
//       'Transfer Search Completed Successfully',
//       'فشل في البحث عن التحويلات',
//     );
//   }
// }