// lib/pages/home/widgets/operations_tab.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OperationsTab extends StatelessWidget {
  const OperationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      // إضافة هذا لضمان RTL في كامل الصفحة
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(221, 36, 36, 36),
                Color(0xFF29B6F6),
                Colors.black87,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'SAP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Business',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'One',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Main Content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              _buildCategorySection(
                                'المخزون',
                                [
                                  _CategoryItem(
                                    title: 'استعلام المخزون',
                                    icon: Icons.inventory_2_outlined,
                                    onTap: () {
                                      Get.toNamed('/stock');
                                    },
                                  ),
                                  _CategoryItem(
                                    title: 'تحويل المخزون',
                                    icon: Icons.swap_horiz,
                                    onTap: () {
                                      Get.toNamed('/transfer');
                                    },
                                  ),
                                  _CategoryItem(
                                    title: 'اضافة باركود',
                                    icon: Icons.line_weight,
                                    onTap: () {
                                      Get.toNamed('/addbar');
                                    },
                                  ),
                                  _CategoryItem(
                                    title: 'طباعة باركود',
                                    icon: Icons.print,
                                    onTap: () {
                                      Get.toNamed('/stock');
                                    },
                                  ),
                                ],
                              ),
                              _buildCategorySection(
                                'الطلبات',
                                [
                                  _CategoryItem(
                                    title: 'إرسال طلب',
                                    icon: Icons.send,
                                    onTap: () {
                                      Get.toNamed('/stock');
                                    },
                                  ),
                                  _CategoryItem(
                                    title: 'استقبال طلبات',
                                    icon: Icons.inbox,
                                    onTap: () {},
                                  ),
                                  _CategoryItem(
                                    title: 'تحويل',
                                    icon: Icons.swap_horiz,
                                    onTap: () {},
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              _buildCategorySection(
                                'المبيعات',
                                [
                                  _CategoryItem(
                                    title: 'مبيعات',
                                    icon: Icons.receipt_long,
                                    onTap: () {},
                                  ),
                                  _CategoryItem(
                                    title: 'مرتجعات',
                                    icon: Icons.keyboard_return,
                                    onTap: () {},
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              _buildCategorySection(
                                'المشتريات',
                                [
                                  _CategoryItem(
                                    title: 'امر شراء',
                                    icon: Icons.business,
                                    onTap: () {
                                      Get.toNamed('/invoice');
                                    },
                                  ),
                                  _CategoryItem(
                                    title: 'فاتورة مشتريات',
                                    icon: Icons.shopping_cart,
                                    onTap: () {},
                                  ),
                                  _CategoryItem(
                                    title: 'الاستلامات',
                                    icon: Icons.local_shipping,
                                    onTap: () {},
                                  ),
                                ],
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(String title, List<_CategoryItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),
        ...items
            .map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: item.onTap,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.arrow_back_ios, // استبدال بالسهم المناسب RTL
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Icon(
                              item.icon,
                              color: const Color.fromARGB(255, 26, 118, 193),
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }
}

class _CategoryItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  _CategoryItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

