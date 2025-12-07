import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

import 'items_page.dart';
import 'package:spot_it/widgets/add_item_form.dart';
import 'package:spot_it/models/lost_item.dart';

class ActionChoicePage extends StatefulWidget {
  const ActionChoicePage({super.key});

  @override
  State<ActionChoicePage> createState() => _ActionChoicePageState();
}

class _ActionChoicePageState extends State<ActionChoicePage> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    // simple fade-in for the row of cards
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() => _show = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('What would you like to do?'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'Campus Lost & Found',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose an action',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 32),

            // HORIZONTAL CARDS WITH CONTAINER TRANSFORM
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _show ? 1 : 0,
              child: Row(
                children: [
                  // REPORT CARD
                  Expanded(
                    child: OpenContainer(
                      closedElevation: 0,
                      openElevation: 0,
                      closedColor: const Color(0xFF151515),
                      openColor: Theme.of(context).scaffoldBackgroundColor,
                      transitionDuration: const Duration(milliseconds: 450),
                      closedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      openBuilder: (context, _) => const ReportItemPage(),
                      closedBuilder: (context, openContainer) {
                        return _ActionCard(
                          icon: Icons.report_gmailerrorred_outlined,
                          title: 'Report',
                          subtitle: 'Lost / found item',
                          onTap: openContainer,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 20),

                  // CLAIM CARD
                  Expanded(
                    child: OpenContainer(
                      closedElevation: 0,
                      openElevation: 0,
                      closedColor: const Color(0xFF151515),
                      openColor: Theme.of(context).scaffoldBackgroundColor,
                      transitionDuration: const Duration(milliseconds: 450),
                      closedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      openBuilder: (context, _) => const ItemsPage(),
                      closedBuilder: (context, openContainer) {
                        return _ActionCard(
                          icon: Icons.search_outlined,
                          title: 'Claim',
                          subtitle: 'Find your item',
                          onTap: openContainer,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// PURE CONTENT CARD – tap is handled by OpenContainer
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: Colors.white24,
        highlightColor: Colors.white10,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 42),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// FULL-SCREEN REPORT PAGE (reusing your AddItemForm)
class ReportItemPage extends StatelessWidget {
  const ReportItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AddItemForm(
          onSubmit: (LostItem item) {
            // TODO: send to backend later
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item reported (dummy frontend)')),
            );
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
