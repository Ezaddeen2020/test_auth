// نموذج وحدة القياس المصحح حسب الاستجابة الفعلية
class UomModel {
  final int uomEntry; // معرف الوحدة (5, 6, 13, etc.)
  final String uomName; // اسم الوحدة (حبة، كرتون، شد، etc.)
  final double baseQty; // الكمية الأساسية (1.0, 12.0, 3.0, etc.)

  UomModel({
    required this.uomEntry,
    required this.uomName,
    required this.baseQty,
  });

  factory UomModel.fromJson(Map<String, dynamic> json) {
    return UomModel(
      uomEntry: json['uomEntry'] ?? 0,
      uomName: json['uomName']?.toString().trim() ?? '',
      baseQty: _parseDouble(json['baseQty']) ?? 1.0,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 1.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 1.0;
      }
    }
    return 1.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'uomEntry': uomEntry,
      'uomName': uomName,
      'baseQty': baseQty,
    };
  }

  // نص عرض مُنسق للوحدة مع الكمية الأساسية
  String get displayText {
    if (baseQty == 1.0) {
      return uomName;
    } else {
      return '$uomName (${baseQty.toStringAsFixed(0)})';
    }
  }

  // كود الوحدة للاستخدام في API (نفس الاسم)
  String get uomCode => uomName;

  // التحقق من أن هذه هي الوحدة الأساسية
  bool get isBaseUnit => baseQty == 1.0;

  // حساب الكمية المحولة إلى الوحدة الأساسية
  double convertToBaseQuantity(double quantity) {
    return quantity * baseQty;
  }

  // حساب الكمية من الوحدة الأساسية إلى هذه الوحدة
  double convertFromBaseQuantity(double baseQuantity) {
    if (baseQty == 0) return 0;
    return baseQuantity / baseQty;
  }

  // التحقق من صحة البيانات
  bool get isValid {
    return uomEntry > 0 && uomName.isNotEmpty && baseQty > 0;
  }

  @override
  String toString() {
    return 'UomModel{uomEntry: $uomEntry, uomName: $uomName, baseQty: $baseQty}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UomModel && other.uomEntry == uomEntry;
  }

  @override
  int get hashCode => uomEntry.hashCode;
}

// تحديث نموذج ItemUnit ليتوافق مع UomModel
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

  // إنشاء من UomModel
  factory ItemUnit.fromUomModel(UomModel uom) {
    return ItemUnit(
      uomCode: uom.uomName,
      uomName: uom.uomName,
      baseQty: uom.baseQty.toInt(),
      uomEntry: uom.uomEntry,
      ugpEntry: 1, // قيمة افتراضية
    );
  }

  factory ItemUnit.fromJson(Map<String, dynamic> json) {
    return ItemUnit(
      uomCode: json['uomCode']?.toString() ?? json['uomName']?.toString() ?? '',
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

// خدمة تحويل الوحدات
class UomConversionService {
  // تحويل الكمية من وحدة إلى أخرى
  static double convertQuantity({
    required double quantity,
    required UomModel fromUnit,
    required UomModel toUnit,
  }) {
    if (fromUnit.uomEntry == toUnit.uomEntry) {
      return quantity; // نفس الوحدة
    }

    // تحويل إلى الوحدة الأساسية أولاً
    double baseQuantity = fromUnit.convertToBaseQuantity(quantity);

    // ثم تحويل إلى الوحدة المطلوبة
    double targetQuantity = toUnit.convertFromBaseQuantity(baseQuantity);

    return targetQuantity;
  }

  // حساب السعر للوحدة الجديدة
  static double convertPrice({
    required double originalPrice,
    required UomModel fromUnit,
    required UomModel toUnit,
  }) {
    if (fromUnit.uomEntry == toUnit.uomEntry) {
      return originalPrice;
    }

    // السعر للوحدة الجديدة = السعر الأصلي × (الكمية الأساسية للوحدة الجديدة / الكمية الأساسية للوحدة الأصلية)
    double conversionFactor = toUnit.baseQty / fromUnit.baseQty;
    return originalPrice * conversionFactor;
  }

  // الحصول على الوحدة الأساسية من قائمة الوحدات
  static UomModel? getBaseUnit(List<UomModel> units) {
    try {
      return units.firstWhere((unit) => unit.isBaseUnit);
    } catch (e) {
      return units.isNotEmpty ? units.first : null;
    }
  }

  // ترتيب الوحدات حسب الكمية الأساسية
  static List<UomModel> sortUnitsByBaseQty(List<UomModel> units) {
    List<UomModel> sorted = List.from(units);
    sorted.sort((a, b) => a.baseQty.compareTo(b.baseQty));
    return sorted;
  }
}
