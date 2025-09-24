import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import 'api_client.dart';

class TransactionService {
  final TransactionApi _transactionApi;

  TransactionService(this._transactionApi);

  Future<List<Transaction>> getTransactions({
    String? type,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _transactionApi.getTransactions(
        type: type,
        status: status,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        offset: offset,
      );

      return response.map<Transaction>((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      // Return empty list as fallback
      return [];
    }
  }

  Future<Transaction?> getTransaction(String id) async {
    try {
      final response = await _transactionApi.getTransaction(id);
      return Transaction.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching transaction: $e');
      return null;
    }
  }

  Future<Transaction?> createTransaction(Map<String, dynamic> transactionData) async {
    try {
      final response = await _transactionApi.createTransaction(transactionData);
      return Transaction.fromJson(response);
    } catch (e) {
      debugPrint('Error creating transaction: $e');
      return null;
    }
  }

  Future<Transaction?> updateTransaction(String id, Map<String, dynamic> transactionData) async {
    try {
      final response = await _transactionApi.updateTransaction(id, transactionData);
      return Transaction.fromJson(response);
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      return null;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      await _transactionApi.deleteTransaction(id);
      return true;
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      return false;
    }
  }

  List<Transaction> filterTransactions(List<Transaction> transactions, {
    String? type,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return transactions.where((transaction) {
      // Filter by type
      if (type != null && type != 'All') {
        final transactionType = _mapFilterToTransactionType(type);
        if (transaction.type != transactionType) {
          return false;
        }
      }

      // Filter by status
      if (status != null && transaction.status.toString().split('.').last != status.toLowerCase()) {
        return false;
      }

      // Filter by date range
      if (startDate != null && transaction.createdAt.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && transaction.createdAt.isAfter(endDate)) {
        return false;
      }

      return true;
    }).toList();
  }

  TransactionType _mapFilterToTransactionType(String filter) {
    switch (filter) {
      case 'Income':
        return TransactionType.deposit;
      case 'Expense':
        return TransactionType.withdrawal;
      default:
        return TransactionType.deposit; // fallback
    }
  }
}
