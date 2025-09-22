// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/Invoic/invoice_Controller.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/controllers/product_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/models/transfer_stock_model.dart';

// class TransferNavigationController extends GetxController {
//   final _currentIndex = 0.obs;
//   final _isSearching = false.obs;
//   final _searchController = TextEditingController();
//   final _selectedSearchType = 'name'.obs;
//   final _searchText = ''.obs;

//   late TransferModel transfer;
//   late int transferId;

//   int get currentIndex => _currentIndex.value;
//   bool get isSearching => _isSearching.value;
//   TextEditingController get searchController => _searchController;
//   String get selectedSearchType => _selectedSearchType.value;
//   String get searchText => _searchText.value;

//   @override
//   void onInit() {
//     super.onInit();
//     final args = Get.arguments as Map<String, dynamic>;
//     transfer = args['transfer'] as TransferModel;
//     transferId = args['transferId'] as int;

//     _searchController.addListener(() {
//       _searchText.value = _searchController.text;
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       try {
//         final invoiceController = Get.find<InvoiceController>();
//         invoiceController.loadTransferDetails(transferId);
//       } catch (e) {
//         print('Invoice Controller not found: $e');
//       }

//       try {
//         if (Get.isRegistered<ProductManagementController>()) {
//           final productController = Get.find<ProductManagementController>();
//           productController.loadTransferLines(transferId);
//         }
//       } catch (e) {
//         print('Product Controller not found: $e');
//       }
//     });
//   }

//   void changeTab(int index) {
//     if (index == _currentIndex.value) return;
//     _currentIndex.value = index;
//   }

//   String getAppBarTitle() {
//     switch (currentIndex) {
//       case 0:
//         return 'فاتورة التحويل';
//       case 1:
//         return 'بحث الأصناف';
//       case 2:
//         return 'إدارة الأصناف';
//       default:
//         return 'تفاصيل التحويل';
//     }
//   }

//   void setSearchType(String type) {
//     _selectedSearchType.value = type;
//   }

//   String getSearchTypeLabel() {
//     switch (selectedSearchType) {
//       case 'name':
//         return 'اسم الصنف';
//       case 'barcode':
//         return 'باركود';
//       case 'number':
//         return 'رقم الصنف';
//       default:
//         return 'غير محدد';
//     }
//   }

//   void performSearch(String query) {
//     if (query.trim().isEmpty) return;

//     _isSearching.value = true;

//     Future.delayed(const Duration(seconds: 1), () {
//       _isSearching.value = false;

//       Get.snackbar(
//         'نتائج البحث',
//         'تم البحث عن: $query',
//         backgroundColor: Colors.blue,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 2),
//       );
//     });
//   }

//   void clearSearch() {
//     _searchController.clear();
//     _searchText.value = '';
//   }

//   @override
//   void onClose() {
//     _searchController.dispose();
//     super.onClose();
//   }
// }

import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/Invoic/invoice_Controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/controllers/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/models/transfer_stock_model.dart';

class TransferNavigationController extends GetxController {
  final _currentIndex = 0.obs;
  final _isSearching = false.obs;
  final _searchController = TextEditingController();
  final _selectedSearchType = 'name'.obs;
  final _searchText = ''.obs;

  late TransferModel transfer;
  late int transferId;
  ProductManagementController? _productController;

  int get currentIndex => _currentIndex.value;
  bool get isSearching => _isSearching.value;
  TextEditingController get searchController => _searchController;
  String get selectedSearchType => _selectedSearchType.value;
  String get searchText => _searchText.value;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    transfer = args['transfer'] as TransferModel;
    transferId = args['transferId'] as int;

    print('TransferNavigationController initialized with transferId: $transferId');

    _searchController.addListener(() {
      _searchText.value = _searchController.text;
    });

    // إعداد ProductManagementController مع transferId
    _setupProductController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _setupProductController() {
    try {
      // محاولة العثور على controller موجود
      if (Get.isRegistered<ProductManagementController>()) {
        _productController = Get.find<ProductManagementController>();
        print('Found existing ProductManagementController');
      } else {
        // إنشاء controller جديد
        _productController = Get.put(ProductManagementController());
        print('Created new ProductManagementController');
      }

      // تحديد transferId
      if (_productController != null) {
        _productController!.setTransferId(transferId);
        print('Set transferId to ProductManagementController: $transferId');
      }
    } catch (e) {
      print('Error setting up ProductManagementController: $e');
    }
  }

  void _loadInitialData() {
    // تحميل بيانات الفاتورة
    try {
      final invoiceController = Get.find<InvoiceController>();
      invoiceController.loadTransferDetails(transferId);
      print('Loaded invoice data for transferId: $transferId');
    } catch (e) {
      print('Invoice Controller not found: $e');
    }

    // تحميل بيانات المنتجات
    try {
      if (_productController != null) {
        _productController!.loadTransferLines(transferId);
        print('Loaded product lines for transferId: $transferId');
      }
    } catch (e) {
      print('Error loading product lines: $e');
    }
  }

  void changeTab(int index) {
    if (index == _currentIndex.value) return;

    print('Changing tab from ${_currentIndex.value} to $index');
    _currentIndex.value = index;

    // عند الانتقال لصفحة المنتجات أو البحث، تأكد من وجود البيانات
    if (index == 1 || index == 2) {
      // البحث أو إدارة المنتجات
      _ensureProductControllerReady();
    }
  }

  void _ensureProductControllerReady() {
    if (_productController == null) {
      _setupProductController();
    }

    if (_productController != null && _productController!.transferId.value != transferId) {
      _productController!.setTransferId(transferId);
      _productController!.loadTransferLines(transferId);
    }
  }

  // دالة للحصول على ProductController (للاستخدام في الصفحات الأخرى)
  ProductManagementController? getProductController() {
    _ensureProductControllerReady();
    return _productController;
  }

  String getAppBarTitle() {
    switch (currentIndex) {
      case 0:
        return 'فاتورة التحويل';
      case 1:
        return 'بحث الأصناف';
      case 2:
        return 'إدارة الأصناف';
      default:
        return 'تفاصيل التحويل';
    }
  }

  void setSearchType(String type) {
    _selectedSearchType.value = type;
  }

  String getSearchTypeLabel() {
    switch (selectedSearchType) {
      case 'name':
        return 'اسم الصنف';
      case 'barcode':
        return 'باركود';
      case 'number':
        return 'رقم الصنف';
      default:
        return 'غير محدد';
    }
  }

  void performSearch(String query) {
    if (query.trim().isEmpty) return;

    _isSearching.value = true;

    Future.delayed(const Duration(seconds: 1), () {
      _isSearching.value = false;

      Get.snackbar(
        'نتائج البحث',
        'تم البحث عن: $query',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    });
  }

  void clearSearch() {
    _searchController.clear();
    _searchText.value = '';
  }

  @override
  void onClose() {
    _searchController.dispose();
    super.onClose();
  }
}




// // ignore_for_file: avoid_print

// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/Invoic/invoice_Controller.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/controller/product_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:get/get.dart';

// // استيراد الصفحات المطلوبة
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/Invoic/invice_page.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/screen/product_page.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/models/transfer_stock_model.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/search/search_page.dart';

// // GetX Controller
// class TransferNavigationController extends GetxController {
//   final _currentIndex = 0.obs;
//   final _isSearching = false.obs;
//   final _searchController = TextEditingController();
//   final _selectedSearchType = 'name'.obs;
//   final _searchText = ''.obs;

//   final PageController pageController = PageController(initialPage: 0);

//   late TransferModel transfer;
//   late int transferId;

//   int get currentIndex => _currentIndex.value;
//   bool get isSearching => _isSearching.value;
//   TextEditingController get searchController => _searchController;
//   String get selectedSearchType => _selectedSearchType.value;
//   String get searchText => _searchText.value;
//   RxString get searchTextRx => _searchText;

//   @override
//   void onInit() {
//     super.onInit();
//     _initializeTransferData();
//     _passDataToPages();

//     _searchController.addListener(() {
//       _searchText.value = _searchController.text;
//     });
//   }

//   void _initializeTransferData() {
//     final args = Get.arguments as Map<String, dynamic>;
//     transfer = args['transfer'] as TransferModel;
//     transferId = args['transferId'] as int;
//   }

//   void _passDataToPages() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       try {
//         final invoiceController = Get.find<InvoiceController>();
//         invoiceController.loadTransferDetails(transferId);
//       } catch (e) {
//         print('Invoice Controller not found: $e');
//       }

//       try {
//         if (Get.isRegistered<ProductManagementController>()) {
//           final productController = Get.find<ProductManagementController>();
//           productController.loadTransferLines(transferId);
//         }
//       } catch (e) {
//         print('Product Controller not found: $e');
//       }
//     });
//   }

//   void changeTab(int index) {
//     if (index == _currentIndex.value) return;

//     _currentIndex.value = index;

//     if (pageController.hasClients) {
//       pageController.animateToPage(
//         index,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   void onPageChanged(int index) {
//     if (_currentIndex.value != index) {
//       _currentIndex.value = index;
//     }
//   }

//   String getAppBarTitle() {
//     switch (currentIndex) {
//       case 0:
//         return 'فاتورة التحويل';
//       case 1:
//         return 'بحث الأصناف';
//       case 2:
//         return 'إدارة الأصناف';
//       default:
//         return 'تفاصيل التحويل';
//     }
//   }

//   void setSearchType(String type) {
//     _selectedSearchType.value = type;
//   }

//   String getSearchTypeLabel() {
//     switch (selectedSearchType) {
//       case 'name':
//         return 'اسم الصنف';
//       case 'barcode':
//         return 'باركود';
//       case 'number':
//         return 'رقم الصنف';
//       default:
//         return 'غير محدد';
//     }
//   }

//   void performSearch(String query) {
//     if (query.trim().isEmpty) return;

//     _isSearching.value = true;

//     Future.delayed(const Duration(seconds: 1), () {
//       _isSearching.value = false;

//       Get.snackbar(
//         'نتائج البحث',
//         'تم البحث عن: $query',
//         backgroundColor: Colors.blue,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 2),
//       );
//     });
//   }

//   void clearSearch() {
//     _searchController.clear();
//     _searchText.value = '';
//   }

//   @override
//   void onClose() {
//     _searchController.dispose();
//     pageController.dispose();
//     super.onClose();
//   }
// }

// // Custom Gesture Detector لحل مشكلة تضارب التمرير
// class SwipeablePageWrapper extends StatelessWidget {
//   final Widget child;
//   final PageController pageController;
//   final int currentIndex;

//   const SwipeablePageWrapper({
//     super.key,
//     required this.child,
//     required this.pageController,
//     required this.currentIndex,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onPanStart: (details) {
//         // تسجيل نقطة البداية
//       },
//       onPanUpdate: (details) {
//         // تحديد اتجاه السحب
//         final dx = details.delta.dx;
//         final dy = details.delta.dy;

//         // إذا كان السحب أفقي أكثر من العمودي
//         if (dx.abs() > dy.abs() && dx.abs() > 10) {
//           // تمرير الحدث لـ PageView
//           if (dx > 0 && currentIndex > 0) {
//             // سحب لليمين - الصفحة السابقة
//             pageController.previousPage(
//               duration: const Duration(milliseconds: 300),
//               curve: Curves.easeInOut,
//             );
//           } else if (dx < 0 && currentIndex < 2) {
//             // سحب لليسار - الصفحة التالية
//             pageController.nextPage(
//               duration: const Duration(milliseconds: 300),
//               curve: Curves.easeInOut,
//             );
//           }
//         }
//       },
//       child: child,
//     );
//   }
// }

// class TransferDetailsNavigationScreen extends StatelessWidget {
//   const TransferDetailsNavigationScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(TransferNavigationController());

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(70),
//         child: AppBar(
//           title: Obx(() => Text(
//                 controller.getAppBarTitle(),
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               )),
//           backgroundColor: Colors.blue.shade900,
//           elevation: 0,
//           centerTitle: true,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
//             onPressed: () => Get.back(),
//           ),
//           actions: [
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Text(
//                 'رقم التحويل: ${controller.transferId}',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//           toolbarHeight: 70,
//         ),
//       ),
//       body: Obx(() => PageView(
//             controller: controller.pageController,
//             onPageChanged: controller.onPageChanged,
//             physics: const BouncingScrollPhysics(), // فيزياء للسحب
//             children: [
//               // صفحة الفاتورة مع إزالة SingleChildScrollView المتضاربة
//               SwipeablePageWrapper(
//                 pageController: controller.pageController,
//                 currentIndex: controller.currentIndex,
//                 child: InvoicePage(
//                   key: ValueKey('invoice_${controller.transferId}'),
//                 ),
//               ),

//               // صفحة البحث
//               SwipeablePageWrapper(
//                 pageController: controller.pageController,
//                 currentIndex: controller.currentIndex,
//                 child: const SearchPage(),
//               ),

//               // صفحة إدارة المنتجات
//               SwipeablePageWrapper(
//                 pageController: controller.pageController,
//                 currentIndex: controller.currentIndex,
//                 child: ProductManagementScreen(
//                   key: ValueKey('products_${controller.transferId}'),
//                 ),
//               ),
//             ],
//           )),
//       bottomNavigationBar: Obx(() => CurvedNavigationBar(
//             index: controller.currentIndex,
//             height: 60,
//             items: const [
//               Icon(Icons.receipt_long, size: 30, color: Colors.white),
//               Icon(Icons.search, size: 30, color: Colors.white),
//               Icon(Icons.inventory_2, size: 30, color: Colors.white),
//             ],
//             color: Colors.blue.shade900,
//             buttonBackgroundColor: const Color(0xFF1976D2),
//             backgroundColor: Colors.white,
//             animationCurve: Curves.easeInOut,
//             animationDuration: const Duration(milliseconds: 300),
//             onTap: controller.changeTab,
//           )),
//     );
//   }
// }

// // حل بديل أقوى: تطبيق TabBarView
// class AlternativeTabBarSolution extends StatelessWidget {
//   const AlternativeTabBarSolution({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<TransferNavigationController>();

//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: PreferredSize(
//           preferredSize: const Size.fromHeight(70),
//           child: AppBar(
//             title: Obx(() => Text(
//                   controller.getAppBarTitle(),
//                   style: const TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 )),
//             backgroundColor: Colors.blue.shade900,
//             elevation: 0,
//             centerTitle: true,
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
//               onPressed: () => Get.back(),
//             ),
//             actions: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Text(
//                   'رقم التحويل: ${controller.transferId}',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//             toolbarHeight: 70,
//             // إخفاء TabBar الافتراضي
//             bottom: const PreferredSize(
//               preferredSize: Size.zero,
//               child: SizedBox.shrink(),
//             ),
//           ),
//         ),
//         body: TabBarView(
//           physics: const BouncingScrollPhysics(), // يسمح بالسحب القوي
//           children: [
//             InvoicePage(
//               key: ValueKey('invoice_${controller.transferId}'),
//             ),
//             const SearchPage(),
//             ProductManagementScreen(
//               key: ValueKey('products_${controller.transferId}'),
//             ),
//           ],
//         ),
//         bottomNavigationBar: Obx(() => CurvedNavigationBar(
//               index: controller.currentIndex,
//               height: 60,
//               items: const [
//                 Icon(Icons.receipt_long, size: 30, color: Colors.white),
//                 Icon(Icons.search, size: 30, color: Colors.white),
//                 Icon(Icons.inventory_2, size: 30, color: Colors.white),
//               ],
//               color: Colors.blue.shade900,
//               buttonBackgroundColor: const Color(0xFF1976D2),
//               backgroundColor: Colors.white,
//               animationCurve: Curves.easeInOut,
//               animationDuration: const Duration(milliseconds: 300),
//               onTap: (index) {
//                 controller.changeTab(index);
//                 // تحديث TabBarView
//                 DefaultTabController.of(context).animateTo(index);
//               },
//             )),
//       ),
//     );
//   }
// }
