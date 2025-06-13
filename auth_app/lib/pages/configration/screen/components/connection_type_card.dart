import 'package:auth_app/pages/configration/controller/configration_controller.dart';
import 'package:flutter/material.dart';

class ConnectionTypeCard extends StatelessWidget {
  final ConfigurationController controller;

  const ConnectionTypeCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return _buildSectionCard(
      title: 'نوع الاتصال',
      icon: Icons.network_wifi,
      child: Column(
        children: [
          RadioListTile<String>(
            title: const Text('شبكة محلية (LAN)'),
            subtitle: const Text('للاتصال داخل الشبكة المحلية'),
            value: 'LAN',
            groupValue: controller.connectionType,
            onChanged: controller.setConnectionType,
            activeColor: Colors.blue[700],
          ),
          RadioListTile<String>(
            title: const Text('شبكة واسعة (WAN)'),
            subtitle: const Text('للاتصال عبر الإنترنت'),
            value: 'WAN',
            groupValue: controller.connectionType,
            onChanged: controller.setConnectionType,
            activeColor: Colors.blue[700],
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
