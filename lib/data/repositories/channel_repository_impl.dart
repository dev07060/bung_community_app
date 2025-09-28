import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:our_bung_play/core/enums/app_enums.dart';
import 'package:our_bung_play/core/exceptions/app_exceptions.dart';
import 'package:our_bung_play/domain/entities/channel_entity.dart';
import 'package:our_bung_play/domain/entities/user_channel_role_entity.dart';
import 'package:our_bung_play/domain/repositories/auth_repository.dart';
import 'package:our_bung_play/domain/repositories/channel_repository.dart';

class ChannelRepositoryImpl implements ChannelRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  ChannelRepositoryImpl({
    FirebaseFirestore? firestore,
    required AuthRepository authRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository;

  @override
  Future<ChannelEntity> createChannel(String name, String description) async {
    try {
      final currentUser = _getCurrentUserId();
      final inviteCode = _generateInviteCode();
      final now = DateTime.now();

      final channelData = {
        'name': name,
        'description': description,
        'adminId': currentUser,
        'inviteCode': inviteCode,
        'status': ChannelStatus.active.name,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final docRef = await _firestore.collection('channels').add(channelData);

      // Add creator as master (모임장)
      final memberData = {
        'userId': currentUser,
        'role': UserRole.master.name,
        'status': UserStatus.active.name,
        'joinedAt': Timestamp.fromDate(now),
      };

      await docRef.collection('members').doc(currentUser).set(memberData);

      // Create channel entity with the creator as master
      final creatorMember = ChannelMember(
        userId: currentUser,
        role: UserRole.master,
        status: UserStatus.active,
        joinedAt: now,
      );

      return ChannelEntity(
        id: docRef.id,
        name: name,
        description: description,
        adminId: currentUser,
        inviteCode: inviteCode,
        members: [creatorMember],
        status: ChannelStatus.active,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      throw ServerException('채널 생성에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<ChannelEntity?> joinChannelByInviteCode(String inviteCode) async {
    try {
      final currentUser = _getCurrentUserId();

      // Find channel by invite code
      final channelQuery = await _firestore
          .collection('channels')
          .where('inviteCode', isEqualTo: inviteCode)
          .where('status', isEqualTo: ChannelStatus.active.name)
          .limit(1)
          .get();

      if (channelQuery.docs.isEmpty) {
        throw const ValidationException('유효하지 않은 초대 코드입니다.');
      }

      final channelDoc = channelQuery.docs.first;
      final channelId = channelDoc.id;

      // Check if user is already a member
      final memberDoc =
          await _firestore.collection('channels').doc(channelId).collection('members').doc(currentUser).get();

      if (memberDoc.exists) {
        throw const ValidationException('이미 가입된 채널입니다.');
      }

      // Add user as member
      final now = DateTime.now();
      final memberData = {
        'userId': currentUser,
        'role': UserRole.member.name,
        'status': UserStatus.active.name,
        'joinedAt': Timestamp.fromDate(now),
      };

      await _firestore.collection('channels').doc(channelId).collection('members').doc(currentUser).set(memberData);

      // Add channelId to the user's document
      await _firestore.collection('users').doc(currentUser).update({
        'channelIds': FieldValue.arrayUnion([channelId]),
      });

      // Update channel's updatedAt
      await _firestore.collection('channels').doc(channelId).update({'updatedAt': Timestamp.fromDate(now)});

      // Return the channel entity
      return await _getChannelById(channelId);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('채널 가입에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<List<ChannelEntity>> getUserChannels(String userId) async {
    try {
      final channels = <ChannelEntity>[];

      // Get all channels where user is a member
      final memberQuery = await _firestore
          .collectionGroup('members')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: UserStatus.active.name)
          .get();

      for (final memberDoc in memberQuery.docs) {
        final channelId = memberDoc.reference.parent.parent!.id;
        final channel = await _getChannelById(channelId);
        if (channel != null && channel.isActive) {
          channels.add(channel);
        }
      }

      // Sort by updatedAt descending
      channels.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return channels;
    } catch (e) {
      throw ServerException('사용자 채널 목록 조회에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<void> updateChannel(ChannelEntity channel) async {
    try {
      final updateData = {
        'name': channel.name,
        'description': channel.description,
        'status': channel.status.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      await _firestore.collection('channels').doc(channel.id).update(updateData);
    } catch (e) {
      throw ServerException('채널 업데이트에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<String> generateNewInviteCode(String channelId) async {
    try {
      final currentUser = _getCurrentUserId();

      // Verify user is admin
      final channel = await _getChannelById(channelId);
      if (channel == null) {
        throw const ValidationException('채널을 찾을 수 없습니다.');
      }

      if (!channel.isAdmin(currentUser)) {
        throw const PermissionException('채널 관리 권한이 없습니다.');
      }

      final newInviteCode = _generateInviteCode();

      await _firestore.collection('channels').doc(channelId).update({
        'inviteCode': newInviteCode,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return newInviteCode;
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('초대 코드 생성에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<void> removeMember(String channelId, String userId) async {
    try {
      final currentUser = _getCurrentUserId();

      // Verify user is admin
      final channel = await _getChannelById(channelId);
      if (channel == null) {
        throw const ValidationException('채널을 찾을 수 없습니다.');
      }

      if (!channel.isAdmin(currentUser)) {
        throw const PermissionException('멤버 관리 권한이 없습니다.');
      }

      // Cannot remove channel admin
      if (channel.adminId == userId) {
        throw const ValidationException('채널 관리자는 제거할 수 없습니다.');
      }

      // Remove member document
      await _firestore.collection('channels').doc(channelId).collection('members').doc(userId).delete();

      // Update channel's updatedAt
      await _firestore.collection('channels').doc(channelId).update({'updatedAt': Timestamp.fromDate(DateTime.now())});
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('멤버 제거에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<void> updateMemberStatus(String channelId, String userId, String status) async {
    try {
      final currentUser = _getCurrentUserId();

      // Verify user is admin
      final channel = await _getChannelById(channelId);
      if (channel == null) {
        throw const ValidationException('채널을 찾을 수 없습니다.');
      }

      if (!channel.isAdmin(currentUser)) {
        throw const PermissionException('멤버 관리 권한이 없습니다.');
      }

      // Cannot change admin status
      if (channel.adminId == userId) {
        throw const ValidationException('채널 관리자의 상태는 변경할 수 없습니다.');
      }

      // Validate status
      final userStatus = UserStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => throw const ValidationException('유효하지 않은 상태입니다.'),
      );

      await _firestore.collection('channels').doc(channelId).collection('members').doc(userId).update({
        'status': userStatus.name,
      });

      // Update channel's updatedAt
      await _firestore.collection('channels').doc(channelId).update({'updatedAt': Timestamp.fromDate(DateTime.now())});
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('멤버 상태 업데이트에 실패했습니다: ${e.toString()}');
    }
  }

  // Private helper methods
  Future<ChannelEntity?> _getChannelById(String channelId) async {
    try {
      final channelDoc = await _firestore.collection('channels').doc(channelId).get();

      if (!channelDoc.exists) return null;

      final channelData = channelDoc.data()!;

      // Get all members
      final membersQuery = await _firestore.collection('channels').doc(channelId).collection('members').get();

      final members = membersQuery.docs.map((doc) {
        final data = doc.data();
        return ChannelMember(
          userId: data['userId'],
          role: UserRole.values.firstWhere((r) => r.name == data['role']),
          status: UserStatus.values.firstWhere((s) => s.name == data['status']),
          joinedAt: (data['joinedAt'] as Timestamp).toDate(),
        );
      }).toList();

      return ChannelEntity(
        id: channelDoc.id,
        name: channelData['name'],
        description: channelData['description'],
        adminId: channelData['adminId'],
        inviteCode: channelData['inviteCode'],
        members: members,
        status: ChannelStatus.values.firstWhere((s) => s.name == channelData['status']),
        createdAt: (channelData['createdAt'] as Timestamp).toDate(),
        updatedAt: (channelData['updatedAt'] as Timestamp).toDate(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateMemberRole(String channelId, String userId, UserRole newRole) async {
    try {
      final currentUser = _getCurrentUserId();

      // Verify user has permission to change roles (only master can change roles)
      final channel = await _getChannelById(channelId);
      if (channel == null) {
        throw const ValidationException('채널을 찾을 수 없습니다.');
      }

      if (!channel.isMaster(currentUser)) {
        throw const PermissionException('역할 변경 권한이 없습니다. 모임장만 역할을 변경할 수 있습니다.');
      }

      // Cannot change master's role
      if (channel.adminId == userId) {
        throw const ValidationException('모임장의 역할은 변경할 수 없습니다.');
      }

      await _firestore.collection('channels').doc(channelId).collection('members').doc(userId).update({
        'role': newRole.name,
        'roleChangedAt': Timestamp.fromDate(DateTime.now()),
        'roleChangedBy': currentUser,
      });

      // Update channel's updatedAt
      await _firestore.collection('channels').doc(channelId).update({'updatedAt': Timestamp.fromDate(DateTime.now())});
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('역할 변경에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<UserChannelRoleEntity?> getUserChannelRole(String userId, String channelId) async {
    try {
      final memberDoc = await _firestore.collection('channels').doc(channelId).collection('members').doc(userId).get();

      if (!memberDoc.exists) return null;

      final data = memberDoc.data()!;
      return UserChannelRoleEntity(
        id: memberDoc.id,
        userId: data['userId'],
        channelId: channelId,
        role: UserRole.values.firstWhere((r) => r.name == data['role']),
        status: UserStatus.values.firstWhere((s) => s.name == data['status']),
        joinedAt: (data['joinedAt'] as Timestamp).toDate(),
        roleChangedAt: data['roleChangedAt'] != null ? (data['roleChangedAt'] as Timestamp).toDate() : null,
        roleChangedBy: data['roleChangedBy'],
      );
    } catch (e) {
      throw ServerException('사용자 역할 조회에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<List<UserChannelRoleEntity>> getChannelMembers(String channelId) async {
    try {
      final membersQuery =
          await _firestore.collection('channels').doc(channelId).collection('members').orderBy('joinedAt').get();

      return membersQuery.docs.map((doc) {
        final data = doc.data();
        return UserChannelRoleEntity(
          id: doc.id,
          userId: data['userId'],
          channelId: channelId,
          role: UserRole.values.firstWhere((r) => r.name == data['role']),
          status: UserStatus.values.firstWhere((s) => s.name == data['status']),
          joinedAt: (data['joinedAt'] as Timestamp).toDate(),
          roleChangedAt: data['roleChangedAt'] != null ? (data['roleChangedAt'] as Timestamp).toDate() : null,
          roleChangedBy: data['roleChangedBy'],
        );
      }).toList();
    } catch (e) {
      throw ServerException('채널 멤버 목록 조회에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<List<UserChannelRoleEntity>> getUserChannelRoles(String userId) async {
    try {
      final roles = <UserChannelRoleEntity>[];

      // Get all channels where user is a member
      final memberQuery = await _firestore
          .collectionGroup('members')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: UserStatus.active.name)
          .get();

      for (final memberDoc in memberQuery.docs) {
        final channelId = memberDoc.reference.parent.parent!.id;
        final data = memberDoc.data();

        roles.add(UserChannelRoleEntity(
          id: memberDoc.id,
          userId: data['userId'],
          channelId: channelId,
          role: UserRole.values.firstWhere((r) => r.name == data['role']),
          status: UserStatus.values.firstWhere((s) => s.name == data['status']),
          joinedAt: (data['joinedAt'] as Timestamp).toDate(),
          roleChangedAt: data['roleChangedAt'] != null ? (data['roleChangedAt'] as Timestamp).toDate() : null,
          roleChangedBy: data['roleChangedBy'],
        ));
      }

      return roles;
    } catch (e) {
      throw ServerException('사용자 채널 역할 목록 조회에 실패했습니다: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasPermission(String userId, String channelId, String permission) async {
    try {
      final userRole = await getUserChannelRole(userId, channelId);
      if (userRole == null || !userRole.isActive) return false;

      switch (permission) {
        case 'manageMembers':
          return userRole.canManageMembers;
        case 'manageEvents':
          return userRole.canManageEvents;
        case 'createEvents':
          return userRole.canCreateEvents;
        case 'deleteChannel':
          return userRole.canDeleteChannel;
        case 'changeRoles':
          return userRole.canChangeRoles;
        case 'sendAnnouncements':
          return userRole.canSendAnnouncements;
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  String _getCurrentUserId() {
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) {
      throw const AuthException('로그인이 필요합니다.');
    }
    return currentUser.id;
  }
}
