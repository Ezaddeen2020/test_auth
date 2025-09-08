// models/stock_check_model.dart
import 'package:auth_app/pages/home/bottombar/main/Stocks/stock_transfer/transfer_list/transfer_card/transfer_navigate/product/model/uom_model.dart';

class StockCheckModel {
  final String itemCode;
  final String whsCode;
  final double avgPrice;
  final double totalOnHand;
  final String updateDate;
  final String itemName;
  final String? uomCode;
  final List<UomModel>? availableUnits; // إضافة قائمة الوحدات المتاحة

  StockCheckModel({
    required this.itemCode,
    required this.whsCode,
    required this.avgPrice,
    required this.totalOnHand,
    required this.updateDate,
    required this.itemName,
    this.uomCode,
    this.availableUnits,
  });

  // تحويل من JSON إلى Object
  factory StockCheckModel.fromJson(Map<String, dynamic> json) {
    return StockCheckModel(
      itemCode: json['itemCode'] ?? '',
      whsCode: json['whsCode'] ?? '',
      avgPrice: _parseDouble(json['avgPrice']),
      totalOnHand: _parseDouble(json['totalOnHand']),
      updateDate: json['updateDate'] ?? '',
      itemName: json['itemName'] ?? '',
      uomCode: json['uomCode'],
      availableUnits: (json['availableUnits'] as List<dynamic>?)
          ?.map((item) => UomModel.fromJson(item))
          .toList(),
    );
  }

  // تحويل من StockModel إلى StockCheckModel
  factory StockCheckModel.fromStockModel(
    dynamic stockModel, {
    List<UomModel>? units,
  }) {
    return StockCheckModel(
      itemCode: stockModel.itemCode ?? '',
      whsCode: stockModel.whsCode ?? '',
      avgPrice: stockModel.avgPrice ?? 0.0,
      totalOnHand: stockModel.totalOnHand ?? 0.0,
      updateDate: stockModel.updateDate ?? '',
      itemName: stockModel.itemName ?? '',
      uomCode: stockModel.uomCode,
      availableUnits: units,
    );
  }

  // تحويل من Object إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'itemCode': itemCode,
      'whsCode': whsCode,
      'avgPrice': avgPrice,
      'totalOnHand': totalOnHand,
      'updateDate': updateDate,
      'itemName': itemName,
      'uomCode': uomCode,
      'availableUnits': availableUnits?.map((unit) => unit.toJson()).toList(),
    };
  }

  // إنشاء نسخة جديدة مع تعديل بعض القيم
  StockCheckModel copyWith({
    String? itemCode,
    String? whsCode,
    double? avgPrice,
    double? totalOnHand,
    String? updateDate,
    String? itemName,
    String? uomCode,
    List<UomModel>? availableUnits,
  }) {
    return StockCheckModel(
      itemCode: itemCode ?? this.itemCode,
      whsCode: whsCode ?? this.whsCode,
      avgPrice: avgPrice ?? this.avgPrice,
      totalOnHand: totalOnHand ?? this.totalOnHand,
      updateDate: updateDate ?? this.updateDate,
      itemName: itemName ?? this.itemName,
      uomCode: uomCode ?? this.uomCode,
      availableUnits: availableUnits ?? this.availableUnits,
    );
  }

  // مساعد لتحويل القيم إلى double بأمان
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  // تحويل التاريخ إلى DateTime
  DateTime? get updateDateTime {
    try {
      return DateTime.parse(updateDate);
    } catch (e) {
      return null;
    }
  }

  // فحص حالة المخزون
  StockStatus get stockStatus {
    if (totalOnHand < 0) return StockStatus.deficit;
    if (totalOnHand == 0) return StockStatus.empty;
    if (totalOnHand < 100) return StockStatus.low;
    return StockStatus.available;
  }

  // الحصول على نص حالة المخزون
  String get stockStatusText {
    switch (stockStatus) {
      case StockStatus.deficit:
        return 'عجز';
      case StockStatus.empty:
        return 'غير متوفر';
      case StockStatus.low:
        return 'قليل';
      case StockStatus.available:
        return 'متوفر';
    }
  }

  // فحص ما إذا كان السعر متوفر
  bool get hasPriceInfo => avgPrice > 0;

  // حساب القيمة الإجمالية للمخزون
  double get totalValue => avgPrice * totalOnHand;

  // خاصية للحصول على وحدة القياس مع قيمة افتراضية
  String get displayUomCode => uomCode ?? 'حبة';

  // فحص ما إذا كانت وحدة القياس متوفرة
  bool get hasUomCode => uomCode != null && uomCode!.isNotEmpty;

  // فحص ما إذا كانت الوحدات المتاحة موجودة
  bool get hasAvailableUnits => availableUnits != null && availableUnits!.isNotEmpty;

  // الحصول على الوحدة الأساسية
  UomModel? get baseUnit {
    if (!hasAvailableUnits) return null;
    try {
      return availableUnits!.firstWhere((unit) => unit.isBaseUnit);
    } catch (e) {
      return availableUnits!.isNotEmpty ? availableUnits!.first : null;
    }
  }

  // الحصول على الوحدة الحالية كـ UomModel
  UomModel? get currentUomModel {
    if (!hasAvailableUnits || !hasUomCode) return null;
    try {
      return availableUnits!.firstWhere(
        (unit) => unit.uomName.toLowerCase() == uomCode!.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // تحويل الكمية إلى وحدة معينة
  double convertQuantityToUnit(double quantity, UomModel targetUnit) {
    if (!hasAvailableUnits) return quantity;

    final currentUnit = currentUomModel ?? baseUnit;
    if (currentUnit == null) return quantity;

    return UomConversionService.convertQuantity(
      quantity: quantity,
      fromUnit: currentUnit,
      toUnit: targetUnit,
    );
  }

  // تحويل السعر إلى وحدة معينة
  double convertPriceToUnit(double price, UomModel targetUnit) {
    if (!hasAvailableUnits) return price;

    final currentUnit = currentUomModel ?? baseUnit;
    if (currentUnit == null) return price;

    return UomConversionService.convertPrice(
      originalPrice: price,
      fromUnit: currentUnit,
      toUnit: targetUnit,
    );
  }

  // تنسيق الكمية للعرض
  String get formattedQuantity {
    return totalOnHand.toStringAsFixed(totalOnHand == totalOnHand.toInt() ? 0 : 3);
  }

  // تنسيق السعر للعرض
  String get formattedPrice {
    return avgPrice.toStringAsFixed(2);
  }

  // تنسيق القيمة الإجمالية للعرض
  String get formattedTotalValue {
    return totalValue.toStringAsFixed(2);
  }

  @override
  String toString() {
    return 'StockCheckModel{itemCode: $itemCode, whsCode: $whsCode, totalOnHand: $totalOnHand, avgPrice: $avgPrice, uomCode: $uomCode}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockCheckModel &&
        other.itemCode == itemCode &&
        other.whsCode == whsCode &&
        other.uomCode == uomCode;
  }

  @override
  int get hashCode {
    return itemCode.hashCode ^ whsCode.hashCode ^ (uomCode?.hashCode ?? 0);
  }
}

// enum لحالة المخزون
enum StockStatus {
  deficit, // عجز
  empty, // فارغ
  low, // قليل
  available // متوفر
}
