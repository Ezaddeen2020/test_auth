import 'package:auth_app/classes/shared_preference.dart';
import 'package:auth_app/functions/handling_data.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:auth_app/services/api_service.dart';

class SendReciveTransferApi {
  final PostGetPage postGetPage;
  SendReciveTransferApi(this.postGetPage);
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

  //// 🟩 ///// استلام تحويل

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
}
