import 'package:flutter/material.dart';

class FloatingAddButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isEnabled;

  const FloatingAddButton({
    super.key,
    required this.onPressed,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: isEnabled ? onPressed : null,
      backgroundColor: isEnabled ? Colors.blue : Colors.grey,
      tooltip: 'إضافة منتج جديد',
      child: const Icon(
        Icons.add,
        color: Colors.white,
      ),
    );
  }
}
