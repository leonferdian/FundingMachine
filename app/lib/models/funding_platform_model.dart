import 'package:json_annotation/json_annotation.dart';

part 'funding_platform_model.g.dart';

enum PlatformType {
  @JsonValue('ads')
  ads,
  @JsonValue('survey')
  survey,
  @JsonValue('investment')
  investment,
  @JsonValue('other')
  other,
}

enum PlatformStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('maintenance')
  maintenance,
}

@JsonSerializable()
class FundingPlatform {
  final String id;
  final String name;
  final String description;
  final PlatformType type;
  final String logoUrl;
  final String? websiteUrl;
  final PlatformStatus status;
  final double? minInvestment;
  final double? maxInvestment;
  final double? estimatedReturnRate;
  final Duration? estimatedReturnPeriod;
  final bool isFeatured;
  final bool isRecommended;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FundingPlatform({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.logoUrl,
    this.websiteUrl,
    this.status = PlatformStatus.active,
    this.minInvestment,
    this.maxInvestment,
    this.estimatedReturnRate,
    this.estimatedReturnPeriod,
    this.isFeatured = false,
    this.isRecommended = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory FundingPlatform.fromJson(Map<String, dynamic> json) => _$FundingPlatformFromJson(json);
  Map<String, dynamic> toJson() => _$FundingPlatformToJson(this);

  FundingPlatform copyWith({
    String? id,
    String? name,
    String? description,
    PlatformType? type,
    String? logoUrl,
    String? websiteUrl,
    PlatformStatus? status,
    double? minInvestment,
    double? maxInvestment,
    double? estimatedReturnRate,
    Duration? estimatedReturnPeriod,
    bool? isFeatured,
    bool? isRecommended,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FundingPlatform(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      logoUrl: logoUrl ?? this.logoUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      status: status ?? this.status,
      minInvestment: minInvestment ?? this.minInvestment,
      maxInvestment: maxInvestment ?? this.maxInvestment,
      estimatedReturnRate: estimatedReturnRate ?? this.estimatedReturnRate,
      estimatedReturnPeriod: estimatedReturnPeriod ?? this.estimatedReturnPeriod,
      isFeatured: isFeatured ?? this.isFeatured,
      isRecommended: isRecommended ?? this.isRecommended,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
