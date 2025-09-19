// ==================== UOM MODEL ====================
class UomModel {
  final int uomEntry;
  final String uomName;
  final double baseQty;

  UomModel({
    required this.uomEntry,
    required this.uomName,
    required this.baseQty,
  });

  factory UomModel.fromJson(Map<String, dynamic> json) {
    return UomModel(
      uomEntry: json['uomEntry'] ?? 0,
      uomName: json['uomName']?.toString().trim() ?? '',
      baseQty: _parseDouble(json['baseQty']),
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

  // ==================== COMPUTED PROPERTIES ====================
  String get displayText {
    if (baseQty == 1.0) {
      return uomName;
    } else {
      return '$uomName (${baseQty.toStringAsFixed(0)})';
    }
  }

  String get uomCode => uomName;

  bool get isBaseUnit => baseQty == 1.0;

  bool get isValid {
    return uomEntry > 0 && uomName.isNotEmpty && baseQty > 0;
  }

  // ==================== CONVERSION METHODS ====================
  double convertToBaseQuantity(double quantity) {
    return quantity * baseQty;
  }

  double convertFromBaseQuantity(double baseQuantity) {
    if (baseQty == 0) return 0;
    return baseQuantity / baseQty;
  }

  // ==================== OVERRIDE METHODS ====================
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

// ==================== ITEM UNIT MODEL ====================
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

  // ==================== FACTORY CONSTRUCTORS ====================
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

  // ==================== SERIALIZATION ====================
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

  // ==================== COMPUTED PROPERTIES ====================
  String get displayText {
    if (baseQty == 1) {
      return uomName;
    } else {
      return '$uomName ($baseQty)';
    }
  }

  bool get isBaseUnit => baseQty == 1;

  bool get isValid {
    return uomCode.isNotEmpty && uomName.isNotEmpty && baseQty > 0 && uomEntry > 0;
  }

  // ==================== CONVERSION METHODS ====================
  double convertToBase(double quantity) {
    return quantity * baseQty;
  }

  double convertFromBase(double baseQuantity) {
    if (baseQty == 0) return 0;
    return baseQuantity / baseQty;
  }

  // ==================== OVERRIDE METHODS ====================
  @override
  String toString() {
    return 'ItemUnit{uomCode: $uomCode, uomName: $uomName, baseQty: $baseQty}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ItemUnit && other.uomEntry == uomEntry && other.uomCode == uomCode;
  }

  @override
  int get hashCode => Object.hash(uomEntry, uomCode);
}

// ==================== UOM CONVERSION SERVICE ====================
class UomConversionService {
  // ==================== QUANTITY CONVERSION ====================
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
    return toUnit.convertFromBaseQuantity(baseQuantity);
  }

  // ==================== PRICE CONVERSION ====================
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

  // ==================== UNIT OPERATIONS ====================
  static UomModel? getBaseUnit(List<UomModel> units) {
    try {
      return units.firstWhere((unit) => unit.isBaseUnit);
    } catch (e) {
      return units.isNotEmpty ? units.first : null;
    }
  }

  static List<UomModel> sortUnitsByBaseQty(List<UomModel> units) {
    List<UomModel> sorted = List.from(units);
    sorted.sort((a, b) => a.baseQty.compareTo(b.baseQty));
    return sorted;
  }

  static List<ItemUnit> sortItemUnitsByBaseQty(List<ItemUnit> units) {
    List<ItemUnit> sorted = List.from(units);
    sorted.sort((a, b) => a.baseQty.compareTo(b.baseQty));
    return sorted;
  }

  // ==================== VALIDATION ====================
  static bool validateUomModel(UomModel? uom) {
    return uom != null && uom.isValid;
  }

  static bool validateItemUnit(ItemUnit? unit) {
    return unit != null && unit.isValid;
  }

  static bool validateUomList(List<UomModel> units) {
    return units.isNotEmpty && units.every((unit) => unit.isValid);
  }

  static bool validateItemUnitList(List<ItemUnit> units) {
    return units.isNotEmpty && units.every((unit) => unit.isValid);
  }

  // ==================== CONVERSION HELPERS ====================
  static List<ItemUnit> convertUomModelsToItemUnits(List<UomModel> uomModels) {
    return uomModels.where((uom) => uom.isValid).map((uom) => ItemUnit.fromUomModel(uom)).toList();
  }

  static List<UomModel> convertItemUnitsToUomModels(List<ItemUnit> itemUnits) {
    return itemUnits
        .where((unit) => unit.isValid)
        .map((unit) => UomModel(
              uomEntry: unit.uomEntry,
              uomName: unit.uomName,
              baseQty: unit.baseQty.toDouble(),
            ))
        .toList();
  }

  // ==================== SEARCH AND FILTER ====================
  static UomModel? findUomByEntry(List<UomModel> units, int uomEntry) {
    try {
      return units.firstWhere((unit) => unit.uomEntry == uomEntry);
    } catch (e) {
      return null;
    }
  }

  static ItemUnit? findItemUnitByEntry(List<ItemUnit> units, int uomEntry) {
    try {
      return units.firstWhere((unit) => unit.uomEntry == uomEntry);
    } catch (e) {
      return null;
    }
  }

  static UomModel? findUomByName(List<UomModel> units, String uomName) {
    try {
      return units.firstWhere((unit) => unit.uomName.toLowerCase() == uomName.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  static ItemUnit? findItemUnitByName(List<ItemUnit> units, String uomName) {
    try {
      return units.firstWhere((unit) => unit.uomName.toLowerCase() == uomName.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  // ==================== STATISTICS ====================
  static Map<String, dynamic> getUnitsStatistics(List<UomModel> units) {
    if (units.isEmpty) {
      return {
        'totalUnits': 0,
        'baseUnits': 0,
        'minBaseQty': 0.0,
        'maxBaseQty': 0.0,
        'avgBaseQty': 0.0,
      };
    }

    List<double> baseQties = units.map((u) => u.baseQty).toList();
    int baseUnitsCount = units.where((u) => u.isBaseUnit).length;

    return {
      'totalUnits': units.length,
      'baseUnits': baseUnitsCount,
      'minBaseQty': baseQties.reduce((a, b) => a < b ? a : b),
      'maxBaseQty': baseQties.reduce((a, b) => a > b ? a : b),
      'avgBaseQty': baseQties.reduce((a, b) => a + b) / baseQties.length,
    };
  }

  static Map<String, dynamic> getItemUnitsStatistics(List<ItemUnit> units) {
    if (units.isEmpty) {
      return {
        'totalUnits': 0,
        'baseUnits': 0,
        'minBaseQty': 0,
        'maxBaseQty': 0,
        'avgBaseQty': 0.0,
      };
    }

    List<int> baseQties = units.map((u) => u.baseQty).toList();
    int baseUnitsCount = units.where((u) => u.isBaseUnit).length;

    return {
      'totalUnits': units.length,
      'baseUnits': baseUnitsCount,
      'minBaseQty': baseQties.reduce((a, b) => a < b ? a : b),
      'maxBaseQty': baseQties.reduce((a, b) => a > b ? a : b),
      'avgBaseQty': baseQties.reduce((a, b) => a + b) / baseQties.length,
    };
  }
}
