import 'package:flutter/material.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/chat/user_search_screen.dart';
import '../presentation/screens/chat/chat_screen.dart';
import '../presentation/screens/friends/friends_screen.dart';
import '../presentation/widgets/main_navigation.dart';


class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const MainNavigation(),
        );
      case '/friends':
        return MaterialPageRoute(
          builder: (_) => const FriendsScreen(),
        );
      case '/friend-requests':
        // This will navigate to the friends screen
        // The tab selection will need to be handled separately
        return MaterialPageRoute(
          builder: (_) => const FriendsScreen(),
        );
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case '/register':
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );
      case '/user-search':
        return MaterialPageRoute(
          builder: (_) => const UserSearchScreen(),
        );
      case '/chat':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: args?['chatId'],
            otherUser: args?['otherUser'],
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
    }
  }
}