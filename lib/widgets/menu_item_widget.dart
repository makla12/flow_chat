import 'package:flutter/material.dart';

class MenuItemWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const MenuItemWidget({
    Key? key,
    required this.icon,
    required this.text,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: color)),
      onTap: () {
        // Dodaj logikę po kliknięciu
      },
    );
  }
}
