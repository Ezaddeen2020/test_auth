// lib/pages/home/widgets/settings_tab.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/classes/shared_preference.dart';
import 'package:auth_app/routes/app_routes.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الإعدادات',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Profile Section
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue,
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اسم المستخدم',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'user@example.com',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Settings Options
            Expanded(
              child: ListView(
                children: [
                  _SettingsItem(
                    icon: Icons.person,
                    title: 'الملف الشخصي',
                    subtitle: 'إدارة معلومات الحساب',
                    onTap: () {
                      // Navigate to profile
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.notifications,
                    title: 'الإشعارات',
                    subtitle: 'إعدادات الإشعارات',
                    onTap: () {
                      // Navigate to notifications settings
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.security,
                    title: 'الأمان',
                    subtitle: 'كلمة المرور والأمان',
                    onTap: () {
                      // Navigate to security settings
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.language,
                    title: 'اللغة',
                    subtitle: 'تغيير لغة التطبيق',
                    onTap: () {
                      // Show language picker
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.help,
                    title: 'المساعدة',
                    subtitle: 'الدعم والمساعدة',
                    onTap: () {
                      // Navigate to help
                    },
                  ),
                  _SettingsItem(
                    icon: Icons.info,
                    title: 'حول التطبيق',
                    subtitle: 'معلومات التطبيق',
                    onTap: () {
                      // Show about dialog
                    },
                  ),
                  const SizedBox(height: 20),
                  _SettingsItem(
                    icon: Icons.logout,
                    title: 'تسجيل الخروج',
                    subtitle: 'الخروج من التطبيق',
                    onTap: () => _showLogoutDialog(context),
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                // Clear user data
                Preferences.setBoolean(Preferences.isLogin, false);
                Preferences.setString('auth_token', '');

                // Navigate to login
                Get.offAllNamed(AppRoutes.login);
              },
              child: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.blue,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
