import 'package:flutter/material.dart';

class MultipiaiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onSearchTap;

  const MultipiaiAppBar({
    super.key,
    this.onSearchTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.black),
      titleSpacing: 4,
      title: Row(
        children: [
          Image.asset(
            'assets/images/MultiplAI_Logo_single.png',
            height: 24,
          ),
          const SizedBox(width: 8),
          const Text(
            'MultipIAI',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onSearchTap,
          icon: const Icon(Icons.search),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz),
          onSelected: (value) {
            // TODO: handle actions if needed
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'settings',
              child: Text('Settings'),
            ),
            PopupMenuItem(
              value: 'about',
              child: Text('About'),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Text('Logout'),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
