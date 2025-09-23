import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'api_client.g.dart';

const String baseUrl = 'https://api.yourdomain.com/v1';

@RestApi(baseUrl: baseUrl)
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  static ApiClient create() {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    // Add interceptors
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 Unauthorized
        if (error.response?.statusCode == 401) {
          // TODO: Implement token refresh logic
        }
        return handler.next(error);
      },
    ));

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ));
    }

    return ApiClient(dio);
  }
}

// Example API endpoints
@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String baseUrl}) = _AuthApi;

  @POST('/auth/login')
  Future<Map<String, dynamic>> login(@Body() Map<String, dynamic> credentials);

  @POST('/auth/register')
  Future<Map<String, dynamic>> register(@Body() Map<String, dynamic> userData);

  @POST('/auth/refresh')
  Future<Map<String, dynamic>> refreshToken(@Body() Map<String, dynamic> token);
}

// Run this command to generate the .g.dart file:
// flutter pub run build_runner build --delete-conflicting-outputs
