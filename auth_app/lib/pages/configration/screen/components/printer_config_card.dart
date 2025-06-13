// lib/pages/configuration/widgets/printer_config_card.dart

import 'package:auth_app/pages/configration/controller/configration_controller.dart';
import 'package:flutter/material.dart';

class PrinterConfigCard extends StatelessWidget {
  final ConfigurationController controller;

  const PrinterConfigCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return _buildSectionCard(
      title: 'إعدادات الطابعة',
      icon: Icons.print,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MAC Address Input
          TextFormField(
            controller: controller.macAddressController,
            decoration: InputDecoration(
              labelText: 'عنوان MAC للطابعة',
              hintText: '00:00:00:00:00:00',
              prefixIcon: const Icon(Icons.router),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue[700]!),
              ),
            ),
            onChanged: controller.onMacAddressChanged,
          ),

          const SizedBox(height: 15),

          // Device Name Input
          TextFormField(
            controller: controller.deviceNameController,
            decoration: InputDecoration(
              labelText: 'اسم الجهاز',
              hintText: 'أدخل اسم الجهاز',
              prefixIcon: const Icon(Icons.device_hub),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue[700]!),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // IP Address Input (for WAN or manual entry)
          if (controller.connectionType == 'WAN' || controller.ipAddressController.text.isNotEmpty)
            Column(
              children: [
                TextFormField(
                  controller: controller.ipAddressController,
                  decoration: InputDecoration(
                    labelText: 'عنوان IP للطابعة',
                    hintText: '192.168.1.100',
                    prefixIcon: const Icon(Icons.computer),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.blue[700]!),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),

          // Auto-detect button
          ElevatedButton.icon(
            onPressed: controller.isLoading ? null : controller.autoDetectPrinter,
            icon: controller.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.search),
            label: Text(controller.isLoading
                ? (controller.isScanning ? 'جاري البحث...' : 'جاري التحميل...')
                : 'البحث التلقائي عن الطابعة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue[700], size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            child,
          ],
        ),
      ),
    );
  }
}
