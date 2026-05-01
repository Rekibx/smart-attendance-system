import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/api_client.dart';
import '../services/token_storage.dart';

class AppState extends ChangeNotifier {
  AppState({required this.apiClient, required this.tokenStorage});

  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  AppUser? user;
  bool isLoading = false;
  String? error;

  bool get isAuthenticated => user != null;

  Future<void> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await apiClient.login(email.trim(), password);
      user = result.user;
      await tokenStorage.saveToken(result.token);
    } on ApiException catch (exception) {
      error = exception.message;
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    user = null;
    error = null;
    apiClient.setToken(null);
    await tokenStorage.clear();
    notifyListeners();
  }
}
