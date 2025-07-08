import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../core/constants/api_constants.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onNavigationTap;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onNavigationTap,
  });
  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        Navigator.pop(context);
        onNavigationTap(index);
      },
      children: [
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user;
            String? avatarUrl;
            if (user != null && user.id.isNotEmpty) {
              avatarUrl = '${ApiConstants.baseUrl}/api/users/${user.id}/profile-picture';
            }
            
            return DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryFixed,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: avatarUrl == null
                        ? Icon(
                            Icons.person,
                            size: 30,
                            color: Theme.of(context).colorScheme.onPrimary,
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user?.username ?? 'User',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    user?.email ?? 'No email',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          },
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.people),
          label: Text('Friends'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.chat),
          label: Text('Chat'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.person),
          label: Text('Profile'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: () async {
            Navigator.pop(context);
            await _handleLogout(context);
          },
        ),
      ],
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }
}