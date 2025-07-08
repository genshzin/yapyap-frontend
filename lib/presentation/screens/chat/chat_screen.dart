import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../data/models/message_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';


class ChatScreen extends StatefulWidget {
  final String chatId;
  final Map<String, dynamic>? otherUser;

  const ChatScreen({
    super.key,
    required this.chatId,
    this.otherUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  ChatProvider? _chatProvider;

  String? _editingMessageId;
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final currentUserId = authProvider.user?.id;
      
      if (currentUserId != null && _chatProvider != null) {
        
        _chatProvider!.setCurrentUserId(currentUserId);
        
        
        _chatProvider!.joinSpecificChatRoom(widget.chatId);
        
        
        _chatProvider!.loadMessagesAndMarkRead(widget.chatId, currentUserId).then((_) {
          
          _scrollToBottom();
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatProvider = context.read<ChatProvider>();
  }

  @override
  void dispose() {
    
    
    if (_isTyping && _chatProvider != null) {
      _chatProvider!.stopTyping(widget.chatId);
    }
    
    
    if (_chatProvider != null) {
      _chatProvider!.leaveChatRoom(widget.chatId);
      
      
      _chatProvider!.clearMessages();
    } else {
    }
    
    _messageController.dispose();
    _scrollController.dispose();
    _editController.dispose();
    
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();
    
    if (_isTyping) {
      _isTyping = false;
      context.read<ChatProvider>().stopTyping(widget.chatId);
    }

    try {
      
      
      context.read<ChatProvider>().sendMessage(widget.chatId, content);
      
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  void _onTextChanged(String text) {
    final chatProvider = context.read<ChatProvider>();
    
    if (text.trim().isNotEmpty && !_isTyping) {
      
      _isTyping = true;
      chatProvider.startTyping(widget.chatId);
    } else if (text.trim().isEmpty && _isTyping) {
      
      _isTyping = false;
      chatProvider.stopTyping(widget.chatId);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final otherUsername = widget.otherUser?['username'] ?? 'Chat';

    final avatarUrl = widget.otherUser?['avatar']?.toString() ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              onBackgroundImageError: avatarUrl.isNotEmpty
                  ? (exception, stackTrace) {
                    }
                  : null,
              child: avatarUrl.isEmpty
                  ? Text(
                      otherUsername.isNotEmpty
                          ? otherUsername.substring(0, 1).toUpperCase()
                          : '?',
                      style: const TextStyle(fontSize: 16),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(otherUsername),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final messages = chatProvider.getMessagesForChat(widget.chatId);
                final currentUserId = context.read<AuthProvider>().user?.id;

                if (chatProvider.isLoading && messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (messages.isEmpty && !chatProvider.isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.message, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No messages yet'),
                        Text('Send a message to start the conversation!'),
                      ],
                    ),
                  );
                }

                
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients && messages.isNotEmpty) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.sender.id == currentUserId;

                    
                    if (message.isDeleted) {
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Text(
                            'This message was deleted',
                            style: TextStyle(
                              color: Colors.black54,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      );
                    }

                    
                    if (_editingMessageId == message.id) {
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _editController,
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  onSubmitted: (value) => _saveEdit(message),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: () => _saveEdit(message),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _editingMessageId = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    
                    return GestureDetector(
                      onLongPress: () => _showMessageMenu(context, message, isMe),
                      child: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      message.content,
                                      style: TextStyle(
                                        color: isMe ? Colors.white : Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatMessageTime(message.createdAt),
                                    style: TextStyle(
                                      color: isMe ? Colors.white70 : Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (message.edited)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: Text(
                                        'edited',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                          color: isMe ? Colors.white70 : Colors.black54,
                                        ),
                                      ),
                                    ),
                                  
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              final typingUsers = chatProvider.getTypingUsers(widget.chatId);
              final currentUsername = context.read<AuthProvider>().user?.username;
              
              final otherTypingUsers = typingUsers.where((username) => username != currentUsername).toList();
              
              if (otherTypingUsers.isEmpty) {
                return const SizedBox.shrink();
              }
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey[100],
                child: Row(
                  children: [
                    Text(
                      '${otherTypingUsers.join(', ')} is typing...',
                      style: const TextStyle(color: Colors.black54, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              );
            },
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: _onTextChanged,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}';
    } else {
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
  }

  void _showMessageMenu(BuildContext context, Message message, bool isMe) async {
    final canEdit = isMe && !message.isDeleted && DateTime.now().difference(message.createdAt).inMinutes < 15;
    final canDelete = isMe && !message.isDeleted;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      ),
      items: [
        if (canEdit)
          const PopupMenuItem<String>(
            value: 'edit',
            child: Text('Edit'),
          ),
        if (canDelete)
          const PopupMenuItem<String>(
            value: 'delete',
            child: Text('Delete'),
          ),
        const PopupMenuItem<String>(
          value: 'copy',
          child: Text('Copy'),
        ),
      ],
    );

    if (result == 'edit') {
      setState(() {
        _editingMessageId = message.id;
        _editController.text = message.content;
      });
    } else if (result == 'delete') {
      _showDeleteDialog(message);
    } else if (result == 'copy') {
      await Clipboard.setData(ClipboardData(text: message.content));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message copied')),
        );
      }
    }
  }

  void _showDeleteDialog(Message message) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Delete this message for everyone or just for you?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'me'),
            child: const Text('Delete for me'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'everyone'),
            child: const Text('Delete for everyone'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result == 'me' || result == 'everyone') {
      context.read<ChatProvider>().deleteMessage(message.id, result!);
    }
  }

  void _saveEdit(Message message) {
    final newContent = _editController.text.trim();
    if (newContent.isNotEmpty && newContent != message.content) {
      context.read<ChatProvider>().editMessage(message.id, newContent);
    }
    setState(() {
      _editingMessageId = null;
    });
  }
}