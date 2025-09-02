import 'package:auth_app/pages/auth/controllers/auth_controller.dart';
import 'package:auth_app/pages/configration/controllers/network_controller.dart';
import 'package:auth_app/pages/configration/controllers/printer_controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/Invoic/invoice_Controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/purchase_controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/controllers/transfer_controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/controllers/stock_controller.dart';
import 'package:auth_app/pages/home/home_controller.dart';
import 'package:auth_app/services/api/post_get_api.dart';
import 'package:auth_app/check_internet/internet_controller.dart';
import 'package:get/get.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    try {
      // تسجيل الخدمات الأساسية أولاً
      Get.lazyPut<PostGetPage>(() => PostGetPage(), fenix: true);

      // تسجيل Controllers الأساسية
      Get.lazyPut<InternetConnectionController>(() => InternetConnectionController(), fenix: true);

      Get.lazyPut<AuthController>(() => AuthController(), fenix: true);

      // Controllers الإضافية
      Get.lazyPut<PrinterController>(() => PrinterController(), fenix: true);

      Get.lazyPut<NetworkController>(() => NetworkController(), fenix: true);

      // Controllers الخاصة بالمخزون والعمليات
      Get.lazyPut<StockController>(() => StockController(), fenix: true);

      Get.lazyPut<TransferNavigationController>(() => TransferNavigationController(), fenix: true);

      Get.lazyPut<TransferController>(() => TransferController(), fenix: true);

      Get.lazyPut<InvoiceController>(() => InvoiceController(), fenix: true);

      // HomeController للصفحة الرئيسية
      Get.lazyPut<HomeController>(() => HomeController(), fenix: true);

      print('✅ All bindings initialized successfully');
    } catch (e) {
      print('❌ Error in InitialBinding: $e');
      // يمكنك إضافة تسجيل خطأ أو معالجة للأخطاء هنا
    }
  }
}

// Binding منفصل للصفحة الرئيسية لضمان تهيئة صحيحة
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    try {
      Get.lazyPut<HomeController>(() => HomeController());

      // تأكد من وجود AuthController
      if (!Get.isRegistered<AuthController>()) {
        Get.lazyPut<AuthController>(() => AuthController());
      }

      print('✅ Home binding initialized successfully');
    } catch (e) {
      print('❌ Error in HomeBinding: $e');
    }
  }
}

// Binding منفصل للمصادقة
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    try {
      Get.lazyPut<AuthController>(() => AuthController());
      Get.lazyPut<PostGetPage>(() => PostGetPage());

      print('✅ Auth binding initialized successfully');
    } catch (e) {
      print('❌ Error in AuthBinding: $e');
    }
  }
}

// import 'package:auth_app/pages/auth/controllers/auth_controller.dart';
// import 'package:auth_app/pages/configration/controllers/network_controller.dart';
// import 'package:auth_app/pages/configration/controllers/printer_controller.dart';

// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/Invoic/invoice_Controller.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/purchase_controller.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/controllers/transfer_controller.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/controllers/stock_controller.dart';
// import 'package:auth_app/services/api/post_get_api.dart';
// import 'package:auth_app/check_internet/internet_controller.dart';
// import 'package:get/get.dart';

// // Binding للـ AuthController
// class InitialBinding extends Bindings {
//   @override
//   void dependencies() {
//     Get.lazyPut<InternetConnectionController>(() => InternetConnectionController(), fenix: true);

//     Get.lazyPut<PostGetPage>(() => PostGetPage());
//     Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
//     Get.lazyPut<PrinterController>(() => PrinterController(), fenix: true);
//     Get.lazyPut<NetworkController>(() => NetworkController(), fenix: true);
//     Get.lazyPut<StockController>(() => StockController(), fenix: true);
//     Get.lazyPut<TransferNavigationController>(() => TransferNavigationController(), fenix: true);
//     Get.lazyPut<TransferController>(() => TransferController(), fenix: true);
//     Get.lazyPut<InvoiceController>(() => InvoiceController(), fenix: true);
//   }
// }
