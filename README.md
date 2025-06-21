# YapYap Frontend

A Flutter mobile application for the YapYap chat platform, providing real-time messaging capabilities with a modern and intuitive user interface.

## 🔗 Related Projects

- [YapYap Backend](https://github.com/genshzin/yapyap-backend) - Node.js backend API

---

**Note**: This app requires the YapYap Backend API to be running. Make sure to start the backend server before running the mobile application. See the [backend repository](https://github.com/genshzin/yapyap-backend) for setup instructions.

## 🚀 Features

- Cross-platform mobile app (Android & iOS)
- Real-time messaging with Socket.IO
- User authentication and profile management
- File and image sharing
- Online status indicators
- Message read receipts
- Typing indicators
- Responsive UI design

## 📁 Project Structure

```
yapyap-frontend/
├── lib/
│   ├── main.dart                          # Application entry point
│   ├── app.dart                          # Root widget with AuthWrapper
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constant.dart             # Api & socket event constants
│   │   │   └── app_theme.dart                # App theme configuration
│   │   ├── utils/
│   │   │   ├── validators.dart               # Form validation utilities
│   │   │   └── date_formatter.dart           # Date/time formatting
│   │   └── network/
│   │       ├── api_client.dart               # HTTP client configuration
│   │       └── socket_client.dart            # Socket.IO client setup
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart               # User data model
│   │   │   ├── message_model.dart            # Message data model
│   │   │   └── chat_model.dart               # Chat room data model
│   │   └── services/
│   │       ├── auth_service.dart             # Authentication API calls
\
│   ├── presentation/
│   │   ├── screens/
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart         # User login interface
│   │   │   │   └── register_screen.dart      # User registration interface
│   │   │   ├── home/
│   │   │   │   └── home_screen.dart          # Main navigation hub
│   │   │   ├── chat/
│   │   │   └── profile/
│   │   ├── widgets/
│   │   │   ├── main_navigation.dart          # Bottom navigation wrapper
│   │   │   ├── app_drawer.dart               # Navigation drawer
│   │   │   ├── common/
│   │   │   │   └── loading_indicator.dart    # Loading animations
│   │   │   ├── chat/
│   │   │   └── auth/
│   │   └── providers/
│   │       ├── auth_provider.dart            # Authentication state management
│   │       ├── chat_provider.dart            # Chat & messages state
│   │       ├── socket_provider.dart          # Socket connection state
│   │       └── user_provider.dart            # User data state management
│   └── routes/
│       ├── app_routes.dart                   # Route definitions
│       └── route_generator.dart              # Navigation logic
├── assets/
│   ├── images/                              # Static images
│   ├── icons/                               # App icons
│   └── fonts/                               # Custom fonts
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

4. **Set up environment variables**

   See [Configuration](#🔧-configuration).

6. **Run the application**
   ```bash
   # For development (with hot reload)
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
- `POST /chat/messages` - Send new message
- `PUT /chat/messages/:messageId/read` - Mark message as read

### User Management
- `GET /api/users/search` - Search users by username

### Real-time Features (Socket.IO)
- `join_chats` - Join user's chat rooms
- `send_message` - Send message to chat
- `new_message` - Receive new messages
- `typing_start/stop` - Handle typing indicators
- `user_status_change` - Handle online status updates

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

```

## 🔧 Configuration

### Environment Setup

The app uses dotenv for environment configuration. Create a `.env` file in the project root:

```bash
# .env
API_BASE_URL=http://localhost:3000
SOCKET_URL=ws://localhost:3000
ENVIRONMENT=development
APP_NAME=YapYap
APP_VERSION=1.0.0
```

## 🚧 Development Status

Current implementation status:

- ✅ Project structure setup
- ✅ Authentication system (Login/Register)
- ✅ API client configuration
- ✅ Socket.IO integration
- ✅ State management with Provider
- ✅ Core UI components
- ✅ Navigation system
- ✅ Chat interface
- ✅ Real-time messaging
- ✅ User search functionality
- ✅ Chat rooms management
- ✅ Message sending/receiving
- ✅ Online status indicators
- ✅ Typing indicators
- ⚠️ File sharing (in progress)
- ⚠️ Message read receipts (in progress)
- ⚠️ Profile picture upload (in progress)
