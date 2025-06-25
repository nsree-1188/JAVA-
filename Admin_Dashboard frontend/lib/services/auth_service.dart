import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_constants.dart';

class AuthService {
  static const String _tokenKey = 'admin_token';
  static const String _userKey = 'admin_user';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<bool> login(String email, String password) async {
    try {
      print('🔐 Attempting login for: $email');
      print('🌐 Login URL: ${ApiConstants.login}');

      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('📡 Login response status: ${response.statusCode}');
      print('📦 Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle different response formats
        String? token;
        Map<String, dynamic>? user;

        if (data['token'] != null) {
          token = data['token'];
          user = data['user'];
        } else if (data['data'] != null && data['data']['token'] != null) {
          token = data['data']['token'];
          user = data['data']['user'];
        }

        if (token != null) {
          await saveToken(token);

          // Save user data if available
          if (user != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_userKey, json.encode(user));
          }

          print('✅ Login successful');
          return true;
        }
      }

      print('❌ Login failed: Invalid credentials or server error');
      return false;
    } catch (e) {
      print('💥 Login error: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    try {
      print('🚪 Logging out...');
      await removeToken();
      print('✅ Logout successful');
    } catch (e) {
      print('💥 Logout error: $e');
    }
  }

  static Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      print('🔑 Attempting to change password...');
      print('🌐 Change password URL: ${ApiConstants.changePassword}');

      final headers = await _getAuthHeaders();

      final response = await http.post(
        Uri.parse(ApiConstants.changePassword),
        headers: headers,
        body: json.encode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      print('📡 Change password response status: ${response.statusCode}');
      print('📦 Change password response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Password changed successfully');
        return true;
      } else {
        print('❌ Password change failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('💥 Change password error: $e');
      return false;
    }
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString(_userKey);
      if (userString != null) {
        return json.decode(userString);
      }
    } catch (e) {
      print('💥 Error getting current user: $e');
    }
    return null;
  }

  static Future<bool> validateToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      // You can add a token validation endpoint here
      // For now, just check if token exists
      return true;
    } catch (e) {
      print('💥 Token validation error: $e');
      return false;
    }
  }
}
