import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'http://your-api-url.com/api';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final SharedPreferences _prefs;

  AuthService(this._prefs);

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'auth_token');
    return token != null;
  }

  // Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _secureStorage.write(key: 'auth_token', value: data['token']);
        await _prefs.setString('user_email', email);
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': 'Login failed. Please check your credentials.'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'An error occurred. Please try again.'};
    }
  }

  // Register a new user
  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        return {'success': true};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'error': error['message']};
      }
    } catch (e) {
      return {'success': false, 'error': 'An error occurred. Please try again.'};
    }
  }

  // Logout the user
  Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
    await _prefs.remove('user_email');
  }

  // Get auth token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  // Get user email from shared preferences
  String? getUserEmail() {
    return _prefs.getString('user_email');
  }
}
