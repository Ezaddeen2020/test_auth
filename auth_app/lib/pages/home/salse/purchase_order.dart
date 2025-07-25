import 'package:auth_app/pages/home/salse/invice_page.dart';
import 'package:auth_app/pages/home/salse/search_page.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class PurchaseOrderPage extends StatefulWidget {
  const PurchaseOrderPage({super.key});

  @override
  State<PurchaseOrderPage> createState() => _PurchaseOrderPageState();
}

class _PurchaseOrderPageState extends State<PurchaseOrderPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: const [
            InvoicePage(),
            SearchPage(),

            // InvoiceDetailPage(),
          ],
        ),
        bottomNavigationBar: CurvedNavigationBar(
          index: _currentIndex,
          backgroundColor: Colors.transparent,
          color: const Color.fromARGB(255, 26, 118, 193),
          buttonBackgroundColor: Colors.white,
          height: 60,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 300),
          items: const [
            Icon(Icons.receipt_long, size: 25, color: Color.fromARGB(255, 26, 118, 193)),
            Icon(Icons.search, size: 25, color: Color.fromARGB(255, 26, 118, 193)),
            Icon(Icons.category, size: 25, color: Color.fromARGB(255, 26, 118, 193)),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ),
    );
  }
}
