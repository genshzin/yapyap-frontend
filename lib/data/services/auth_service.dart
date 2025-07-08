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


      return {
        'success': true,
        'message': response.data['message'] ?? 'Registration successful',
        'user': User.fromJson(response.data['user']),
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Registration failed',
        'errors': e.response?.data['errors'] ?? [],
      };
    } catch (e) {
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
      
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

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
  }
  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userMap = user.toJson();
    await prefs.setString('user_data', jsonEncode(userMap));
  }

  Future<User?> getSavedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      try {
        final userMap = jsonDecode(userData) as Map<String, dynamic>;
        return User.fromJson(userMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data'); // Clear user data juga
  }
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final isLoggedIn = token != null;
    return isLoggedIn;
  }
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      
      final token = await getToken();
      final user = await getSavedUserData();
      
      if (token != null && user != null) {
        return {
          'success': true,
          'user': user,
        };
      }
      
      return {
        'success': false,
        'message': 'No saved user data found',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get saved user data: $e',
      };
    }
  }
}