import 'package:auth_app/functions/handling_data.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:auth_app/services/api_service.dart';
import 'package:auth_app/classes/shared_preference.dart';

class StockApi {
  final PostGetPage postGetPage;

  StockApi(this.postGetPage);

  Future<Map<String, dynamic>> getStockByItemCode(String itemCode) async {
    String token = Preferences.getString(Preferences.token);

    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    logMessage('Stock', 'Getting stock for item code: $itemCode');

    return handleEitherResult(
      postGetPage.getDataWithToken(ApiServices.getStockItem(itemCode), token),
      'Stock Data Retrieved Successfully',
      ' فشل جلب البيانات تحقق من رقم الصنف او من التوكن',
    );
  }
}
