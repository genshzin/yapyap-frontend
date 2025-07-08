import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/constants/api_constants.dart';

class ProfilePageView extends StatelessWidget {
  const ProfilePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        String? avatarUrl;
        if (user != null && user.id.isNotEmpty) {
          avatarUrl = '${ApiConstants.baseUrl}/api/users/${user.id}/profile-picture';
        }
        
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (user != null)
                CircleAvatar(
                  radius: 60,
                  backgroundImage: avatarUrl != null 
                      ? NetworkImage(avatarUrl)
                      : null,
                  backgroundColor: Colors.grey.shade200,
                  onBackgroundImageError: (exception, stackTrace) {
                  },
                  child: avatarUrl == null
                      ? Text(
                          user.username.isNotEmpty
                              ? user.username.substring(0, 1).toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                          ),
                        )
                      : null,
                )
              else
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey,
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                'Welcome, ${user?.username ?? "User"}!',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                user?.email ?? "No email",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              if (user != null)
                Text(
                  'Member since ${_formatDate(user.createdAt)}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
            ],
          ),
        );
      },
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}