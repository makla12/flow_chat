import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final Color dividerColor;

  const CustomDivider({super.key, required this.dividerColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: dividerColor,
    );
  }
}
