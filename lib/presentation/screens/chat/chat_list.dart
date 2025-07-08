import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/friendship_provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with WidgetsBindingObserver {
  ChatProvider? _chatProvider;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final chatProvider = context.read<ChatProvider>();
        final authProvider = context.read<AuthProvider>();
        final friendshipProvider = context.read<FriendshipProvider>();

        if (authProvider.user?.id != null) {
          chatProvider.setCurrentUserId(authProvider.user!.id);
        }

        chatProvider.loadChats();
        friendshipProvider.loadFriends(); 
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatProvider = context.read<ChatProvider>();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted && _chatProvider != null) {
      _chatProvider!.loadChats();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/user-search');
        },
        child: const Icon(Icons.add),
      ),      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoading && chatProvider.chats.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (chatProvider.chats.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No chats yet'),
                  Text('Start a conversation!'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chatProvider.chats.length,
            itemBuilder: (context, index) {
              final chat = chatProvider.chats[index];
              final currentUserId = context.read<AuthProvider>().user?.id;
              final otherUser = chat.getOtherParticipant(currentUserId ?? '');

              return ListTile(
              leading: CircleAvatar(
                  backgroundImage: (otherUser?.avatar != null && otherUser!.avatar!.isNotEmpty)
                      ? NetworkImage(otherUser.avatar!)
                      : null,
                  child: (otherUser?.avatar == null || otherUser!.avatar!.isEmpty)
                      ? Text(otherUser?.username.substring(0, 1).toUpperCase() ?? 'U')
                      : null,
                ),
                title: Text(otherUser?.username ?? 'Unknown User'),
                subtitle: chat.lastMessage != null
                    ? Text(
                        chat.lastMessage!.content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : const Text('No messages yet'),
                trailing: chat.unreadCount > 0
                    ? Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${chat.unreadCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      )
                    : null,
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    '/chat',
                    arguments: {
                      'chatId': chat.id, 
                      'otherUser': otherUser?.toJson(),
                    },
                  );
                  
                  if (mounted && _chatProvider != null) {
                    await _chatProvider!.loadChats();
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}