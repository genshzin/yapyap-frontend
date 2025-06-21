import 'user_model.dart';
import 'message_model.dart';

class Chat {
  final String id;
  final List<User> participants;
  final String type;
  final Message? lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int? unreadCount;

  Chat({
    required this.id,
    required this.participants,
    this.type = 'direct',
    this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.unreadCount,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['_id'] ?? json['id'],
      participants: (json['participants'] as List)
          .map((e) => User.fromJson(e))
          .toList(),
      type: json['type'] ?? 'direct',
      lastMessage: json['lastMessage'] != null 
          ? Message.fromJson(json['lastMessage']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'] ?? true,
      unreadCount: json['unreadCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants.map((e) => e.toJson()).toList(),
      'type': type,
      'lastMessage': lastMessage?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'unreadCount': unreadCount,
    };
  }

  // Get the other participant in a direct chat
  User? getOtherParticipant(String currentUserId) {
    if (type == 'direct' && participants.length == 2) {
      return participants.firstWhere(
        (user) => user.id != currentUserId,
      );
    }
    return null;
  }

  // Get chat display name
  String getDisplayName(String currentUserId) {
    if (type == 'direct') {
      final otherUser = getOtherParticipant(currentUserId);
      return otherUser?.username ?? 'Unknown User';
    }
    return 'Group Chat'; // For future group chat support
  }
}
