import 'package:auth_app/controllers/auth_controller.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:get/get.dart';

// Binding للـ AuthController
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostGetPage>(() => PostGetPage()); // إضافة تسجيل PostGetPage

    Get.lazyPut<AuthController>(() => AuthController());
  }
}
