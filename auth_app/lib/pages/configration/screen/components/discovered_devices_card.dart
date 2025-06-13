import 'package:auth_app/pages/configration/controller/configration_controller.dart';
import 'package:flutter/material.dart';

class DiscoveredDevicesCard extends StatelessWidget {
  final ConfigurationController controller;

  const DiscoveredDevicesCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return _buildSectionCard(
      title: 'الطابعات المكتشفة',
      icon: Icons.devices,
      child: Column(
        children: controller.discoveredDevices.map((device) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Icon(
                Icons.print,
                color: device.isOnline ? Colors.green : Colors.grey,
              ),
              title: Text(device.name),
              subtitle: Text('IP: ${device.ip}\nMAC: ${device.macAddress}'),
              trailing: Icon(
                device.isOnline ? Icons.check_circle : Icons.error,
                color: device.isOnline ? Colors.green : Colors.red,
              ),
              onTap: () => controller.selectDiscoveredDevice(device),
            ),
          );
        }).toList(),
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
