// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'funding_platform_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FundingPlatform _$FundingPlatformFromJson(Map<String, dynamic> json) =>
    FundingPlatform(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$PlatformTypeEnumMap, json['type']),
      logoUrl: json['logoUrl'] as String,
      websiteUrl: json['websiteUrl'] as String?,
      status: $enumDecodeNullable(_$PlatformStatusEnumMap, json['status']) ??
          PlatformStatus.active,
      minInvestment: (json['minInvestment'] as num?)?.toDouble(),
      maxInvestment: (json['maxInvestment'] as num?)?.toDouble(),
      estimatedReturnRate: (json['estimatedReturnRate'] as num?)?.toDouble(),
      estimatedReturnPeriod: json['estimatedReturnPeriod'] == null
          ? null
          : Duration(
              microseconds: (json['estimatedReturnPeriod'] as num).toInt()),
      isFeatured: json['isFeatured'] as bool? ?? false,
      isRecommended: json['isRecommended'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FundingPlatformToJson(FundingPlatform instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'type': _$PlatformTypeEnumMap[instance.type]!,
      'logoUrl': instance.logoUrl,
      'websiteUrl': instance.websiteUrl,
      'status': _$PlatformStatusEnumMap[instance.status]!,
      'minInvestment': instance.minInvestment,
      'maxInvestment': instance.maxInvestment,
      'estimatedReturnRate': instance.estimatedReturnRate,
      'estimatedReturnPeriod': instance.estimatedReturnPeriod?.inMicroseconds,
      'isFeatured': instance.isFeatured,
      'isRecommended': instance.isRecommended,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$PlatformTypeEnumMap = {
  PlatformType.ads: 'ads',
  PlatformType.survey: 'survey',
  PlatformType.investment: 'investment',
  PlatformType.other: 'other',
};

const _$PlatformStatusEnumMap = {
  PlatformStatus.active: 'active',
  PlatformStatus.inactive: 'inactive',
  PlatformStatus.maintenance: 'maintenance',
};
