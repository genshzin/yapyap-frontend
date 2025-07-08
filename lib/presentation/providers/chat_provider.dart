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
  final Map<String, List<Message>> _messagesMap = {}; // Store messages per chatId
  bool _isLoading = false;
  String? _error;
  String? _currentChatId;
  String? _currentUserId; // Add this field

  // Add typing indicator state
  final Map<String, Set<String>> _typingUsers = {}; // chatId -> Set of usernames

  List<Chat> get chats => _chats;
  List<Message> get messages => _currentChatId != null ? (_messagesMap[_currentChatId!] ?? []) : [];
  bool get isLoading => _isLoading;
  String? get error => _error;

  ChatProvider() {
    _initializeSocket();
  }

  // Add method to set current user ID
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }
  Set<String> getTypingUsers(String chatId) {
    return _typingUsers[chatId] ?? {};
  }
  void _initializeSocket() {
    print('ChatProvider: Initializing socket connection...');
    _socketClient.connect();
    
    // Add connection status listeners for debugging
    _socketClient.on('connect', (data) {
      print('ChatProvider: Socket CONNECTED successfully!');
    });
    
    _socketClient.on('disconnect', (data) {
      print('ChatProvider: Socket DISCONNECTED: $data');
    });
      _socketClient.on('connect_error', (data) {
      print('ChatProvider: Socket CONNECTION ERROR: $data');
    });    // Listen for chat join confirmation
    _socketClient.on('chats_joined', (data) {
      print('ChatProvider: Successfully joined chats: $data');
    });
      // Listen for specific chat room join confirmation
    _socketClient.on('chat_room_joined', (data) {
      print('ChatProvider: Successfully joined specific chat room: $data');
    });
      // Listen for specific chat room leave confirmation
    _socketClient.on('chat_room_left', (data) {
      print('ChatProvider: *** RECEIVED CHAT_ROOM_LEFT CONFIRMATION ***');
      print('ChatProvider: Successfully left specific chat room: $data');
      print('ChatProvider: *** END CHAT_ROOM_LEFT CONFIRMATION ***');
    });// Listen for new messages
    _socketClient.on(ApiConstants.newMessage, (data) {
      try {
        print('ChatProvider: Received new message event: $data');
        
        if (data != null && data['message'] != null) {
          final message = Message.fromJson(data['message']);
          final chatId = message.chatId;
          final usersInRoom = data['usersInRoom'] as List<dynamic>? ?? [];
          
          print('ChatProvider: New message - ChatId: $chatId, Sender: ${message.sender.id} (${message.sender.username}), Content: ${message.content}');
          print('ChatProvider: Users in room: $usersInRoom');
          
          // Initialize messages list if needed
          if (_messagesMap[chatId] == null) {
            _messagesMap[chatId] = [];
          }
            
          // Check for duplicates before adding
          final existingIndex = _messagesMap[chatId]!.indexWhere((m) => 
            m.content == message.content && 
            m.createdAt.difference(message.createdAt).abs().inSeconds < 10
          );
            
          if (existingIndex == -1) {
            _messagesMap[chatId]!.add(message);            
            print('ChatProvider: Added socket message - Sender: ${message.sender.id} (${message.sender.username})');
            
            // ✅ UPDATE CHAT LIST IN REAL-TIME
            _updateChatListWithNewMessage(chatId, message, usersInRoom);
            
            // If this is the current chat, notify listeners (already handled in _updateChatListWithNewMessage)
            if (chatId == _currentChatId) {
              print('ChatProvider: Socket message added to current chat');
            }
          } else {
            print('ChatProvider: Duplicate socket message detected, skipping');
          }
        }
      } catch (e) {
        print('Error handling new message: $e');
      }
    });// Listen for typing indicators
    _socketClient.on('user_typing', (data) {
      try {
        print('ChatProvider: Received user_typing event: $data');
        if (data != null && data['username'] != null && data['chatId'] != null) {
          final username = data['username'];
          final chatId = data['chatId'];
            print('ChatProvider: User $username is typing in chat $chatId');
          
          // Add user to typing list
          if (_typingUsers[chatId] == null) {
            _typingUsers[chatId] = <String>{};
          }
          _typingUsers[chatId]!.add(username);
          
          print('ChatProvider: Current typing users for $chatId: ${_typingUsers[chatId]}');
          
          // Only notify if this affects the current chat
          if (chatId == _currentChatId) {
            notifyListeners();
          }
        }
      } catch (e) {
        print('Error handling typing indicator: $e');
      }
    });

    _socketClient.on('user_stop_typing', (data) {
      try {
        print('ChatProvider: Received user_stop_typing event: $data');
        if (data != null && data['username'] != null && data['chatId'] != null) {
          final username = data['username'];
          final chatId = data['chatId'];
            print('ChatProvider: User $username stopped typing in chat $chatId');
          
          // Remove user from typing list
          _typingUsers[chatId]?.remove(username);
          if (_typingUsers[chatId]?.isEmpty == true) {
            _typingUsers.remove(chatId);
          }
          
          print('ChatProvider: Current typing users for $chatId: ${_typingUsers[chatId]}');
          
          // Only notify if this affects the current chat
          if (chatId == _currentChatId) {
            notifyListeners();
          }
        }
      } catch (e) {
        print('Error handling stop typing indicator: $e');
      }
    });

    // Listen for messages read events
    _socketClient.on(ApiConstants.messagesRead, (data) {
      try {
        print('ChatProvider: Received messages read event: $data');
        
        if (data != null && data['messageIds'] != null && data['readBy'] != null) {
          final chatId = data['chatId'];
          final readBy = data['readBy'];
          
          // Update read status in local messages
          if (_messagesMap[chatId] != null) {
            for (final message in _messagesMap[chatId]!) {
              if (data['messageIds'].contains(message.id)) {
                // Add read receipt to message
                message.readBy.add(ReadReceipt(
                  userId: readBy,
                  readAt: DateTime.parse(data['readAt']),
                ));
              }
            }
          }
          
          // Update chat unread count if it's for current user
          // (This would be handled when other users read your messages)
          
          notifyListeners();
        }
      } catch (e) {
        print('Error handling messages read event: $e');
      }
    });
    
    // Server confirmation for message edit
   // CORRECTED CODE
    _socketClient.on(ApiConstants.messageEdited, (data) {
      try {
        print('Received message_edited confirmation from server: $data');
        
        // 1. Check for the nested 'message' object
        if (data != null && data['message'] != null) {
          final messageData = data['message'];

          // 2. Parse data from the nested object
          final messageId = messageData['_id'];
          final newContent = messageData['content'];
          final chatId = messageData['chatId'];

          if (chatId != null && _messagesMap.containsKey(chatId)) {
            final messageIndex = _messagesMap[chatId]!.indexWhere((m) => m.id == messageId);
            if (messageIndex != -1) {
              // 3. Update the local state
              _messagesMap[chatId]![messageIndex].content = newContent;
              _messagesMap[chatId]![messageIndex].edited = true;
              _messagesMap[chatId]![messageIndex].editedAt = DateTime.now(); // Or parse from server if sent

              // 4. Trigger the UI rebuild for the recipient!
              notifyListeners(); 
              print('Successfully updated message $messageId from socket event.');
            }
          }
        }
      } catch (e) {
        print('Error handling message edited event: $e');
      }
    });
    
    // Server confirmation for message delete
    _socketClient.on(ApiConstants.messageDeleted, (data) {
      try {
        print('Received message_deleted confirmation from server: $data');
        if (data != null){
          final messageId = data['messageId'];
          final deleteType = data['deleteType'];  
          final chatId = data['chatId']; // Server should return chatId

          if (chatId != null && _messagesMap[chatId] != null){
            final messageIndex = _messagesMap[chatId]!.indexWhere((m) => m.id == messageId);
            if (messageIndex != -1){
              if (deleteType == 'everyone'){
                 _messagesMap[chatId]![messageIndex].isDeleted = true;
                 _messagesMap[chatId]![messageIndex].deletedAt = DateTime.now();
              }
              // 'me' is handled optimistically and doesn't need server confirmation
              // as it only affects the current user.
            }
            notifyListeners();
          }
        }
      }
      catch (e) {
        print('Error handling message deleted event: $e');
      }
    });

  }  Future<void> loadChats() async {
    // Only show loading for initial load or if we have no chats
    if (_chats.isEmpty) {
      _setLoading(true);
    }
    
    try {
      final result = await _chatService.getUserChats();
      if (result['success']) {
        final newChats = result['chats'] as List<Chat>;
        
        // If we have a current chat, preserve its unread count as 0
        if (_currentChatId != null) {
          final currentChatIndex = newChats.indexWhere((chat) => chat.id == _currentChatId);
          if (currentChatIndex != -1) {
            newChats[currentChatIndex].unreadCount = 0;
            print('ChatProvider: Forced unread count to 0 for current chat $_currentChatId');
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
    print('ChatProvider: Loading messages for chatId: $chatId');
    _currentChatId = chatId;
    
    // Only show loading if we don't have cached messages
    if (_messagesMap[chatId] == null || _messagesMap[chatId]!.isEmpty) {
      _setLoading(true);
    }
    
    try {
      final result = await _chatService.getChatMessages(chatId);
      print('ChatProvider: Service result: $result');
        if (result['success']) {
        final messages = result['messages'] as List<Message>;
        _messagesMap[chatId] = messages;
        print('ChatProvider: Stored ${messages.length} messages for chat $chatId');
        
        notifyListeners();
      } else {
        print('ChatProvider: Error loading messages: ${result['message']}');
        _setError(result['message']);
      }
    } catch (e) {
      print('ChatProvider: Exception loading messages: $e');
      _setError('Failed to load messages: $e');
    }
    _setLoading(false);
  }  Future<void> loadMessagesAndMarkRead(String chatId, String currentUserId) async {
    print('ChatProvider: Loading messages for chatId: $chatId, currentUserId: $currentUserId');
    
    // Leave previous chat room first
    if (_currentChatId != null && _currentChatId != chatId) {
      _socketClient.emit('leave_chat_room', {'chatId': _currentChatId});
      print('ChatProvider: Left previous chat room: $_currentChatId');
    }
    
    _currentChatId = chatId;
    _currentUserId = currentUserId; // Make sure this is set
    
    // Only show loading if we don't have cached messages
    if (_messagesMap[chatId] == null || _messagesMap[chatId]!.isEmpty) {
      _setLoading(true);
    }
    
    try {
      final result = await _chatService.getChatMessages(chatId);
      print('ChatProvider: Service result: $result');
      
      if (result['success']) {
        final messages = result['messages'] as List<Message>;
        _messagesMap[chatId] = messages;        print('ChatProvider: Stored ${messages.length} messages for chat $chatId');
        
        // Mark all unread messages as read when entering chat
        await _markChatAsReadWithUserId(chatId, messages, currentUserId);
        
        // Reset unread count to 0 for this chat
        final chatIndex = _chats.indexWhere((chat) => chat.id == chatId);
        if (chatIndex != -1) {
          _chats[chatIndex].unreadCount = 0;
          print('ChatProvider: Reset unread count to 0 for chat $chatId');
        }        // Join the chat room for real-time updates
        print('ChatProvider: Joining chat rooms...');
        _socketClient.emit(ApiConstants.joinChats, {});
        print('ChatProvider: Join chats event emitted');
        
        // Join specific chat room to be tracked as "in room"
        _socketClient.emit('join_chat_room', {'chatId': chatId});
        print('ChatProvider: Joined specific chat room: $chatId');
        
        notifyListeners();
      } else {
        print('ChatProvider: Error loading messages: ${result['message']}');
        _setError(result['message']);
      }
    } catch (e) {
      print('ChatProvider: Exception loading messages: $e');
      _setError('Failed to load messages: $e');
    }
    _setLoading(false);
  }
  Future<void> _markChatAsReadWithUserId(String chatId, List<Message> messages, String currentUserId) async {
    try {
      // Get unread message IDs (messages that current user hasn't read)
      final unreadMessageIds = messages
          .where((message) => !message.isReadBy(currentUserId))
          .map((message) => message.id)
          .toList();

      print('ChatProvider: Found ${unreadMessageIds.length} unread messages for user $currentUserId');

      if (unreadMessageIds.isNotEmpty) {
        print('ChatProvider: Marking ${unreadMessageIds.length} messages as read');
        
        // Mark as read via API
        final result = await _chatService.markMessagesAsRead(chatId, unreadMessageIds);
        
        if (result['success']) {
          // Also emit via socket for real-time updates
          _socketClient.emit(ApiConstants.markReadEvent, {
            'chatId': chatId,
            'messageIds': unreadMessageIds,
          });

          // Update local chat unread count to 0
          final chatIndex = _chats.indexWhere((chat) => chat.id == chatId);
          if (chatIndex != -1) {
            _chats[chatIndex].unreadCount = 0;
            print('ChatProvider: Updated unread count for chat $chatId to 0');
            notifyListeners();
          }
        }
      } else {
        print('ChatProvider: No unread messages to mark as read');
        // Still reset unread count to 0 just in case
        final chatIndex = _chats.indexWhere((chat) => chat.id == chatId);
        if (chatIndex != -1) {
          _chats[chatIndex].unreadCount = 0;
          print('ChatProvider: Reset unread count for chat $chatId to 0');
        }
      }
    } catch (e) {      print('ChatProvider: Error marking messages as read: $e');
    }
  }

  Future<void> _markOwnMessageAsRead(String chatId, String messageId, String currentUserId) async {
    try {
      // Mark our own message as read immediately
      final result = await _chatService.markMessagesAsRead(chatId, [messageId]);
      
      if (result['success']) {
        // Also emit via socket for real-time updates
        _socketClient.emit(ApiConstants.markReadEvent, {
          'chatId': chatId,
          'messageIds': [messageId],
        });

        // Ensure unread count stays 0 for current chat
        final chatIndex = _chats.indexWhere((chat) => chat.id == chatId);
        if (chatIndex != -1) {
          _chats[chatIndex].unreadCount = 0;
          print('ChatProvider: Marked own message as read for chat $chatId');
        }
      }
    } catch (e) {
      print('ChatProvider: Error marking own message as read: $e');
    }
  }Future<void> sendMessage(String chatId, String content) async {
    try {
      print('ChatProvider: Sending message to chatId: $chatId via WebSocket');
      
      // Only send via socket for all users, including the sender.
      // The 'new_message' listener will handle adding the message to the UI.
      _socketClient.emit(ApiConstants.sendMessageEvent, {
        'chatId': chatId,
        'content': content,
        'type': 'text',
      });

    } catch (e) {
      print('ChatProvider: Error sending message: $e');
      // Optionally handle the error, e.g., by setting an error state
      _setError('Failed to send message: $e');
    }
  }

  Future<Map<String, dynamic>> createOrGetChat(String participantId) async {
    try {
      final result = await _chatService.createOrGetChat(participantId);
      if (result['success']) {
        // Add the new chat to the list if it's new
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

  // Add this method to the ChatProvider class to create or get a chat with a friend
Future<Chat?> createOrGetChatWith(String userId) async {
  try {
    final response = await _chatService.createOrGetChat(userId);
    
    if (response['success']) {
      // The response['chat'] is already a Chat object, not a Map
      final chat = response['chat'] as Chat;
      
      // Refresh chat list after creating a new chat
      await loadChats();
      
      return chat;
    } else {
      print('Error creating chat: ${response['message']}');
      return null;
    }
  } catch (e) {
    print('Exception creating chat: $e');
    return null;
  }
}
  List<Message> getMessagesForChat(String chatId) {
    final messages = _messagesMap[chatId] ?? [];
    
    // Remove duplicates based on content and timestamp
    final uniqueMessages = <Message>[];
    final seen = <String>{};
    
    for (final message in messages) {
      final key = '${message.content}_${message.createdAt.millisecondsSinceEpoch ~/ 10000}'; // Group by 10-second intervals
      if (!seen.contains(key)) {
        seen.add(key);
        uniqueMessages.add(message);
      }
    }
    
    // Update the map with unique messages
    _messagesMap[chatId] = uniqueMessages;
    
    print('getMessagesForChat($chatId): returning ${uniqueMessages.length} unique messages (filtered from ${messages.length})');
    print('Available chatIds in map: ${_messagesMap.keys.toList()}');
    return uniqueMessages;
  }  void clearMessages() {
    final previousChatId = _currentChatId;
    
    // Leave the previous chat room if we were in one
    if (previousChatId != null) {
      _socketClient.emit('leave_chat_room', {'chatId': previousChatId});
      print('ChatProvider: Left chat room: $previousChatId');
    }
    
    _currentChatId = null;
    
    // Reset unread count for the chat we just left
    if (previousChatId != null) {
      final chatIndex = _chats.indexWhere((chat) => chat.id == previousChatId);
      if (chatIndex != -1) {
        _chats[chatIndex].unreadCount = 0;
        print('ChatProvider: Reset unread count to 0 for exited chat $previousChatId');
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
  }  // Add methods to emit typing events
  void startTyping(String chatId) {
    print('ChatProvider: *** EMITTING TYPING START ***');
    print('ChatProvider: Emitting startTyping for chatId: $chatId');
    print('ChatProvider: Event name: typing_start');
    
    _socketClient.emit('typing_start', {
      'chatId': chatId,
    });
    
    print('ChatProvider: *** TYPING START EMIT COMPLETED ***');
  }

  void stopTyping(String chatId) {
    print('ChatProvider: *** EMITTING TYPING STOP ***');
    print('ChatProvider: Emitting stopTyping for chatId: $chatId');
    print('ChatProvider: Event name: typing_stop');
    
    _socketClient.emit('typing_stop', {
      'chatId': chatId,
    });
    
    print('ChatProvider: *** TYPING STOP EMIT COMPLETED ***');
  }

  // Add these helper methods to check cached data
  bool hasChatsLoaded() => _chats.isNotEmpty;
  
  bool hasMessagesForChat(String chatId) {
    return _messagesMap[chatId] != null && _messagesMap[chatId]!.isNotEmpty;
  }
  
  bool get shouldShowChatListLoading => _isLoading && _chats.isEmpty;
  
  bool shouldShowMessagesLoading(String chatId) {
    return _isLoading && !hasMessagesForChat(chatId);
  }

  // Add these new methods for join/leave chat room
  void joinSpecificChatRoom(String chatId) {
    print('ChatProvider: Joining specific chat room $chatId');
    // Emit socket event to join specific chat room
    _socketClient.emit('join_chat_room', {'chatId': chatId});
  }
    void leaveChatRoom(String chatId) {
    print('ChatProvider: *** EMITTING LEAVE CHAT ROOM ***');
    print('ChatProvider: Leaving chat room $chatId');
    print('ChatProvider: Event name: leave_chat_room');
    print('ChatProvider: Current _currentChatId: $_currentChatId');
    
    // Emit socket event to leave specific chat room
    _socketClient.emit('leave_chat_room', {'chatId': chatId});
    
    print('ChatProvider: *** LEAVE CHAT ROOM EMIT COMPLETED ***');
  }

  // ✅ ADD THIS NEW METHOD
  void _updateChatListWithNewMessage(String chatId, Message message, List<dynamic> usersInRoom) {
    // Find the chat in the list
    final chatIndex = _chats.indexWhere((chat) => chat.id == chatId);
    
    if (chatIndex != -1) {
      // Remove chat from current position
      final chat = _chats.removeAt(chatIndex);
      
      // Update the chat's last message
      chat.lastMessage = message;
      chat.updatedAt = message.createdAt;
      
      // Only increment unread count if:
      // 1. Message is not from current user
      // 2. Current user is not in the chat room (not viewing this chat)
      // 3. Current user is not in the users in room list
      if (_currentUserId != null && 
          message.sender.id != _currentUserId &&
          chatId != _currentChatId &&
          !usersInRoom.contains(_currentUserId)) {
        chat.unreadCount += 1;
        print('ChatProvider: Incremented unread count for chat $chatId to ${chat.unreadCount}');
      } else {
        print('ChatProvider: Not incrementing unread count - user in room or own message');
      }
      
      // Move chat to the top of the list (most recent)
      _chats.insert(0, chat);
      
      // Notify listeners to refresh UI
      notifyListeners();
      print('ChatProvider: Updated chat list and notified listeners');
    } else {
      print('ChatProvider: Chat $chatId not found in chat list');
      
      // If chat is not in the list, reload the entire chat list
      // This can happen if it's a new chat
      loadChats();
    }
  }

  // ==========================================================
  // BAGIAN INI DIUBAH (Optimistic Update)
  // ==========================================================
  void editMessage(String messageId, String newContent) {
    // 1. Lakukan Optimistic Update
    if (_currentChatId != null && _messagesMap.containsKey(_currentChatId)) {
      final messageIndex = _messagesMap[_currentChatId]!.indexWhere((m) => m.id == messageId);
      
      if (messageIndex != -1) {
        // Langsung ubah state lokal
        _messagesMap[_currentChatId]![messageIndex].content = newContent;
        _messagesMap[_currentChatId]![messageIndex].edited = true;
        _messagesMap[_currentChatId]![messageIndex].editedAt = DateTime.now().toUtc(); // Use UTC time
        
        // Langsung refresh UI
        notifyListeners();
        print('Optimistic Update: Message $messageId updated locally.');
      }
    }

    // 2. Kirim event ke server
    _socketClient.emit(ApiConstants.editMessage, {
      'messageId': messageId, 
      'content': newContent,
    });
  }

  void deleteMessage(String messageId, String deleteType) {
    // Optimistic update untuk delete
    if (_currentChatId != null && _messagesMap.containsKey(_currentChatId)) {
      final messageIndex = _messagesMap[_currentChatId]!.indexWhere((m) => m.id == messageId);
      if (messageIndex != -1) {
        // Untuk 'me' atau 'everyone', kita bisa langsung tampilkan placeholder
        // Server akan menghapusnya dari database dan memberitahu user lain
        _messagesMap[_currentChatId]![messageIndex].isDeleted = true;
        _messagesMap[_currentChatId]![messageIndex].deletedAt = DateTime.now().toUtc();
        
        // Refresh UI
        notifyListeners();
        print('Optimistic Update: Message $messageId marked as deleted locally.');
      }
    }

    // Kirim event ke server
    _socketClient.emit(ApiConstants.deleteMessage, {
      'messageId': messageId, 
      'deleteType': deleteType
    });
  }
}