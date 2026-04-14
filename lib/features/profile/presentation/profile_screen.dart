import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_repository.dart';
import '../data/profile_repository.dart';
import '../domain/user_profile_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController _certificateController = TextEditingController();

  final List<String> _interests = const [
    'AI',
    'Flutter',
    'Web',
    'Data',
    'UI/UX',
    'Cloud',
    'DevOps',
    'Security',
  ];

  final List<String> _studyTimes = const [
    '15 mins',
    '30 mins',
    '45 mins',
    '1 hour',
    '2 hours',
  ];

  @override
  void dispose() {
    _certificateController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile(
    UserProfileModel profile,
    Map<String, dynamic> fields,
  ) async {
    await ref
        .read(profileRepositoryProvider)
        .updateFields(profile.userId, fields);
  }

  ThemeMode _themeFromProfile(UserProfileModel profile) {
    switch (profile.themePreference) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> _setTheme(UserProfileModel profile, ThemeMode mode) async {
    ref.read(themeModeProvider.notifier).state = mode;
    await ThemePreference.saveThemeMode(mode);
    await _updateProfile(profile, {
      'themePreference': mode == ThemeMode.light
          ? 'light'
          : mode == ThemeMode.dark
          ? 'dark'
          : 'system',
    });
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authStateProvider).valueOrNull;
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/profile/edit'),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profile not available.'));
          }

          final themeMode = _themeFromProfile(profile);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: profile.photoURL.isNotEmpty
                        ? NetworkImage(profile.photoURL)
                        : null,
                    child: profile.photoURL.isEmpty
                        ? const Icon(Icons.person, size: 36)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text('@${profile.username}'),
                        const SizedBox(height: 4),
                        Text(authUser?.email ?? ''),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Skill level',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Beginner', label: Text('Beginner')),
                  ButtonSegment(
                    value: 'Intermediate',
                    label: Text('Intermediate'),
                  ),
                  ButtonSegment(value: 'Advanced', label: Text('Advanced')),
                ],
                selected: {profile.skillLevel},
                onSelectionChanged: (selection) {
                  final value = selection.first;
                  _updateProfile(profile, {'skillLevel': value});
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Interests',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _interests.map((interest) {
                  final selected = profile.interests.contains(interest);
                  return FilterChip(
                    label: Text(interest),
                    selected: selected,
                    onSelected: (value) {
                      final updated = List<String>.from(profile.interests);
                      if (value) {
                        updated.add(interest);
                      } else {
                        updated.remove(interest);
                      }
                      _updateProfile(profile, {'interests': updated});
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: profile.dailyStudyTime,
                decoration: const InputDecoration(
                  labelText: 'Daily study time',
                ),
                items: _studyTimes
                    .map(
                      (time) =>
                          DropdownMenuItem(value: time, child: Text(time)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  _updateProfile(profile, {'dailyStudyTime': value});
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(
                    height: 70,
                    width: 70,
                    child: CircularProgressIndicator(
                      value: profile.completionPercent / 100,
                      backgroundColor: AppColors.border,
                      color: AppColors.secondary,
                      strokeWidth: 8,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${profile.completionPercent.toStringAsFixed(0)}% completion',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${profile.streakDays} day streak'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Certificates',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.certificates
                    .map(
                      (certificate) => Chip(
                        label: Text(certificate),
                        onDeleted: () {
                          final updated = List<String>.from(
                            profile.certificates,
                          )..remove(certificate);
                          _updateProfile(profile, {'certificates': updated});
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _certificateController,
                      decoration: const InputDecoration(
                        hintText: 'Add certificate',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: () {
                      final value = _certificateController.text.trim();
                      if (value.isEmpty) return;
                      final updated = List<String>.from(profile.certificates)
                        ..add(value);
                      _updateProfile(profile, {'certificates': updated});
                      _certificateController.clear();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Notifications',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              SwitchListTile(
                value: profile.notificationPrefs.email,
                onChanged: (value) => _updateProfile(profile, {
                  'notificationPrefs': profile.notificationPrefs
                      .copyWith(email: value)
                      .toJson(),
                }),
                title: const Text('Email updates'),
              ),
              SwitchListTile(
                value: profile.notificationPrefs.push,
                onChanged: (value) => _updateProfile(profile, {
                  'notificationPrefs': profile.notificationPrefs
                      .copyWith(push: value)
                      .toJson(),
                }),
                title: const Text('Push notifications'),
              ),
              SwitchListTile(
                value: profile.notificationPrefs.weeklySummary,
                onChanged: (value) => _updateProfile(profile, {
                  'notificationPrefs': profile.notificationPrefs
                      .copyWith(weeklySummary: value)
                      .toJson(),
                }),
                title: const Text('Weekly summary'),
              ),
              const SizedBox(height: 20),
              Text(
                'Theme',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                  ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ],
                selected: {themeMode},
                onSelectionChanged: (selection) =>
                    _setTheme(profile, selection.first),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authRepositoryProvider).signOut();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
