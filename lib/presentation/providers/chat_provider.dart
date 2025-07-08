import 'package:flutter/material.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/message_model.dart';
import '../../data/services/chat_service.dart';
import '../../core/network/socket_client.dart';
import '../../core/constants/api_constants.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  final SocketClient _socketClient = SocketClient();

  List<Chat> _chats = [];
  final Map<String, List<Message>> _messagesMap = {}; 
  bool _isLoading = false;
  String? _error;
  String? _currentChatId;
  String? _currentUserId; 

  final Map<String, Set<String>> _typingUsers = {}; 

  List<Chat> get chats => _chats;
  List<Message> get messages => _currentChatId != null ? (_messagesMap[_currentChatId!] ?? []) : [];
  bool get isLoading => _isLoading;
  String? get error => _error;

  ChatProvider() {
    _initializeSocket();
  }

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }
  Set<String> getTypingUsers(String chatId) {
    return _typingUsers[chatId] ?? {};
  }
  void _initializeSocket() {
    _socketClient.connect();
    
    
    _socketClient.on('connect', (data) {
    });
    
    _socketClient.on('disconnect', (data) {
    });
      _socketClient.on('connect_error', (data) {
    });   
    _socketClient.on('chats_joined', (data) {
    });
    _socketClient.on('chat_room_joined', (data) {
    });
    _socketClient.on('chat_room_left', (data) {
    });
    _socketClient.on(ApiConstants.newMessage, (data) {
      try {
        
        if (data != null && data['message'] != null) {
          final message = Message.fromJson(data['message']);
          final chatId = message.chatId;
          final usersInRoom = data['usersInRoom'] as List<dynamic>? ?? [];

          if (_messagesMap[chatId] == null) {
            _messagesMap[chatId] = [];
          }

          final existingIndex = _messagesMap[chatId]!.indexWhere((m) => 
            m.content == message.content && 
            m.createdAt.difference(message.createdAt).abs().inSeconds < 10
          );
            
          if (existingIndex == -1) {
            _messagesMap[chatId]!.add(message);            

            _updateChatListWithNewMessage(chatId, message, usersInRoom);
            
          } 
        }
      } catch (e) {
      }
    });
    _socketClient.on('user_typing', (data) {
      try {
        if (data != null && data['username'] != null && data['chatId'] != null) {
          final username = data['username'];
          final chatId = data['chatId'];
      
          if (_typingUsers[chatId] == null) {
            _typingUsers[chatId] = <String>{};
          }
          _typingUsers[chatId]!.add(username);

          if (chatId == _currentChatId) {
            notifyListeners();
          }
        }
      } catch (e) {
      }
    });

    _socketClient.on('user_stop_typing', (data) {
      try {
        if (data != null && data['username'] != null && data['chatId'] != null) {
          final username = data['username'];
          final chatId = data['chatId'];

          _typingUsers[chatId]?.remove(username);
          if (_typingUsers[chatId]?.isEmpty == true) {
            _typingUsers.remove(chatId);
          }

          if (chatId == _currentChatId) {
            notifyListeners();
          }
        }
      } catch (e) {
      }
    });

    _socketClient.on(ApiConstants.messagesRead, (data) {
      try {
        
        if (data != null && data['messageIds'] != null && data['readBy'] != null) {
          final chatId = data['chatId'];
          final readBy = data['readBy'];
          
          
          if (_messagesMap[chatId] != null) {
            for (final message in _messagesMap[chatId]!) {
              if (data['messageIds'].contains(message.id)) {
                
                message.readBy.add(ReadReceipt(
                  userId: readBy,
                  readAt: DateTime.parse(data['readAt']),
                ));
              }
            }
          }
          
          notifyListeners();
        }
      } catch (e) {
      }
    });

    _socketClient.on(ApiConstants.messageEdited, (data) {
      try {
        
        if (data != null && data['message'] != null) {
          final messageData = data['message'];

          final messageId = messageData['_id'];
          final newContent = messageData['content'];
          final chatId = messageData['chatId'];

          if (chatId != null && _messagesMap.containsKey(chatId)) {
            final messageIndex = _messagesMap[chatId]!.indexWhere((m) => m.id == messageId);
            if (messageIndex != -1) {
              _messagesMap[chatId]![messageIndex].content = newContent;
              _messagesMap[chatId]![messageIndex].edited = true;
              _messagesMap[chatId]![messageIndex].editedAt = DateTime.now(); 
              notifyListeners(); 
            }
          }
        }
      } catch (e) {
      }
    });
    
    _socketClient.on(ApiConstants.messageDeleted, (data) {
      try {
        if (data != null){
          final messageId = data['messageId'];
          final deleteType = data['deleteType'];  
          final chatId = data['chatId']; 
          if (chatId != null && _messagesMap[chatId] != null){
            final messageIndex = _messagesMap[chatId]!.indexWhere((m) => m.id == messageId);
            if (messageIndex != -1){
              if (deleteType == 'everyone'){
                 _messagesMap[chatId]![messageIndex].isDeleted = true;
                 _messagesMap[chatId]![messageIndex].deletedAt = DateTime.now();
              }
              
            }
            notifyListeners();
          }
        }
      }
      catch (e) {
      }
    });

  } Future<void> loadChats() async {
    if (_chats.isEmpty) {
      _setLoading(true);
    }
    
    try {
      final result = await _chatService.getUserChats();
      if (result['success']) {
        final newChats = result['chats'] as List<Chat>;
       
        if (_currentChatId != null) {
          final currentChatIndex = newChats.indexWhere((chat) => chat.id == _currentChatId);
          if (currentChatIndex != -1) {
            newChats[currentChatIndex].unreadCount = 0;
          }
        }
        
        _chats = newChats;
        notifyListeners();
      } else {
        _setError(result['message']);
      }
    } catch (e) {
      _setError('Failed to load chats: $e');
    }
    _setLoading(false);
  }Future<void> loadMessages(String chatId) async {
    _currentChatId = chatId;

    if (_messagesMap[chatId] == null || _messagesMap[chatId]!.isEmpty) {
      _setLoading(true);
    }
    
    try {
      final result = await _chatService.getChatMessages(chatId);
        if (result['success']) {
        final messages = result['messages'] as List<Message>;
        _messagesMap[chatId] = messages;
        
        notifyListeners();
      } else {
        _setError(result['message']);
      }
    } catch (e) {
      _setError('Failed to load messages: $e');
    }
    _setLoading(false);
  }  Future<void> loadMessagesAndMarkRead(String chatId, String currentUserId) async {
  
    if (_currentChatId != null && _currentChatId != chatId) {
      _socketClient.emit('leave_chat_room', {'chatId': _currentChatId});
    }
    
    _currentChatId = chatId;
    _currentUserId = currentUserId; 
    
    if (_messagesMap[chatId] == null || _messagesMap[chatId]!.isEmpty) {
      _setLoading(true);
    }
    
    try {
      final result = await _chatService.getChatMessages(chatId);
      
      if (result['success']) {
        final messages = result['messages'] as List<Message>;
        _messagesMap[chatId] = messages;
        
        await _markChatAsReadWithUserId(chatId, messages, currentUserId);
        
        final chatIndex = _chats.indexWhere((chat) => chat.id == chatId);
        if (chatIndex != -1) {
          _chats[chatIndex].unreadCount = 0;
        }
        _socketClient.emit(ApiConstants.joinChats, {});
        
        _socketClient.emit('join_chat_room', {'chatId': chatId});
        
        notifyListeners();
      } else {
        _setError(result['message']);
      }
    } catch (e) {
      _setError('Failed to load messages: $e');
    }
    _setLoading(false);
  }
  Future<void> _markChatAsReadWithUserId(String chatId, List<Message> messages, String currentUserId) async {
    try {
      final unreadMessageIds = messages
          .where((message) => !message.isReadBy(currentUserId))
          .map((message) => message.id)
          .toList();


      if (unreadMessageIds.isNotEmpty) {

        final result = await _chatService.markMessagesAsRead(chatId, unreadMessageIds);
        
        if (result['success']) {
          _socketClient.emit(ApiConstants.markReadEvent, {
            'chatId': chatId,
            'messageIds': unreadMessageIds,
          });

          final chatIndex = _chats.indexWhere((chat) => chat.id == chatId);
          if (chatIndex != -1) {
            _chats[chatIndex].unreadCount = 0;
            notifyListeners();
          }
        }
      } else {
        final chatIndex = _chats.indexWhere((chat) => chat.id == chatId);
        if (chatIndex != -1) {
          _chats[chatIndex].unreadCount = 0;
        }
      }
    } catch (e) {
    }
  }

  Future<void> sendMessage(String chatId, String content) async {
    try {
      
      _socketClient.emit(ApiConstants.sendMessageEvent, {
        'chatId': chatId,
        'content': content,
        'type': 'text',
      });

    } catch (e) {
      _setError('Failed to send message: $e');
    }
  }

  Future<Map<String, dynamic>> createOrGetChat(String participantId) async {
    try {
      final result = await _chatService.createOrGetChat(participantId);
      if (result['success']) {
        final chat = result['chat'];
        final existingIndex = _chats.indexWhere((c) => c.id == chat.id);
        if (existingIndex == -1) {
          _chats.insert(0, chat);
          notifyListeners();
        }
      }
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create chat: $e',
      };
    }
  }

