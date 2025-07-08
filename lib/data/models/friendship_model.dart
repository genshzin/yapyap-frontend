class Friendship {
  final String id;
  final String requesterId;
  final String recipientId;
  final String requesterName; 
  final String recipientName; 
  final String status;
  final DateTime createdAt;
  final String? requesterAvatar;
  final String? recipientAvatar;

  Friendship({
    required this.id,
    required this.requesterId,
    required this.recipientId,
    required this.requesterName,
    required this.recipientName,
    required this.status,
    required this.createdAt,
    this.requesterAvatar,
    this.recipientAvatar,
  });

  factory Friendship.fromJson(Map<String, dynamic> json) {
    // Handle recipient which can be either an object with _id and username 
    // or just a string ID
    String recipientId;
    String recipientName = 'Unknown User';
    String? recipientAvatar;
    
    if (json['recipient'] is String) {
      recipientId = json['recipient'];
    } else if (json['recipient'] is Map) {
      recipientId = json['recipient']['_id'] ?? '';
      recipientName = json['recipient']['username'] ?? 'Unknown User';
      recipientAvatar = json['recipient']['profilePictureUrl'];
    } else {
      recipientId = '';
    }

    return Friendship(
      id: json['_id'] as String,
      requesterId: json['requester']['_id'] as String,
      recipientId: recipientId,
      requesterName: json['requester']['username'] as String,
      recipientName: recipientName,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      requesterAvatar: json['requester']['profilePictureUrl'],
      recipientAvatar: recipientAvatar,
    );
  }
}