import 'package:auth_app/functions/handling_data.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/services/transfer_api.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:auth_app/services/api_service.dart';
import 'package:auth_app/classes/shared_preference.dart';

class StockApi {
  final PostGetPage postGetPage;

  StockApi(this.postGetPage);

  Future<Map<String, dynamic>> getStockByItemCode(String itemCode) async {
    String token = Preferences.getString('auth_token');

    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    logMessage('Stock', 'Getting stock for item code: $itemCode');

    return handleEitherResult(
      postGetPage.getDataWithToken(ApiServices.getStockItem(itemCode), token),
      'Stock Data Retrieved Successfully',
      'فشل في جلب بيانات المخزون',
    );
  }
}
  // // دالة للحصول على قائمة من المودلز مباشرة
  // Future<List<StockModel>> getStockModelsByItemCode(String itemCode) async {
  //   try {
  //     var response = await getStockByItemCode(itemCode);

  //     if (response['status'] == 'success' && response['data'] != null) {
  //       List<dynamic> data = response['data'];
  //       return data.map((item) => StockModel.fromJson(item)).toList();
  //     }

  //     return [];
  //   } catch (e) {
  //     logMessage('Stock', 'Error getting stock models: $e');
  //     return [];
  //   }
  // }