Future<Chat?> createOrGetChatWith(String userId) async {
  try {
    final response = await _chatService.createOrGetChat(userId);
    
    if (response['success']) {
      final chat = response['chat'] as Chat;

      await loadChats();
      
      return chat;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}
  List<Message> getMessagesForChat(String chatId) {
    final messages = _messagesMap[chatId] ?? [];
    
    final uniqueMessages = <Message>[];
    final seen = <String>{};
    
    for (final message in messages) {
      final key = '${message.content}_${message.createdAt.millisecondsSinceEpoch ~/ 10000}'; 
      if (!seen.contains(key)) {
        seen.add(key);
        uniqueMessages.add(message);
      }
    }
    
    _messagesMap[chatId] = uniqueMessages;
    
    return uniqueMessages;
  }  void clearMessages() {
    final previousChatId = _currentChatId;
    
    if (previousChatId != null) {
      _socketClient.emit('leave_chat_room', {'chatId': previousChatId});
    }
    
    _currentChatId = null;
    
    if (previousChatId != null) {
      final chatIndex = _chats.indexWhere((chat) => chat.id == previousChatId);
      if (chatIndex != -1) {
        _chats[chatIndex].unreadCount = 0;
      }
    }
    
    notifyListeners();
  }
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }  
  void startTyping(String chatId) {
    
    _socketClient.emit('typing_start', {
      'chatId': chatId,
    });
    
  }

  void stopTyping(String chatId) {
    
    _socketClient.emit('typing_stop', {
      'chatId': chatId,
    });
    
  }

  bool hasChatsLoaded() => _chats.isNotEmpty;
  
  bool hasMessagesForChat(String chatId) {
    return _messagesMap[chatId] != null && _messagesMap[chatId]!.isNotEmpty;
  }
  
  bool get shouldShowChatListLoading => _isLoading && _chats.isEmpty;
  
  bool shouldShowMessagesLoading(String chatId) {
    return _isLoading && !hasMessagesForChat(chatId);
  }

  void joinSpecificChatRoom(String chatId) {
    _socketClient.emit('join_chat_room', {'chatId': chatId});
  }
    void leaveChatRoom(String chatId) {
    
    _socketClient.emit('leave_chat_room', {'chatId': chatId});
    
  }

  void _updateChatListWithNewMessage(String chatId, Message message, List<dynamic> usersInRoom) {
    final chatIndex = _chats.indexWhere((chat) => chat.id == chatId);
    
    if (chatIndex != -1) {
      final chat = _chats.removeAt(chatIndex);

      chat.lastMessage = message;
      chat.updatedAt = message.createdAt;

      if (_currentUserId != null && 
          message.sender.id != _currentUserId &&
          chatId != _currentChatId &&
          !usersInRoom.contains(_currentUserId)) {
        chat.unreadCount += 1;
      } else {
      }
      
      _chats.insert(0, chat);
      
      notifyListeners();
    } else {

      loadChats();
    }
  }

  
  void editMessage(String messageId, String newContent) {
    if (_currentChatId != null && _messagesMap.containsKey(_currentChatId)) {
      final messageIndex = _messagesMap[_currentChatId]!.indexWhere((m) => m.id == messageId);
      
      if (messageIndex != -1) {
        _messagesMap[_currentChatId]![messageIndex].content = newContent;
        _messagesMap[_currentChatId]![messageIndex].edited = true;
        _messagesMap[_currentChatId]![messageIndex].editedAt = DateTime.now().toUtc();
        notifyListeners();
      }
    }

    _socketClient.emit(ApiConstants.editMessage, {
      'messageId': messageId, 
      'content': newContent,
    });
  }

  void deleteMessage(String messageId, String deleteType) {
    if (_currentChatId != null && _messagesMap.containsKey(_currentChatId)) {
      final messageIndex = _messagesMap[_currentChatId]!.indexWhere((m) => m.id == messageId);
      if (messageIndex != -1) {
        
        _messagesMap[_currentChatId]![messageIndex].isDeleted = true;
        _messagesMap[_currentChatId]![messageIndex].deletedAt = DateTime.now().toUtc();

        notifyListeners();
      }
    }
    _socketClient.emit(ApiConstants.deleteMessage, {
      'messageId': messageId, 
      'deleteType': deleteType
    });
  }
}