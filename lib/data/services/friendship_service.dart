import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';

class FriendshipService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> sendFriendRequest(String recipientId) async {
    try {
      final response = await _apiClient.post(ApiConstants.sendFriendRequest, data: {
        'recipientId': recipientId,
      });
      return response.data;
    } catch (e) {
      return {'success': false, 'message': 'Failed to send friend request'};
    }
  }

  Future<Map<String, dynamic>> acceptFriendRequest(String requesterId) async {
    try {
      final response = await _apiClient.post(ApiConstants.acceptFriendRequest, data: {
        'requesterId': requesterId,
      });
      return response.data;
    } catch (e) {
      return {'success': false, 'message': 'Failed to accept friend request'};
    }
  }

  Future<Map<String, dynamic>> declineFriendRequest(String requesterId) async {
    try {
      final response = await _apiClient.post(ApiConstants.declineFriendRequest, data: {
        'requesterId': requesterId,
      });
      return response.data;
    } catch (e) {
      return {'success': false, 'message': 'Failed to decline friend request'};
    }
  }

  Future<Map<String, dynamic>> deleteFriendship(String friendId) async {
    try {
      final response = await _apiClient.delete('${ApiConstants.deleteFriendship}/$friendId');
      return response.data;
    } catch (e) {
      return {'success': false, 'message': 'Failed to delete friendship'};
    }
  }

  Future<List<dynamic>> getFriendRequests() async {
    try {
      final response = await _apiClient.get(ApiConstants.listFriendRequests);
      
      
      if (response.data is List) {
        return response.data;
      } else if (response.data is Map && response.data.containsKey('requests')) {
        return response.data['requests'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getFriends() async {
    try {
      final response = await _apiClient.get(ApiConstants.listFriends);
      
      
      if (response.data is List) {
        return response.data;
      } else if (response.data is Map && response.data.containsKey('friends')) {
        return response.data['friends'];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}