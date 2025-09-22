import 'package:flutter/material.dart';

class ProductCardState {
  final Color borderColor;
  final Color backgroundColor;
  final String statusText;
  final bool isDeleted;
  final bool isNew;
  final bool isModified;

  const ProductCardState({
    required this.borderColor,
    required this.backgroundColor,
    required this.statusText,
    required this.isDeleted,
    required this.isNew,
    required this.isModified,
  });
}
