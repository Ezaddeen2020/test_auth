import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/controllers/transfer_controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/screens/widgets/transfer_card.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/screens/widgets/transfer_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/functions/status_request.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransferController>();

    return Scaffold(
      // backgroundColor: Colors.grey[50],
      backgroundColor: Colors.white,
      appBar: _buildAppBar(controller),
      body: Column(
        children: [
          _buildStatsBar(controller),
          _buildActionBar(controller),
          Expanded(child: _buildContent(controller)),
          _buildPagination(controller),
        ],
      ),
    );
  }

  //======================= AppBar ==============================
  PreferredSizeWidget _buildAppBar(TransferController controller) => AppBar(
        title: const Text('قائمة التحويلات', style: TextStyle(fontSize: 18, color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.refreshTransfers,
          ),
        ],
      );

  //===================== شريط الإحصائيات
  Widget _buildStatsBar(TransferController controller) => Obx(() {
        final stats = controller.getTransferStats();
        final items = [
          ('الإجمالي', stats['total'], Colors.white),
          ('قيد التحضير', stats['pending'], Colors.orange[200]!),
          ('تم الإرسال', stats['sent'], Colors.blue[200]!),
          ('مكتمل', stats['posted'], Colors.green[200]!),
        ];

        return Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: items
                .map((item) => Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${item.$2}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold, color: item.$3)),
                          Text(item.$1,
                              style: TextStyle(fontSize: 11, color: item.$3.withOpacity(0.9)),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ))
                .toList(),
          ),
        );
      });

  //=================== شريط العمليات (البحث + إضافة + فلتر)
  Widget _buildActionBar(TransferController controller) => Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            // حقل البحث
            Expanded(child: _buildSearchField(controller)),
            const SizedBox(width: 8),
            // زر إضافة
            _buildActionButton(
              icon: Icons.add,
              label: 'إضافة',
              color: const Color(0xFF4CAF50),
              onPressed: () => Get.snackbar('قريباً', 'سيتم إضافة صفحة إنشاء التحويل قريباً',
                  backgroundColor: Colors.green, colorText: Colors.white),
            ),
            const SizedBox(width: 8),
            // زر فلتر
            _buildActionButton(
              icon: Icons.tune,
              color: const Color(0xFF2196F3),
              onPressed: () => TransferDialogs.showFilterDialog(controller),
            ),
          ],
        ),
      );

  //========================= حقل البحث
  Widget _buildSearchField(TransferController controller) => Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: TextField(
          controller: controller.searchController,
          onChanged: controller.updateSearch,
          decoration: InputDecoration(
            hintText: 'البحث في التحويلات...',
            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
            suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      controller.searchController.clear();
                      controller.updateSearch('');
                    },
                    child: Icon(Icons.clear, color: Colors.grey[500], size: 20),
                  )
                : const SizedBox.shrink()),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      );

  //=========================== زر عملية (إضافة أو فلتر)
  Widget _buildActionButton({
    required IconData icon,
    String? label,
    required Color color,
    required VoidCallback onPressed,
  }) =>
      Container(
        height: 44,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
          boxShadow: label != null
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))
                ]
              : null,
        ),
        child: label != null
            ? ElevatedButton.icon(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
                icon: Icon(icon, size: 18),
                label:
                    Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              )
            : IconButton(icon: Icon(icon, color: Colors.white, size: 20), onPressed: onPressed),
      );

  //============================ المحتوى الرئيسي ===============================
  Widget _buildContent(TransferController controller) => Obx(() {
        if (controller.statusRequest.value == StatusRequest.loading &&
            controller.transfers.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2196F3)));
        }

        if (controller.statusRequest.value == StatusRequest.failure) {
          return _buildEmptyState(
            icon: Icons.wifi_off_rounded,
            title: 'فشل في تحميل البيانات',
            subtitle: 'تحقق من اتصال الإنترنت',
            actionLabel: 'إعادة المحاولة',
            onPressed: controller.getTransfersList,
          );
        }

        if (controller.filteredTransfers.isEmpty) {
          return _buildEmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'لا توجد تحويلات',
            subtitle: 'لم يتم العثور على أي تحويلات',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshTransfers,
          color: const Color(0xFF2196F3),
          child: ListView.builder(
            controller: controller.scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: controller.filteredTransfers.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TransferCard(
                transfer: controller.filteredTransfers[index],
                controller: controller,
              ),
            ),
          ),
        );
      });

  //========================= حالة فارغة موحدة
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onPressed,
  }) =>
      Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(title,
                  style: TextStyle(
                      fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              if (actionLabel != null && onPressed != null) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(actionLabel),
                ),
              ],
            ],
          ),
        ),
      );

  //==================== شريط عداد الصفحات
  Widget _buildPagination(TransferController controller) => Obx(() {
        if (controller.totalPages.value <= 1) return const SizedBox.shrink();

        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -2))
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavButton(
                  'السابق',
                  Icons.chevron_left,
                  controller.currentPage.value > 1 && !controller.isLoading.value,
                  () => controller.goToPage(controller.currentPage.value - 1)),
              _buildPageInfo(controller),
              _buildNavButton(
                  'التالي',
                  Icons.chevron_right,
                  controller.currentPage.value < controller.totalPages.value &&
                      !controller.isLoading.value,
                  () => controller.goToPage(controller.currentPage.value + 1)),
            ],
          ),
        );
      });

  //========================== زر تنقل
  Widget _buildNavButton(String label, IconData icon, bool enabled, VoidCallback onPressed) =>
      TextButton.icon(
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(
          foregroundColor: enabled ? const Color(0xFF2196F3) : Colors.grey[400],
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      );

  //============================== كونتينر عرض الصفحات
  Widget _buildPageInfo(TransferController controller) => GestureDetector(
        onTap: () => _showPageDialog(controller),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              controller.isLoading.value
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3))))
                  : const Icon(Icons.more_horiz, size: 16, color: Color(0xFF2196F3)),
              const SizedBox(width: 8),
              Text('${controller.currentPage.value} / ${controller.totalPages.value}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
            ],
          ),
        ),
      );

  //========================== نافذة اختيار الصفحة ================================================
  void _showPageDialog(TransferController controller) => Get.dialog(
        AlertDialog(
          title: const Text('اختر الصفحة'),
          content: SizedBox(
            width: double.maxFinite,
            height: 200,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: controller.totalPages.value,
              itemBuilder: (context, index) {
                final pageNumber = index + 1;
                final isCurrentPage = pageNumber == controller.currentPage.value;

                return GestureDetector(
                  onTap: () {
                    Get.back();
                    controller.goToPage(pageNumber);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCurrentPage ? const Color(0xFF2196F3) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: isCurrentPage ? const Color(0xFF2196F3) : Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Text(
                        pageNumber.toString(),
                        style: TextStyle(
                          color: isCurrentPage ? Colors.white : Colors.grey[700],
                          fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [TextButton(onPressed: () => Get.back(), child: const Text('إلغاء'))],
        ),
      );
}
