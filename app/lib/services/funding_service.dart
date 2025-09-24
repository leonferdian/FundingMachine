import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/funding_platform_model.dart';
import 'api_config.dart';

/// Service class for handling all funding-related operations
class FundingService {
  static const String _authTokenKey = 'auth_token';
  static const String _paymentMethodKey = 'payment_methods';
  
  final FlutterSecureStorage _storage;
  final String baseUrl;
  final http.Client _httpClient;
  final Uuid _uuid;
  
  // Analytics service (to be injected)
  final Function(String event, Map<String, dynamic>? params)? _logEvent;
  
  // Cache for storing platform data
  List<FundingPlatform>? _cachedPlatforms;
  DateTime? _lastCacheUpdate;
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Constructor with dependency injection for testing
  FundingService({
    FlutterSecureStorage? storage,
    String? baseUrl,
    http.Client? httpClient,
    Uuid? uuid,
    Function(String, Map<String, dynamic>?)? logEvent,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _httpClient = httpClient ?? http.Client(),
        _uuid = uuid ?? const Uuid(),
        _logEvent = logEvent;

  /// Headers for API requests
  Future<Map<String, String>> get _headers async {
    final token = await _storage.read(key: _authTokenKey);
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'X-Request-ID': _uuid.v4(),
      'X-Client-Version': '1.0.0',
    };
  }

  /// Get funding platforms with caching
  Future<List<FundingPlatform>> getFundingPlatforms({bool forceRefresh = false}) async {
    try {
      // Return cached data if it's still valid
      if (!forceRefresh &&
          _cachedPlatforms != null &&
          _lastCacheUpdate != null &&
          DateTime.now().difference(_lastCacheUpdate!) < _cacheDuration) {
        return _cachedPlatforms!;
      }

      final response = await _httpClient.get(
        Uri.parse('$baseUrl/funding-platforms'),
        headers: await _headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        _cachedPlatforms = data.map((json) => FundingPlatform.fromJson(json)).toList();
        _lastCacheUpdate = DateTime.now();
        _logEvent?.call('funding_platforms_loaded', {'count': _cachedPlatforms?.length ?? 0});
        return _cachedPlatforms!;
      } else {
        throw _handleError(response, 'Failed to load funding platforms');
      }
    } on TimeoutException catch (e) {
      _logEvent?.call('api_timeout', {'endpoint': 'funding-platforms', 'error': e.toString()});
      // Return cached data if available, otherwise throw
      return _cachedPlatforms ?? _getMockFundingPlatforms();
    } catch (e) {
      _logEvent?.call('api_error', {
        'endpoint': 'funding-platforms',
        'error': e.toString(),
        'stackTrace': StackTrace.current.toString(),
      });
      // Return cached data if available, otherwise fallback to mock data
      return _cachedPlatforms ?? _getMockFundingPlatforms();
    }
  }

  /// Create a new funding platform
  Future<FundingPlatform> createPlatform(FundingPlatform platform) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/funding-platforms'),
        headers: await _headers,
        body: jsonEncode(platform.toJson()),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );

