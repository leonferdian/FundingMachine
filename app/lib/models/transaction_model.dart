import 'package:json_annotation/json_annotation.dart';

part 'transaction_model.g.dart';

enum TransactionType {
  @JsonValue('deposit')
  deposit,
  @JsonValue('withdrawal')
  withdrawal,
  @JsonValue('profit')
  profit,
  @JsonValue('subscription')
  subscription,
  @JsonValue('refund')
  refund,
  @JsonValue('bonus')
  bonus,
}

enum TransactionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('cancelled')
  cancelled,
}

@JsonSerializable()
class Transaction {
  final String id;
  final String userId;
  final String? fundingId;
  final String? bankAccountId;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final double? fee;
  final String currency;
  final String description;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  Transaction({
    required this.id,
    required this.userId,
    this.fundingId,
    this.bankAccountId,
    required this.type,
    this.status = TransactionStatus.pending,
    required this.amount,
    this.fee,
    this.currency = 'IDR',
    required this.description,
    this.metadata,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  Transaction copyWith({
    String? id,
    String? userId,
    String? fundingId,
    String? bankAccountId,
    TransactionType? type,
    TransactionStatus? status,
    double? amount,
    double? fee,
    String? currency,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fundingId: fundingId ?? this.fundingId,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      type: type ?? this.type,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      fee: fee ?? this.fee,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  double get netAmount => fee != null ? amount - fee! : amount;
}
