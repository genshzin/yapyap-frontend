class ApiConstants {
  // Base URLs
  static const String baseUrl = 'http://localhost:3000';
  static const String socketUrl = 'http://localhost:3000';
  
  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';
  
  // User endpoints
  static const String userSearch = '/api/users/search';
  
  // Chat endpoints
  static const String chatRooms = '/chat/rooms';
  static const String chatMessages = '/chat/messages';
  static const String sendMessage = '/chat/messages';
  static const String markRead = '/chat/messages/read';
  
  // Socket events 
  static const String joinChats = 'join_chats';
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
}
