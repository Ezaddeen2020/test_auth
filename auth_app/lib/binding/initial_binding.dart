import 'package:auth_app/pages/auth/controllers/auth_controller.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:get/get.dart';

// Binding للـ AuthController
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostGetPage>(() => PostGetPage());

    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}
