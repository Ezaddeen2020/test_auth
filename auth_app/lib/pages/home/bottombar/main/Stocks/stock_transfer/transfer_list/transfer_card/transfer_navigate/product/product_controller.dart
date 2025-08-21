import 'package:auth_app/classes/shared_preference.dart';
import 'package:auth_app/functions/handling_data.dart';
import 'package:auth_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:auth_app/functions/status_request.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/models/details_model.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/services/transfer_api.dart';
import 'package:auth_app/services/api/post_get_api.dart';

class ProductManagementController extends GetxController {
  // Status States
  var statusRequest = StatusRequest.none.obs;
  var isLoading = false.obs;
  var isSaving = false.obs;
  var isLoadingUnits = false.obs;

  // Data
  var transferId = Rxn<int>();
  var transferDetails = Rxn<TransferDetailDto>();
  var transferLines = <TransferLine>[].obs;
  var filteredLines = <TransferLine>[].obs;

  // إضافة خريطة لتخزين وحدات كل صنف
  var itemUnitsCache = <String, List<ItemUnit>>{}.obs;

  // Search
  var searchQuery = ''.obs;
  late TextEditingController searchController;

  // API
  late TransferApi transferApi;

  // Track changes
  var hasUnsavedChanges = false.obs;
  var modifiedLines = <int, TransferLine>{}.obs;
  var newLines = <TransferLine>[].obs;
  var deletedLines = <int>[].obs;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    transferApi = TransferApi(PostGetPage());
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// جلب وحدات صنف معين بشكل ديناميكي
  // Future<List<ItemUnit>> getItemUnits(String itemCode) async {
  //   try {
  //     // التحقق من وجود الوحدات في الذاكرة المؤقتة
  //     if (itemUnitsCache.containsKey(itemCode)) {
  //       logMessage('Transfer', 'Units loaded from cache for: $itemCode');
  //       return itemUnitsCache[itemCode]!;
  //     }

  //     // جلب الوحدات من الخادم
  //     logMessage('Transfer', 'Loading units from server for: $itemCode');
  //     isLoadingUnits.value = true;

  //     var response = await transferApi.getItemUnits(itemCode.trim());
  //     logMessage('Transfer', 'Units API response: ${response.toString()}');

  //     if (response['status'] == 'success') {
  //       List<ItemUnit> units = [];

  //       // تحويل البيانات إلى قائمة وحدات
  //       if (response['data'] != null) {
  //         var unitsData = response['data'];

  //         // التعامل مع أنواع البيانات المختلفة
  //         if (unitsData is List) {
  //           units =
  //               unitsData.map((unit) => ItemUnit.fromJson(unit as Map<String, dynamic>)).toList();
  //         } else if (unitsData is Map) {
  //           // إذا كانت البيانات Map واحد، نحوله إلى قائمة
  //           units = [ItemUnit.fromJson(unitsData as Map<String, dynamic>)];
  //         }

  //         logMessage('Transfer', 'Parsed ${units.length} units for item: $itemCode');
  //       }

  //       // إذا لم تكن هناك وحدات، إنشاء وحدة افتراضية
  //       if (units.isEmpty) {
  //         logMessage('Transfer', 'No units found, creating default unit for: $itemCode');
  //         units = _getDefaultUnits();
  //       }

  //       // حفظ في الذاكرة المؤقتة
  //       itemUnitsCache[itemCode] = units;
  //       return units;
  //     } else {
  //       logMessage('Transfer', 'API error: ${response['message']}');
  //       // في حالة الفشل، إرجاع وحدات افتراضية
  //       List<ItemUnit> defaultUnits = _getDefaultUnits();
  //       itemUnitsCache[itemCode] = defaultUnits;
  //       return defaultUnits;
  //     }
  //   } catch (e) {
  //     logMessage('Transfer', 'Exception in getItemUnits: ${e.toString()}');
  //     // في حالة الاستثناء، إرجاع وحدات افتراضية
  //     List<ItemUnit> defaultUnits = _getDefaultUnits();
  //     itemUnitsCache[itemCode] = defaultUnits;
  //     return defaultUnits;
  //   } finally {
  //     isLoadingUnits.value = false;
  //   }
  // }

