// controllers/printer_controller.dart
import 'dart:async';
import 'package:auth_app/pages/configration/models/printer_model.dart';
import 'package:auth_app/pages/configration/servicers/printer_service.dart';
import 'package:get/get.dart';

class PrinterController extends GetxController {
  final PrinterService _printerService = PrinterService();

  // قائمة الطابعات المكتشفة
  final RxList<PrinterModel> discoveredPrinters = <PrinterModel>[].obs;

  // قائمة الطابعات المحفوظة
  final RxList<PrinterModel> savedPrinters = <PrinterModel>[].obs;

  // الطابعة المختارة حالياً
  final Rxn<PrinterModel> selectedPrinter = Rxn<PrinterModel>();

  // حالة البحث
  final RxBool isScanning = false.obs;
  final RxBool isConnecting = false.obs;
  final RxBool isTestingConnection = false.obs;

  // تقدم البحث
  final RxDouble scanProgress = 0.0.obs;
  final RxString scanStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedData();
  }

// في PrinterController
  Future<void> scanForPrinters(String networkRange) async {
    if (isScanning.value) return;

    isScanning.value = true;
    scanProgress.value = 0.0;
    scanStatus.value = 'تحديث ARP table...';
    discoveredPrinters.clear();

    try {
      // تحديث تقدم المسح
      Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!isScanning.value) {
          timer.cancel();
          return;
        }
        if (scanProgress.value < 0.9) {
          scanProgress.value += 0.01;
        }
      });

      List<PrinterModel> printers = await _printerService.scanForPrinters(networkRange);

      discoveredPrinters.value = printers;
      scanProgress.value = 1.0;

      if (printers.isNotEmpty) {
        scanStatus.value = 'تم العثور على ${printers.length} جهاز';
        await _printerService.savePrinters(printers);
        _updateSavedPrinters();
      } else {
        scanStatus.value = 'لم يتم العثور على أي طابعات';
      }
    } catch (e) {
      scanStatus.value = 'خطأ في البحث: $e';
      _showError('فشل في البحث عن الطابعات: $e');
    } finally {
      isScanning.value = false;
    }
  }

  // تحميل البيانات المحفوظة
  Future<void> _loadSavedData() async {
    try {
      // تحميل الطابعات المحفوظة
      savedPrinters.value = await _printerService.loadSavedPrinters();

      // تحميل الطابعة المختارة
      PrinterModel? selected = await _printerService.loadSelectedPrinter();
      if (selected != null) {
        selectedPrinter.value = selected;
        // التحقق من حالة الاتصال
        _checkSelectedPrinterConnection();
      }
    } catch (e) {
      _showError('خطأ في تحميل البيانات المحفوظة: $e');
    }
  }

  // اختيار طابعة
  Future<void> selectPrinter(PrinterModel printer) async {
    isConnecting.value = true;

    try {
      // اختبار الاتصال أولاً
      bool isConnected = await _printerService.testConnection(printer);

      if (isConnected) {
        // تحديث حالة الطابعة
        PrinterModel connectedPrinter = printer.copyWith(
          isConnected: true,
          lastConnected: DateTime.now(),
        );

        selectedPrinter.value = connectedPrinter;

        // حفظ الطابعة المختارة
        await _printerService.saveSelectedPrinter(connectedPrinter);

        _showSuccess('تم الاتصال بالطابعة: ${printer.name}');

        // تحديث قائمة الطابعات المحفوظة
        _updateSavedPrinters();
      } else {
        _showError('فشل في الاتصال بالطابعة: ${printer.name}');
      }
    } catch (e) {
      _showError('خطأ في الاتصال: $e');
    } finally {
      isConnecting.value = false;
    }
  }

  // قطع الاتصال مع الطابعة
  Future<void> disconnectPrinter() async {
    if (selectedPrinter.value != null) {
      selectedPrinter.value = selectedPrinter.value!.copyWith(isConnected: false);
      await _printerService.clearSelectedPrinter();
      _showSuccess('تم قطع الاتصال مع الطابعة');
    }
  }

  // اختبار الاتصال مع الطابعة المختارة
  Future<void> testSelectedPrinterConnection() async {
    if (selectedPrinter.value == null) return;

    isTestingConnection.value = true;

    try {
      bool isConnected = await _printerService.testConnection(selectedPrinter.value!);

      selectedPrinter.value = selectedPrinter.value!.copyWith(
        isConnected: isConnected,
        lastConnected: isConnected ? DateTime.now() : selectedPrinter.value!.lastConnected,
      );

      if (isConnected) {
        await _printerService.saveSelectedPrinter(selectedPrinter.value!);
        _showSuccess('الطابعة متصلة بنجاح');
      } else {
        _showError('الطابعة غير متاحة');
      }
    } catch (e) {
      _showError('خطأ في اختبار الاتصال: $e');
    } finally {
      isTestingConnection.value = false;
    }
  }

  // التحقق التلقائي من اتصال الطابعة المختارة
  Future<void> _checkSelectedPrinterConnection() async {
    if (selectedPrinter.value != null) {
      bool isConnected = await _printerService.testConnection(selectedPrinter.value!);
      selectedPrinter.value = selectedPrinter.value!.copyWith(isConnected: isConnected);
    }
  }

  // تحديث قائمة الطابعات المحفوظة
  void _updateSavedPrinters() {
    // دمج الطابعات المكتشفة مع المحفوظة
    Set<PrinterModel> allPrinters = <PrinterModel>{};
    allPrinters.addAll(savedPrinters);
    allPrinters.addAll(discoveredPrinters);

    savedPrinters.value = allPrinters.toList();
    _printerService.savePrinters(savedPrinters);
  }

  // إزالة طابعة من القائمة المحفوظة
  Future<void> removeSavedPrinter(PrinterModel printer) async {
    savedPrinters.remove(printer);
    await _printerService.savePrinters(savedPrinters);

    // إذا كانت الطابعة المحذوفة هي المختارة حالياً
    if (selectedPrinter.value == printer) {
      selectedPrinter.value = null;
      await _printerService.clearSelectedPrinter();
    }
  }

  // مسح جميع البيانات
  Future<void> clearAllData() async {
    await _printerService.clearAllData();
    discoveredPrinters.clear();
    savedPrinters.clear();
    selectedPrinter.value = null;
    _showSuccess('تم مسح جميع البيانات');
  }

  // إعادة تحميل البيانات
  Future<void> refreshData() async {
    await _loadSavedData();
  }

  // عرض رسالة نجاح
  void _showSuccess(String message) {
    Get.snackbar(
      'نجح',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
      colorText: Get.theme.colorScheme.primary,
      duration: const Duration(seconds: 2),
    );
  }

  // عرض رسالة خطأ
  void _showError(String message) {
    Get.snackbar(
      'خطأ',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error.withOpacity(0.1),
      colorText: Get.theme.colorScheme.error,
      duration: const Duration(seconds: 3),
    );
  }

  // معلومات الطابعة المختارة
  String get selectedPrinterInfo {
    if (selectedPrinter.value == null) return 'لا توجد طابعة مختارة';

    final printer = selectedPrinter.value!;
    final status = printer.isConnected ? 'متصلة' : 'غير متصلة';
    return '${printer.name} ($status)';
  }

  // عدد الطابعات المكتشفة
  int get discoveredPrintersCount => discoveredPrinters.length;

  // عدد الطابعات المحفوظة
  int get savedPrintersCount => savedPrinters.length;

  // حالة الاتصال العامة
  bool get hasConnectedPrinter => selectedPrinter.value?.isConnected ?? false;

  @override
  void onClose() {
    // تنظيف الموارد إذا لزم الأمر
    super.onClose();
  }
}
