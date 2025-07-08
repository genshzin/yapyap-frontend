# YapYap Frontend

A Flutter mobile application for the YapYap chat platform, providing real-time messaging capabilities with a modern and intuitive user interface.

## 🔗 Related Projects

- [YapYap Backend](https://github.com/genshzin/yapyap-backend) - Node.js backend API

---

**Note**: This app requires the YapYap Backend API to be running. Make sure to start the backend server before running the mobile application. See the [backend repository](https://github.com/genshzin/yapyap-backend) for setup instructions.

## 🚀 Features

- Cross-platform mobile app
- Real-time messaging with Socket.IO
- User authentication
- Message read receipts
- Typing indicators
- Online status indicators
- Chat creation and management
- Friend requests and friend management
- Profile picture upload
- Responsive UI design

## 📁 Project Structure

```
yapyap-frontend/
├── lib/
│   ├── main.dart                          # Application entry point
│   ├── app.dart                           # Root widget with AuthWrapper
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart         # API & socket event constants
│   │   │   └── app_theme.dart             # App theme configuration
│   │   ├── network/
│   │   │   └── api_client.dart            # HTTP client configuration
│   │   └── utils/
│   │       └── validators.dart            # Form validation utilities
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart            # User data model
│   │   │   ├── message_model.dart         # Message data model
│   │   │   └── chat_model.dart            # Chat room data model
│   │   └── services/
│   │       ├── auth_service.dart          # Authentication API calls
│   │       ├── chat_service.dart          # Chat-related API calls
│   │       └── friendship_service.dart    # Friend-related API calls
│   ├── presentation/
│   │   ├── screens/
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart      # User login interface
│   │   │   │   └── register_screen.dart   # User registration interface
│   │   │   ├── chat/
│   │   │   │   └── chat_list.dart         # Chat list screen
│   │   │   ├── friends/
│   │   │   │   └── friends_screen.dart    # Friends and requests screen
│   │   │   └── profile/
│   │   │       └── profile_screen.dart    # User profile screen
│   │   ├── widgets/
│   │   │   ├── main_navigation.dart       # Bottom navigation wrapper
│   │   │   ├── app_drawer.dart            # Navigation drawer
│   │   │   └── common/
│   │   │       ├── loading_indicator.dart # Loading animations
│   │   │       └── image_picker_widget.dart # Profile picture picker
│   │   └── providers/
│   │       ├── auth_provider.dart         # Authentication state management
│   │       ├── chat_provider.dart         # Chat & messages state
│   │       └── friendship_provider.dart   # Friend-related state
│   └── routes/
│       └── route_generator.dart           # Navigation logic

```

## 🛠 Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android development)
- Xcode (for iOS development on macOS)
- YapYap Backend API running (see [yapyap-backend](https://github.com/genshzin/yapyap-backend))

## 🚀 Quick Start

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/genshzin/yapyap-frontend.git
   cd yapyap-frontend
   ```

2. **Verify Flutter installation**
   ```bash
   flutter doctor
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## 🌐 API Integration

The app connects to the YapYap Backend API with the following endpoints:

### Authentication
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `POST /auth/logout` - User logout
- `GET /auth/profile` - Get user profile
- `PUT /auth/profile` - Update user profile

### Chat Management
- `GET /chat/rooms` - Get user's chat rooms
- `POST /chat/rooms` - Create or get chat with user
- `GET /chat/messages/:chatId` - Get chat messages


### User Management
- `GET /api/users/search` - Search users by username

### Friendship Management
- `POST /friendships/send` - Send friend request
- `POST /friendships/accept` - Accept friend request
- `POST /friendships/decline` - Decline friend request
- `DELETE /friendships/delete/:id` - Delete friendship

### Real-time Features (Socket.IO)
- `join_chats` - Join user's chat rooms
- `join_chat_room` - Join a specific chat room
- `leave_chat_room` - Leave a specific chat room
- `send_message` - Send a message to a chat
- `new_message` - Receive new messages
- `typing_start` - Notify when a user starts typing
- `typing_stop` - Notify when a user stops typing
- `user_typing` - Handle typing indicators for other users
- `user_stop_typing` - Handle when other users stop typing
- `edit_message` - Edit a message
- `delete_message` - Delete a message
- `messages_read` - Mark messages as read
- `message_edited` - Handle updates to edited messages
- `message_deleted` - Handle updates to deleted messages
- `connect` - Handle socket connection
- `disconnect` - Handle socket disconnection
- `connect_error` - Handle connection errors
- `chats_joined` - Handle when chats are joined
- `chat_room_joined` - Handle when a chat room is joined
- `chat_room_left` - Handle when a chat room is left

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  http: ^1.4.0
  dio: ^5.8.0+1
  socket_io_client: ^3.1.2
  provider: ^6.1.5
  shared_preferences: ^2.5.3
  image_picker: ^1.1.2
  file_picker: ^10.2.0
  cached_network_image: ^3.4.1
  flutter_chat_bubble: ^2.0.2
  intl: ^0.20.2
  timeago: ^3.7.1
  flutter_dotenv: ^5.2.1
  flex_color_scheme: ^8.0.2
```



