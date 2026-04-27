import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/material.dart";

import "../models/user_model.dart";
import "../services/auth_service.dart";

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String? _token;
  UserModel? _user;
  bool _loading = false;

  String? get token => _token;
  UserModel? get user => _user;
  bool get isLoggedIn => _token != null;
  bool get loading => _loading;

  Future<String?> sendOtp(String phone) async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _authService.sendOtp(phone);
      return data["data"]?["otpForDev"] as String?;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(String phone, String otp) async {
    _loading = true;
    notifyListeners();
    try {
      String? fcmToken;
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        debugPrint("Error getting FCM token: $e");
      }

      final data = await _authService.verifyOtp(phone, otp, fcmToken: fcmToken);
      _token = data["data"]["token"];
      _user = UserModel.fromJson(data["data"]["user"]);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }


  Future<void> loginDirectly(String phone) async {
    _loading = true;
    notifyListeners();
    try {
      // Mocking a successful login
      _token = "dummy_token";
      _user = UserModel(
        id: "dev_id",
        phone: phone,
        name: "Test User",
        role: "customer",
        activeMode: "customer",
      );
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getMe() async {
    if (_token == null) return null;
    try {
      final response = await _authService.getMe(_token!);
      return response["data"];
    } catch (e) {
      debugPrint("AuthProvider getMe error: $e");
      return null;
    }
  }

  void updateUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void logout() {
    _token = null;
    _user = null;
    notifyListeners();
  }
}
