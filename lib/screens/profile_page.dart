import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Avatar
            const CircleAvatar(
              radius: 40,
              child: Text('A', style: TextStyle(fontSize: 32)),
            ),

            const SizedBox(height: 16),

            // Name
            Text(
              'A',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            // Email
            Text(
              'sumithjesse@gmail.com',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 24),

            // Some basic info tiles
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.badge_outlined),
                    title: Text('Role'),
                    subtitle: Text('Student'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.account_circle_outlined),
                    title: Text('Username'),
                    subtitle: Text('campus_user'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Log out button (dummy for now)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: hook into real auth later
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logout not implemented yet')),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
