// lib/pages/home/widgets/main_tab.dart

import 'package:auth_app/pages/home/bottombar/invoice_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainTab extends StatelessWidget {
  MainTab({super.key});

  final List<Map<String, String>> invoices = [
    {
      'number': '22350',
      'supplier': 'شركة المراعي فريش',
      'date': '2025-07-05',
      'category': 'فاتورة مشتريات',
    },
    {
      'number': '23951',
      'supplier': 'شركة المذاق المميز للتجارة',
      'date': '2025-07-05',
      'category': 'فاتورة مشتريات',
    },
    {
      'number': '23950',
      'supplier': 'شركة التموين العربي - جلاكسي',
      'date': '2025-07-05',
      'category': 'فاتورة مشتريات',
    },
    {
      'number': '23949',
      'supplier': 'مصنع أطياب الوادي للتمور',
      'date': '2025-07-05',
      'category': 'فاتورة مشتريات',
    },
    {
      'number': '23948',
      'supplier': 'شركة ملم المتميزة للتجارة',
      'date': '2025-07-05',
      'category': 'فاتورة مشتريات',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          itemCount: invoices.length,
          separatorBuilder: (context, index) => const SizedBox(height: 6),
          itemBuilder: (context, index) {
            final invoice = invoices[index];

            return GestureDetector(
              onTap: () {
                Get.to(
                  () => const InvoiceDetailPage(),
                  arguments: {
                    'invoice': invoice,
                    'items': [
                      {
                        'name': 'صنف 1',
                        'quantity': 10,
                        'price': 50,
                        'total': 500,
                      },
                      {
                        'name': 'صنف 2',
                        'quantity': 5,
                        'price': 100,
                        'total': 500,
                      },
                      {
                        'name': 'صنف 3',
                        'quantity': 2,
                        'price': 200,
                        'total': 400,
                      },
                    ],
                  },
                );
              },
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // التاريخ والرقم
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            invoice['date']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            invoice['number']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // اسم المورد
                      Text(
                        invoice['supplier']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // الخط البرتقالي
                      Container(
                        height: 3,
                        width: double.infinity,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 4),
                      // فئة الفاتورة
                      Text(
                        invoice['category']!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// lib/pages/home/widgets/main_tab.dart

// import 'package:auth_app/pages/home/bottombar/invoice_detail_page.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class MainTab extends StatelessWidget {
//   MainTab({super.key});

//   final List<Map<String, String>> invoices = [
//     {
//       'number': '23951',
//       'supplier': 'شركة المداد المميز',
//       'date': '2025-07-05',
//       'total': '2500',
//     },
//     {
//       'number': '23950',
//       'supplier': 'شركة التمور العربي',
//       'date': '2025-07-04',
//       'total': '4300',
//     },
//     {
//       'number': '23949',
//       'supplier': 'مصنع أطايب الوادي',
//       'date': '2025-07-03',
//       'total': '1250',
//     },
//     {
//       'number': '23948',
//       'supplier': 'شركة ملهم المتميزة',
//       'date': '2025-07-02',
//       'total': '3750',
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text(
//           'قائمة الفواتير المستلمة',
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//       ),
//       body: ListView.separated(
//         padding: const EdgeInsets.all(8),
//         itemCount: invoices.length,
//         separatorBuilder: (_, __) => const Divider(height: 1),
//         itemBuilder: (context, index) {
//           final invoice = invoices[index];
//           return ListTile(
//             tileColor: Colors.white,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
//             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             title: Text(
//               'فاتورة رقم: ${invoice['number']}',
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(invoice['supplier']!, style: const TextStyle(fontSize: 14)),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Icon(Icons.date_range, size: 16, color: Colors.grey[600]),
//                     const SizedBox(width: 4),
//                     Text(invoice['date']!, style: TextStyle(color: Colors.grey[700])),
//                   ],
//                 ),
//               ],
//             ),
//             trailing: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text('${invoice['total']} ر.س',
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 16)),
//                 const SizedBox(height: 4),
//                 const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
//               ],
//             ),
//             onTap: () {
//               Get.to(
//                 () => const InvoiceDetailPage(),
//                 arguments: {
//                   'invoice': invoice,
//                   'items': [
//                     {
//                       'name': 'صنف 1',
//                       'quantity': 10,
//                       'price': 50,
//                       'total': 500,
//                     },
//                     {
//                       'name': 'صنف 2',
//                       'quantity': 5,
//                       'price': 100,
//                       'total': 500,
//                     },
//                   ],
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }



// // lib/pages/home/widgets/main_tab.dart
// import 'package:flutter/material.dart';

// class MainTab extends StatelessWidget {
//   const MainTab({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'الصفحة الرئيسية',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.blue,
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Welcome Card
//             Card(
//               elevation: 4,
//               child: Padding(
//                 padding: EdgeInsets.all(20.0),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.waving_hand,
//                       color: Colors.orange,
//                       size: 30,
//                     ),
//                     SizedBox(width: 10),
//                     Text(
//                       'مرحباً بك',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             SizedBox(height: 20),

//             // Stats Cards
//             Text(
//               'نظرة عامة',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             SizedBox(height: 10),

//             Expanded(
//               child: GridView.count(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//                 children: [
//                   _StatCard(
//                     icon: Icons.inventory,
//                     title: 'المخزون',
//                     value: '150',
//                     color: Colors.green,
//                   ),
//                   _StatCard(
//                     icon: Icons.trending_up,
//                     title: 'المبيعات',
//                     value: '85',
//                     color: Colors.blue,
//                   ),
//                   _StatCard(
//                     icon: Icons.shopping_cart,
//                     title: 'الطلبات',
//                     value: '25',
//                     color: Colors.orange,
//                   ),
//                   _StatCard(
//                     icon: Icons.account_balance_wallet,
//                     title: 'الإيرادات',
//                     value: '12,500',
//                     color: Colors.purple,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _StatCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String value;
//   final Color color;

//   const _StatCard({
//     required this.icon,
//     required this.title,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 3,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               size: 40,
//               color: color,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
