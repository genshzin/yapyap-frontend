import 'user_model.dart';

class Message {
  final String id;
  final String chatId;
  final User sender;
  String content;
  final String type;
  final DateTime createdAt;
  bool edited;
  DateTime? editedAt;
  final List<ReadReceipt> readBy;
  final String? replyTo;
  DateTime? deletedAt;
  bool isDeleted ;

  Message({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.content,
    this.type = 'text',
    required this.createdAt,
    this.edited = false,
    this.editedAt,
    this.readBy = const [],
    this.replyTo,
    this.deletedAt,
    this.isDeleted = false,
  });
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? json['id'] ?? '',
      chatId: json['chatId'] ?? '',
      sender: json['sender'] != null 
          ? (json['sender'] is Map<String, dynamic> 
              ? User.fromJson(json['sender'])
              : User.fromJson({
                  '_id': json['sender'].toString(),
                  'username': 'Unknown',
                  'email': '',
                  'createdAt': DateTime.now().toIso8601String()
                }))
          : User.fromJson({
              '_id': 'unknown',
              'username': 'Unknown',
              'email': '',
              'createdAt': DateTime.now().toIso8601String()
            }),
      content: json['content'] ?? '',
      type: json['type'] ?? 'text',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      edited: json['edited'] ?? false,
      editedAt: json['editedAt'] != null 
          ? DateTime.parse(json['editedAt']) 
          : null,
      readBy: json['readBy'] != null && json['readBy'] is List
          ? (json['readBy'] as List)
              .map((e) => e is Map<String, dynamic> ? ReadReceipt.fromJson(e) : null)
              .where((e) => e != null)
              .cast<ReadReceipt>()
              .toList()
          : [],
      replyTo: json['replyTo'],
      deletedAt: json['deletedAt'] != null 
          ? DateTime.parse(json['deletedAt']) 
          : null,
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'sender': sender.toJson(),
      'content': content,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'edited': edited,
      'editedAt': editedAt?.toIso8601String(),
      'readBy': readBy.map((e) => e.toJson()).toList(),
      'replyTo': replyTo,
      'deletedAt': deletedAt?.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  bool isReadBy(String userId) {
    return readBy.any((receipt) => receipt.userId == userId);
  }
}

class ReadReceipt {
  final String userId;
  final DateTime readAt;

  ReadReceipt({
    required this.userId,
    required this.readAt,
  });
  factory ReadReceipt.fromJson(Map<String, dynamic> json) {
    return ReadReceipt(
      userId: json['user'] ?? json['userId'] ?? '',
      readAt: json['readAt'] != null 
          ? DateTime.parse(json['readAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'readAt': readAt.toIso8601String(),
    };
  }
}
