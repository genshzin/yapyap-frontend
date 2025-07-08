import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();
  Future<Map<String, dynamic>> searchUsers(String query, {int page = 1, int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.userSearch,
        queryParameters: {
          'q': query,
          'page': page,
          'limit': limit,
        },
      );
      
      if (response.data != null && response.data['users'] != null) {
        final users = (response.data['users'] as List)
            .map((json) => json is Map<String, dynamic> ? User.fromJson(json) : null)
            .where((user) => user != null)
            .cast<User>()
            .toList();

        return {
          'success': true,
          'users': users,
          'pagination': response.data['pagination'] ?? {},
        };
      } else {
        return {
          'success': true,
          'users': <User>[],
          'pagination': {},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to search users: $e',
      };
    }
  }
}