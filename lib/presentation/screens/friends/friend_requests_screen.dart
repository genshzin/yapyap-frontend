import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/friendship_provider.dart';

class FriendRequestsScreen extends StatelessWidget {
  const FriendRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final friendshipProvider = Provider.of<FriendshipProvider>(context);

    return Scaffold(
      body: friendshipProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : friendshipProvider.friendRequests.isEmpty
              ? const Center(child: Text('No friend requests found.'))
              : ListView.builder(
                  itemCount: friendshipProvider.friendRequests.length,
                  itemBuilder: (context, index) {
                    final request = friendshipProvider.friendRequests[index];
                    final requesterAvatar = request.requesterAvatar;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: (requesterAvatar != null && requesterAvatar.isNotEmpty)
                            ? NetworkImage(requesterAvatar)
                            : null,
                        child: (requesterAvatar == null || requesterAvatar.isEmpty)
                            ? Text(request.requesterName.substring(0, 1).toUpperCase())
                            : null,
                      ),
                      title: Text(request.requesterName),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () {
                              friendshipProvider.acceptFriendRequest(request.requesterId);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              friendshipProvider.declineFriendRequest(request.requesterId);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}