import '../../core/network/api_client.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final ApiClient _apiClient = ApiClient();  Future<Map<String, dynamic>> getUserChats() async {
    try {
      final response = await _apiClient.get('/chat/rooms');
      
      
      if (response.data != null) {
        
        List<dynamic> chatsData;
        if (response.data is List) {
          chatsData = response.data;
        } else if (response.data['chats'] != null) {
          chatsData = response.data['chats'];
        } else {
          chatsData = [];
        }
        
        final chats = chatsData
            .map((json) => json is Map<String, dynamic> ? Chat.fromJson(json) : null)
            .where((chat) => chat != null)
            .cast<Chat>()
            .toList();


        return {
          'success': true,
          'chats': chats,
        };
      } else {
        return {
          'success': true,
          'chats': <Chat>[],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load chats: $e',
      };
    }
  }Future<Map<String, dynamic>> getChatMessages(String chatId) async {
    try {
      final response = await _apiClient.get(
        '/chat/messages',
        queryParameters: {'chatId': chatId},
      );
      
      
      if (response.data != null) {
        
        final messagesData = response.data['messages'];
        if (messagesData != null && messagesData is List) {
          final messages = (messagesData)
              .map((json) => json is Map<String, dynamic> ? Message.fromJson(json) : null)
              .where((message) => message != null)
              .cast<Message>()
              .toList();

          
          return {
            'success': true,
            'messages': messages,
            'pagination': response.data['pagination'],
          };
        }
      }
      
      return {
        'success': true,
        'messages': <Message>[],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load messages: $e',
      };
    }
  }
  Future<Map<String, dynamic>> sendMessage(String chatId, String content) async {
    try {
      final response = await _apiClient.post(
        '/chat/messages',
        data: {
          'chatId': chatId,
          'content': content,
        },
      );

      if (response.data != null) {
        return {
          'success': true,
          'message': Message.fromJson(response.data),
        };
      } else {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send message: $e',
      };
    }
  }  Future<Map<String, dynamic>> createOrGetChat(String participantId) async {
    try {
      final response = await _apiClient.post(
        '/chat/rooms',
        data: {'participantId': participantId},
      );

      if (response.data != null) {
        
        final chatData = response.data;
        
        if (chatData is Map<String, dynamic>) {
          final chat = Chat.fromJson(chatData);
          
          return {
            'success': true,
            'chat': chat,
          };
        } else {
          return {
            'success': false,
            'message': 'Unexpected response format',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create chat: $e',
      };
    }
  }

  Future<Map<String, dynamic>> markMessagesAsRead(String chatId, List<String> messageIds) async {
    try {
      final response = await _apiClient.patch(
        '/chat/messages/read',
        data: {
          'chatId': chatId,
          'messageIds': messageIds,
        },
      );


      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to mark messages as read: $e',
      };
    }
  }
}