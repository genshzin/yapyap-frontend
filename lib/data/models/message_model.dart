import 'user_model.dart';

class Message {
  final String id;
  final String chatId;
  final User sender;
  final String content;
  final String type;
  final DateTime createdAt;
  final bool edited;
  final DateTime? editedAt;
  final List<ReadReceipt> readBy;
  final String? replyTo;

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
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? json['id'],
      chatId: json['chatId'],
      sender: User.fromJson(json['sender']),
      content: json['content'],
      type: json['type'] ?? 'text',
      createdAt: DateTime.parse(json['createdAt']),
      edited: json['edited'] ?? false,
      editedAt: json['editedAt'] != null 
          ? DateTime.parse(json['editedAt']) 
          : null,
      readBy: (json['readBy'] as List?)
          ?.map((e) => ReadReceipt.fromJson(e))
          .toList() ?? [],
      replyTo: json['replyTo'],
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
      userId: json['user'],
      readAt: DateTime.parse(json['readAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'readAt': readAt.toIso8601String(),
    };
  }
}
