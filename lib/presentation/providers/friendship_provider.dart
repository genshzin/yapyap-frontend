import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../data/services/friendship_service.dart';
import '../../data/models/friendship_model.dart';

class FriendshipProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final FriendshipService _friendshipService = FriendshipService();

  List<Friendship> _friends = [];
  List<Friendship> _friendRequests = [];
  bool _isLoading = false;

  List<Friendship> get friends => _friends;
  List<Friendship> get friendRequests => _friendRequests;
  bool get isLoading => _isLoading;

  Future<void> loadFriends() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _friendshipService.getFriends();
      _friends = result.map((data) => Friendship.fromJson(data)).toList();
    } catch (e) {
      _friends = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFriendRequests() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _friendshipService.getFriendRequests();
      _friendRequests = result.map((data) => Friendship.fromJson(data)).toList();
    } catch (e) {
      _friendRequests = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendFriendRequest(String recipientId) async {
    await _friendshipService.sendFriendRequest(recipientId);
    await loadFriendRequests();
  }

  Future<void> acceptFriendRequest(String requesterId) async {
    await _friendshipService.acceptFriendRequest(requesterId);
    await loadFriends();
    await loadFriendRequests();
  }

  Future<void> declineFriendRequest(String requesterId) async {
    await _friendshipService.declineFriendRequest(requesterId);
    await loadFriendRequests();
  }

  Future<void> deleteFriendship(String friendshipId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final response = await _apiClient.delete('/friendships/delete/$friendshipId');
      
      if (response.statusCode == 200) {
        _friends.removeWhere((friendship) => friendship.id == friendshipId);
        notifyListeners();
      } else {
      }
    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}