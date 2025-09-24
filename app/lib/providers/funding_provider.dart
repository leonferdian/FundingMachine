import 'package:flutter/foundation.dart';
import '../models/funding_platform_model.dart';
import '../services/funding_service.dart';

class FundingProvider with ChangeNotifier {
  final FundingService _fundingService;
  
  // State
  List<FundingPlatform> _platforms = [];
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _paymentMethods = [];
  
  // Getters
  List<FundingPlatform> get platforms => _platforms;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get transactions => _transactions;
  List<Map<String, dynamic>> get paymentMethods => _paymentMethods;
  
  FundingProvider({FundingService? fundingService}) 
      : _fundingService = fundingService ?? FundingService();
  
  // Load funding platforms with error handling and loading state
  Future<void> loadPlatforms({bool forceRefresh = false}) async {
    _setLoading(true);
    _error = null;
    
    try {
      _platforms = await _fundingService.getFundingPlatforms(
        forceRefresh: forceRefresh,
      );
      _error = null;
    } catch (e) {
      _error = 'Failed to load funding platforms: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  // Process a new transaction
  Future<Map<String, dynamic>> processTransaction({
    required String platformId,
    required double amount,
    required String paymentMethodId,
    Map<String, dynamic>? metadata,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      final result = await _fundingService.processTransaction(
        platformId: platformId,
        amount: amount,
        paymentMethodId: paymentMethodId,
        metadata: metadata,
      );
      
      // Add to local transactions list
      _transactions.insert(0, result);
      notifyListeners();
      
      return result;
    } catch (e) {
      _error = 'Transaction failed: ${e.toString()}';
      debugPrint(_error);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // Load transaction history
  Future<void> loadTransactionHistory({
    int limit = 20,
    int offset = 0,
    String? platformId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    _error = null;
    
    try {
      _transactions = await _fundingService.getTransactionHistory(
        limit: limit,
        offset: offset,
        platformId: platformId,
        startDate: startDate,
        endDate: endDate,
      );
      _error = null;
    } catch (e) {
      _error = 'Failed to load transaction history: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  // Load saved payment methods
  Future<void> loadPaymentMethods() async {
    _setLoading(true);
    _error = null;
    
    try {
      _paymentMethods = await _fundingService.getSavedPaymentMethods();
      _error = null;
    } catch (e) {
      _error = 'Failed to load payment methods: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }
  
  // Remove a payment method
  Future<void> removePaymentMethod(String paymentMethodId) async {
    _setLoading(true);
    _error = null;

    try {
      await _fundingService.removePaymentMethod(paymentMethodId);
      await loadPaymentMethods(); // Refresh the list
      _error = null;
    } catch (e) {
      _error = 'Failed to remove payment method: ${e.toString()}';
      debugPrint(_error);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // Get platform by ID
  FundingPlatform? getPlatformById(String id) {
    try {
      return _platforms.firstWhere((platform) => platform.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Helper method to update loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
