import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResponsiveHelper {
  // الحصول على عرض الشاشة
  static double get screenWidth => Get.width;

  // الحصول على ارتفاع الشاشة
  static double get screenHeight => Get.height;

  // تحديد نوع الجهاز
  static bool get isMobile => screenWidth < 600;
  static bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  static bool get isDesktop => screenWidth >= 1024;

  // حساب العرض المتجاوب (نسبة من عرض الشاشة)
  static double width(double percentage) {
    return screenWidth * (percentage / 100);
  }

  // حساب الارتفاع المتجاوب (نسبة من ارتفاع الشاشة)
  static double height(double percentage) {
    return screenHeight * (percentage / 100);
  }

  // حساب حجم الخط المتجاوب
  static double fontSize(double size) {
    if (isMobile) {
      return size;
    } else if (isTablet) {
      return size * 1.2;
    } else {
      return size * 1.4;
    }
  }

  // حساب المسافات المتجاوبة (padding & margin)
  static double spacing(double size) {
    if (isMobile) {
      return size;
    } else if (isTablet) {
      return size * 1.3;
    } else {
      return size * 1.5;
    }
  }

  // حساب حجم الأيقونة المتجاوب
  static double iconSize(double size) {
    if (isMobile) {
      return size;
    } else if (isTablet) {
      return size * 1.3;
    } else {
      return size * 1.5;
    }
  }

  // حساب عرض الحاوية (Container) بحد أقصى
  static double containerWidth({double maxWidth = 1200}) {
    if (screenWidth > maxWidth) {
      return maxWidth;
    }
    return screenWidth * 0.9; // 90% من عرض الشاشة
  }

  // الحصول على عدد الأعمدة المناسب للـ GridView
  static int getGridColumns({int mobile = 1, int tablet = 2, int desktop = 3}) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }

  // الحصول على النسبة المناسبة للـ GridView
  static double getAspectRatio({
    double mobile = 1.0,
    double tablet = 1.2,
    double desktop = 1.5,
  }) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }

  // دالة لإرجاع قيم مختلفة حسب حجم الشاشة
  static T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  // الحصول على Padding متجاوب
  static EdgeInsets getPadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: spacing(left ?? horizontal ?? all ?? 0),
      right: spacing(right ?? horizontal ?? all ?? 0),
      top: spacing(top ?? vertical ?? all ?? 0),
      bottom: spacing(bottom ?? vertical ?? all ?? 0),
    );
  }

  // الحصول على BorderRadius متجاوب
  static BorderRadius getBorderRadius(double radius) {
    return BorderRadius.circular(spacing(radius));
  }

  // الحصول على حجم الـ SizedBox المتجاوب
  static SizedBox verticalSpace(double size) {
    return SizedBox(height: spacing(size));
  }

  static SizedBox horizontalSpace(double size) {
    return SizedBox(width: spacing(size));
  }

  // الحصول على TextStyle متجاوب
  static TextStyle getTextStyle({
    required double fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
  }) {
    return TextStyle(
      fontSize: ResponsiveHelper.fontSize(fontSize),
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }

  // دالة لحساب الحجم بناءً على حجم الشاشة
  // مفيدة للصور والأيقونات
  static double scaledSize(double size) {
    // استخدام عرض الشاشة كمرجع (375 هو عرض iPhone القياسي)
    double scaleFactor = screenWidth / 375;
    return size * scaleFactor;
  }

  // الحصول على MediaQuery
  static MediaQueryData get mediaQuery => MediaQuery.of(Get.context!);

  // الحصول على SafeArea padding
  static EdgeInsets get safeAreaPadding => mediaQuery.padding;

  // التحقق من الاتجاه
  static bool get isPortrait => mediaQuery.orientation == Orientation.portrait;
  static bool get isLandscape => mediaQuery.orientation == Orientation.landscape;
}

// Extension مساعد للأرقام
extension ResponsiveNum on num {
  double get w => ResponsiveHelper.width(toDouble());
  double get h => ResponsiveHelper.height(toDouble());
  double get sp => ResponsiveHelper.fontSize(toDouble());
  double get r => ResponsiveHelper.spacing(toDouble());

  SizedBox get verticalSpace => ResponsiveHelper.verticalSpace(toDouble());
  SizedBox get horizontalSpace => ResponsiveHelper.horizontalSpace(toDouble());
}
