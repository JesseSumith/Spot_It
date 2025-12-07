import 'package:flutter/material.dart';

import '../screens/profile_page.dart';
import '../screens/settings_page.dart';
import '../screens/about_page.dart';

class AppDrawer extends StatelessWidget {
  final String currentPage; // "home", "profile", "settings", "about"

  const AppDrawer({super.key, this.currentPage = "home"});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF000000),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👇 TOP PROFILE SECTION – NOW CLICKABLE
              Padding(
                padding: const EdgeInsets.all(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.pop(context); // close drawer
                    if (currentPage != "profile") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 22, child: Text('A')),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'A',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'sumithjesse@gmail.com',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(color: Colors.white24, height: 1),

              // MENU ITEMS
              _drawerItem(
                context,
                label: "Home",
                icon: Icons.home_outlined,
                selected: currentPage == "home",
                onTap: () => Navigator.pop(context),
              ),

              _drawerItem(
                context,
                label: "Profile",
                icon: Icons.person_outline,
                selected: currentPage == "profile",
                onTap: () {
                  Navigator.pop(context);
                  if (currentPage != "profile") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                  }
                },
              ),

              _drawerItem(
                context,
                label: "Settings",
                icon: Icons.settings_outlined,
                selected: currentPage == "settings",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
              ),

              _drawerItem(
                context,
                label: "About",
                icon: Icons.info_outline,
                selected: currentPage == "about",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutPage()),
                  );
                },
              ),

              // 👇 removed Spacer + "Made with Flutter"
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? Colors.white10 : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white30,
        highlightColor: Colors.white10,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: selected ? Colors.white : Colors.white70,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
