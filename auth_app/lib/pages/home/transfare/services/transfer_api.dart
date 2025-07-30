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

  // جلب تفاصيل تحويل محدد - محدثة للعمل ديناميكياً مع أي transferId
  Future<Map<String, dynamic>> getTransferDetails(int transferId) async {
    String token = Preferences.getString('auth_token');

    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    logMessage('Transfer', 'Getting transfer details for ID: $transferId');

    return handleEitherResult(
      postGetPage.getDataWithToken(
        ApiServices.getTransferDetails(transferId), // يتم تمرير transferId ديناميكياً
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
      postGetPage.postDataWithToken(
        ApiServices.sendTransfer(),
        {'transferId': transferId},
        token,
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
      postGetPage.postDataWithToken(
        ApiServices.receiveTransfer(),
        {'transferId': transferId},
        token,
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
      postGetPage.postDataWithToken(
        ApiServices.postTransferToSAP(),
        {'transferId': transferId},
        token,
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

  // إدارة سطر التحويل (إضافة/تعديل)
  Future<Map<String, dynamic>> upsertTransferLine({
    required int docEntry,
    int? lineNum, // إذا كان null أو 0 أو -1 = إضافة جديدة
    required String itemCode,
    required String description,
    required double quantity,
    required double price,
    required double lineTotal,
    required String uomCode,
    String? uomCode2,
    double? invQty,
    int? baseQty1,
    int? ugpEntry,
    int? uomEntry,
  }) async {
    String token = Preferences.getString('auth_token');

    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    // تحضير البيانات للإرسال
    Map<String, dynamic> lineData = {
      'docEntry': docEntry,
      'itemCode': itemCode,
      'description': description,
      'quantity': quantity,
      'price': price,
      'lineTotal': lineTotal,
      'uomCode': uomCode,
      'uomCode2': uomCode2,
      'invQty': invQty,
      'baseQty1': baseQty1,
      'ugpEntry': ugpEntry,
      'uomEntry': uomEntry,
    };

    // تحديد نوع العملية بناءً على lineNum
    if (lineNum != null && lineNum > 0) {
      // عملية تعديل - إضافة lineNum
      lineData['lineNum'] = lineNum;
      logMessage('Transfer', 'Updating existing line with lineNum: $lineNum');
    } else {
      // عملية إضافة جديدة - عدم إرسال lineNum أو إرسال -1
      lineData['lineNum'] = -1;
      logMessage('Transfer', 'Adding new line (lineNum will be generated)');
    }

    return handleEitherResult(
      postGetPage.postDataWithToken(
        ApiServices.upsertTransferLine(),
        lineData,
        token,
      ),
      lineNum != null && lineNum > 0 ? 'Line Updated Successfully' : 'Line Added Successfully',
      lineNum != null && lineNum > 0 ? 'فشل في تعديل السطر' : 'فشل في إضافة السطر',
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
      postGetPage.postDataWithToken(
        ApiServices.createTransfer(),
        transferData,
        token,
      ),
      'Transfer Created Successfully',
      'فشل في إنشاء التحويل',
    );
  }
}
