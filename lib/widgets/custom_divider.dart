import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final Color dividerColor;

  const CustomDivider({Key? key, required this.dividerColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: dividerColor,
    );
  }
}
