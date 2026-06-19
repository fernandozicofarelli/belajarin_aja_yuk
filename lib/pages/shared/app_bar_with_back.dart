import 'package:flutter/material.dart';
import '../navigation/main_navigation.dart';

PreferredSizeWidget buildAppBarWithBack(BuildContext context, String title) {
  return AppBar(
    title: Text(title),
    backgroundColor: Colors.blue,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainNavigation(initialIndex: 2),
          ),
        );
      },
    ),
  );
}
