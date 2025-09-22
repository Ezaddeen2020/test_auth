import 'dart:async';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/controllers/stock_controller.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/model/stock_model.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/services/get_transfer_detailsApi.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/services/upsert_transfer_api.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/model/uom_model.dart';
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/services/get_unit_api.dart';
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

  // Cache for item units
  var itemUnitsCache = <String, List<ItemUnit>>{}.obs;

  // Search
  var searchQuery = ''.obs;
  late TextEditingController searchController;

  // API
  late TransferApi transferApi;
  late UpsertTransferApi upsertTransferApi;
  late GetTransferDetailsApi gettransferdetailsApi;
  late GetUnitApi getUnitApi;

  // Track changes
  var hasUnsavedChanges = false.obs;
  var modifiedLines = <int, TransferLine>{}.obs;
  var deletedLines = <int>[].obs;
  var newLines = <TransferLine>[].obs;

  // Stock controller reference
  late StockController stockController;

  // Current variables
  final pulledItem = Rx<StockModel?>(null);
  final searchResults = <StockModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    transferApi = TransferApi(PostGetPage());
    upsertTransferApi = UpsertTransferApi(PostGetPage());
    getUnitApi = GetUnitApi(PostGetPage());
    gettransferdetailsApi = GetTransferDetailsApi(PostGetPage());

    // Initialize StockController
    stockController = Get.put(StockController());
  }

  @override
  void onClose() {
    searchController.dispose();
    _searchTimer?.cancel();
    super.onClose();
  }

// void setTransferId(int transferIdValue) {
//   transferId.value = transferIdValue;
//   print('Transfer ID set to: $transferIdValue');
// }

  void setTransferId(int transferIdValue) {
    transferId.value = transferIdValue;
    print('ProductManagementController: Transfer ID set to $transferIdValue');

    // إذا كانت هناك بيانات محملة لتحويل مختلف، امسحها
    if (transferDetails.value?.header.id != transferIdValue) {
      print('Clearing existing data for different transfer');
      transferDetails.value = null;
      transferLines.clear();
      filteredLines.clear();
      _resetChangeTracking();
    }
  }

