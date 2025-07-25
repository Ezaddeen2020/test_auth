// lib/pages/home/screens/home_page.dart

import 'package:auth_app/pages/home/bottombar/mainpage.dart';
import 'package:auth_app/pages/home/bottombar/operation_tab.dart';
import 'package:auth_app/pages/home/bottombar/setting.dart';
import 'package:auth_app/pages/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeController controller = Get.put(HomeController());

  final List<Widget> items = const [
    Icon(Icons.home, size: 30, color: Colors.white),
    Icon(Icons.business_center, size: 30, color: Colors.white),
    Icon(Icons.settings, size: 30, color: Colors.white),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Obx(() => _getSelectedPage(controller.selectedIndex.value)),
      bottomNavigationBar: Obx(() {
        return CurvedNavigationBar(
          index: controller.selectedIndex.value,
          items: items,
          height: 60,
          backgroundColor: Colors.grey[200]!,
          color: Colors.blue.shade900,
          animationDuration: const Duration(milliseconds: 300),
          onTap: (index) => controller.changeTab(index),
        );
      }),
    );
  }

  Widget _getSelectedPage(int index) {
    switch (index) {
      case 0:
        return MainTab();
      case 1:
        return const OperationsTab();
      case 2:
        return const SettingsTab();
      default:
        return MainTab();
    }
  }
}
