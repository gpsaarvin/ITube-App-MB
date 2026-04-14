import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/auth_repository.dart';
import '../domain/user_profile_model.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  );
});

final userProfileProvider = StreamProvider<UserProfileModel?>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return const Stream.empty();
  return ref.watch(profileRepositoryProvider).watchProfile(user);
});

class ProfileRepository {
  ProfileRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _storage = storage;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  DocumentReference<Map<String, dynamic>> _doc(String userId) {
    return _firestore.collection('userProfiles').doc(userId);
  }

  Stream<UserProfileModel?> watchProfile(User user) {
    return _doc(user.uid).snapshots().asyncMap((snapshot) async {
      final data = snapshot.data();
      if (data == null) {
        final profile = _defaultProfile(user);
        await _doc(user.uid).set(profile.toJson());
        return profile;
      }
      return UserProfileModel.fromJson(data, user.uid);
    });
  }

  Future<void> updateProfile(UserProfileModel profile) async {
    await _doc(profile.userId).set(profile.toJson(), SetOptions(merge: true));
  }

  Future<void> updateFields(String userId, Map<String, dynamic> fields) async {
    await _doc(userId).set(fields, SetOptions(merge: true));
  }

  Future<String> uploadProfilePhoto(String userId, Uint8List bytes) async {
    final ref = _storage.ref('profile_photos/$userId.jpg');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  UserProfileModel _defaultProfile(User user) {
    return UserProfileModel(
      userId: user.uid,
      name: user.displayName ?? 'Learner',
      username: (user.email ?? 'learner').split('@').first.replaceAll('.', ''),
      phone: user.phoneNumber ?? '',
      country: 'Unknown',
      skillLevel: 'Beginner',
      interests: const ['AI', 'Flutter'],
      dailyStudyTime: '30 mins',
      photoURL: user.photoURL ?? '',
      themePreference: 'system',
      completionPercent: 0,
      streakDays: 0,
      certificates: const [],
      notificationPrefs: const NotificationPrefs(
        email: true,
        push: true,
        weeklySummary: true,
      ),
    );
  }
}
