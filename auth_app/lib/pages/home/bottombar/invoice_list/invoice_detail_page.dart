// lib/pages/home/bottombar/invoice_detail_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvoiceDetailPage extends StatelessWidget {
  const InvoiceDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final invoice = Get.arguments['invoice'];
    final List<Map<String, dynamic>> items =
        List<Map<String, dynamic>>.from(Get.arguments['items']);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('فاتورة رقم ${invoice['number']}'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بيانات الفاتورة الأساسية
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(invoice['supplier'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.date_range, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('تاريخ الفاتورة: ${invoice['date']}',
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.monetization_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('الإجمالي: ${invoice['total']} ر.س',
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // عنوان الجدول
            const Text(
              'الأصناف المستلمة',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),

            // جدول الأصناف
            Expanded(
              child: Card(
                elevation: 1,
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      tileColor: Colors.white,
                      title: Text(
                        item['name'],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text('الكمية: ${item['quantity']} - السعر: ${item['price']} ر.س'),
                      trailing: Text(
                        '${item['total']} ر.س',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
