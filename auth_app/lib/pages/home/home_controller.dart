// lib/pages/home/controllers/home_controller.dart
import 'package:get/get.dart';

class HomeController extends GetxController {
  RxInt selectedIndex = 1.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }
}
