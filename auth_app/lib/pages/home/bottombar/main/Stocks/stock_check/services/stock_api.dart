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



// Future<Map<String, dynamic>> getStockByItemCode(String itemCode) async {
//   String token = Preferences.getString('auth_token');

//   if (token.isEmpty) {
//     return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
//   }

//   logMessage('Stock', 'Getting stock for item code: $itemCode');

//   var result = await postGetPage.getDataWithToken(
//     ApiServices.getStockItem(itemCode),
//     token,
//   );

//   // إذا فشل الطلب بسبب انتهاء صلاحية التوكن
//   if (result.isLeft()) {
//     // نحاول تحديث التوكن
//     bool refreshed = await _refreshToken();

//     if (refreshed) {
//       String newToken = Preferences.getString('auth_token');
//       // إعادة الطلب مرة ثانية بالتوكن الجديد
//       result = await postGetPage.getDataWithToken(
//         ApiServices.getStockItem(itemCode),
//         newToken,
//       );
//     }
//   }

//   return handleEitherResult(
//     result,
//     'Stock Data Retrieved Successfully',
//     'فشل في جلب بيانات المخزون',
//   );
// }

// // دالة لتحديث التوكن
// Future<bool> _refreshToken() async {
//   String refreshToken = Preferences.getString('refresh_token');

//   if (refreshToken.isEmpty) return false;

//   var res = await postGetPage.postData(
//     ApiServices.refreshToken(), // رابط API لتحديث التوكن
//     {'refresh_token': refreshToken},
//   );

//   return res.fold((failure) => false, (data) {
//     if (data['status'] == 'success' && data['token'] != null) {
//       Preferences.setString('auth_token', data['token']);
//       return true;
//     }
//     return false;
//   });
// }



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

