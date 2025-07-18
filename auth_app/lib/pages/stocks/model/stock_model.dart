// models/stock_model.dart
class StockModel {
  final String itemCode;
  final String whsCode;
  final double avgPrice;
  final double totalOnHand;
  final String updateDate;
  final String itemName;

  StockModel({
    required this.itemCode,
    required this.whsCode,
    required this.avgPrice,
    required this.totalOnHand,
    required this.updateDate,
    required this.itemName,
  });

  // تحويل من JSON إلى Object
  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      itemCode: json['itemCode'] ?? '',
      whsCode: json['whsCode'] ?? '',
      avgPrice: _parseDouble(json['avgPrice']),
      totalOnHand: _parseDouble(json['totalOnHand']),
      updateDate: json['updateDate'] ?? '',
      itemName: json['itemName'] ?? '',
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
    };
  }

  // إنشاء نسخة جديدة مع تعديل بعض القيم
  StockModel copyWith({
    String? itemCode,
    String? whsCode,
    double? avgPrice,
    double? totalOnHand,
    String? updateDate,
    String? itemName,
  }) {
    return StockModel(
      itemCode: itemCode ?? this.itemCode,
      whsCode: whsCode ?? this.whsCode,
      avgPrice: avgPrice ?? this.avgPrice,
      totalOnHand: totalOnHand ?? this.totalOnHand,
      updateDate: updateDate ?? this.updateDate,
      itemName: itemName ?? this.itemName,
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

  @override
  String toString() {
    return 'StockModel{itemCode: $itemCode, whsCode: $whsCode, totalOnHand: $totalOnHand, avgPrice: $avgPrice}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockModel && other.itemCode == itemCode && other.whsCode == whsCode;
  }

  @override
  int get hashCode {
    return itemCode.hashCode ^ whsCode.hashCode;
  }
}

// enum لحالة المخزون
enum StockStatus {
  deficit, // عجز
  empty, // فارغ
  low, // قليل
  available // متوفر
}
