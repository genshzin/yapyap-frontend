import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    File? profilePicture,
  }) async {
    try {
      print('[AuthService] Attempting registration for: $email');
      
      FormData formData = FormData.fromMap({
        'username': username,
        'email': email,
        'password': password,
      });

      // Add profile picture if provided
      if (profilePicture != null) {
        formData.files.add(MapEntry(
          'profilePicture',
          await MultipartFile.fromFile(
            profilePicture.path,
            filename: 'profile.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        ));
      }

      final response = await _apiClient.post(
        ApiConstants.register,
        data: formData,
      );

      print('[AuthService] Registration response: ${response.data}');

      return {
        'success': true,
        'message': response.data['message'] ?? 'Registration successful',
        'user': User.fromJson(response.data['user']),
      };
    } on DioException catch (e) {
      print('[AuthService] Registration DioException: ${e.response?.data}');
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Registration failed',
        'errors': e.response?.data['errors'] ?? [],
      };
    } catch (e) {
      print('[AuthService] Registration Exception: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('[AuthService] Attempting login for: $email');
      
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      print('[AuthService] Login response: ${response.data}');
      if (response.data['success'] == true) {
        // Convert the user data first
        final userData = response.data['user'];
        
        // Add the base URL to the profile picture URL if it's a relative URL
        if (userData['profilePictureUrl'] != null && 
            userData['profilePictureUrl'].toString().startsWith('/')) {
          userData['profilePictureUrl'] = 
              '${ApiConstants.baseUrl}${userData['profilePictureUrl']}';
        }
        
        final user = User.fromJson(userData);
        print('[AuthService] Processed Avatar Url: ${user.avatar}');
        
        // Save token
        await _saveToken(response.data['token']);
        // Save user data
        await _saveUserData(user);
        
        return {
          'success': true,
          'message': response.data['message'] ?? 'Login successful',
          'user': user,
          'token': response.data['token'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Invalid credentials',
      };
    } on DioException catch (e) {
      print('[AuthService] Login DioException: ${e.response?.data}');
      print('[AuthService] Login DioException Type: ${e.type}');
      print('[AuthService] Login DioException Message: ${e.message}');
      
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return {
          'success': false,
          'message': 'Cannot connect to server. Please check your connection.',
        };
      }
        return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Login failed. Please try again.',
      };
    } catch (e) {
      print('[AuthService] Login Exception: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
      await _clearToken();
      
      return {
        'success': true,
        'message': 'Logout successful',
      };
    } catch (e) {
      // Clear token even if API call fails
      await _clearToken();
      return {
        'success': true,
        'message': 'Logout successful',
      };
    }
  }
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print('[AuthService] Token saved: ${token.substring(0, 20)}...');
  }
  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userMap = user.toJson();
    await prefs.setString('user_data', jsonEncode(userMap));
    print('[AuthService] User data saved');
  }

  Future<User?> getSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      try {
        final userMap = jsonDecode(userData) as Map<String, dynamic>;
        return User.fromJson(userMap);
      } catch (e) {
        print('[AuthService] Error parsing saved user data: $e');
        return null;
      }
    }
    return null;
  }
  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data'); // Clear user data juga
    print('[AuthService] Token and user data cleared');
  }
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print('[AuthService] Retrieved token: ${token != null ? '${token.substring(0, 20)}...' : 'null'}');
    return token;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final isLoggedIn = token != null;
    print('[AuthService] Is logged in: $isLoggedIn');
    return isLoggedIn;
  }
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      print('[AuthService] Getting saved user profile...');
      
      final token = await getToken();
      final user = await getSavedUserData();
      
      if (token != null && user != null) {
        print('[AuthService] Found saved user data');
        return {
          'success': true,
          'user': user,
        };
      }
      
      print('[AuthService] No saved user data found');
      return {
        'success': false,
        'message': 'No saved user data found',
      };
    } catch (e) {
      print('[AuthService] Error getting saved user data: $e');
      return {
        'success': false,
        'message': 'Failed to get saved user data: $e',
      };
    }
  }
}