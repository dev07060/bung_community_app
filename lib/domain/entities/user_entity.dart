import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';

part 'user_entity.freezed.dart';
part 'user_entity.g.dart';

@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id, // Firebase Auth UID
    @Default('') String uuid, // 앱 내부 UUID
    @Default('') String email,
    @Default('') String displayName,
    String? nickname, // 사용자 지정 닉네임
    String? photoURL,
    @Default([]) List<String> channelIds,
    @Default(UserRole.member) UserRole role,
    @Default(UserStatus.active) UserStatus status,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) = _UserEntity;

  const UserEntity._();

  factory UserEntity.fromJson(Map<String, dynamic> json) => _$UserEntityFromJson(json);

  // Validation methods
  bool get isValid =>
      id.isNotEmpty && uuid.isNotEmpty && email.isNotEmpty && _isValidEmail(email);

  bool get isAdmin => role == UserRole.admin;
  bool get isActive => status == UserStatus.active;
  bool get isRestricted => status == UserStatus.restricted;
  bool get isBanned => status == UserStatus.banned;

  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String get displayRole => role.displayName;
  String get displayStatus => status.displayName;

  /// 표시용 이름 (닉네임 > displayName > 이메일)
  String get displayNameOrNickname =>
      nickname?.isNotEmpty == true
          ? nickname!
          : displayName.isNotEmpty
              ? displayName
              : email;

  /// 닉네임 설정 여부
  bool get hasNickname => nickname?.isNotEmpty == true;
}