      if (response.statusCode == 201) {
        final createdPlatform = FundingPlatform.fromJson(jsonDecode(response.body));
        _logEvent?.call('platform_created', {'platform_id': createdPlatform.id});
        // Invalidate cache
        _cachedPlatforms = null;
        return createdPlatform;
      } else {
        throw _handleError(response, 'Failed to create platform');
      }
    } catch (e) {
      _logEvent?.call('platform_creation_failed', {
        'error': e.toString(),
        'platform_name': platform.name,
      });
      rethrow;
    }
  }

  /// Process a funding transaction
  Future<Map<String, dynamic>> processTransaction({
    required String platformId,
    required double amount,
    required String paymentMethodId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final transactionId = _uuid.v4();
      final payload = {
        'transaction_id': transactionId,
        'platform_id': platformId,
        'amount': amount,
        'payment_method_id': paymentMethodId,
        'metadata': metadata ?? {},
        'currency': 'USD', // Default currency, can be made configurable
      };

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/transactions'),
        headers: await _headers,
        body: jsonEncode(payload),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Transaction processing timed out'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        _logEvent?.call('transaction_processed', {
          'transaction_id': transactionId,
          'platform_id': platformId,
          'amount': amount,
          'status': result['status'],
        });
        return result;
      } else {
        throw _handleError(response, 'Transaction failed');
      }
    } catch (e) {
      _logEvent?.call('transaction_failed', {
        'platform_id': platformId,
        'amount': amount,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Get transaction history
  Future<List<Map<String, dynamic>>> getTransactionHistory({
    int limit = 20,
    int offset = 0,
    String? platformId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = {
        'limit': limit.toString(),
        'offset': offset.toString(),
        if (platformId != null) 'platform_id': platformId,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final uri = Uri.parse('$baseUrl/transactions').replace(queryParameters: params);
      final response = await _httpClient.get(
        uri,
        headers: await _headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw _handleError(response, 'Failed to fetch transaction history');
      }
    } catch (e) {
      _logEvent?.call('transaction_history_fetch_failed', {
        'error': e.toString(),
        'platform_id': platformId,
      });
      rethrow;
    }
  }

  /// Save payment method
  Future<void> savePaymentMethod(Map<String, dynamic> paymentMethod) async {
    try {
      final methods = await getSavedPaymentMethods();
      methods.add(paymentMethod);
      await _storage.write(
        key: _paymentMethodKey,
        value: jsonEncode(methods),
      );
      _logEvent?.call('payment_method_saved', {'type': paymentMethod['type']});
    } catch (e) {
      _logEvent?.call('payment_method_save_failed', {
        'error': e.toString(),
        'method_type': paymentMethod['type'],
      });
      rethrow;
    }
  }

  /// Remove payment method
  Future<void> removePaymentMethod(String paymentMethodId) async {
    try {
      final methods = await getSavedPaymentMethods();
      final updatedMethods = methods.where((method) => method['id'] != paymentMethodId).toList();
      await _storage.write(
        key: _paymentMethodKey,
        value: jsonEncode(updatedMethods),
      );
      _logEvent?.call('payment_method_removed', {'method_id': paymentMethodId});
    } catch (e) {
      _logEvent?.call('payment_method_remove_failed', {
        'error': e.toString(),
        'method_id': paymentMethodId,
      });
      rethrow;
    }
  }

  /// Handle API errors consistently
  Exception _handleError(http.Response response, String defaultMessage) {
    final statusCode = response.statusCode;
    String message = defaultMessage;
    String? errorCode;
    
    try {
      final errorBody = jsonDecode(response.body);
      message = errorBody['message'] ?? defaultMessage;
      errorCode = errorBody['code'];
    } catch (e) {
      // If we can't parse the error body, use the status code
      message = 'HTTP $statusCode: $defaultMessage';
    }
    
    _logEvent?.call('api_error', {
      'status_code': statusCode,
      'error_code': errorCode,
      'message': message,
    });
    
    switch (statusCode) {
      case 400:
        return BadRequestException(message);
      case 401:
        return UnauthorizedException(message);
      case 403:
        return ForbiddenException(message);
      case 404:
        return NotFoundException(message);
      case 409:
        return ConflictException(message);
      case 429:
        return RateLimitExceededException(message);
      case 500:
      case 502:
      case 503:
        return ServerException(message);
      default:
        return Exception(message);
    }
  }

  /// Mock data for development and fallback
  List<FundingPlatform> _getMockFundingPlatforms() {
    final now = DateTime.now();
    return [
      FundingPlatform(
        id: '1',
        name: 'GoFundMe',
        description: 'The world\'s largest social fundraising platform',
        type: PlatformType.other,
        logoUrl: 'https://www.gofundme.com/favicon.ico',
        websiteUrl: 'https://www.gofundme.com',
        status: PlatformStatus.active,
        isFeatured: true,
        isRecommended: true,
        minInvestment: 5.0,
        maxInvestment: 10000.0,
        estimatedReturnRate: 0.0,
        estimatedReturnPeriod: const Duration(days: 0),
        createdAt: now,
      ),
      FundingPlatform(
        id: '2',
        name: 'Kickstarter',
        description: 'Bring creative projects to life',
        type: PlatformType.other,
        logoUrl: 'https://www.kickstarter.com/favicon.ico',
        websiteUrl: 'https://www.kickstarter.com',
        status: PlatformStatus.active,
        isFeatured: true,
        isRecommended: true,
        minInvestment: 1.0,
        maxInvestment: 100000.0,
        estimatedReturnRate: 0.0,
        estimatedReturnPeriod: const Duration(days: 0),
        createdAt: now,
      ),
    ];
  }
}

// Custom exceptions for better error handling
class BadRequestException implements Exception {
  final String message;
  BadRequestException(this.message);
  @override
  String toString() => 'BadRequest: $message';
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  @override
  String toString() => 'Unauthorized: $message';
}

class ForbiddenException implements Exception {
  final String message;
  ForbiddenException(this.message);
  @override
  String toString() => 'Forbidden: $message';
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
  @override
  String toString() => 'Not Found: $message';
}

class ConflictException implements Exception {
  final String message;
  ConflictException(this.message);
  @override
  String toString() => 'Conflict: $message';
}

class RateLimitExceededException implements Exception {
  final String message;
  RateLimitExceededException(this.message);
  @override
  String toString() => 'Rate Limit Exceeded: $message';
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  @override
  String toString() => 'Server Error: \$message';
}
