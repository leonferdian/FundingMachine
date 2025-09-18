import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String? fcmToken;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    required this.createdAt,
    this.updatedAt,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.fcmToken,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? fcmToken,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
