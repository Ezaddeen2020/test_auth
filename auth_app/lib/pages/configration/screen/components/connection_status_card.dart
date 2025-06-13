import 'package:auth_app/pages/configration/controller/configration_controller.dart';
import 'package:flutter/material.dart';

class ConnectionStatusCard extends StatelessWidget {
  final ConfigurationController controller;

  const ConnectionStatusCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return _buildSectionCard(
      title: 'حالة الاتصال',
      icon: Icons.info,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: controller.isConnected ? Colors.green[50] : Colors.red[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: controller.isConnected ? Colors.green : Colors.red,
          ),
        ),
        child: Row(
          children: [
            Icon(
              controller.isConnected ? Icons.check_circle : Icons.error,
              color: controller.isConnected ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                controller.connectionStatus,
                style: TextStyle(
                  color: controller.isConnected ? Colors.green[800] : Colors.red[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
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
