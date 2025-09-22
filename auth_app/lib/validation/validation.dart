class Validation {
  static String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال الكمية';
    }

    double? quantity = double.tryParse(value.trim());
    if (quantity == null || quantity < 0) {
      return 'يرجى إدخال كمية صحيحة';
    }

    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    return null;
  }

  static String? defaultValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }
}
