import 'package:json_annotation/json_annotation.dart';

part 'subscription_model.g.dart';

enum SubscriptionPlan {
  @JsonValue('monthly')
  monthly,
  @JsonValue('quarterly')
  quarterly,
  @JsonValue('yearly')
  yearly,
}

enum SubscriptionStatus {
  @JsonValue('active')
  active,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('expired')
  expired,
  @JsonValue('pending_payment')
  pendingPayment,
}

@JsonSerializable()
class Subscription {
  final String id;
  final String userId;
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final bool autoRenew;
  final double amount;
  final String currency;
  final String? paymentMethodId;
  final String? transactionId;
  final DateTime? cancelledAt;
  final DateTime? nextBillingDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Subscription({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.autoRenew = true,
    required this.amount,
    this.currency = 'IDR',
    this.paymentMethodId,
    this.transactionId,
    this.cancelledAt,
    this.nextBillingDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) => _$SubscriptionFromJson(json);
  Map<String, dynamic> toJson() => _$SubscriptionToJson(this);

  bool get isActive => status == SubscriptionStatus.active && endDate.isAfter(DateTime.now());
  bool get isExpired => endDate.isBefore(DateTime.now());
  bool get isCancelled => status == SubscriptionStatus.cancelled;
  bool get isPendingPayment => status == SubscriptionStatus.pendingPayment;

  Duration get remainingDuration => endDate.difference(DateTime.now());

  Subscription copyWith({
    String? id,
    String? userId,
    SubscriptionPlan? plan,
    SubscriptionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    bool? autoRenew,
    double? amount,
    String? currency,
    String? paymentMethodId,
    String? transactionId,
    DateTime? cancelledAt,
    DateTime? nextBillingDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      autoRenew: autoRenew ?? this.autoRenew,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      transactionId: transactionId ?? this.transactionId,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
