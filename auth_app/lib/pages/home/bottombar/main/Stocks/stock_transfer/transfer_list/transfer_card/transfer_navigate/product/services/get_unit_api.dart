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
    // print('***************************************' + endpoint);
    try {
      final result = await handleEitherResult(
        postGetPage.getDataWithToken(endpoint, token),
        'Item Units Retrieved Successfully',
        'فشل في جلب وحدات الصنف',
      );
      print('================= بيانات الوحدات المستلمة من API =================');
      print(result);
      if (result['status'] == 'success' && result['data'] != null && result['data'] is List) {
        print('--- قائمة الوحدات لهذا الصنف ($itemCode) ---');
        for (var unit in result['data']) {
          if (unit is Map && unit.containsKey('uomName')) {
            print('الوحدة: ${unit['uomName']}');
          } else {
            print(unit.toString());
          }
        }
        print('--- نهاية قائمة الوحدات ---');
      }
      print('================= نهاية بيانات الوحدات =================');
      return result;
    } catch (e) {
      logMessage('Transfer', 'Error getting item units: [31m${e.toString()}[0m');
      return {'status': 'error', 'message': 'فشل في جلب وحدات الصنف: ${e.toString()}'};
    }
  }
}
