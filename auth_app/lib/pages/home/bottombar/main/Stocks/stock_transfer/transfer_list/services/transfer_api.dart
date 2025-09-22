import 'package:auth_app/functions/handling_data.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:auth_app/classes/shared_preference.dart';
import 'package:auth_app/services/api_service.dart';

class TransferApi {
  final PostGetPage postGetPage;

  TransferApi(this.postGetPage);

  ////// 🟩 /////ترحيل تحويل إلى SAP
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

  Future<Map<String, dynamic>> deleteTransferLine({
    required int docEntry,
    required int lineNum,
  }) async {
    String token = Preferences.getString('auth_token');
    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    Map<String, dynamic> deleteData = {
      'docEntry': docEntry,
      'lineNum': lineNum,
    };

    logMessage(
        'Transfer', 'Deleting line with DELETE method - docEntry: $docEntry, lineNum: $lineNum');

    return handleEitherResult(
      postGetPage.deleteDataWithToken(
        // استخدام DELETE method
        "https://qitaf3.dynalias.net:44322/echo2/api/TransferApi/DeleteLine",
        deleteData,
        token,
      ),
      'Line Deleted Successfully',
      'فشل في حذف السطر',
    );
  }

  /// 🟩 إلغاء تحويل محدد
  Future<Map<String, dynamic>> cancelTransfer(int transferId) async {
    String token = Preferences.getString('auth_token');
    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    logMessage('Transfer', 'Cancelling transfer with ID: $transferId');

    return handleEitherResult(
      postGetPage.postDataWithToken(
        ApiServices.cancelTransfer(),
        {'transferId': transferId},
        token,
      ),
      'Transfer Cancelled Successfully',
      'فشل في إلغاء التحويل',
    );
  }
}
