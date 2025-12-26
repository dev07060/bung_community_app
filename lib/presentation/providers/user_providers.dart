import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:our_bung_play/domain/entities/user_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_providers.g.dart';

/// ImagePicker Provider
@riverpod
ImagePicker imagePicker(ImagePickerRef ref) {
  return ImagePicker();
}

/// FirebaseStorage Provider
@riverpod
FirebaseStorage firebaseStorage(FirebaseStorageRef ref) {
  return FirebaseStorage.instance;
}

/// 사용자 정보 조회 Provider (ID로 조회)
@riverpod
Future<UserEntity?> user(UserRef ref, String userId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    data['id'] = doc.id;
    return UserEntity.fromJson(data);
  } catch (e) {
    return null;
  }
}

/// 여러 사용자 정보 조회 Provider
@riverpod
Future<Map<String, UserEntity>> users(UsersRef ref, List<String> userIds) async {
  final result = <String, UserEntity>{};

  for (final userId in userIds) {
    final user = await ref.watch(userProvider(userId).future);
    if (user != null) {
      result[userId] = user;
    }
  }

  return result;
}
