import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';

part 'user_entity.freezed.dart';
part 'user_entity.g.dart';

@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id, // Firebase Auth UID
    required String uuid, // 앱 내부 UUID
    required String email,
    required String displayName,
    String? photoURL,
    @Default([]) List<String> channelIds,
    @Default(UserRole.member) UserRole role,
    @Default(UserStatus.active) UserStatus status,
    required DateTime createdAt,
    required DateTime lastLoginAt,
  }) = _UserEntity;

  const UserEntity._();

  factory UserEntity.fromJson(Map<String, dynamic> json) => _$UserEntityFromJson(json);

  // Validation methods
  bool get isValid =>
      id.isNotEmpty && uuid.isNotEmpty && email.isNotEmpty && displayName.isNotEmpty && _isValidEmail(email);

  bool get isAdmin => role == UserRole.admin;
  bool get isActive => status == UserStatus.active;
  bool get isRestricted => status == UserStatus.restricted;
  bool get isBanned => status == UserStatus.banned;

  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String get displayRole => role.displayName;
  String get displayStatus => status.displayName;
}
