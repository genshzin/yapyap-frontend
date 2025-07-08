import 'user_model.dart';
import 'message_model.dart';

class Chat {
  final String id;
  final List<User> participants;
  final String type;
  Message? lastMessage;
  final DateTime createdAt;
  DateTime updatedAt;
  final bool isActive;
  int unreadCount; 

  Chat({
    required this.id,
    required this.participants,
    this.type = 'direct',
    this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.unreadCount = 0,
  });

  
  void updateUnreadCount(int count) {
    unreadCount = count;
  }

  void markAsRead() {
    unreadCount = 0;
  }  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['_id'] ?? json['id'] ?? '',
      participants: json['participants'] != null 
          ? (json['participants'] as List)
              .map((e) => e is Map<String, dynamic> ? User.fromJson(e) : User.fromJson({'_id': e.toString(), 'username': 'Unknown', 'email': '', 'createdAt': DateTime.now().toIso8601String()}))
              .toList()
          : [],
      type: json['type'] ?? 'direct',
      lastMessage: json['lastMessage'] != null 
          ? (json['lastMessage'] is Map<String, dynamic> 
              ? Message.fromJson(json['lastMessage']) 
              : null)
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      isActive: json['isActive'] ?? true,
      unreadCount: json['unreadCount'] ?? 0,
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

  User? getOtherParticipant(String currentUserId) {
    if (type == 'direct' && participants.length == 2) {
      return participants.firstWhere(
        (user) => user.id != currentUserId,
      );
    }
    return null;
  }

  String getDisplayName(String currentUserId) {
    if (type == 'direct') {
      final otherUser = getOtherParticipant(currentUserId);
      return otherUser?.username ?? 'Unknown User';
    }
    return 'Group Chat'; 
  }
}
