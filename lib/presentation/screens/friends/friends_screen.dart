import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/friendship_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart'; 

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final friendshipProvider = context.read<FriendshipProvider>();
        friendshipProvider.loadFriendRequests();
        friendshipProvider.loadFriends();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  
  void _navigateToChat(String friendId, String friendName, String? friendAvatar) async {
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      
      final chatProvider = context.read<ChatProvider>();
      final result = await chatProvider.createOrGetChatWith(friendId);

      
      if (context.mounted) Navigator.pop(context);
      
      if (result != null && context.mounted) {
        
        await Navigator.pushNamed(
          context,
          '/chat',
          arguments: {
            'chatId': result.id,
            'otherUser': {
              'id': friendId,
              'username': friendName,
              'avatar': friendAvatar,
            },
          },
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open chat')),
        );
      }
    } catch (e) {
      
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendshipProvider = Provider.of<FriendshipProvider>(context);
    final currentUserId = Provider.of<AuthProvider>(context).user?.id;

    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'Friends'),
              Tab(text: 'Requests'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                
                friendshipProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : friendshipProvider.friends.isEmpty
                        ? const Center(child: Text('No friends found.'))
                        : ListView.builder(
                            itemCount: friendshipProvider.friends.length,
                            itemBuilder: (context, index) {
                              final friend = friendshipProvider.friends[index];
                              final friendName = friend.requesterId == currentUserId
                                  ? friend.recipientName
                                  : friend.requesterName;
                              final friendAvatar = friend.requesterId == currentUserId
                                  ? friend.recipientAvatar
                                  : friend.requesterAvatar;
                              final friendId = friend.requesterId == currentUserId
                                  ? friend.recipientId
                                  : friend.requesterId;

                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () => _navigateToChat(
                                      friendId, 
                                      friendName,
                                      friendAvatar
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: (friendAvatar != null && friendAvatar.isNotEmpty) 
                                            ? NetworkImage(friendAvatar)
                                            : null,
                                        child: (friendAvatar == null || friendAvatar.isEmpty)
                                            ? Text(friendName.substring(0, 1).toUpperCase())
                                            : null,
                                      ),
                                      title: Text(friendName),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                    title: const Text('Delete Friend'),
                                                    content: Text(
                                                        'Are you sure you want to delete $friendName from your friends?'),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(ctx).pop(),
                                                          child: const Text('Cancel')),
                                                      TextButton(
                                                          onPressed: () {
                                                            friendshipProvider
                                                                .deleteFriendship(friend.id);
                                                            Navigator.of(ctx).pop();
                                                          },
                                                          child: const Text('Delete',
                                                              style: TextStyle(
                                                                  color: Colors.red))),
                                                    ],
                                                  ));
                                        },
                                      ),
                                    ),
                                  ),
                                  const Divider(),
                                ],
                              );
                            },
                          ),

                
                friendshipProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : friendshipProvider.friendRequests.isEmpty
                        ? const Center(child: Text('No friend requests found.'))
                        : ListView.builder(
                            itemCount: friendshipProvider.friendRequests.length,
                            itemBuilder: (context, index) {
                              final request = friendshipProvider.friendRequests[index];
                              final requesterName = request.requesterName;
                              final requesterAvatar = request.requesterAvatar;

                              return Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: (requesterAvatar != null && requesterAvatar.isNotEmpty) 
                                          ? NetworkImage(requesterAvatar)
                                          : null,
                                      child: (requesterAvatar == null || requesterAvatar.isEmpty)
                                          ? Text(requesterName.substring(0, 1).toUpperCase())
                                          : null,
                                    ),
                                    title: Text(
                                      requesterName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: const Text('Wants to be your friend'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check, color: Colors.green),
                                          onPressed: () {
                                            friendshipProvider.acceptFriendRequest(
                                                request.requesterId);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, color: Colors.red),
                                          onPressed: () {
                                            friendshipProvider.declineFriendRequest(
                                                request.requesterId);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(),
                                ],
                              );
                            },
                          ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/user-search');
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}