  Future<List<ItemUnit>> getItemUnits(String itemCode) async {
    try {
      // التحقق من وجود الوحدات في الذاكرة المؤقتة
      if (itemUnitsCache.containsKey(itemCode)) {
        logMessage('Transfer', 'Units loaded from cache for: $itemCode');
        return itemUnitsCache[itemCode]!;
      }

      // جلب الوحدات من الخادم
      logMessage('Transfer', 'Loading units from server for: $itemCode');
      isLoadingUnits.value = true;

      // تجريب endpoints متعددة حتى نجد الصحيح
      var response = await _tryMultipleEndpoints(itemCode);

      logMessage('Transfer', 'Units API response: ${response.toString()}');

      if (response['status'] == 'success' && response['data'] != null) {
        List<ItemUnit> units = [];
        var unitsData = response['data'];

        // التعامل مع أنواع البيانات المختلفة
        if (unitsData is List) {
          units = unitsData.map((unit) => ItemUnit.fromJson(unit as Map<String, dynamic>)).toList();
        } else if (unitsData is Map) {
          // إذا كانت البيانات Map واحد، نحوله إلى قائمة
          units = [ItemUnit.fromJson(unitsData as Map<String, dynamic>)];
        }

        logMessage('Transfer', 'Parsed ${units.length} units for item: $itemCode');

        // التحقق من صحة البيانات المستلمة
        if (units.isNotEmpty && _validateUnitsData(units)) {
          // حفظ في الذاكرة المؤقتة
          itemUnitsCache[itemCode] = units;
          return units;
        } else {
          logMessage('Transfer', 'Invalid units data received for: $itemCode');
          throw Exception('بيانات الوحدات المستلمة غير صحيحة');
        }
      } else {
        // فشل في جلب البيانات من جميع الـ endpoints
        throw Exception(response['message'] ?? 'فشل في جلب وحدات الصنف من الخادم');
      }
    } catch (e) {
      logMessage('Transfer', 'Exception in getItemUnits: ${e.toString()}');

      // عرض رسالة خطأ للمستخدم
      Get.snackbar(
        'خطأ في تحميل الوحدات',
        'فشل في تحميل وحدات الصنف $itemCode: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );

      // إرجاع قائمة فارغة بدلاً من البيانات الوهمية
      return [];
    } finally {
      isLoadingUnits.value = false;
    }
  }

  Future<Map<String, dynamic>> _tryMultipleEndpoints(String itemCode) async {
    // قائمة بالـ endpoints المحتملة
    List<Future<Map<String, dynamic>>> endpointTries = [
      // الـ endpoint الأساسي
      transferApi.getItemUnits(itemCode),

      // endpoints بديلة
      _tryAlternativeEndpoint1(itemCode),
      _tryAlternativeEndpoint2(itemCode),
      _tryAlternativeEndpoint3(itemCode),
    ];

    // تجريب كل endpoint حتى نجد واحد يعمل
    for (int i = 0; i < endpointTries.length; i++) {
      try {
        var response = await endpointTries[i];
        if (response['status'] == 'success' && response['data'] != null) {
          logMessage('Transfer', 'Successfully loaded units using endpoint ${i + 1}');
          return response;
        }
      } catch (e) {
        logMessage('Transfer', 'Endpoint ${i + 1} failed: ${e.toString()}');
        continue;
      }
    }

    // إذا فشلت جميع الـ endpoints
    return {'status': 'error', 'message': 'فشل في جلب البيانات من جميع الـ endpoints المتاحة'};
  }

  /// endpoint بديل 1
  Future<Map<String, dynamic>> _tryAlternativeEndpoint1(String itemCode) async {
    // استخدام endpoint مختلف
    return await handleEitherResult(
      transferApi.postGetPage.getDataWithToken(
        '${ApiServices.server}/api/Items/Units/$itemCode',
        Preferences.getString('auth_token'),
      ),
      'Units Retrieved Successfully',
      'فشل في جلب وحدات الصنف',
    );
  }

  /// endpoint بديل 2
  Future<Map<String, dynamic>> _tryAlternativeEndpoint2(String itemCode) async {
    return await handleEitherResult(
      transferApi.postGetPage.getDataWithToken(
        '${ApiServices.server}/api/StockSAPWPOS1/Units/$itemCode',
        Preferences.getString('auth_token'),
      ),
      'Units Retrieved Successfully',
      'فشل في جلب وحدات الصنف',
    );
  }

  /// endpoint بديل 3
  Future<Map<String, dynamic>> _tryAlternativeEndpoint3(String itemCode) async {
    return await handleEitherResult(
      transferApi.postGetPage.getDataWithToken(
        '${ApiServices.server}/api/TransferApi/GetItemUnits?itemCode=$itemCode',
        Preferences.getString('auth_token'),
      ),
      'Units Retrieved Successfully',
      'فشل في جلب وحدات الصنف',
    );
  }

  /// التحقق من صحة بيانات الوحدات المستلمة
  bool _validateUnitsData(List<ItemUnit> units) {
    for (ItemUnit unit in units) {
      // التحقق من وجود البيانات الأساسية
      if (unit.uomCode.isEmpty || unit.uomName.isEmpty || unit.baseQty <= 0 || unit.uomEntry <= 0) {
        return false;
      }
    }
    return true;
  }

  /// إرجاع وحدات افتراضية في حالة عدم توفر البيانات
  // List<ItemUnit> _getDefaultUnits() {
  //   return [
  //     ItemUnit(
  //       uomCode: 'حبة',
  //       uomName: 'حبة',
  //       baseQty: 1,
  //       uomEntry: 1,
  //       ugpEntry: 1,
  //     ),
  //     ItemUnit(
  //       uomCode: 'شد12',
  //       uomName: 'شد 12',
  //       baseQty: 12,
  //       uomEntry: 2,
  //       ugpEntry: 1,
  //     ),
  //     ItemUnit(
  //       uomCode: 'كرتون',
  //       uomName: 'كرتون',
  //       baseQty: 50,
  //       uomEntry: 3,
  //       ugpEntry: 1,
  //     ),
  //   ];
  // }

  /// عرض نافذة اختيار الوحدة لصنف معين
  // Future<void> showUnitSelectionDialog(TransferLine line) async {
  //   if (line.itemCode == null || line.itemCode!.isEmpty) {
  //     Get.snackbar(
  //       'خطأ',
  //       'كود الصنف غير متوفر',
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //     return;
  //   }

  //   try {
  //     // جلب وحدات الصنف
  //     List<ItemUnit> units = await getItemUnits(line.itemCode!);

  //     if (units.isEmpty) {
  //       Get.snackbar(
  //         'تنبيه',
  //         'لا توجد وحدات متوفرة لهذا الصنف',
  //         backgroundColor: Colors.orange,
  //         colorText: Colors.white,
  //       );
  //       return;
  //     }

  //     // عرض النافذة
  //     Get.dialog(
  //       Dialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16),
  //         ),
  //         child: Container(
  //           width: 400,
  //           constraints: const BoxConstraints(maxHeight: 600),
  //           padding: const EdgeInsets.all(24),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               // رأس النافذة
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Expanded(
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         const Text(
  //                           'اختيار الوحدة',
  //                           style: TextStyle(
  //                             fontSize: 20,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                         const SizedBox(height: 4),
  //                         Text(
  //                           'الصنف: ${line.itemCode}',
  //                           style: TextStyle(
  //                             fontSize: 14,
  //                             color: Colors.grey[600],
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   IconButton(
  //                     onPressed: () => Get.back(),
  //                     icon: const Icon(Icons.close),
  //                     style: IconButton.styleFrom(
  //                       backgroundColor: Colors.grey[100],
  //                     ),
  //                   ),
  //                 ],
  //               ),

  //               const SizedBox(height: 24),

  //               // قائمة الوحدات
  //               Flexible(
  //                 child: ListView.builder(
  //                   shrinkWrap: true,
  //                   itemCount: units.length,
  //                   itemBuilder: (context, index) {
  //                     final unit = units[index];
  //                     final isSelected = unit.uomCode == line.uomCode;

  //                     return Card(
  //                       margin: const EdgeInsets.only(bottom: 12),
  //                       elevation: isSelected ? 4 : 2,
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(12),
  //                         side: BorderSide(
  //                           color: isSelected ? Colors.blue : Colors.transparent,
  //                           width: 2,
  //                         ),
  //                       ),
  //                       child: InkWell(
  //                         onTap: () {
  //                           Get.back();
  //                           updateProductUnit(
  //                             line,
  //                             unit.uomCode,
  //                             unit.baseQty,
  //                             unit.uomEntry,
  //                           );
  //                         },
  //                         borderRadius: BorderRadius.circular(12),
  //                         child: Container(
  //                           padding: const EdgeInsets.all(16),
  //                           child: Row(
  //                             children: [
  //                               // أيقونة الوحدة
  //                               Container(
  //                                 padding: const EdgeInsets.all(8),
  //                                 decoration: BoxDecoration(
  //                                   color: isSelected ? Colors.blue[50] : Colors.green[50],
  //                                   borderRadius: BorderRadius.circular(8),
  //                                 ),
  //                                 child: Icon(
  //                                   isSelected ? Icons.check_circle : Icons.check_circle_outline,
  //                                   color: isSelected ? Colors.blue[600] : Colors.green[600],
  //                                   size: 20,
  //                                 ),
  //                               ),

  //                               const SizedBox(width: 16),

  //                               // معلومات الوحدة
  //                               Expanded(
  //                                 child: Column(
  //                                   crossAxisAlignment: CrossAxisAlignment.start,
  //                                   children: [
  //                                     Text(
  //                                       unit.uomName,
  //                                       style: TextStyle(
  //                                         fontSize: 16,
  //                                         fontWeight: FontWeight.bold,
  //                                         color: isSelected ? Colors.blue[700] : Colors.black87,
  //                                       ),
  //                                     ),
  //                                     const SizedBox(height: 4),
  //                                     Text(
  //                                       'الكمية الأساسية: ${unit.baseQty}',
  //                                       style: TextStyle(
  //                                         fontSize: 14,
  //                                         color: Colors.grey[600],
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),

  //                               // معرف الوحدة
  //                               Container(
  //                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //                                 decoration: BoxDecoration(
  //                                   color: isSelected ? Colors.blue[100] : Colors.grey[100],
  //                                   borderRadius: BorderRadius.circular(20),
  //                                 ),
  //                                 child: Text(
  //                                   '${unit.uomEntry}',
  //                                   style: TextStyle(
  //                                     fontSize: 12,
  //                                     fontWeight: FontWeight.w500,
  //                                     color: isSelected ? Colors.blue[700] : Colors.black87,
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     );
  //   } catch (e) {
  //     logMessage('Transfer', 'Error in showUnitSelectionDialog: ${e.toString()}');
  //     Get.snackbar(
  //       'خطأ',
  //       'فشل في عرض وحدات الصنف: ${e.toString()}',
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //   }
  // }

  Future<void> showUnitSelectionDialog(TransferLine line) async {
    if (line.itemCode == null || line.itemCode!.isEmpty) {
      Get.snackbar(
        'خطأ',
        'كود الصنف غير متوفر',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // جلب وحدات الصنف من الخادم
      List<ItemUnit> units = await getItemUnits(line.itemCode!);

      if (units.isEmpty) {
        Get.snackbar(
          'تنبيه',
          'لا توجد وحدات متوفرة لهذا الصنف في النظام',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      // عرض النافذة مع البيانات الحقيقية
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 500, // زيادة العرض لاستيعاب البيانات الإضافية
            constraints: const BoxConstraints(maxHeight: 700),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // رأس النافذة مع معلومات إضافية
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'اختيار الوحدة',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'الصنف: ${line.itemCode}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'عدد الوحدات المتاحة: ${units.length}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // قائمة الوحدات مع تحسين العرض
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: units.length,
                    itemBuilder: (context, index) {
                      final unit = units[index];
                      final isSelected = unit.uomCode == line.uomCode;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: isSelected ? 4 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? Colors.blue : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            Get.back();
                            updateProductUnit(
                              line,
                              unit.uomCode,
                              unit.baseQty,
                              unit.uomEntry,
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // أيقونة الوحدة
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.blue[50] : Colors.green[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isSelected ? Icons.check_circle : Icons.check_circle_outline,
                                    color: isSelected ? Colors.blue[600] : Colors.green[600],
                                    size: 20,
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // معلومات الوحدة
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        unit.uomName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.blue[700] : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'الكمية الأساسية: ${unit.baseQty}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      if (unit.description != null &&
                                          unit.description!.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          unit.description!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // معرف الوحدة
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.blue[100] : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${unit.uomEntry}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? Colors.blue[700] : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      logMessage('Transfer', 'Error in showUnitSelectionDialog: ${e.toString()}');
      Get.snackbar(
        'خطأ',
        'فشل في عرض وحدات الصنف: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  // تحميل أسطر التحويل من الباك إند
  Future<void> loadTransferLines(int selectedTransferId) async {
    try {
      isLoading.value = true;
      statusRequest.value = StatusRequest.loading;
      transferId.value = selectedTransferId;

      var response = await transferApi.getTransferDetails(selectedTransferId);

      if (response['status'] == 'success') {
        TransferDetailDto details = TransferDetailDto.fromJson(response['data']);

        transferDetails.value = details;
        transferLines.value = details.lines;

        // إعادة تعيين التتبع للتغييرات
        _resetChangeTracking();

        _applyFilter();
        statusRequest.value = StatusRequest.success;
      } else {
        statusRequest.value = StatusRequest.failure;
        Get.snackbar(
          'خطأ',
          response['message'] ?? 'فشل في تحميل أصناف التحويل',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      statusRequest.value = StatusRequest.failure;
      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // تحديث وحدة المنتج
  void updateProductUnit(TransferLine line, String newUnitCode, int newBaseQty, int newUomEntry) {
    try {
      int index = transferLines
          .indexWhere((item) => item.lineNum == line.lineNum && item.itemCode == line.itemCode);

      if (index != -1) {
        // إنشاء سطر محدث بالوحدة الجديدة
        TransferLine updatedLine = TransferLine(
          docEntry: line.docEntry,
          lineNum: line.lineNum,
          itemCode: line.itemCode,
          description: line.description,
          quantity: line.quantity,
          price: line.price,
          lineTotal: line.lineTotal,
          uomCode: newUnitCode,
          uomCode2: line.uomCode2,
          invQty: line.invQty,
          baseQty1: newBaseQty,
          ugpEntry: line.ugpEntry,
          uomEntry: newUomEntry,
        );

        transferLines[index] = updatedLine;

        // تتبع التغيير
        _trackLineChange(updatedLine);

        _applyFilter();

        Get.snackbar(
          'تم التحديث',
          'تم تغيير الوحدة إلى $newUnitCode',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      logMessage('Transfer', 'Error in updateProductUnit: ${e.toString()}');
      Get.snackbar(
        'خطأ',
        'فشل في تحديث الوحدة: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // تحديث كمية المنتج
  void updateProductQuantity(TransferLine line, double newQuantity) {
    try {
      int index = transferLines
          .indexWhere((item) => item.lineNum == line.lineNum && item.itemCode == line.itemCode);

      if (index != -1) {
        // إنشاء سطر محدث بالكمية الجديدة
        TransferLine updatedLine = TransferLine(
          docEntry: line.docEntry,
          lineNum: line.lineNum,
          itemCode: line.itemCode,
          description: line.description,
          quantity: newQuantity,
          price: line.price,
          lineTotal: newQuantity * (line.price ?? 0.0),
          uomCode: line.uomCode,
          uomCode2: line.uomCode2,
          invQty: line.invQty,
          baseQty1: line.baseQty1,
          ugpEntry: line.ugpEntry,
          uomEntry: line.uomEntry,
        );

        transferLines[index] = updatedLine;

        // تتبع التغيير
        _trackLineChange(updatedLine);

        _applyFilter();
      }
    } catch (e) {
      logMessage('Transfer', 'Error in updateProductQuantity: ${e.toString()}');
      Get.snackbar(
        'خطأ',
        'فشل في تحديث الكمية: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // باقي الدوال كما هي...
  void _resetChangeTracking() {
    hasUnsavedChanges.value = false;
    modifiedLines.clear();
    newLines.clear();
    deletedLines.clear();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    _applyFilter();
  }

  void _applyFilter() {
    if (transferLines.isEmpty) {
      filteredLines.clear();
      return;
    }

    if (searchQuery.value.isEmpty) {
      filteredLines.value = List.from(transferLines);
    } else {
      String query = searchQuery.value.toLowerCase();
      filteredLines.value = transferLines.where((line) {
        bool matchesItemCode = line.itemCode?.toLowerCase().contains(query) ?? false;
        bool matchesDescription = line.description?.toLowerCase().contains(query) ?? false;
        return matchesItemCode || matchesDescription;
      }).toList();
    }
  }

  void _trackLineChange(TransferLine line) {
    if (line.lineNum != null && line.lineNum! > 0) {
      modifiedLines[line.lineNum!] = line;
      hasUnsavedChanges.value = true;
    }
  }

  void clearUnitsCache() {
    itemUnitsCache.clear();
  }

  void clearItemUnitsCache(String itemCode) {
    itemUnitsCache.remove(itemCode);
  }

  Map<String, dynamic> getProductStats() {
    if (filteredLines.isEmpty) {
      return {
        'totalItems': 0,
        'totalQuantity': 0.0,
        'totalAmount': 0.0,
        'uniqueItems': 0,
      };
    }

    double totalQuantity = 0.0;
    double totalAmount = 0.0;
    Set<String> uniqueItems = {};

    for (TransferLine line in filteredLines) {
      totalQuantity += line.quantity ?? 0.0;
      totalAmount += line.lineTotal ?? 0.0;

      if (line.itemCode != null && line.itemCode!.isNotEmpty) {
        uniqueItems.add(line.itemCode!);
      }
    }

    return {
      'totalItems': filteredLines.length,
      'totalQuantity': totalQuantity,
      'totalAmount': totalAmount,
      'uniqueItems': uniqueItems.length,
    };
  }

  void clearSearch() {
    searchController.clear();
    updateSearch('');
  }

  void resetData() {
    transferId.value = null;
    transferDetails.value = null;
    transferLines.clear();
    filteredLines.clear();
    searchController.clear();
    searchQuery.value = '';
    statusRequest.value = StatusRequest.none;
    itemUnitsCache.clear();
    _resetChangeTracking();
  }

  // Helper methods للحصول على المعلومات
  int get totalProductsCount => transferLines.length;
  int get filteredProductsCount => filteredLines.length;
  bool get hasActiveSearch => searchQuery.value.isNotEmpty;
  bool get hasData => transferLines.isNotEmpty;
  bool get hasSelectedTransfer => transferId.value != null;
  int get unsavedChangesCount => newLines.length + modifiedLines.length + deletedLines.length;
  bool get canSave => hasUnsavedChanges.value && !isSaving.value;

  // إضافة منتج جديد
  void addProduct(Map<String, dynamic> productData) {
    try {
      // التحقق من صحة البيانات
      if (!validateProductData(productData)) {
        return;
      }

      // إنشاء سطر جديد بدون lineNum (سيتم إنشاؤه من الخادم)
      TransferLine newLine = TransferLine(
        docEntry: transferId.value,
        lineNum: null, // لا نحدد lineNum للإضافات الجديدة
        itemCode: productData['itemCode'],
        description: productData['description'],
        quantity: productData['quantity']?.toDouble(),
        price: productData['price']?.toDouble(),
        lineTotal: (productData['quantity']?.toDouble() ?? 0.0) *
            (productData['price']?.toDouble() ?? 0.0),
        uomCode: productData['uomCode'],
        uomCode2: productData['uomCode2'],
        invQty: productData['invQty']?.toDouble(),
        baseQty1: productData['baseQty1']?.toInt(),
        ugpEntry: productData['ugpEntry']?.toInt(),
        uomEntry: productData['uomEntry']?.toInt(),
      );

      // إضافة للقائمة الرئيسية مع lineNum مؤقت للعرض
      TransferLine displayLine = TransferLine(
        docEntry: newLine.docEntry,
        lineNum: _getNextTempLineNumber(), // رقم مؤقت للعرض
        itemCode: newLine.itemCode,
        description: newLine.description,
        quantity: newLine.quantity,
        price: newLine.price,
        lineTotal: newLine.lineTotal,
        uomCode: newLine.uomCode,
        uomCode2: newLine.uomCode2,
        invQty: newLine.invQty,
        baseQty1: newLine.baseQty1,
        ugpEntry: newLine.ugpEntry,
        uomEntry: newLine.uomEntry,
      );

      transferLines.add(displayLine);
      newLines.add(newLine); // تتبع كونه جديد
      hasUnsavedChanges.value = true;

      _applyFilter();

      Get.snackbar(
        'نجح',
        'تم إضافة المنتج بنجاح (يتطلب حفظ)',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      logMessage('Transfer', 'Error in addProduct: ${e.toString()}');
      Get.snackbar(
        'خطأ',
        'فشل في إضافة المنتج: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // تعديل منتج موجود
  void updateProduct(TransferLine oldLine, Map<String, dynamic> newData) {
    try {
      int index = transferLines.indexWhere(
          (line) => line.lineNum == oldLine.lineNum && line.itemCode == oldLine.itemCode);

      if (index != -1) {
        TransferLine updatedLine = TransferLine(
          docEntry: oldLine.docEntry,
          lineNum: oldLine.lineNum,
          itemCode: newData['itemCode'] ?? oldLine.itemCode,
          description: newData['description'] ?? oldLine.description,
          quantity: newData['quantity']?.toDouble() ?? oldLine.quantity,
          price: newData['price']?.toDouble() ?? oldLine.price,
          lineTotal: (newData['quantity']?.toDouble() ?? oldLine.quantity ?? 0.0) *
              (newData['price']?.toDouble() ?? oldLine.price ?? 0.0),
          uomCode: newData['uomCode'] ?? oldLine.uomCode,
          uomCode2: newData['uomCode2'] ?? oldLine.uomCode2,
          invQty: newData['invQty']?.toDouble() ?? oldLine.invQty,
          baseQty1: newData['baseQty1']?.toInt() ?? oldLine.baseQty1,
          ugpEntry: newData['ugpEntry']?.toInt() ?? oldLine.ugpEntry,
          uomEntry: newData['uomEntry']?.toInt() ?? oldLine.uomEntry,
        );

        transferLines[index] = updatedLine;

        // تتبع التغيير
        _trackLineChange(updatedLine);

        _applyFilter();

        Get.snackbar(
          'نجح',
          'تم تعديل المنتج بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      logMessage('Transfer', 'Error in updateProduct: ${e.toString()}');
      Get.snackbar(
        'خطأ',
        'فشل في تعديل المنتج: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // حذف منتج
  void deleteProduct(TransferLine line) {
    try {
      // إزالة من القائمة الرئيسية
      transferLines
          .removeWhere((item) => item.lineNum == line.lineNum && item.itemCode == line.itemCode);

      // تتبع الحذف
      if (line.lineNum != null && line.lineNum! > 0) {
        // إذا كان سطر موجود في الخادم
        deletedLines.add(line.lineNum!);
        hasUnsavedChanges.value = true;
      } else {
        // إذا كان سطر جديد لم يُحفظ بعد
        newLines.removeWhere((newLine) => newLine.itemCode == line.itemCode);
      }

      _applyFilter();

      Get.snackbar(
        'نجح',
        'تم حذف المنتج بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      logMessage('Transfer', 'Error in deleteProduct: ${e.toString()}');
      Get.snackbar(
        'خطأ',
        'فشل في حذف المنتج: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // نسخ منتج
  void duplicateProduct(TransferLine line) {
    try {
      // إنشاء سطر مكرر كسطر جديد
      TransferLine duplicatedLine = TransferLine(
        docEntry: line.docEntry,
        lineNum: null, // سطر جديد بدون lineNum
        itemCode: line.itemCode,
        description: line.description,
        quantity: line.quantity,
        price: line.price,
        lineTotal: line.lineTotal,
        uomCode: line.uomCode,
        uomCode2: line.uomCode2,
        invQty: line.invQty,
        baseQty1: line.baseQty1,
        ugpEntry: line.ugpEntry,
        uomEntry: line.uomEntry,
      );

      // إضافة للعرض مع رقم مؤقت
      TransferLine displayLine = TransferLine(
        docEntry: duplicatedLine.docEntry,
        lineNum: _getNextTempLineNumber(),
        itemCode: duplicatedLine.itemCode,
        description: duplicatedLine.description,
        quantity: duplicatedLine.quantity,
        price: duplicatedLine.price,
        lineTotal: duplicatedLine.lineTotal,
        uomCode: duplicatedLine.uomCode,
        uomCode2: duplicatedLine.uomCode2,
        invQty: duplicatedLine.invQty,
        baseQty1: duplicatedLine.baseQty1,
        ugpEntry: duplicatedLine.ugpEntry,
        uomEntry: duplicatedLine.uomEntry,
      );

      transferLines.add(displayLine);
      newLines.add(duplicatedLine); // تتبع كونه جديد
      hasUnsavedChanges.value = true;

      _applyFilter();

      Get.snackbar(
        'نجح',
        'تم نسخ المنتج بنجاح (يتطلب حفظ)',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      logMessage('Transfer', 'Error in duplicateProduct: ${e.toString()}');
      Get.snackbar(
        'خطأ',
        'فشل في نسخ المنتج: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // الحصول على رقم سطر مؤقت للعرض
  int _getNextTempLineNumber() {
    int maxLineNum = 0;
    for (TransferLine line in transferLines) {
      if (line.lineNum != null && line.lineNum! > maxLineNum) {
        maxLineNum = line.lineNum!;
      }
    }
    return -(maxLineNum + 1); // استخدام أرقام سالبة للأسطر الجديدة
  }

  // حفظ جميع التغييرات على الخادم
  Future<void> saveAllChangesToServer() async {
    if (!hasUnsavedChanges.value) {
      Get.snackbar(
        'تنبيه',
        'لا توجد تغييرات للحفظ',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSaving.value = true;
      int successCount = 0;
      int errorCount = 0;

      // 1. حفظ الأسطر الجديدة
      for (TransferLine newLine in newLines) {
        var result = await _saveNewLine(newLine);
        if (result['success'] == true) {
          successCount++;
          // تحديث lineNum من الاستجابة
          if (result['lineNum'] != null) {
            _updateLineNumInList(newLine, result['lineNum']);
          }
        } else {
          errorCount++;
        }
      }

      // 2. حفظ الأسطر المعدلة
      for (TransferLine modifiedLine in modifiedLines.values) {
        var result = await _saveModifiedLine(modifiedLine);
        if (result['success'] == true) {
          successCount++;
        } else {
          errorCount++;
        }
      }

      // 3. حذف الأسطر المحذوفة
      for (int deletedLineNum in deletedLines) {
        var result = await _deleteLineFromServer(deletedLineNum);
        if (result['success'] == true) {
          successCount++;
        } else {
          errorCount++;
        }
      }

      // عرض النتائج
      if (errorCount == 0) {
        _resetChangeTracking();
        Get.snackbar(
          'نجح',
          'تم حفظ جميع التغييرات بنجاح ($successCount عملية)',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // إعادة تحميل البيانات من الخادم للتأكد من التطابق
        if (transferId.value != null) {
          await loadTransferLines(transferId.value!);
        }
      } else {
        Get.snackbar(
          'تحذير',
          'تم حفظ $successCount عملية بنجاح، فشل في $errorCount عملية',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      logMessage('Transfer', 'Error in saveAllChangesToServer: ${e.toString()}');
      Get.snackbar(
        'خطأ',
        'فشل في حفظ التغييرات: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  // حفظ سطر جديد
  Future<Map<String, dynamic>> _saveNewLine(TransferLine line) async {
    try {
      var response = await transferApi.upsertTransferLine(
        docEntry: line.docEntry ?? transferId.value!,
        lineNum: null, // أو -1 أو 0 للإضافة الجديدة
        itemCode: line.itemCode!,
        description: line.description ?? '',
        quantity: line.quantity ?? 0.0,
        price: line.price ?? 0.0,
        lineTotal: line.lineTotal ?? 0.0,
        uomCode: line.uomCode ?? '',
        uomCode2: line.uomCode2,
        invQty: line.invQty,
        baseQty1: line.baseQty1,
        ugpEntry: line.ugpEntry,
        uomEntry: line.uomEntry,
      );

      if (response['status'] == 'success') {
        return {
          'success': true,
          'lineNum': response['data']?['lineNum'], // lineNum الجديد من الخادم
        };
      } else {
        return {'success': false, 'error': response['message']};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // حفظ سطر معدل
  Future<Map<String, dynamic>> _saveModifiedLine(TransferLine line) async {
    try {
      var response = await transferApi.upsertTransferLine(
        docEntry: line.docEntry!,
        lineNum: line.lineNum!, // lineNum موجود للتعديل
        itemCode: line.itemCode!,
        description: line.description ?? '',
        quantity: line.quantity ?? 0.0,
        price: line.price ?? 0.0,
        lineTotal: line.lineTotal ?? 0.0,
        uomCode: line.uomCode ?? '',
        uomCode2: line.uomCode2,
        invQty: line.invQty,
        baseQty1: line.baseQty1,
        ugpEntry: line.ugpEntry,
        uomEntry: line.uomEntry,
      );

      return {
        'success': response['status'] == 'success',
        'error': response['message'],
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // حذف سطر من الخادم
  Future<Map<String, dynamic>> _deleteLineFromServer(int lineNum) async {
    try {
      var response = await transferApi.deleteTransferLine(
        docEntry: transferId.value!,
        lineNum: lineNum,
      );

      return {
        'success': response['status'] == 'success',
        'error': response['message'],
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // تحديث lineNum في القائمة بعد الإضافة الناجحة
  void _updateLineNumInList(TransferLine oldLine, int newLineNum) {
    int index = transferLines.indexWhere(
        (line) => line.itemCode == oldLine.itemCode && line.lineNum != null && line.lineNum! < 0);

    if (index != -1) {
      TransferLine updatedLine = TransferLine(
        docEntry: transferLines[index].docEntry,
        lineNum: newLineNum, // LineNum الجديد من الخادم
        itemCode: transferLines[index].itemCode,
        description: transferLines[index].description,
        quantity: transferLines[index].quantity,
        price: transferLines[index].price,
        lineTotal: transferLines[index].lineTotal,
        uomCode: transferLines[index].uomCode,
        uomCode2: transferLines[index].uomCode2,
        invQty: transferLines[index].invQty,
        baseQty1: transferLines[index].baseQty1,
        ugpEntry: transferLines[index].ugpEntry,
        uomEntry: transferLines[index].uomEntry,
      );

      transferLines[index] = updatedLine;
    }
  }

  // التحقق من صحة بيانات المنتج
  bool validateProductData(Map<String, dynamic> productData) {
    if (productData['itemCode'] == null || productData['itemCode'].toString().trim().isEmpty) {
      Get.snackbar(
        'خطأ في البيانات',
        'كود المنتج مطلوب',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (productData['quantity'] == null || productData['quantity'] <= 0) {
      Get.snackbar(
        'خطأ في البيانات',
        'الكمية يجب أن تكون أكبر من صفر',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (productData['price'] == null || productData['price'] < 0) {
      Get.snackbar(
        'خطأ في البيانات',
        'السعر يجب أن يكون أكبر من أو يساوي صفر',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  // دالة مساعدة للتسجيل
  void logMessage(String tag, String message) {
    print('[$tag] $message');
  }
}

/// نموذج بيانات للوحدة
class ItemUnit {
  final String uomCode;
  final String uomName;
  final int baseQty;
  final int uomEntry;
  final int ugpEntry;
  final String? description;

  ItemUnit({
    required this.uomCode,
    required this.uomName,
    required this.baseQty,
    required this.uomEntry,
    required this.ugpEntry,
    this.description,
  });

  factory ItemUnit.fromJson(Map<String, dynamic> json) {
    return ItemUnit(
      uomCode: json['uomCode']?.toString() ?? '',
      uomName: json['uomName']?.toString() ?? json['uomCode']?.toString() ?? '',
      baseQty: json['baseQty']?.toInt() ?? 1,
      uomEntry: json['uomEntry']?.toInt() ?? 1,
      ugpEntry: json['ugpEntry']?.toInt() ?? 1,
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uomCode': uomCode,
      'uomName': uomName,
      'baseQty': baseQty,
      'uomEntry': uomEntry,
      'ugpEntry': ugpEntry,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'ItemUnit{uomCode: $uomCode, uomName: $uomName, baseQty: $baseQty}';
  }
}
