import 'package:our_bung_play/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity> getUserById(String userId);
}
