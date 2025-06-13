import 'package:auth_app/pages/configration/controller/configration_controller.dart';
import 'package:flutter/material.dart';

class SubnetConfigCard extends StatelessWidget {
  final ConfigurationController controller;

  const SubnetConfigCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return _buildSectionCard(
      title: 'إعدادات الشبكة الفرعية',
      icon: Icons.lan,
      child: TextFormField(
        controller: controller.customSubnetController,
        decoration: InputDecoration(
          labelText: 'الشبكة الفرعية',
          hintText: '192.168.1',
          prefixIcon: const Icon(Icons.settings_ethernet),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue[700]!),
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
