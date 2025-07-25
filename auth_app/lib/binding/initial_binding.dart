import 'package:auth_app/pages/auth/controllers/auth_controller.dart';
import 'package:auth_app/pages/configration/controllers/network_controller.dart';
import 'package:auth_app/pages/configration/controllers/printer_controller.dart';
import 'package:auth_app/pages/home/home_controller.dart';
import 'package:auth_app/pages/home/home_page.dart';
import 'package:auth_app/pages/home/salse/main/purchase_controller.dart';
import 'package:auth_app/pages/home/salse/main/purchase_order.dart';
import 'package:auth_app/pages/home/transfare/controllers/transfer_controller.dart';
import 'package:auth_app/pages/stocks/controllers/stock_controller.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:get/get.dart';

// Binding للـ AuthController
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostGetPage>(() => PostGetPage());
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<PrinterController>(() => PrinterController(), fenix: true);
    Get.lazyPut<NetworkController>(() => NetworkController(), fenix: true);
    Get.lazyPut<StockController>(() => StockController(), fenix: true);
    Get.lazyPut<PurchaseController>(() => PurchaseController(), fenix: true);
    Get.lazyPut<TransferController>(() => TransferController(), fenix: true);
  }
}
