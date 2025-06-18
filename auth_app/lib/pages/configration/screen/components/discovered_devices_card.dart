import 'package:auth_app/pages/configration/controller/configration_controller.dart';
import 'package:flutter/material.dart';

class DeviceInfoCard extends StatelessWidget {
  final ConfigurationController controller;

  const DeviceInfoCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return _buildSectionCard(
      title: 'معلومات الطابعة المختارة',
      icon: Icons.info_outline,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.devices, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'اسم الجهاز:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              controller.deviceNameController.text.isEmpty
                  ? 'غير محدد'
                  : controller.deviceNameController.text,
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Icon(Icons.network_check, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'MAC Address:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              controller.macAddressController.text.isEmpty
                  ? 'غير محدد'
                  : controller.macAddressController.text,
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
            if (controller.ipAddressController.text.isNotEmpty) ...[
              const SizedBox(height: 15),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'IP Address:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                controller.ipAddressController.text,
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 14,
                  fontFamily: 'monospace',
                ),
              ),
            ],
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


// import 'package:auth_app/pages/configration/controller/configration_controller.dart';
// import 'package:flutter/material.dart';

// class DiscoveredDevicesCard extends StatelessWidget {
//   final ConfigurationController controller;

//   const DiscoveredDevicesCard({super.key, required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return _buildSectionCard(
//       title: 'الطابعات المكتشفة',
//       icon: Icons.devices,
//       child: Column(
//         children: controller.discoveredDevices.map((device) {
//           return Card(
//             margin: const EdgeInsets.only(bottom: 10),
//             child: ListTile(
//               leading: Icon(
//                 Icons.print,
//                 color: device.isOnline ? Colors.green : Colors.grey,
//               ),
//               title: Text(device.name),
//               subtitle: Text('IP: ${device.ip}\nMAC: ${device.macAddress}'),
//               trailing: Icon(
//                 device.isOnline ? Icons.check_circle : Icons.error,
//                 color: device.isOnline ? Colors.green : Colors.red,
//               ),
//               onTap: () => controller.selectDiscoveredDevice(device),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildSectionCard({
//     required String title,
//     required IconData icon,
//     required Widget child,
//   }) {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, color: Colors.blue[700], size: 24),
//                 const SizedBox(width: 10),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 15),
//             child,
//           ],
//         ),
//       ),
//     );
//   }
// }
