import 'package:auth_app/functions/handling_data.dart';
import 'package:auth_app/pages/auth/models/user_model.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:auth_app/services/api_service.dart';

class AuthApi {
  final PostGetPage postGetPage;

  AuthApi(this.postGetPage);

  Future<Map<String, dynamic>> postlogin(UserModel userModel) async {
    logMessage('Login', 'Attempting login with data: ${userModel.toJson()}');
    return handleEitherResult(
      postGetPage.postData(ApiServices.login, userModel.toJson()),
      'Login Success',
      'فشل في الاتصال بالخادم',
    );
  }

  Future<Map<String, dynamic>> postSignUp(UserModel userModel) async {
    logMessage('Signup', 'Attempting signup with data: ${userModel.toJson()}');
    return handleEitherResult(
      postGetPage.postData(ApiServices.register, userModel.toJson()),
      'Signup API Success',
      'فشل في إنشاء الحساب',
    );
  }
}

  // Future<Map<String, dynamic>> getStockInfo(String stockCode, String token) async {
  //   logMessage('Stock Info', 'Getting stock info for code: $stockCode');
  //   return handleEitherResult(
  //     postGetPage.getDataWithToken(ApiServices.stockInfo(stockCode), token),
  //     'Stock API Success',
  //     'فشل في جلب بيانات المخزون',
  //   );
  // }
// }