// Check if transfer ID is set
  bool get hasValidTransferId => transferId.value != null && transferId.value! > 0;

  /// Get current transfer ID
  int? get currentTransferId => transferId.value;

  /// Pull item data for use in other parts of the application
  Future<Map<String, dynamic>?> pullItemData(String itemCode) async {
    if (itemCode.trim().isEmpty) {
      _showErrorMessage('كود الصنف مطلوب');
      return null;
    }

    try {
      stockController.itemCodeController.text = itemCode.trim();
      await stockController.searchStock();

      if (stockController.stockItems.isNotEmpty) {
        var stockItem = stockController.stockItems.first;

        return {
          'itemCode': itemCode.trim(),
          'description': stockItem.itemName,
          'quantity': stockItem.totalOnHand > 0 ? stockItem.totalOnHand : 1.0,
          'price': stockItem.avgPrice > 0 ? stockItem.avgPrice : 0.0,
          'uomCode': stockItem.uomCode ?? 'حبة',
          'baseQty1': 1,
          'uomEntry': 1,
          'success': true,
          'message': 'تم سحب بيانات الصنف بنجاح',
        };
      } else {
        return {
          'success': false,
          'message': 'لم يتم العثور على بيانات لهذا الصنف',
        };
      }
    } catch (e) {
      logMessage('Transfer', 'Error in pullItemData: ${e.toString()}');
      return {
        'success': false,
        'message': 'فشل في سحب بيانات الصنف: ${e.toString()}',
      };
    }
  }

  /// Enhanced function to add product with pull capability
  Future<void> addProductWithPull(
    String itemCode, {
    double? quantity,
    double? price,
    String? description,
    String? uomCode,
    bool pullData = true,
  }) async {
    try {
      Map<String, dynamic> productData = {};

      if (pullData) {
        var pulledData = await pullItemData(itemCode);

        if (pulledData != null && pulledData['success'] == true) {
          productData = {
            'itemCode': pulledData['itemCode'],
            'description': description ?? pulledData['description'],
            'quantity': quantity ?? pulledData['quantity'],
            'price': price ?? pulledData['price'],
            'uomCode': uomCode ?? pulledData['uomCode'],
            'baseQty1': pulledData['baseQty1'],
            'uomEntry': pulledData['uomEntry'],
          };

          _showSuccessMessage(pulledData['message']);
        } else {
          productData = {
            'itemCode': itemCode.trim(),
            'description': description ?? '',
            'quantity': quantity ?? 1.0,
            'price': price ?? 0.0,
            'uomCode': uomCode ?? 'حبة',
            'baseQty1': 1,
            'uomEntry': 1,
          };

          _showWarningMessage(pulledData?['message'] ??
              'لم يتم العثور على بيانات الصنف، تم استخدام القيم الافتراضية');
        }
      } else {
        productData = {
          'itemCode': itemCode.trim(),
          'description': description ?? '',
          'quantity': quantity ?? 1.0,
          'price': price ?? 0.0,
          'uomCode': uomCode ?? 'حبة',
          'baseQty1': 1,
          'uomEntry': 1,
        };
      }

      addProduct(productData);
    } catch (e) {
      logMessage('Transfer', 'Error in addProductWithPull: ${e.toString()}');
      _showErrorMessage('فشل في إضافة المنتج: ${e.toString()}');
    }
  }

  /// Get item units from server with caching
  Future<List<ItemUnit>> getItemUnits(String itemCode) async {
    try {
      String cacheKey = itemCode.trim().toUpperCase();
      if (itemUnitsCache.containsKey(cacheKey)) {
        logMessage('Transfer', 'Units loaded from cache for: $itemCode');
        return itemUnitsCache[cacheKey]!;
      }

      logMessage('Transfer', 'Loading units from server for: $itemCode');
      isLoadingUnits.value = true;

      var response = await getUnitApi.getItemUnits(itemCode.trim());
      logMessage('Transfer', 'Units API response: ${response.toString()}');

      if (response['status'] == 'success' && response['data'] != null) {
        List<ItemUnit> units = [];
        var unitsData = response['data'];

        if (unitsData is List) {
          units = unitsData.map((unitJson) {
            UomModel uomModel = UomModel.fromJson(unitJson as Map<String, dynamic>);
            return ItemUnit.fromUomModel(uomModel);
          }).toList();
        }

        logMessage('Transfer', 'Parsed ${units.length} units for item: $itemCode');

        if (units.isNotEmpty && _validateItemUnitsData(units)) {
          itemUnitsCache[cacheKey] = units;
          return units;
        } else {
          logMessage('Transfer', 'Invalid units data received for: $itemCode');
          throw Exception('بيانات الوحدات المستلمة غير صحيحة');
        }
      } else {
        throw Exception(response['message'] ?? 'فشل في جلب وحدات الصنف من الخادم');
      }
    } catch (e) {
      logMessage('Transfer', 'Exception in getItemUnits: ${e.toString()}');
      _showErrorMessage('فشل في تحميل وحدات الصنف $itemCode: ${e.toString()}', duration: 5);
      return [];
    } finally {
      isLoadingUnits.value = false;
    }
  }

  /// Get unit selection for item code and execute callback
  Future<void> selectUnitForItemCode(String itemCode, Function(ItemUnit) onSelected) async {
    try {
      List<ItemUnit> units = await getItemUnits(itemCode);

      if (units.isEmpty) {
        _showWarningMessage('لا توجد وحدات متوفرة لهذا الصنف', duration: 4);
        return;
      }

      List<ItemUnit> sortedUnits = List.from(units);
      sortedUnits.sort((a, b) => a.baseQty.compareTo(b.baseQty));

      // This will be handled by the UI widget
      _triggerUnitSelectionDialog(sortedUnits, onSelected);
    } catch (e) {
      _showErrorMessage('فشل في عرض الوحدات: $e', duration: 5);
    }
  }

  /// Select unit for existing transfer line
  Future<void> selectUnitForTransferLine(TransferLine line) async {
    if (line.itemCode == null || line.itemCode!.isEmpty) {
      _showErrorMessage('كود الصنف غير متوفر');
      return;
    }

    try {
      String itemCodeToUse = await _getFullItemCodeForUnits(line.itemCode!);

      if (itemCodeToUse.isEmpty) {
        _showErrorMessage('لم يتم العثور على الكود الكامل للصنف');
        return;
      }

      print('Using item code for units: $itemCodeToUse');

      List<ItemUnit> units = await getItemUnits(itemCodeToUse);

      if (units.isEmpty) {
        _showWarningMessage('لا توجد وحدات متوفرة لهذا الصنف في النظام', duration: 4);
        return;
      }

      List<ItemUnit> sortedUnits = List.from(units);
      sortedUnits.sort((a, b) => a.baseQty.compareTo(b.baseQty));

      // This will be handled by the UI widget
      _triggerTransferLineUnitSelectionDialog(line, sortedUnits);
    } catch (e) {
      logMessage('Transfer', 'Error in selectUnitForTransferLine: ${e.toString()}');
      _showErrorMessage('فشل في عرض وحدات الصنف: ${e.toString()}', duration: 5);
    }
  }

  /// Get unit selection for new product - returns selected unit directly
  Future<String?> getSelectedUnitForNewProduct(String itemCode) async {
    if (itemCode.isEmpty) {
      _showErrorMessage('كود الصنف غير متوفر');
      return null;
    }

    try {
      List<ItemUnit> units = await getItemUnits(itemCode);

      if (units.isEmpty) {
        _showWarningMessage('لا توجد وحدات متوفرة لهذا الصنف في النظام', duration: 4);
        return null;
      }

      List<ItemUnit> sortedUnits = List.from(units);
      sortedUnits.sort((a, b) => a.baseQty.compareTo(b.baseQty));

      // This will be handled by the UI widget and return the selected unit
      return await _triggerNewProductUnitSelectionDialog(sortedUnits);
    } catch (e) {
      logMessage('Transfer', 'Error in getSelectedUnitForNewProduct: ${e.toString()}');
      _showErrorMessage('فشل في عرض وحدات الصنف: ${e.toString()}', duration: 5);
      return null;
    }
  }

  // Data Management Methods

  /// Load transfer lines from backend
  // Future<void> loadTransferLines(int selectedTransferId) async {
  //   try {
  //     isLoading.value = true;
  //     statusRequest.value = StatusRequest.loading;
  //     transferId.value = selectedTransferId;

  //     var response = await gettransferdetailsApi.getTransferDetails(selectedTransferId);

  //     if (response['status'] == 'success') {
  //       TransferDetailDto details = TransferDetailDto.fromJson(response['data']);

  //       transferDetails.value = details;
  //       transferLines.value = details.lines;

  //       _resetChangeTracking();
  //       _applyFilter();
  //       statusRequest.value = StatusRequest.success;
  //     } else {
  //       statusRequest.value = StatusRequest.failure;
  //       _showErrorMessage(response['message'] ?? 'فشل في تحميل أصناف التحويل', duration: 3);
  //     }
  //   } catch (e) {
  //     statusRequest.value = StatusRequest.failure;
  //     _showErrorMessage('حدث خطأ غير متوقع: ${e.toString()}', duration: 3);
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  /// Load transfer lines from backend - IMPROVED VERSION
  Future<void> loadTransferLines(int selectedTransferId) async {
    try {
      isLoading.value = true;
      statusRequest.value = StatusRequest.loading;

      // Store current unsaved changes before loading
      List<TransferLine> currentNewLines = List.from(newLines);
      Map<int, TransferLine> currentModifiedLines = Map.from(modifiedLines);
      List<int> currentDeletedLines = List.from(deletedLines);

      print('Loading transfer lines for ID: $selectedTransferId');
      print(
          'Current unsaved changes: ${currentNewLines.length} new, ${currentModifiedLines.length} modified, ${currentDeletedLines.length} deleted');

      transferId.value = selectedTransferId;

      var response = await gettransferdetailsApi.getTransferDetails(selectedTransferId);

      if (response['status'] == 'success') {
        TransferDetailDto details = TransferDetailDto.fromJson(response['data']);

        transferDetails.value = details;
        transferLines.value = details.lines;

        // Restore unsaved changes after loading server data
        if (currentNewLines.isNotEmpty ||
            currentModifiedLines.isNotEmpty ||
            currentDeletedLines.isNotEmpty) {
          print('Restoring unsaved changes after server load...');

          // Restore new lines
          for (TransferLine newLine in currentNewLines) {
            if (!transferLines.any(
                (line) => line.itemCode == newLine.itemCode && line.lineNum == newLine.lineNum)) {
              transferLines.add(newLine);
            }
          }
          newLines.value = currentNewLines;

          // Restore modified lines
          modifiedLines.value = currentModifiedLines;

          // Restore deleted lines
          deletedLines.value = currentDeletedLines;

          hasUnsavedChanges.value = true;
          print(
              'Restored unsaved changes: ${newLines.length} new, ${modifiedLines.length} modified, ${deletedLines.length} deleted');
        } else {
          _resetChangeTracking();
        }

        _applyFilter();
        statusRequest.value = StatusRequest.success;
        print('Successfully loaded ${transferLines.length} transfer lines');
      } else {
        statusRequest.value = StatusRequest.failure;
        _showErrorMessage(response['message'] ?? 'فشل في تحميل أصناف التحويل', duration: 3);
      }
    } catch (e) {
      statusRequest.value = StatusRequest.failure;
      _showErrorMessage('حدث خطأ غير متوقع: ${e.toString()}', duration: 3);
    } finally {
      isLoading.value = false;
    }
  }

  /// Update product unit
  void updateProductUnit(TransferLine line, String newUnitCode, int newBaseQty, int newUomEntry) {
    try {
      int index = transferLines
          .indexWhere((item) => item.lineNum == line.lineNum && item.itemCode == line.itemCode);

      if (index != -1) {
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
        _trackLineChange(updatedLine);
        _applyFilter();

        _showSuccessMessage('تم تغيير الوحدة إلى $newUnitCode', duration: 2);
      }
    } catch (e) {
      logMessage('Transfer', 'Error in updateProductUnit: ${e.toString()}');
      _showErrorMessage('فشل في تحديث الوحدة: ${e.toString()}');
    }
  }

  /// Update product quantity
  void updateProductQuantity(TransferLine line, double newQuantity) {
    if (!_isValidQuantity(newQuantity)) {
      _showErrorMessage('قيمة الكمية غير صالحة');
      return;
    }

    try {
      int index = transferLines
          .indexWhere((item) => item.lineNum == line.lineNum && item.itemCode == line.itemCode);

      if (index != -1) {
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
        _trackLineChange(updatedLine);
        _applyFilter();
      }
    } catch (e) {
      logMessage('Transfer', 'Error in updateProductQuantity: ${e.toString()}');
      _showErrorMessage('فشل في تحديث الكمية: ${e.toString()}');
    }
  }

  Timer? _searchTimer;

  /// Update search filter
  void updateSearch(String query) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = query;
      _applyFilter();
    });
  }

  /// Add new product
  // void addProduct(Map<String, dynamic> productData) {
  //   try {
  //     if (!validateProductData(productData)) {
  //       return;
  //     }

  //     TransferLine newLine = TransferLine(
  //       docEntry: transferId.value,
  //       lineNum: null,
  //       itemCode: productData['itemCode'],
  //       description: productData['description'],
  //       quantity: productData['quantity']?.toDouble(),
  //       price: productData['price']?.toDouble(),
  //       lineTotal: (productData['quantity']?.toDouble() ?? 0.0) *
  //           (productData['price']?.toDouble() ?? 0.0),
  //       uomCode: productData['uomCode'],
  //       uomCode2: productData['uomCode2'],
  //       invQty: productData['invQty']?.toDouble(),
  //       baseQty1: productData['baseQty1']?.toInt(),
  //       ugpEntry: productData['ugpEntry']?.toInt(),
  //       uomEntry: productData['uomEntry']?.toInt(),
  //     );

  //     TransferLine displayLine = TransferLine(
  //       docEntry: newLine.docEntry,
  //       lineNum: _getNextTempLineNumber(),
  //       itemCode: newLine.itemCode,
  //       description: newLine.description,
  //       quantity: newLine.quantity,
  //       price: newLine.price,
  //       lineTotal: newLine.lineTotal,
  //       uomCode: newLine.uomCode,
  //       uomCode2: newLine.uomCode2,
  //       invQty: newLine.invQty,
  //       baseQty1: newLine.baseQty1,
  //       ugpEntry: newLine.ugpEntry,
  //       uomEntry: newLine.uomEntry,
  //     );

  //     transferLines.add(displayLine);
  //     newLines.add(newLine);
  //     hasUnsavedChanges.value = true;

  //     _applyFilter();

  //     _showSuccessMessage('تم إضافة المنتج بنجاح (يتطلب حفظ)');
  //   } catch (e) {
  //     logMessage('Transfer', 'Error in addProduct: ${e.toString()}');
  //     _showErrorMessage('فشل في إضافة المنتج: ${e.toString()}');
  //   }
  // }

  void addProduct(Map<String, dynamic> productData, {bool saveImmediately = false}) {
    try {
      // التحقق من وجود transferId
      if (transferId.value == null) {
        _showErrorMessage('يجب تحديد التحويل أولاً');
        return;
      }

      if (!validateProductData(productData)) {
        return;
      }

      print('=== إضافة منتج جديد ===');
      print('Transfer ID: ${transferId.value}');
      print('Product Data: $productData');
      print('Save immediately: $saveImmediately');

      TransferLine newLine = TransferLine(
        docEntry: transferId.value,
        lineNum: null,
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

      TransferLine displayLine = TransferLine(
        docEntry: newLine.docEntry,
        lineNum: _getNextTempLineNumber(),
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

      // إضافة السطر إلى القائمة
      transferLines.add(displayLine);
      newLines.add(newLine);
      hasUnsavedChanges.value = true;

      // تطبيق الفلتر وإعادة التحديث
      _applyFilter();
      update();

      print('تم إضافة المنتج. إجمالي الأسطر: ${transferLines.length}');
      print('أسطر جديدة: ${newLines.length}');

      if (saveImmediately) {
        _showSuccessMessage('تم إضافة المنتج، جاري الحفظ...');
        // Save immediately to server
        Future.delayed(Duration(milliseconds: 500), () {
          saveAllChangesToServer();
        });
      } else {
        _showSuccessMessage('تم إضافة المنتج بنجاح (يتطلب حفظ)');
      }
    } catch (e) {
      logMessage('Transfer', 'Error in addProduct: ${e.toString()}');
      _showErrorMessage('فشل في إضافة المنتج: ${e.toString()}');
    }
  }

  /// Force manual reload only when explicitly requested
  Future<void> forceReloadFromServer() async {
    if (transferId.value != null) {
      print('Force reloading data from server...');
      await loadTransferLines(transferId.value!);
    }
  }

  /// Update existing product
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
        _trackLineChange(updatedLine);
        _applyFilter();

        _showSuccessMessage('تم تعديل المنتج بنجاح');
      }
    } catch (e) {
      logMessage('Transfer', 'Error in updateProduct: ${e.toString()}');
      _showErrorMessage('فشل في تعديل المنتج: ${e.toString()}');
    }
  }

  /// Delete product
  void deleteProduct(TransferLine line) {
    try {
      bool isNewLine = line.lineNum == null || line.lineNum! < 0;
      bool isExistingLine = line.lineNum != null && line.lineNum! > 0;

      if (isNewLine) {
        transferLines
            .removeWhere((item) => item.lineNum == line.lineNum && item.itemCode == line.itemCode);
        newLines.removeWhere(
            (newLine) => newLine.itemCode == line.itemCode && newLine.lineNum == line.lineNum);
        _updateUnsavedChangesStatus();
        _applyFilter();
        _showSuccessMessage('تم حذف الصنف الجديد محلياً');
      } else if (isExistingLine) {
        deletedLines.add(line.lineNum!);
        modifiedLines.remove(line.lineNum!);
        _markLineAsDeleted(line);
        hasUnsavedChanges.value = true;
        _applyFilter();
        _showWarningMessage('تم تحديد السطر للحذف (يتطلب حفظ)');
      } else {
        _showErrorMessage('لا يمكن تحديد نوع السطر للحذف');
      }
    } catch (e) {
      logMessage('Transfer', 'Error in deleteProduct: ${e.toString()}');
      _showErrorMessage('فشل في حذف المنتج: ${e.toString()}');
    }
  }

  /// Duplicate product
  void duplicateProduct(TransferLine line) {
    try {
      TransferLine duplicatedLine = TransferLine(
        docEntry: line.docEntry,
        lineNum: null,
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
      newLines.add(duplicatedLine);
      hasUnsavedChanges.value = true;

      _applyFilter();

      _showSuccessMessage('تم نسخ المنتج بنجاح (يتطلب حفظ)');
    } catch (e) {
      logMessage('Transfer', 'Error in duplicateProduct: ${e.toString()}');
      _showErrorMessage('فشل في نسخ المنتج: ${e.toString()}');
    }
  }

  /// Save all changes to server - FIXED VERSION
  Future<void> saveAllChangesToServer() async {
    if (!hasUnsavedChanges.value) {
      _showInfoMessage('لا توجد تغييرات للحفظ');
      return;
    }

    try {
      isSaving.value = true;
      int successCount = 0;
      int errorCount = 0;
      List<String> errorMessages = [];

      // Save new lines
      List<TransferLine> newLinesToSave = List.from(newLines);
      for (TransferLine newLine in newLinesToSave) {
        var result = await _saveNewLine(newLine);
        if (result['success'] == true) {
          successCount++;
          newLines.removeWhere(
              (line) => line.itemCode == newLine.itemCode && line.lineNum == newLine.lineNum);
        } else {
          errorCount++;
          errorMessages.add('فشل حفظ سطر جديد: ${result['error']}');
        }
      }

      // Save modified lines
      List<TransferLine> modifiedLinesToSave = modifiedLines.values.toList();
      for (TransferLine modifiedLine in modifiedLinesToSave) {
        var result = await _saveModifiedLine(modifiedLine);
        if (result['success'] == true) {
          successCount++;
          modifiedLines.remove(modifiedLine.lineNum);
        } else {
          errorCount++;
          errorMessages.add('فشل تحديث السطر ${modifiedLine.lineNum}: ${result['error']}');
        }
      }

      // Delete lines from database
      List<int> linesToDelete = List.from(deletedLines);
      for (int deletedLineNum in linesToDelete) {
        var result = await _deleteLineFromServer(deletedLineNum);
        if (result['success'] == true) {
          successCount++;
          deletedLines.remove(deletedLineNum);
          transferLines.removeWhere((line) => line.lineNum == deletedLineNum);
        } else {
          errorCount++;
          errorMessages.add('فشل حذف السطر $deletedLineNum: ${result['error']}');
        }
      }

      _updateUnsavedChangesStatus();
      _applyFilter();

      if (errorCount == 0) {
        _showSuccessMessage('تم حفظ جميع التغييرات بنجاح ($successCount عملية)', duration: 3);

        // FIXED: Only reload if we have a valid transfer ID AND all changes were saved successfully
        if (transferId.value != null &&
            newLines.isEmpty &&
            modifiedLines.isEmpty &&
            deletedLines.isEmpty) {
          print('Reloading data from server after successful save...');
          await loadTransferLines(transferId.value!);
        } else {
          print('Skipping reload - unsaved changes still exist');
        }
      } else {
        _triggerPartialSaveDialog(successCount, errorCount, errorMessages);
      }
    } catch (e) {
      logMessage('Transfer', 'Error in saveAllChangesToServer: ${e.toString()}');
      _showErrorMessage('فشل في حفظ التغييرات: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }

  // Utility Methods

  /// Validate product data
  bool validateProductData(Map<String, dynamic> productData) {
    if (productData['itemCode'] == null || productData['itemCode'].toString().trim().isEmpty) {
      _showErrorMessage('كود المنتج مطلوب');
      return false;
    }

    if (productData['quantity'] == null || productData['quantity'] <= 0) {
      _showErrorMessage('الكمية يجب أن تكون أكبر من صفر');
      return false;
    }

    if (productData['price'] == null || productData['price'] < 0) {
      _showErrorMessage('السعر يجب أن يكون أكبر من أو يساوي صفر');
      return false;
    }

    return true;
  }

  /// Get product statistics
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

  /// Clear search
  void clearSearch() {
    searchController.clear();
    updateSearch('');
  }

  /// Reset all data
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

  /// Clear units cache
  void clearUnitsCache() {
    itemUnitsCache.clear();
  }

  /// Clear specific item units cache
  void clearItemUnitsCache(String itemCode) {
    itemUnitsCache.remove(itemCode);
  }

  // Helper Properties
  int get totalProductsCount => transferLines.length;
  int get filteredProductsCount => filteredLines.length;
  bool get hasActiveSearch => searchQuery.value.isNotEmpty;
  bool get hasData => transferLines.isNotEmpty;
  bool get hasSelectedTransfer => transferId.value != null;
  int get unsavedChangesCount => newLines.length + modifiedLines.length + deletedLines.length;
  bool get canSave => hasUnsavedChanges.value && !isSaving.value;

  // Helper Methods for UomModel conversion
  List<ItemUnit> convertUomModelsToItemUnits(List<UomModel> uomModels) {
    return uomModels.map((uom) => ItemUnit.fromUomModel(uom)).toList();
  }

  // Private Helper Methods

  bool _isValidQuantity(double? quantity) {
    if (quantity == null) return false;
    if (quantity < 0) return false;
    if (quantity > 999999) return false;
    return true;
  }

  void _resetChangeTracking() {
    hasUnsavedChanges.value = false;
    modifiedLines.clear();
    newLines.clear();
    deletedLines.clear();
  }

  // void _applyFilter() {
  //   if (transferLines.isEmpty) {
  //     filteredLines.clear();
  //     return;
  //   }

  //   if (searchQuery.value.isEmpty) {
  //     filteredLines.value = List.from(transferLines);
  //   } else {
  //     String query = searchQuery.value.toLowerCase();
  //     filteredLines.value = transferLines.where((line) {
  //       bool matchesItemCode = line.itemCode?.toLowerCase().contains(query) ?? false;
  //       bool matchesDescription = line.description?.toLowerCase().contains(query) ?? false;
  //       return matchesItemCode || matchesDescription;
  //     }).toList();
  //   }
  // }

  void _applyFilter() {
    print('=== تطبيق الفلتر ===');
    print('إجمالي الأسطر: ${transferLines.length}');
    print('البحث: "${searchQuery.value}"');

    if (transferLines.isEmpty) {
      filteredLines.clear();
      print('لا توجد أسطر للفلترة');
      return;
    }

    if (searchQuery.value.isEmpty) {
      filteredLines.value = List.from(transferLines);
      print('لا يوجد بحث، عرض جميع الأسطر: ${filteredLines.length}');
    } else {
      String query = searchQuery.value.toLowerCase();
      filteredLines.value = transferLines.where((line) {
        bool matchesItemCode = line.itemCode?.toLowerCase().contains(query) ?? false;
        bool matchesDescription = line.description?.toLowerCase().contains(query) ?? false;
        return matchesItemCode || matchesDescription;
      }).toList();
      print('بعد الفلترة: ${filteredLines.length} سطر');
    }

    // إشعار الـ UI بالتحديث
    update();
  }

/////////////////////////////////////////////////////////////// Check if product already exists
  bool isProductAlreadyExists(String itemCode) {
    return transferLines.any((line) =>
        line.itemCode?.toLowerCase() == itemCode.toLowerCase() &&
        !deletedLines.contains(line.lineNum));
  }

  void addProductWithDuplicateCheck(Map<String, dynamic> productData) {
    String itemCode = productData['itemCode'] ?? '';

    if (isProductAlreadyExists(itemCode)) {
      Get.dialog(
        AlertDialog(
          title: const Text('تأكيد الإضافة'),
          content: Text('المنتج "$itemCode" موجود مسبقاً. هل تريد إضافته مرة أخرى؟'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                addProduct(productData);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      );
    } else {
      addProduct(productData);
    }
  }

  void _trackLineChange(TransferLine line) {
    if (line.lineNum != null && line.lineNum! > 0) {
      modifiedLines[line.lineNum!] = line;
      hasUnsavedChanges.value = true;
    }
  }

  void _updateUnsavedChangesStatus() {
    hasUnsavedChanges.value =
        newLines.isNotEmpty || modifiedLines.isNotEmpty || deletedLines.isNotEmpty;
  }

  void _markLineAsDeleted(TransferLine line) {
    // UI components will check deletedLines.contains(line.lineNum) to show deleted state
  }

  int _getNextTempLineNumber() {
    int maxLineNum = 0;
    for (TransferLine line in transferLines) {
      if (line.lineNum != null && line.lineNum! > maxLineNum) {
        maxLineNum = line.lineNum!;
      }
    }
    return -(maxLineNum + 1); // Use negative numbers for new lines
  }

  bool _validateItemUnitsData(List<ItemUnit> units) {
    for (ItemUnit unit in units) {
      if (unit.uomCode.isEmpty || unit.uomName.isEmpty || unit.baseQty <= 0 || unit.uomEntry <= 0) {
        return false;
      }
    }
    return true;
  }

  Future<String> _getFullItemCodeForUnits(String itemCode) async {
    if (itemCode.toUpperCase().contains('INV')) {
      return itemCode;
    }

    try {
      stockController.itemCodeController.text = itemCode;
      await stockController.searchStock();

      if (stockController.stockItems.isNotEmpty) {
        String fullCode = stockController.stockItems.first.itemCode;
        logMessage('Transfer', 'Found full code from stock: $itemCode -> $fullCode');
        return fullCode;
      }

      String withPrefix = 'INV$itemCode';
      stockController.itemCodeController.text = withPrefix;
      await stockController.searchStock();

      if (stockController.stockItems.isNotEmpty) {
        String fullCode = stockController.stockItems.first.itemCode;
        logMessage('Transfer', 'Found full code with prefix: $itemCode -> $fullCode');
        return fullCode;
      }

      String paddedCode = itemCode.padLeft(5, '0');
      String fullCodeAttempt = 'INV$paddedCode';
      stockController.itemCodeController.text = fullCodeAttempt;
      await stockController.searchStock();

      if (stockController.stockItems.isNotEmpty) {
        String fullCode = stockController.stockItems.first.itemCode;
        logMessage('Transfer', 'Found full code with padding: $itemCode -> $fullCode');
        return fullCode;
      }

      logMessage('Transfer', 'Could not find full code for: $itemCode');
      return '';
    } catch (e) {
      logMessage('Transfer', 'Error getting full item code: ${e.toString()}');
      return '';
    }
  }

  // Server Communication Methods

  Future<Map<String, dynamic>> _saveNewLine(TransferLine line) async {
    try {
      var response = await upsertTransferApi.upsertTransferLine(
        docEntry: line.docEntry ?? transferId.value!,
        lineNum: null,
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
        int? newLineNum = response['data']?['lineNum'];
        _updateLineNumInList(line, newLineNum!);
        return {'success': true, 'lineNum': newLineNum, 'message': 'تم حفظ السطر الجديد بنجاح'};
      } else {
        return {'success': false, 'error': response['message'] ?? 'فشل في حفظ السطر الجديد'};
      }
    } catch (e) {
      logMessage('Transfer', 'Exception in _saveNewLine: ${e.toString()}');
      return {'success': false, 'error': 'خطأ في حفظ السطر الجديد: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> _saveModifiedLine(TransferLine line) async {
    try {
      var response = await upsertTransferApi.upsertTransferLine(
        docEntry: line.docEntry!,
        lineNum: line.lineNum!,
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

  void _updateLineNumInList(TransferLine oldLine, int newLineNum) {
    int index = transferLines.indexWhere(
        (line) => line.itemCode == oldLine.itemCode && line.lineNum != null && line.lineNum! < 0);

    if (index != -1) {
      TransferLine updatedLine = TransferLine(
        docEntry: transferLines[index].docEntry,
        lineNum: newLineNum,
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

  // Message Display Methods (to be handled by UI)

  void _showSuccessMessage(String message, {int duration = 2}) {
    Get.snackbar(
      'نجح',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: duration),
    );
  }

  void _showErrorMessage(String message, {int duration = 3}) {
    Get.snackbar(
      'خطأ',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: duration),
    );
  }

  void _showWarningMessage(String message, {int duration = 3}) {
    Get.snackbar(
      'تنبيه',
      message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: Duration(seconds: duration),
    );
  }

  void _showInfoMessage(String message, {int duration = 2}) {
    Get.snackbar(
      'تنبيه',
      message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: duration),
    );
  }

  // UI Trigger Methods (these will be implemented by UI widgets)

  void _triggerUnitSelectionDialog(List<ItemUnit> units, Function(ItemUnit) onSelected) {
    // This method will be called by UI components
    // UI implementation should handle the dialog display
  }

  void _triggerTransferLineUnitSelectionDialog(TransferLine line, List<ItemUnit> units) {
    // This method will be called by UI components
    // UI implementation should handle the dialog display and call updateProductUnit
  }

  Future<String?> _triggerNewProductUnitSelectionDialog(List<ItemUnit> units) async {
    // This method will be called by UI components
    // UI implementation should handle the dialog display and return selected unit
    return null; // Placeholder - will be implemented in UI
  }

  void _triggerPartialSaveDialog(int successCount, int errorCount, List<String> errorMessages) {
    // This method will be called by UI components
    // UI implementation should handle the dialog display
  }

  // Logging utility
  void logMessage(String tag, String message) {
    print('[$tag] $message');
  }
}




// import 'dart:async';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/controllers/stock_controller.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_check/model/stock_model.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/services/get_transfer_detailsApi.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/services/upsert_transfer_api.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/model/uom_model.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/services/get_unit_api.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:auth_app/functions/status_request.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/models/details_model.dart';
// import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/services/transfer_api.dart';
// import 'package:auth_app/services/api/post_get_api.dart';

// class ProductManagementController extends GetxController {
//   // Status States
//   var statusRequest = StatusRequest.none.obs;
//   var isLoading = false.obs;
//   var isSaving = false.obs;
//   var isLoadingUnits = false.obs;

//   // Data
//   var transferId = Rxn<int>();
//   var transferDetails = Rxn<TransferDetailDto>();
//   var transferLines = <TransferLine>[].obs;
//   var filteredLines = <TransferLine>[].obs;

//   // إضافة خريطة لتخزين وحدات كل صنف
//   var itemUnitsCache = <String, List<ItemUnit>>{}.obs;

//   // Search
//   var searchQuery = ''.obs;
//   late TextEditingController searchController;

//   // API
//   late TransferApi transferApi;
//   late UpsertTransferApi upsertTransferApi;
//   late GetTransferDetailsApi gettransferdetailsApi;
//   late GetUnitApi getUnitApi;

//   // Track changes
//   var hasUnsavedChanges = false.obs;
//   var modifiedLines = <int, TransferLine>{}.obs;
//   var deletedLines = <int>[].obs;
//   var newLines = <TransferLine>[].obs;

//   // إضافة مرجع لـ StockController للاستفادة من وظائف البحث
//   late StockController stockController;

//   // المتغيرات الحالية...
//   final pulledItem = Rx<StockModel?>(null);
//   final searchResults = <StockModel>[].obs;
//   @override
//   void onInit() {
//     super.onInit();
//     searchController = TextEditingController();
//     transferApi = TransferApi(PostGetPage());
//     upsertTransferApi = UpsertTransferApi(PostGetPage());
//     getUnitApi = GetUnitApi(PostGetPage());
//     gettransferdetailsApi = GetTransferDetailsApi(PostGetPage());

//     // تهيئة StockController
//     stockController = Get.put(StockController());
//   }

//   @override
//   void onClose() {
//     searchController.dispose();
//     _searchTimer?.cancel();
//     super.onClose();
//   }

//   // إضافة دالة سحب بيانات الصنف للاستخدام في أجزاء أخرى من التطبيق
//   Future<Map<String, dynamic>?> pullItemData(String itemCode) async {
//     if (itemCode.trim().isEmpty) {
//       Get.snackbar(
//         'خطأ',
//         'كود الصنف مطلوب',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return null;
//     }

//     try {
//       // استخدام StockController للبحث
//       stockController.itemCodeController.text = itemCode.trim();
//       await stockController.searchStock();

//       if (stockController.stockItems.isNotEmpty) {
//         var stockItem = stockController.stockItems.first;

//         return {
//           'itemCode': itemCode.trim(),
//           'description': stockItem.itemName,
//           'quantity': stockItem.totalOnHand > 0 ? stockItem.totalOnHand : 1.0,
//           'price': stockItem.avgPrice > 0 ? stockItem.avgPrice : 0.0,
//           'uomCode': stockItem.uomCode ?? 'حبة',
//           'baseQty1': 1,
//           'uomEntry': 1,
//           'success': true,
//           'message': 'تم سحب بيانات الصنف بنجاح',
//         };
//       } else {
//         return {
//           'success': false,
//           'message': 'لم يتم العثور على بيانات لهذا الصنف',
//         };
//       }
//     } catch (e) {
//       logMessage('Transfer', 'Error in pullItemData: ${e.toString()}');
//       return {
//         'success': false,
//         'message': 'فشل في سحب بيانات الصنف: ${e.toString()}',
//       };
//     }
//   }

//   // دالة محسنة لإضافة منتج مع إمكانية سحب البيانات
//   Future<void> addProductWithPull(
//     String itemCode, {
//     double? quantity,
//     double? price,
//     String? description,
//     String? uomCode,
//     bool pullData = true,
//   }) async {
//     try {
//       Map<String, dynamic> productData = {};

//       if (pullData) {
//         // سحب البيانات من النظام
//         var pulledData = await pullItemData(itemCode);

//         if (pulledData != null && pulledData['success'] == true) {
//           productData = {
//             'itemCode': pulledData['itemCode'],
//             'description': description ?? pulledData['description'],
//             'quantity': quantity ?? pulledData['quantity'],
//             'price': price ?? pulledData['price'],
//             'uomCode': uomCode ?? pulledData['uomCode'],
//             'baseQty1': pulledData['baseQty1'],
//             'uomEntry': pulledData['uomEntry'],
//           };

//           Get.snackbar(
//             'نجح',
//             pulledData['message'],
//             backgroundColor: Colors.green,
//             colorText: Colors.white,
//           );
//         } else {
//           // في حالة فشل السحب، استخدم البيانات المرسلة أو القيم الافتراضية
//           productData = {
//             'itemCode': itemCode.trim(),
//             'description': description ?? '',
//             'quantity': quantity ?? 1.0,
//             'price': price ?? 0.0,
//             'uomCode': uomCode ?? 'حبة',
//             'baseQty1': 1,
//             'uomEntry': 1,
//           };

//           Get.snackbar(
//             'تنبيه',
//             pulledData?['message'] ?? 'لم يتم العثور على بيانات الصنف، تم استخدام القيم الافتراضية',
//             backgroundColor: Colors.orange,
//             colorText: Colors.white,
//           );
//         }
//       } else {
//         // استخدام البيانات المرسلة مباشرة
//         productData = {
//           'itemCode': itemCode.trim(),
//           'description': description ?? '',
//           'quantity': quantity ?? 1.0,
//           'price': price ?? 0.0,
//           'uomCode': uomCode ?? 'حبة',
//           'baseQty1': 1,
//           'uomEntry': 1,
//         };
//       }

//       // إضافة المنتج
//       addProduct(productData);
//     } catch (e) {
//       logMessage('Transfer', 'Error in addProductWithPull: ${e.toString()}');
//       Get.snackbar(
//         'خطأ',
//         'فشل في إضافة المنتج: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   Future<List<ItemUnit>> getItemUnits(String itemCode) async {
//     try {
//       // التحقق من وجود الوحدات في الذاكرة المؤقتة
//       String cacheKey = itemCode.trim().toUpperCase();
//       if (itemUnitsCache.containsKey(cacheKey)) {
//         logMessage('Transfer', 'Units loaded from cache for: $itemCode');
//         return itemUnitsCache[cacheKey]!;
//       }

//       // جلب الوحدات من الخادم
//       logMessage('Transfer', 'Loading units from server for: $itemCode');
//       isLoadingUnits.value = true;

//       var response = await getUnitApi.getItemUnits(itemCode.trim());
//       logMessage('Transfer', 'Units API response: ${response.toString()}');

//       if (response['status'] == 'success' && response['data'] != null) {
//         List<ItemUnit> units = [];
//         var unitsData = response['data'];

//         // تحويل البيانات إلى قائمة ItemUnit
//         if (unitsData is List) {
//           units = unitsData.map((unitJson) {
//             // تحويل من استجابة API إلى UomModel ثم إلى ItemUnit
//             UomModel uomModel = UomModel.fromJson(unitJson as Map<String, dynamic>);
//             return ItemUnit.fromUomModel(uomModel);
//           }).toList();
//         }

//         logMessage('Transfer', 'Parsed ${units.length} units for item: $itemCode');

//         // التحقق من صحة البيانات المستلمة
//         if (units.isNotEmpty && _validateItemUnitsData(units)) {
//           // حفظ في الذاكرة المؤقتة
//           itemUnitsCache[cacheKey] = units;
//           return units;
//         } else {
//           logMessage('Transfer', 'Invalid units data received for: $itemCode');
//           throw Exception('بيانات الوحدات المستلمة غير صحيحة');
//         }
//       } else {
//         throw Exception(response['message'] ?? 'فشل في جلب وحدات الصنف من الخادم');
//       }
//     } catch (e) {
//       logMessage('Transfer', 'Exception in getItemUnits: ${e.toString()}');

//       // عرض رسالة خطأ للمستخدم
//       Get.snackbar(
//         'خطأ في تحميل الوحدات',
//         'فشل في تحميل وحدات الصنف $itemCode: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 5),
//       );

//       // إرجاع قائمة فارغة
//       return [];
//     } finally {
//       isLoadingUnits.value = false;
//     }
//   }

//   // دالة مساعدة لتحويل UomModel إلى ItemUnit للتوافق
//   List<ItemUnit> convertUomModelsToItemUnits(List<UomModel> uomModels) {
//     return uomModels.map((uom) => ItemUnit.fromUomModel(uom)).toList();
//   }

//   bool _validateItemUnitsData(List<ItemUnit> units) {
//     for (ItemUnit unit in units) {
//       // التحقق من وجود البيانات الأساسية
//       if (unit.uomCode.isEmpty || unit.uomName.isEmpty || unit.baseQty <= 0 || unit.uomEntry <= 0) {
//         return false;
//       }
//     }
//     return true;
//   }

//   Future<void> showUnitSelectionDialogFromCode(
//     String itemCode,
//     Function(ItemUnit) onSelected,
//   ) async {
//     try {
//       // جلب الوحدات من السيرفر
//       List<ItemUnit> units = await getItemUnits(itemCode);

//       if (units.isEmpty) {
//         Get.snackbar(
//           'تنبيه',
//           'لا توجد وحدات متوفرة لهذا الصنف',
//           backgroundColor: Colors.orange,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 4),
//         );
//         return;
//       }

//       // ترتيب الوحدات
//       List<ItemUnit> sortedUnits = List.from(units);
//       sortedUnits.sort((a, b) => a.baseQty.compareTo(b.baseQty));

//       Get.dialog(
//         Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           elevation: 0,
//           backgroundColor: Colors.transparent,
//           insetPadding: const EdgeInsets.all(16),
//           child: Container(
//             constraints: const BoxConstraints(maxHeight: 400),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: ListView.builder(
//               itemCount: sortedUnits.length,
//               itemBuilder: (context, index) {
//                 ItemUnit unit = sortedUnits[index];
//                 return ListTile(
//                   title: Text(unit.uomName),
//                   subtitle: Text("الكمية: ${unit.baseQty} | Entry: ${unit.uomEntry}"),
//                   onTap: () {
//                     Get.back();
//                     onSelected(unit); // ✅ نرجع الوحدة المختارة
//                   },
//                 );
//               },
//             ),
//           ),
//         ),
//       );
//     } catch (e) {
//       Get.snackbar(
//         'خطأ',
//         'فشل في عرض الوحدات: $e',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 5),
//       );
//     }
//   }

//   /////////////////////////////////////////////////// عرض نافذة اختيار الوحدة

// // ===== تحديث دالة showUnitSelectionDialog في ProductManagementController =====

//   Future<void> showUnitSelectionDialog(TransferLine line) async {
//     if (line.itemCode == null || line.itemCode!.isEmpty) {
//       Get.snackbar(
//         'خطأ',
//         'كود الصنف غير متوفر',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     try {
//       // ✅ الحل: التأكد من استخدام الكود الكامل
//       String itemCodeToUse = await _getFullItemCodeForUnits(line.itemCode!);

//       if (itemCodeToUse.isEmpty) {
//         Get.snackbar(
//           'خطأ',
//           'لم يتم العثور على الكود الكامل للصنف',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//         return;
//       }

//       print('Using item code for units: $itemCodeToUse'); // للتتبع

//       // جلب وحدات الصنف من الخادم باستخدام الكود الكامل
//       List<ItemUnit> units = await getItemUnits(itemCodeToUse);

//       if (units.isEmpty) {
//         Get.snackbar(
//           'تنبيه',
//           'لا توجد وحدات متوفرة لهذا الصنف في النظام',
//           backgroundColor: Colors.orange,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 4),
//         );
//         return;
//       }

//       // ترتيب الوحدات حسب الكمية الأساسية
//       List<ItemUnit> sortedUnits = List.from(units);
//       sortedUnits.sort((a, b) => a.baseQty.compareTo(b.baseQty));

//       Get.dialog(
//         Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           elevation: 0,
//           backgroundColor: Colors.transparent,
//           insetPadding: const EdgeInsets.all(16),
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               double dialogWidth = constraints.maxWidth > 600 ? 600 : constraints.maxWidth - 32;
//               double maxHeight = constraints.maxHeight * 0.8;

//               return Container(
//                 width: dialogWidth,
//                 constraints: BoxConstraints(
//                   maxHeight: maxHeight,
//                   minHeight: 300,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       spreadRadius: 0,
//                       blurRadius: 20,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // رأس النافذة
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [Colors.blue[600]!, Colors.blue[700]!],
//                         ),
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(16),
//                           topRight: Radius.circular(16),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: const Icon(
//                               Icons.straighten,
//                               color: Colors.white,
//                               size: 20,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'اختيار الوحدة',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 2),
//                                 Text(
//                                   line.itemCode ?? '',
//                                   style: TextStyle(
//                                     color: Colors.white.withOpacity(0.9),
//                                     fontSize: 12,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           IconButton(
//                             onPressed: () => Get.back(),
//                             icon: const Icon(
//                               Icons.close,
//                               color: Colors.white,
//                               size: 20,
//                             ),
//                             constraints: const BoxConstraints(),
//                             padding: const EdgeInsets.all(4),
//                           ),
//                         ],
//                       ),
//                     ),

//                     // قائمة الوحدات
//                     Expanded(
//                       child: Container(
//                         margin: const EdgeInsets.all(12),
//                         child: ListView.builder(
//                           itemCount: sortedUnits.length,
//                           itemBuilder: (context, index) {
//                             ItemUnit unit = sortedUnits[index];
//                             bool isSelected = unit.uomName == line.uomCode;

//                             return Container(
//                               margin: const EdgeInsets.only(bottom: 8),
//                               decoration: BoxDecoration(
//                                 color: isSelected ? Colors.blue[50] : Colors.white,
//                                 border: Border.all(
//                                   color: isSelected ? Colors.blue[300]! : Colors.grey[300]!,
//                                   width: isSelected ? 2 : 1,
//                                 ),
//                                 borderRadius: BorderRadius.circular(12),
//                                 boxShadow: [
//                                   if (isSelected)
//                                     BoxShadow(
//                                       color: Colors.blue.withOpacity(0.1),
//                                       spreadRadius: 1,
//                                       blurRadius: 4,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                 ],
//                               ),
//                               child: InkWell(
//                                 onTap: () {
//                                   Get.back();
//                                   updateProductUnit(
//                                     line,
//                                     unit.uomName,
//                                     unit.baseQty,
//                                     unit.uomEntry,
//                                   );
//                                 },
//                                 borderRadius: BorderRadius.circular(12),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(16),
//                                   child: Row(
//                                     children: [
//                                       // رقم تسلسلي
//                                       Container(
//                                         width: 32,
//                                         height: 32,
//                                         decoration: BoxDecoration(
//                                           color: isSelected ? Colors.blue[600] : Colors.grey[400],
//                                           borderRadius: BorderRadius.circular(16),
//                                         ),
//                                         child: Center(
//                                           child: Text(
//                                             '${index + 1}',
//                                             style: const TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(width: 16),
//                                       // معلومات الوحدة
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               unit.uomName,
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.bold,
//                                                 color:
//                                                     isSelected ? Colors.blue[700] : Colors.black87,
//                                               ),
//                                             ),
//                                             const SizedBox(height: 4),
//                                             Wrap(
//                                               spacing: 12,
//                                               runSpacing: 4,
//                                               children: [
//                                                 _buildInfoChip(
//                                                   'Entry: ${unit.uomEntry}',
//                                                   Icons.numbers,
//                                                   Colors.grey[600]!,
//                                                 ),
//                                                 _buildInfoChip(
//                                                   'الكمية: ${unit.baseQty}',
//                                                   Icons.inventory,
//                                                   Colors.green[600]!,
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       // زر الحالة
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 12,
//                                           vertical: 6,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           color: isSelected ? Colors.blue[600] : Colors.green[500],
//                                           borderRadius: BorderRadius.circular(20),
//                                         ),
//                                         child: Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             Icon(
//                                               isSelected
//                                                   ? Icons.check_circle
//                                                   : Icons.radio_button_unchecked,
//                                               color: Colors.white,
//                                               size: 16,
//                                             ),
//                                             const SizedBox(width: 4),
//                                             Text(
//                                               isSelected ? 'محدد' : 'اختيار',
//                                               style: const TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 12,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),

//                     // تذييل النافذة
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[50],
//                         borderRadius: const BorderRadius.only(
//                           bottomLeft: Radius.circular(16),
//                           bottomRight: Radius.circular(16),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.info_outline,
//                                 color: Colors.blue[600],
//                                 size: 16,
//                               ),
//                               const SizedBox(width: 6),
//                               Text(
//                                 'انقر على الوحدة لاختيارها',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.blue[100],
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               '${sortedUnits.length} وحدة',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.blue[700],
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       );
//     } catch (e) {
//       logMessage('Transfer', 'Error in showUnitSelectionDialog: ${e.toString()}');
//       Get.snackbar(
//         'خطأ',
//         'فشل في عرض وحدات الصنف: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 5),
//       );
//     }
//   }

// // ===== إضافة دالة مساعدة جديدة =====

//   Future<String> _getFullItemCodeForUnits(String itemCode) async {
//     // إذا كان الكود يحتوي على INV بالفعل، استخدمه كما هو
//     if (itemCode.toUpperCase().contains('INV')) {
//       return itemCode;
//     }

//     try {
//       // محاولة البحث في بيانات المخزون للحصول على الكود الكامل
//       stockController.itemCodeController.text = itemCode;
//       await stockController.searchStock();

//       if (stockController.stockItems.isNotEmpty) {
//         String fullCode = stockController.stockItems.first.itemCode;
//         logMessage('Transfer', 'Found full code from stock: $itemCode -> $fullCode');
//         return fullCode;
//       }

//       // إذا فشل البحث، جرب إضافة INV prefix
//       String withPrefix = 'INV$itemCode';
//       stockController.itemCodeController.text = withPrefix;
//       await stockController.searchStock();

//       if (stockController.stockItems.isNotEmpty) {
//         String fullCode = stockController.stockItems.first.itemCode;
//         logMessage('Transfer', 'Found full code with prefix: $itemCode -> $fullCode');
//         return fullCode;
//       }

//       // جرب إضافة أصفار
//       String paddedCode = itemCode.padLeft(5, '0');
//       String fullCodeAttempt = 'INV$paddedCode';
//       stockController.itemCodeController.text = fullCodeAttempt;
//       await stockController.searchStock();

//       if (stockController.stockItems.isNotEmpty) {
//         String fullCode = stockController.stockItems.first.itemCode;
//         logMessage('Transfer', 'Found full code with padding: $itemCode -> $fullCode');
//         return fullCode;
//       }

//       logMessage('Transfer', 'Could not find full code for: $itemCode');
//       return '';
//     } catch (e) {
//       logMessage('Transfer', 'Error getting full item code: ${e.toString()}');
//       return '';
//     }
//   }

//   // ===== إضافة هذه الدالة إلى ProductManagementController =====

//   /// دالة جديدة لاختيار الوحدة للمنتجات الجديدة - ترجع الوحدة المختارة مباشرة
//   Future<String?> showUnitSelectionForNewProduct(String itemCode) async {
//     if (itemCode.isEmpty) {
//       Get.snackbar(
//         'خطأ',
//         'كود الصنف غير متوفر',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return null;
//     }

//     try {
//       // جلب وحدات الصنف من الخادم
//       List<ItemUnit> units = await getItemUnits(itemCode);

//       if (units.isEmpty) {
//         Get.snackbar(
//           'تنبيه',
//           'لا توجد وحدات متوفرة لهذا الصنف في النظام',
//           backgroundColor: Colors.orange,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 4),
//         );
//         return null;
//       }

//       // ترتيب الوحدات حسب الكمية الأساسية
//       List<ItemUnit> sortedUnits = List.from(units);
//       sortedUnits.sort((a, b) => a.baseQty.compareTo(b.baseQty));

//       // متغير لحفظ الوحدة المختارة
//       String? selectedUnit;

//       await Get.dialog(
//         Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           elevation: 0,
//           backgroundColor: Colors.transparent,
//           insetPadding: const EdgeInsets.all(16),
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               double dialogWidth = constraints.maxWidth > 600 ? 600 : constraints.maxWidth - 32;
//               double maxHeight = constraints.maxHeight * 0.8;

//               return Container(
//                 width: dialogWidth,
//                 constraints: BoxConstraints(
//                   maxHeight: maxHeight,
//                   minHeight: 300,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       spreadRadius: 0,
//                       blurRadius: 20,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // رأس النافذة
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [Colors.blue[600]!, Colors.blue[700]!],
//                         ),
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(16),
//                           topRight: Radius.circular(16),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: const Icon(
//                               Icons.straighten,
//                               color: Colors.white,
//                               size: 20,
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'اختيار الوحدة',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 2),
//                                 Text(
//                                   itemCode,
//                                   style: TextStyle(
//                                     color: Colors.white.withOpacity(0.9),
//                                     fontSize: 12,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           IconButton(
//                             onPressed: () => Get.back(),
//                             icon: const Icon(
//                               Icons.close,
//                               color: Colors.white,
//                               size: 20,
//                             ),
//                             constraints: const BoxConstraints(),
//                             padding: const EdgeInsets.all(4),
//                           ),
//                         ],
//                       ),
//                     ),

//                     // قائمة الوحدات
//                     Expanded(
//                       child: Container(
//                         margin: const EdgeInsets.all(12),
//                         child: ListView.builder(
//                           itemCount: sortedUnits.length,
//                           itemBuilder: (context, index) {
//                             ItemUnit unit = sortedUnits[index];

//                             return Container(
//                               margin: const EdgeInsets.only(bottom: 8),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 border: Border.all(
//                                   color: Colors.grey[300]!,
//                                   width: 1,
//                                 ),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: InkWell(
//                                 onTap: () {
//                                   selectedUnit = unit.uomName;
//                                   Get.back(); // إغلاق النافذة
//                                 },
//                                 borderRadius: BorderRadius.circular(12),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(16),
//                                   child: Row(
//                                     children: [
//                                       // رقم تسلسلي
//                                       Container(
//                                         width: 32,
//                                         height: 32,
//                                         decoration: BoxDecoration(
//                                           color: Colors.grey[400],
//                                           borderRadius: BorderRadius.circular(16),
//                                         ),
//                                         child: Center(
//                                           child: Text(
//                                             '${index + 1}',
//                                             style: const TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       const SizedBox(width: 16),
//                                       // معلومات الوحدة
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               unit.uomName,
//                                               style: const TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.black87,
//                                               ),
//                                             ),
//                                             const SizedBox(height: 4),
//                                             Text(
//                                               'الكمية الأساسية: ${unit.baseQty} | Entry: ${unit.uomEntry}',
//                                               style: TextStyle(
//                                                 fontSize: 12,
//                                                 color: Colors.grey[600],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       // زر الاختيار
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 12,
//                                           vertical: 6,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           color: Colors.green[500],
//                                           borderRadius: BorderRadius.circular(20),
//                                         ),
//                                         child: const Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: [
//                                             Icon(
//                                               Icons.radio_button_unchecked,
//                                               color: Colors.white,
//                                               size: 16,
//                                             ),
//                                             SizedBox(width: 4),
//                                             Text(
//                                               'اختيار',
//                                               style: TextStyle(
//                                                 color: Colors.white,
//                                                 fontSize: 12,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),

//                     // تذييل النافذة
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[50],
//                         borderRadius: const BorderRadius.only(
//                           bottomLeft: Radius.circular(16),
//                           bottomRight: Radius.circular(16),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'انقر على الوحدة لاختيارها',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.blue[100],
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               '${sortedUnits.length} وحدة',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.blue[700],
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       );

//       return selectedUnit;
//     } catch (e) {
//       logMessage('Transfer', 'Error in showUnitSelectionForNewProduct: ${e.toString()}');
//       Get.snackbar(
//         'خطأ',
//         'فشل في عرض وحدات الصنف: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 5),
//       );
//       return null;
//     }
//   }

//   Widget _buildInfoChip(String text, IconData icon, Color color) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(
//           icon,
//           size: 12,
//           color: color,
//         ),
//         const SizedBox(width: 4),
//         Text(
//           text,
//           style: TextStyle(
//             fontSize: 11,
//             color: color,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   // تحميل أسطر التحويل من الباك إند
//   Future<void> loadTransferLines(int selectedTransferId) async {
//     try {
//       isLoading.value = true;
//       statusRequest.value = StatusRequest.loading;
//       transferId.value = selectedTransferId;

//       var response = await gettransferdetailsApi.getTransferDetails(selectedTransferId);

//       if (response['status'] == 'success') {
//         TransferDetailDto details = TransferDetailDto.fromJson(response['data']);

//         transferDetails.value = details;
//         transferLines.value = details.lines;

//         // إعادة تعيين التتبع للتغييرات
//         _resetChangeTracking();

//         _applyFilter();
//         statusRequest.value = StatusRequest.success;
//       } else {
//         statusRequest.value = StatusRequest.failure;
//         Get.snackbar(
//           'خطأ',
//           response['message'] ?? 'فشل في تحميل أصناف التحويل',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 3),
//         );
//       }
//     } catch (e) {
//       statusRequest.value = StatusRequest.failure;
//       Get.snackbar(
//         'خطأ',
//         'حدث خطأ غير متوقع: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // باقي الدوال الموجودة...
//   void updateProductUnit(TransferLine line, String newUnitCode, int newBaseQty, int newUomEntry) {
//     try {
//       int index = transferLines
//           .indexWhere((item) => item.lineNum == line.lineNum && item.itemCode == line.itemCode);

//       if (index != -1) {
//         // إنشاء سطر محدث بالوحدة الجديدة
//         TransferLine updatedLine = TransferLine(
//           docEntry: line.docEntry,
//           lineNum: line.lineNum,
//           itemCode: line.itemCode,
//           description: line.description,
//           quantity: line.quantity,
//           price: line.price,
//           lineTotal: line.lineTotal,
//           uomCode: newUnitCode,
//           uomCode2: line.uomCode2,
//           invQty: line.invQty,
//           baseQty1: newBaseQty,
//           ugpEntry: line.ugpEntry,
//           uomEntry: newUomEntry,
//         );

//         transferLines[index] = updatedLine;

//         // تتبع التغيير
//         _trackLineChange(updatedLine);

//         _applyFilter();

//         Get.snackbar(
//           'تم التحديث',
//           'تم تغيير الوحدة إلى $newUnitCode',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 2),
//         );
//       }
//     } catch (e) {
//       logMessage('Transfer', 'Error in updateProductUnit: ${e.toString()}');
//       Get.snackbar(
//         'خطأ',
//         'فشل في تحديث الوحدة: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   // إضافة دالة مساعدة دون تغيير الدوال الموجودة
//   bool _isValidQuantity(double? quantity) {
//     if (quantity == null) return false;
//     if (quantity < 0) return false;
//     if (quantity > 999999) return false;
//     return true;
//   }

//   // تحديث كمية المنتج
//   void updateProductQuantity(TransferLine line, double newQuantity) {
//     if (!_isValidQuantity(newQuantity)) {
//       Get.snackbar('خطأ', 'قيمة الكمية غير صالحة');
//       return;
//     }
//     try {
//       int index = transferLines
//           .indexWhere((item) => item.lineNum == line.lineNum && item.itemCode == line.itemCode);

//       if (index != -1) {
//         // إنشاء سطر محدث بالكمية الجديدة
//         TransferLine updatedLine = TransferLine(
//           docEntry: line.docEntry,
//           lineNum: line.lineNum,
//           itemCode: line.itemCode,
//           description: line.description,
//           quantity: newQuantity,
//           price: line.price,
//           lineTotal: newQuantity * (line.price ?? 0.0),
//           uomCode: line.uomCode,
//           uomCode2: line.uomCode2,
//           invQty: line.invQty,
//           baseQty1: line.baseQty1,
//           ugpEntry: line.ugpEntry,
//           uomEntry: line.uomEntry,
//         );

//         transferLines[index] = updatedLine;

//         // تتبع التغيير
//         _trackLineChange(updatedLine);

//         _applyFilter();
//       }
//     } catch (e) {
//       logMessage('Transfer', 'Error in updateProductQuantity: ${e.toString()}');
//       Get.snackbar(
//         'خطأ',
//         'فشل في تحديث الكمية: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   // باقي الدوال كما هي...
//   void _resetChangeTracking() {
//     hasUnsavedChanges.value = false;
//     modifiedLines.clear();
//     newLines.clear();
//     deletedLines.clear();
//   }

//   Timer? _searchTimer;

//   // تعديل دالة موجودة دون تغيير signature
//   void updateSearch(String query) {
//     _searchTimer?.cancel();
//     _searchTimer = Timer(const Duration(milliseconds: 300), () {
//       searchQuery.value = query;
//       _applyFilter();
//     });
//   }

//   void _applyFilter() {
//     if (transferLines.isEmpty) {
//       filteredLines.clear();
//       return;
//     }

//     if (searchQuery.value.isEmpty) {
//       filteredLines.value = List.from(transferLines);
//     } else {
//       String query = searchQuery.value.toLowerCase();
//       filteredLines.value = transferLines.where((line) {
//         bool matchesItemCode = line.itemCode?.toLowerCase().contains(query) ?? false;
//         bool matchesDescription = line.description?.toLowerCase().contains(query) ?? false;
//         return matchesItemCode || matchesDescription;
//       }).toList();
//     }
//   }

//   void _trackLineChange(TransferLine line) {
//     if (line.lineNum != null && line.lineNum! > 0) {
//       modifiedLines[line.lineNum!] = line;
//       hasUnsavedChanges.value = true;
//     }
//   }

//   void clearUnitsCache() {
//     itemUnitsCache.clear();
//   }

//   void clearItemUnitsCache(String itemCode) {
//     itemUnitsCache.remove(itemCode);
//   }

//   Map<String, dynamic> getProductStats() {
//     if (filteredLines.isEmpty) {
//       return {
//         'totalItems': 0,
//         'totalQuantity': 0.0,
//         'totalAmount': 0.0,
//         'uniqueItems': 0,
//       };
//     }

//     double totalQuantity = 0.0;
//     double totalAmount = 0.0;
//     Set<String> uniqueItems = {};

//     for (TransferLine line in filteredLines) {
//       totalQuantity += line.quantity ?? 0.0;
//       totalAmount += line.lineTotal ?? 0.0;

//       if (line.itemCode != null && line.itemCode!.isNotEmpty) {
//         uniqueItems.add(line.itemCode!);
//       }
//     }

//     return {
//       'totalItems': filteredLines.length,
//       'totalQuantity': totalQuantity,
//       'totalAmount': totalAmount,
//       'uniqueItems': uniqueItems.length,
//     };
//   }

//   void clearSearch() {
//     searchController.clear();
//     updateSearch('');
//   }

//   void resetData() {
//     transferId.value = null;
//     transferDetails.value = null;
//     transferLines.clear();
//     filteredLines.clear();
//     searchController.clear();
//     searchQuery.value = '';
//     statusRequest.value = StatusRequest.none;
//     itemUnitsCache.clear();
//     _resetChangeTracking();
//   }

//   // Helper methods للحصول على المعلومات
//   int get totalProductsCount => transferLines.length;
//   int get filteredProductsCount => filteredLines.length;
//   bool get hasActiveSearch => searchQuery.value.isNotEmpty;
//   bool get hasData => transferLines.isNotEmpty;
//   bool get hasSelectedTransfer => transferId.value != null;
//   int get unsavedChangesCount => newLines.length + modifiedLines.length + deletedLines.length;
//   bool get canSave => hasUnsavedChanges.value && !isSaving.value;

//   // إضافة منتج جديد
//   void addProduct(Map<String, dynamic> productData) {
//     try {
//       // التحقق من صحة البيانات
//       if (!validateProductData(productData)) {
//         return;
//       }

//       // إنشاء سطر جديد بدون lineNum (سيتم إنشاؤه من الخادم)
//       TransferLine newLine = TransferLine(
//         docEntry: transferId.value,
//         lineNum: null, // لا نحدد lineNum للإضافات الجديدة
//         itemCode: productData['itemCode'],
//         description: productData['description'],
//         quantity: productData['quantity']?.toDouble(),
//         price: productData['price']?.toDouble(),
//         lineTotal: (productData['quantity']?.toDouble() ?? 0.0) *
//             (productData['price']?.toDouble() ?? 0.0),
//         uomCode: productData['uomCode'],
//         uomCode2: productData['uomCode2'],
//         invQty: productData['invQty']?.toDouble(),
//         baseQty1: productData['baseQty1']?.toInt(),
//         ugpEntry: productData['ugpEntry']?.toInt(),
//         uomEntry: productData['uomEntry']?.toInt(),
//       );

//       // إضافة للقائمة الرئيسية مع lineNum مؤقت للعرض
//       TransferLine displayLine = TransferLine(
//         docEntry: newLine.docEntry,
//         lineNum: _getNextTempLineNumber(), // رقم مؤقت للعرض
//         itemCode: newLine.itemCode,
//         description: newLine.description,
//         quantity: newLine.quantity,
//         price: newLine.price,
//         lineTotal: newLine.lineTotal,
//         uomCode: newLine.uomCode,
//         uomCode2: newLine.uomCode2,
//         invQty: newLine.invQty,
//         baseQty1: newLine.baseQty1,
//         ugpEntry: newLine.ugpEntry,
//         uomEntry: newLine.uomEntry,
//       );

//       transferLines.add(displayLine);
//       newLines.add(newLine); // تتبع كونه جديد
//       hasUnsavedChanges.value = true;

//       _applyFilter();

//       Get.snackbar(
//         'نجح',
//         'تم إضافة المنتج بنجاح (يتطلب حفظ)',
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       logMessage('Transfer', 'Error in addProduct: ${e.toString()}');
//       Get.snackbar(
//         'خطأ',
//         'فشل في إضافة المنتج: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   // تعديل منتج موجود
//   void updateProduct(TransferLine oldLine, Map<String, dynamic> newData) {
//     try {
//       int index = transferLines.indexWhere(
//           (line) => line.lineNum == oldLine.lineNum && line.itemCode == oldLine.itemCode);

//       if (index != -1) {
//         TransferLine updatedLine = TransferLine(
//           docEntry: oldLine.docEntry,
//           lineNum: oldLine.lineNum,
//           itemCode: newData['itemCode'] ?? oldLine.itemCode,
//           description: newData['description'] ?? oldLine.description,
//           quantity: newData['quantity']?.toDouble() ?? oldLine.quantity,
//           price: newData['price']?.toDouble() ?? oldLine.price,
//           lineTotal: (newData['quantity']?.toDouble() ?? oldLine.quantity ?? 0.0) *
//               (newData['price']?.toDouble() ?? oldLine.price ?? 0.0),
//           uomCode: newData['uomCode'] ?? oldLine.uomCode,
//           uomCode2: newData['uomCode2'] ?? oldLine.uomCode2,
//           invQty: newData['invQty']?.toDouble() ?? oldLine.invQty,
//           baseQty1: newData['baseQty1']?.toInt() ?? oldLine.baseQty1,
//           ugpEntry: newData['ugpEntry']?.toInt() ?? oldLine.ugpEntry,
//           uomEntry: newData['uomEntry']?.toInt() ?? oldLine.uomEntry,
//         );

//         transferLines[index] = updatedLine;

//         // تتبع التغيير
//         _trackLineChange(updatedLine);

//         _applyFilter();

//         Get.snackbar(
//           'نجح',
//           'تم تعديل المنتج بنجاح',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       logMessage('Transfer', 'Error in updateProduct: ${e.toString()}');
//       Get.snackbar(
//         'خطأ',
//         'فشل في تعديل المنتج: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   void deleteProduct(TransferLine line) {
//     try {
//       // التحقق من نوع السطر
//       bool isNewLine = line.lineNum == null || line.lineNum! < 0;
//       bool isExistingLine = line.lineNum != null && line.lineNum! > 0;

//       if (isNewLine) {
//         // السطر جديد لم يُحفظ في قاعدة البيانات بعد
//         // إزالة من القائمة المحلية فقط
//         transferLines
//             .removeWhere((item) => item.lineNum == line.lineNum && item.itemCode == line.itemCode);

//         // إزالة من قائمة الأسطر الجديدة
//         newLines.removeWhere(
//             (newLine) => newLine.itemCode == line.itemCode && newLine.lineNum == line.lineNum);

//         // تحديث حالة التغييرات
//         _updateUnsavedChangesStatus();

//         _applyFilter();

//         Get.snackbar(
//           'نجح',
//           'تم حذف الصنف الجديد محلياً',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
//       } else if (isExistingLine) {
//         // السطر موجود في قاعدة البيانات
//         // إضافة إلى قائمة الحذف للحفظ لاحقاً
//         deletedLines.add(line.lineNum!);

//         // إزالة من قائمة التعديلات إذا كان موجود
//         modifiedLines.remove(line.lineNum!);

//         // تحديث العرض ليظهر السطر كمحذوف
//         _markLineAsDeleted(line);

//         hasUnsavedChanges.value = true;
//         _applyFilter();

//         Get.snackbar(
//           'نجح',
//           'تم تحديد السطر للحذف (يتطلب حفظ)',
//           backgroundColor: Colors.orange,
//           colorText: Colors.white,
//         );
//       } else {
//         // حالة غير متوقعة
//         Get.snackbar(
//           'خطأ',
//           'لا يمكن تحديد نوع السطر للحذف',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       logMessage('Transfer', 'Error in deleteProduct: ${e.toString()}');
//       Get.snackbar(
//         'خطأ',
//         'فشل في حذف المنتج: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   // دالة مساعدة جديدة لتحديث حالة التغييرات
//   void _updateUnsavedChangesStatus() {
//     hasUnsavedChanges.value =
//         newLines.isNotEmpty || modifiedLines.isNotEmpty || deletedLines.isNotEmpty;
//   }

//   // دالة مساعدة لتحديد السطر كمحذوف في العرض
//   void _markLineAsDeleted(TransferLine line) {
//     // يمكن إضافة خاصية deleted للسطر أو استخدام deletedLines list
//     // الكود الحالي يعتمد على deletedLines.contains(line.lineNum) في UI
//   }

//   // نسخ منتج
//   void duplicateProduct(TransferLine line) {
//     try {
//       // إنشاء سطر مكرر كسطر جديد
//       TransferLine duplicatedLine = TransferLine(
//         docEntry: line.docEntry,
//         lineNum: null, // سطر جديد بدون lineNum
//         itemCode: line.itemCode,
//         description: line.description,
//         quantity: line.quantity,
//         price: line.price,
//         lineTotal: line.lineTotal,
//         uomCode: line.uomCode,
//         uomCode2: line.uomCode2,
//         invQty: line.invQty,
//         baseQty1: line.baseQty1,
//         ugpEntry: line.ugpEntry,
//         uomEntry: line.uomEntry,
//       );

//       // إضافة للعرض مع رقم مؤقت
//       TransferLine displayLine = TransferLine(
//         docEntry: duplicatedLine.docEntry,
//         lineNum: _getNextTempLineNumber(),
//         itemCode: duplicatedLine.itemCode,
//         description: duplicatedLine.description,
//         quantity: duplicatedLine.quantity,
//         price: duplicatedLine.price,
//         lineTotal: duplicatedLine.lineTotal,
//         uomCode: duplicatedLine.uomCode,
//         uomCode2: duplicatedLine.uomCode2,
//         invQty: duplicatedLine.invQty,
//         baseQty1: duplicatedLine.baseQty1,
//         ugpEntry: duplicatedLine.ugpEntry,
//         uomEntry: duplicatedLine.uomEntry,
//       );

//       transferLines.add(displayLine);
//       newLines.add(duplicatedLine); // تتبع كونه جديد
//       hasUnsavedChanges.value = true;

//       _applyFilter();

//       Get.snackbar(
//         'نجح',
//         'تم نسخ المنتج بنجاح (يتطلب حفظ)',
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//       );
//     } catch (e) {
//       logMessage('Transfer', 'Error in duplicateProduct: ${e.toString()}');
//       Get.snackbar(
//         'خطأ',
//         'فشل في نسخ المنتج: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   // الحصول على رقم سطر مؤقت للعرض
//   int _getNextTempLineNumber() {
//     int maxLineNum = 0;
//     for (TransferLine line in transferLines) {
//       if (line.lineNum != null && line.lineNum! > maxLineNum) {
//         maxLineNum = line.lineNum!;
//       }
//     }
//     return -(maxLineNum + 1); // استخدام أرقام سالبة للأسطر الجديدة
//   }

//   Future<void> saveAllChangesToServer() async {
//     if (!hasUnsavedChanges.value) {
//       Get.snackbar(
//         'تنبيه',
//         'لا توجد تغييرات للحفظ',
//         backgroundColor: Colors.blue,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     try {
//       isSaving.value = true;
//       int successCount = 0;
//       int errorCount = 0;
//       List<String> errorMessages = [];

//       // 1. حفظ الأسطر الجديدة أولاً
//       List<TransferLine> newLinesToSave = List.from(newLines);
//       for (TransferLine newLine in newLinesToSave) {
//         var result = await _saveNewLine(newLine);
//         if (result['success'] == true) {
//           successCount++;
//           // إزالة من قائمة الأسطر الجديدة بعد الحفظ الناجح
//           newLines.removeWhere(
//               (line) => line.itemCode == newLine.itemCode && line.lineNum == newLine.lineNum);
//         } else {
//           errorCount++;
//           errorMessages.add('فشل حفظ سطر جديد: ${result['error']}');
//         }
//       }

//       // 2. حفظ الأسطر المعدلة
//       List<TransferLine> modifiedLinesToSave = modifiedLines.values.toList();
//       for (TransferLine modifiedLine in modifiedLinesToSave) {
//         var result = await _saveModifiedLine(modifiedLine);
//         if (result['success'] == true) {
//           successCount++;
//           // إزالة من قائمة التعديلات بعد الحفظ الناجح
//           modifiedLines.remove(modifiedLine.lineNum);
//         } else {
//           errorCount++;
//           errorMessages.add('فشل تحديث السطر ${modifiedLine.lineNum}: ${result['error']}');
//         }
//       }

//       // 3. حذف الأسطر المحذوفة من قاعدة البيانات
//       List<int> linesToDelete = List.from(deletedLines);
//       for (int deletedLineNum in linesToDelete) {
//         var result = await _deleteLineFromServer(deletedLineNum);
//         if (result['success'] == true) {
//           successCount++;
//           // إزالة من قائمة الحذف بعد الحذف الناجح
//           deletedLines.remove(deletedLineNum);

//           // إزالة السطر نهائياً من العرض
//           transferLines.removeWhere((line) => line.lineNum == deletedLineNum);
//         } else {
//           errorCount++;
//           errorMessages.add('فشل حذف السطر $deletedLineNum: ${result['error']}');
//         }
//       }

//       // تحديث حالة التغييرات
//       _updateUnsavedChangesStatus();
//       _applyFilter();

//       // عرض النتائج
//       if (errorCount == 0) {
//         Get.snackbar(
//           'نجح',
//           'تم حفظ جميع التغييرات بنجاح ($successCount عملية)',
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//           duration: const Duration(seconds: 3),
//         );

//         // إعادة تحميل البيانات من الخادم للتأكد من التطابق
//         if (transferId.value != null) {
//           await loadTransferLines(transferId.value!);
//         }
//       } else {
//         // عرض تفاصيل الأخطاء
//         String errorSummary = errorMessages.length <= 3
//             ? errorMessages.join('\n')
//             : '${errorMessages.take(2).join('\n')}\nو ${errorMessages.length - 2} أخطاء أخرى...';

//         Get.dialog(
//           AlertDialog(
//             title: const Text('تحذير - حفظ جزئي'),
//             content: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text('تم حفظ $successCount عملية بنجاح'),
//                   Text('فشل في $errorCount عملية'),
//                   const SizedBox(height: 12),
//                   const Text('تفاصيل الأخطاء:', style: TextStyle(fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 8),
//                   Text(errorSummary, style: const TextStyle(fontSize: 12)),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Get.back(),
//                 child: const Text('موافق'),
//               ),
//               if (errorCount > 0)
//                 ElevatedButton(
//                   onPressed: () {
//                     Get.back();
//                     // إعادة المحاولة للعمليات الفاشلة
//                     saveAllChangesToServer();
//                   },
//                   child: const Text('إعادة المحاولة'),
//                 ),
//             ],
//           ),
//         );
//       }
//     } catch (e) {
//       logMessage('Transfer', 'Error in saveAllChangesToServer: ${e.toString()}');
//       Get.snackbar(
//         'خطأ',
//         'فشل في حفظ التغييرات: ${e.toString()}',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     } finally {
//       isSaving.value = false;
//     }
//   }

//   // تحديث دالة _saveNewLine لمعالجة الأسطر الجديدة بشكل صحيح
//   Future<Map<String, dynamic>> _saveNewLine(TransferLine line) async {
//     try {
//       var response = await upsertTransferApi.upsertTransferLine(
//         docEntry: line.docEntry ?? transferId.value!,
//         lineNum: null, // للإضافة الجديدة
//         itemCode: line.itemCode!,
//         description: line.description ?? '',
//         quantity: line.quantity ?? 0.0,
//         price: line.price ?? 0.0,
//         lineTotal: line.lineTotal ?? 0.0,
//         uomCode: line.uomCode ?? '',
//         uomCode2: line.uomCode2,
//         invQty: line.invQty,
//         baseQty1: line.baseQty1,
//         ugpEntry: line.ugpEntry,
//         uomEntry: line.uomEntry,
//       );

//       if (response['status'] == 'success') {
//         // الحصول على lineNum الجديد من الاستجابة
//         int? newLineNum = response['data']?['lineNum'];

//         // تحديث lineNum في القائمة المحلية
//         _updateLineNumInList(line, newLineNum!);

//         return {'success': true, 'lineNum': newLineNum, 'message': 'تم حفظ السطر الجديد بنجاح'};
//       } else {
//         return {'success': false, 'error': response['message'] ?? 'فشل في حفظ السطر الجديد'};
//       }
//     } catch (e) {
//       logMessage('Transfer', 'Exception in _saveNewLine: ${e.toString()}');
//       return {'success': false, 'error': 'خطأ في حفظ السطر الجديد: ${e.toString()}'};
//     }
//   }

//   // حفظ سطر معدل
//   Future<Map<String, dynamic>> _saveModifiedLine(TransferLine line) async {
//     try {
//       var response = await upsertTransferApi.upsertTransferLine(
//         docEntry: line.docEntry!,
//         lineNum: line.lineNum!, // lineNum موجود للتعديل
//         itemCode: line.itemCode!,
//         description: line.description ?? '',
//         quantity: line.quantity ?? 0.0,
//         price: line.price ?? 0.0,
//         lineTotal: line.lineTotal ?? 0.0,
//         uomCode: line.uomCode ?? '',
//         uomCode2: line.uomCode2,
//         invQty: line.invQty,
//         baseQty1: line.baseQty1,
//         ugpEntry: line.ugpEntry,
//         uomEntry: line.uomEntry,
//       );

//       return {
//         'success': response['status'] == 'success',
//         'error': response['message'],
//       };
//     } catch (e) {
//       return {'success': false, 'error': e.toString()};
//     }
//   }

//   // حذف سطر من الخادم
//   Future<Map<String, dynamic>> _deleteLineFromServer(int lineNum) async {
//     try {
//       var response = await transferApi.deleteTransferLine(
//         docEntry: transferId.value!,
//         lineNum: lineNum,
//       );

//       return {
//         'success': response['status'] == 'success',
//         'error': response['message'],
//       };
//     } catch (e) {
//       return {'success': false, 'error': e.toString()};
//     }
//   }

//   // تحديث lineNum في القائمة بعد الإضافة الناجحة
//   void _updateLineNumInList(TransferLine oldLine, int newLineNum) {
//     int index = transferLines.indexWhere(
//         (line) => line.itemCode == oldLine.itemCode && line.lineNum != null && line.lineNum! < 0);

//     if (index != -1) {
//       TransferLine updatedLine = TransferLine(
//         docEntry: transferLines[index].docEntry,
//         lineNum: newLineNum, // LineNum الجديد من الخادم
//         itemCode: transferLines[index].itemCode,
//         description: transferLines[index].description,
//         quantity: transferLines[index].quantity,
//         price: transferLines[index].price,
//         lineTotal: transferLines[index].lineTotal,
//         uomCode: transferLines[index].uomCode,
//         uomCode2: transferLines[index].uomCode2,
//         invQty: transferLines[index].invQty,
//         baseQty1: transferLines[index].baseQty1,
//         ugpEntry: transferLines[index].ugpEntry,
//         uomEntry: transferLines[index].uomEntry,
//       );

//       transferLines[index] = updatedLine;
//     }
//   }

//   // التحقق من صحة بيانات المنتج
//   bool validateProductData(Map<String, dynamic> productData) {
//     if (productData['itemCode'] == null || productData['itemCode'].toString().trim().isEmpty) {
//       Get.snackbar(
//         'خطأ في البيانات',
//         'كود المنتج مطلوب',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return false;
//     }

//     if (productData['quantity'] == null || productData['quantity'] <= 0) {
//       Get.snackbar(
//         'خطأ في البيانات',
//         'الكمية يجب أن تكون أكبر من صفر',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return false;
//     }

//     if (productData['price'] == null || productData['price'] < 0) {
//       Get.snackbar(
//         'خطأ في البيانات',
//         'السعر يجب أن يكون أكبر من أو يساوي صفر',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return false;
//     }

//     return true;
//   }

//   // دالة مساعدة للتسجيل
//   void logMessage(String tag, String message) {
//     print('[$tag] $message');
//   }
// }
