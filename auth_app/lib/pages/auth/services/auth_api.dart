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







  // Future<Map<String, dynamic>> testApiWithToken(String token) async {
  //   _log('Test API', 'Testing API with token: $token');
  //   return _handleResult(
  //     postGetPage.getDataWithToken(ApiServices.salesDataTest, token),
  //     'Test API Success',
  //     'فشل في اختبار API',
  //   );
  // }

  // Future<Map<String, dynamic>> getStockInfo(String stockCode, String token) async {
  //   _log('Stock Info', 'Getting stock info for code: $stockCode');
  //   return _handleResult(
  //     postGetPage.getDataWithToken(ApiServices.stockInfo(stockCode), token),
  //     'Stock API Success',
  //     'فشل في جلب بيانات المخزون',
  //   );
  // }

  // Future<Map<String, dynamic>> getSalesData(String token) async {
  //   _log('Sales Data', 'Getting sales data with token: $token');
  //   return _handleResult(
  //     postGetPage.getDataWithToken(ApiServices.salesData, token),
  //     'Sales Data API Success',
  //     'فشل في جلب بيانات المبيعات',
  //   );
  // }

  // Future<Map<String, dynamic>> testEchoEndpoint(String stockCode, String token) async {
  //   _log('Echo Endpoint', 'Testing echo endpoint with stock code: $stockCode');
  //   return _handleResult(
  //     postGetPage.getDataWithToken("${ApiServices.echo}/$stockCode", token),
  //     'Echo API Success',
  //     'فشل في اختبار Echo',
  //   );
  // }

  
