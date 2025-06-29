import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

class UniversalPrinter extends StatelessWidget {
  final String printerIp = '192.168.194.132';
  final int port = 9100;

  const UniversalPrinter({super.key});

  // =======================================================
  // دالة الطابعات المكتبية (HP, Canon, Epson, Brother)
  // تستخدم PCL/PostScript - مناسبة لجميع الطابعات المكتبية
  // =======================================================
  Future<void> printToOfficePrinter({
    required String title,
    required List<String> content,
    bool centerTitle = true,
    bool addBorders = true,
    String fontSize = '12H',
  }) async {
    try {
      final socket = await Socket.connect(printerIp, port, timeout: const Duration(seconds: 5));
      print('✅ Connected to Office Printer');

      String pclCommands = '';

      // 1. Reset printer
      pclCommands += '\x1B' + 'E'; // ESC E (reset printer)

      // 2. Set font size
      pclCommands += '\x1B' + '(s$fontSize'; // Set font size

      // 3. Set margins
      pclCommands += '\x1B' + '&l6D'; // 6 lines per inch
      pclCommands += '\x1B' + '&a5L'; // Left margin 5 columns

      // 4. Print title (centered if requested)
      if (centerTitle) {
        pclCommands += '\x1B' + '&a40C'; // Center position
      }

      // Bold title
      pclCommands += '\x1B' + '(s3B'; // Bold font
      pclCommands += '$title\r\n';
      pclCommands += '\x1B' + '(s0B'; // Turn off bold

      // 5. Add border if requested
      if (addBorders) {
        pclCommands += '\x1B' + '&a5L'; // Reset to left margin
        pclCommands += '=' * 50 + '\r\n';
      }

      // 6. Print content
      pclCommands += '\x1B' + '&a5L'; // Left align content
      for (String line in content) {
        if (line.isEmpty) {
          pclCommands += '\r\n';
        } else {
          pclCommands += '$line\r\n';
        }
      }

      // 7. Add bottom border
      if (addBorders) {
        pclCommands += '${'=' * 50}\r\n';
      }

      // 8. Add spacing and form feed
      pclCommands += '\r\n\r\n\r\n';
      pclCommands += '\x0C'; // Form feed (eject page)

      socket.add(utf8.encode(pclCommands));
      await socket.flush();
      await socket.close();

      print('✅ Office printer job completed');
    } catch (e) {
      print('❌ Office printer failed: $e');
    }
  }

  // =======================================================
  // دالة الطابعات الحرارية (POS, Receipt Printers)
  // تستخدم ESC/POS commands - مناسبة لجميع الطابعات الحرارية
  // =======================================================
  Future<void> printToThermalPrinter({
    required String title,
    required List<String> content,
    bool centerTitle = true,
    bool addBorders = true,
    bool cutPaper = true,
    int fontSize = 0, // 0=normal, 1=double height, 2=double width, 3=double both
  }) async {
    try {
      final socket = await Socket.connect(printerIp, port, timeout: const Duration(seconds: 5));
      print('✅ Connected to Thermal Printer');

      final List<int> commands = [];

      // 1. Initialize printer
      commands.addAll([27, 64]); // ESC @ (initialize)

      // 2. Set character set to UTF-8
      commands.addAll([27, 116, 16]); // ESC t 16 (UTF-8)

      // 3. Print title
      if (centerTitle) {
        commands.addAll([27, 97, 1]); // ESC a 1 (center align)
      }

      // Set font size for title
      commands.addAll([29, 33, fontSize]); // GS ! (font size)
      commands.addAll([27, 69, 1]); // ESC E 1 (bold on)

      commands.addAll(utf8.encode(title));
      commands.addAll([10, 13]); // LF CR

      // Turn off bold and reset font size
      commands.addAll([27, 69, 0]); // ESC E 0 (bold off)
      commands.addAll([29, 33, 0]); // GS ! 0 (normal font)

      // 4. Add top border
      if (addBorders) {
        commands.addAll([27, 97, 0]); // ESC a 0 (left align)
        commands.addAll(utf8.encode('-' * 32)); // 32 chars for thermal printer
        commands.addAll([10, 13]);
      }

      // 5. Print content
      commands.addAll([27, 97, 0]); // ESC a 0 (left align)
      for (String line in content) {
        if (line.isEmpty) {
          commands.addAll([10, 13]);
        } else {
          commands.addAll(utf8.encode(line));
          commands.addAll([10, 13]);
        }
      }

      // 6. Add bottom border
      if (addBorders) {
        commands.addAll(utf8.encode('-' * 32));
        commands.addAll([10, 13]);
      }

      // 7. Add spacing
      commands.addAll([10, 13, 10, 13]);

      // 8. Cut paper if supported
      if (cutPaper) {
        commands.addAll([29, 86, 65, 0]); // GS V A 0 (full cut)
      }

      socket.add(commands);
      await socket.flush();
      await socket.close();

      print('✅ Thermal printer job completed');
    } catch (e) {
      print('❌ Thermal printer failed: $e');
    }
  }

