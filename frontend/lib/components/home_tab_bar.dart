import 'package:flutter/material.dart';

class HomeTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<Map<String, dynamic>> categories;
  final VoidCallback onAddPressed;

  const HomeTabBar({
    required this.controller,
    required this.categories,
    required this.onAddPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      indicatorColor: Colors.white,
      labelColor: Colors.white,
      dividerHeight: 0,
      unselectedLabelColor: const Color.fromARGB(250, 227, 227, 227),
      controller: controller,
      isScrollable: true,
      labelPadding: EdgeInsets.symmetric(
        horizontal: 12,
      ), // veya EdgeInsets.zero

      tabs: [
        Tab(
          icon: IconButton(
            icon: const Icon(Icons.add, size: 25),
            onPressed: onAddPressed,
            color: Colors.white,
          ),
        ),
        const Tab(text: "İlgi Alanları"),
        const Tab(text: "Takip Ettiklerin"),
        ...categories.map((c) => Tab(text: c['name'])).toList(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
