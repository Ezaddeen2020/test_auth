import 'package:auth_app/classes/shared_preference.dart';
import 'package:auth_app/functions/handling_data.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:auth_app/services/api_service.dart';

class GetUnitApi {
  final PostGetPage postGetPage;
  GetUnitApi(this.postGetPage);

  /// يستخدم endpoints مصححة حسب نمط MVC للشركة
  /// 🟩 جلب الوحدات المتوفرة لصنف معين - محدث بناءً على نمط الموقع
  Future<Map<String, dynamic>> getItemUnits(String itemCode) async {
    String token = Preferences.getString('auth_token');
    if (token.isEmpty) {
      return {'status': 'error', 'message': 'يجب تسجيل الدخول أولاً'};
    }

    logMessage('Transfer', 'Getting units for item: $itemCode');

    // استخدام الـ endpoint الصحيح من الاستجابة المقدمة
    String endpoint = "${ApiServices.server}/Uom/GetUoms?itemCode=${Uri.encodeComponent(itemCode)}";

    try {
      return handleEitherResult(
        postGetPage.getDataWithToken(endpoint, token),
        'Item Units Retrieved Successfully',
        'فشل في جلب وحدات الصنف',
      );
    } catch (e) {
      logMessage('Transfer', 'Error getting item units: ${e.toString()}');
      return {'status': 'error', 'message': 'فشل في جلب وحدات الصنف: ${e.toString()}'};
    }
  }
}