  // =======================================================
  // دوال مساعدة للاستخدام السريع
  // =======================================================

  // طباعة فاتورة على طابعة مكتبية
  Future<void> printOfficeInvoice() async {
    await printToOfficePrinter(
      title: 'INVOICE - TABUK COMPANY',
      content: [
        '',
        'Date: ${DateTime.now().toString().substring(0, 10)}',
        'Time: ${DateTime.now().toString().substring(11, 16)}',
        'Invoice #: INV-${DateTime.now().millisecondsSinceEpoch}',
        '',
        'Customer: Azooz Alqubati',
        'Phone: +966 556400884',
        'Email: ahmed@example.com',
        '',
        'ITEMS:',
        '1. Product A          150.00 SAR',
        '2. Product B           75.00 SAR',
        '3. Product C          100.00 SAR',
        '',
        'Subtotal:            325.00 SAR',
        'VAT (15%):            48.75 SAR',
        'Total:               373.75 SAR',
        '',
        'Payment: Credit Card - PAID',
        '',
        'Thank you for your business!',
      ],
      centerTitle: true,
      addBorders: true,
      fontSize: '14H', // Larger font
    );
  }

  // طباعة إيصال على طابعة حرارية
  Future<void> printThermalReceipt() async {
    await printToThermalPrinter(
      title: 'TABUK COMPANY RECEIPT',
      content: [
        '',
        'Date: ${DateTime.now().toString().substring(0, 10)}',
        'Time: ${DateTime.now().toString().substring(11, 16)}',
        '',
        'Items:',
        'Product A        150.00',
        'Product B         75.00',
        'Product C        100.00',
        '',
        'Subtotal:        325.00',
        'VAT (15%):        48.75',
        'TOTAL:           373.75 SAR',
        '',
        'Payment: Cash',
        'Change: 26.25 SAR',
        '',
        'Thank you!',
        'Visit us again',
      ],
      centerTitle: true,
      addBorders: true,
      cutPaper: true,
      fontSize: 0, // Normal size
    );
  }

  // اختبار سريع للطابعات المكتبية
  Future<void> testOfficePrinter() async {
    await printToOfficePrinter(
      title: 'OFFICE PRINTER TEST',
      content: [
        'This is a test for office printers',
        'HP, Canon, Epson, Brother, etc.',
        '',
        'Features:',
        '• PCL commands support',
        '• Font size control',
        '• Margins and alignment',
        '• Form feed support',
        '',
        'Status: SUCCESS',
      ],
    );
  }

  // اختبار سريع للطابعات الحرارية
  Future<void> testThermalPrinter() async {
    await printToThermalPrinter(
      title: 'THERMAL PRINTER TEST',
      content: [
        'This is a test for thermal printers',
        'POS, Receipt printers, etc.',
        '',
        'Features:',
        '• ESC/POS commands',
        '• Paper cutting',
        '• Font size control',
        '• Character alignment',
        '',
        'Status: SUCCESS',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Universal Printer'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Office Printers Section
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '🖨️ Office Printers (HP, Canon, Epson)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: testOfficePrinter,
                      icon: const Icon(Icons.print),
                      label: const Text('Test Office Printer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: printOfficeInvoice,
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('Print Office Invoice'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Thermal Printers Section
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '🧾 Thermal Printers (POS, Receipt)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: testThermalPrinter,
                      icon: const Icon(Icons.receipt),
                      label: const Text('Test Thermal Printer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: printThermalReceipt,
                      icon: const Icon(Icons.point_of_sale),
                      label: const Text('Print Thermal Receipt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 45),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Info Section
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Column(
                children: [
                  Text(
                    '📋 Universal Printer Functions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '• Office Function: PCL commands for HP, Canon, Epson, Brother\n'
                    '• Thermal Function: ESC/POS for POS and receipt printers\n'
                    '• Automatic detection and formatting\n'
                    '• Customizable parameters for each printer type',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
