import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue[900],
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {},
      ),
      title: Text('FlowChat', style: TextStyle(color: Colors.white)),
      actions: [
        Icon(Icons.signal_cellular_alt, color: Colors.white),
        SizedBox(width: 10),
        Icon(Icons.more_vert, color: Colors.white),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}