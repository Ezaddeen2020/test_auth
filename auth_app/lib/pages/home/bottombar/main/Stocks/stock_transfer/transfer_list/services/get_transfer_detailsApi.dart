import 'package:auth_app/functions/handling_data.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:auth_app/classes/shared_preference.dart';
import 'package:auth_app/services/api_service.dart';

class GetTransferDetailsApi {
  final PostGetPage postGetPage;

  GetTransferDetailsApi(this.postGetPage);

  //====================== جلب قائمة التحويلات مع تقسيم الصفحات =============================== //
  //////// 🟩 //////////جلب تفاصيل تحويل معين باستخدام transferId
  Future<Map<String, dynamic>> getTransferDetails(int transferId) async {
    String token = Preferences.getString('auth_token');

    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    logMessage('Transfer', 'Getting transfer details for ID: $transferId');

    return handleEitherResult(
      postGetPage.getDataWithToken(
        ApiServices.getTransferDetails(transferId),
        token,
      ),
      'Transfer Details Retrieved Successfully',
      'فشل في جلب تفاصيل التحويل',
    );
  }
}
