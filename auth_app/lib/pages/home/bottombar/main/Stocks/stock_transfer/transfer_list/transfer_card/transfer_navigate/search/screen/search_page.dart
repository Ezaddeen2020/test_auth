import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/purchase_controller.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransferNavigationController>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Search Box
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 26, 118, 193),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(
                    () => TextFormField(
                      controller: controller.searchController,
                      decoration: InputDecoration(
                        hintText: 'بحث (اسم، باركود، رقم صنف)',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blueGrey),
                        ),
                        suffixIcon: controller.searchText.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: controller.clearSearch,
                              )
                            : null,
                      ),
                      onFieldSubmitted: controller.performSearch,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Obx(() => ElevatedButton(
                      onPressed: controller.isSearching
                          ? null
                          : () => controller.performSearch(controller.searchController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: controller.isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'بحث',
                              style: TextStyle(color: Colors.white),
                            ),
                    )),
              ],
            ),

            const SizedBox(height: 20),

            // Search Type Filter Buttons
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    final bool isSelected = controller.selectedSearchType == 'name';
                    return GestureDetector(
                      onTap: () => controller.setSearchType('name'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF2196F3).withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.text_fields,
                              size: 16,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'اسم الصنف',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(() {
                    final bool isSelected = controller.selectedSearchType == 'barcode';
                    return GestureDetector(
                      onTap: () => controller.setSearchType('barcode'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF2196F3).withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code,
                              size: 16,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'باركود',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(() {
                    final bool isSelected = controller.selectedSearchType == 'number';
                    return GestureDetector(
                      onTap: () => controller.setSearchType('number'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF2196F3).withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.numbers,
                              size: 16,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'رقم الصنف',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Search Results
            Expanded(
              child: Obx(() => controller.isSearching
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFF2196F3),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'جاري البحث...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'ابدأ البحث لعرض النتائج',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'نوع البحث الحالي: ${controller.getSearchTypeLabel()}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )),
            ),
          ],
        ),
      ),
    );
  }
}
