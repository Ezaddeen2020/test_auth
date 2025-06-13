import 'package:auth_app/pages/configration/controller/configration_controller.dart';
import 'package:flutter/material.dart';

class NetworkInfoCard extends StatelessWidget {
  final ConfigurationController controller;

  const NetworkInfoCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return _buildSectionCard(
      title: 'معلومات الشبكة الحالية',
      icon: Icons.network_check,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Text(
          controller.getNetworkStatusInfo(),
          style: TextStyle(
            color: Colors.blue[800],
            fontSize: 14,
          ),
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
