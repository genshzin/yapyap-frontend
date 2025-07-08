class ApiConstants {
  // Base URLs
  static const String baseUrl = 'http://localhost:3000';
  static const String socketUrl = 'http://localhost:3000';
  // static const String baseUrl = 'http://10.0.2.2:3000';
  // static const String socketUrl = 'http://10.0.2.2:3000';
  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';
  
  // User endpoints
  static const String userSearch = '/api/users/search';

  // Friendship endpoints
  static const String sendFriendRequest = '/friendships/send';
  static const String acceptFriendRequest = '/friendships/accept';
  static const String declineFriendRequest = '/friendships/decline';
  static const String deleteFriendship = '/friendships/delete';
  static const String listFriends = '/friendships/friends';
  static const String listFriendRequests = '/friendships/requests';
  
  // Chat endpoints
  static const String chatRooms = '/chat/rooms';
  static const String chatMessages = '/chat/messages';
  static const String sendMessage = '/chat/messages';
  static const String markRead = '/chat/messages/read';
    // Socket events 
  static const String joinChats = 'join_chats';
  static const String joinChatRoom = 'join_chat_room';
  static const String leaveChatRoom = 'leave_chat_room';
  static const String chatRoomJoined = 'chat_room_joined';
  static const String chatRoomLeft = 'chat_room_left';
  static const String sendMessageEvent = 'send_message';
  static const String newMessage = 'new_message';
  static const String typingStart = 'typing_start';
  static const String typingStop = 'typing_stop';
  static const String userTyping = 'user_typing';
  static const String userStopTyping = 'user_stop_typing';
  static const String markReadEvent = 'mark_read';
  static const String messagesRead = 'messages_read';
  static const String userStatusChange = 'user_status_change';
  static const String onlineCount = 'online_count';
  static const String editMessage = 'edit_message';
  static const String deleteMessage = 'delete_message';
  static const String messageEdited = 'message_edited';
  static const String messageDeleted = 'message_deleted';
}
