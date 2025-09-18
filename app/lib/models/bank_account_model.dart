import 'package:json_annotation/json_annotation.dart';

part 'bank_account_model.g.dart';

enum BankType {
  @JsonValue('local')
  local,
  @JsonValue('digital')
  digital,
  @JsonValue('ewallet')
  ewallet,
}

@JsonSerializable()
class BankAccount {
  final String id;
  final String userId;
  final String bankCode;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final BankType type;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BankAccount({
    required this.id,
    required this.userId,
    required this.bankCode,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    required this.type,
    this.isDefault = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) => _$BankAccountFromJson(json);
  Map<String, dynamic> toJson() => _$BankAccountToJson(this);

  BankAccount copyWith({
    String? id,
    String? userId,
    String? bankCode,
    String? bankName,
    String? accountNumber,
    String? accountName,
    BankType? type,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BankAccount(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bankCode: bankCode ?? this.bankCode,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountName: accountName ?? this.accountName,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
