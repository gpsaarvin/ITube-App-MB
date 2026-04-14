class NotificationPrefs {
  const NotificationPrefs({
    required this.email,
    required this.push,
    required this.weeklySummary,
  });

  final bool email;
  final bool push;
  final bool weeklySummary;

  NotificationPrefs copyWith({bool? email, bool? push, bool? weeklySummary}) {
    return NotificationPrefs(
      email: email ?? this.email,
      push: push ?? this.push,
      weeklySummary: weeklySummary ?? this.weeklySummary,
    );
  }

  factory NotificationPrefs.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const NotificationPrefs(
        email: true,
        push: true,
        weeklySummary: true,
      );
    }
    return NotificationPrefs(
      email: (json['email'] ?? true) as bool,
      push: (json['push'] ?? true) as bool,
      weeklySummary: (json['weeklySummary'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'push': push, 'weeklySummary': weeklySummary};
  }
}

class UserProfileModel {
  const UserProfileModel({
    required this.userId,
    required this.name,
    required this.username,
    required this.phone,
    required this.country,
    required this.skillLevel,
    required this.interests,
    required this.dailyStudyTime,
    required this.photoURL,
    required this.themePreference,
    required this.completionPercent,
    required this.streakDays,
    required this.certificates,
    required this.notificationPrefs,
  });

  final String userId;
  final String name;
  final String username;
  final String phone;
  final String country;
  final String skillLevel;
  final List<String> interests;
  final String dailyStudyTime;
  final String photoURL;
  final String themePreference;
  final double completionPercent;
  final int streakDays;
  final List<String> certificates;
  final NotificationPrefs notificationPrefs;

  UserProfileModel copyWith({
    String? userId,
    String? name,
    String? username,
    String? phone,
    String? country,
    String? skillLevel,
    List<String>? interests,
    String? dailyStudyTime,
    String? photoURL,
    String? themePreference,
    double? completionPercent,
    int? streakDays,
    List<String>? certificates,
    NotificationPrefs? notificationPrefs,
  }) {
    return UserProfileModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      skillLevel: skillLevel ?? this.skillLevel,
      interests: interests ?? this.interests,
      dailyStudyTime: dailyStudyTime ?? this.dailyStudyTime,
      photoURL: photoURL ?? this.photoURL,
      themePreference: themePreference ?? this.themePreference,
      completionPercent: completionPercent ?? this.completionPercent,
      streakDays: streakDays ?? this.streakDays,
      certificates: certificates ?? this.certificates,
      notificationPrefs: notificationPrefs ?? this.notificationPrefs,
    );
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json, String userId) {
    return UserProfileModel(
      userId: userId,
      name: (json['name'] ?? '') as String,
      username: (json['username'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      country: (json['country'] ?? '') as String,
      skillLevel: (json['skillLevel'] ?? 'Beginner') as String,
      interests: (json['interests'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      dailyStudyTime: (json['dailyStudyTime'] ?? '30 mins') as String,
      photoURL: (json['photoURL'] ?? '') as String,
      themePreference: (json['themePreference'] ?? 'system') as String,
      completionPercent: (json['completionPercent'] ?? 0).toDouble(),
      streakDays: (json['streakDays'] ?? 0) as int,
      certificates: (json['certificates'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      notificationPrefs: NotificationPrefs.fromJson(
        json['notificationPrefs'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'username': username,
      'phone': phone,
      'country': country,
      'skillLevel': skillLevel,
      'interests': interests,
      'dailyStudyTime': dailyStudyTime,
      'photoURL': photoURL,
      'themePreference': themePreference,
      'completionPercent': completionPercent,
      'streakDays': streakDays,
      'certificates': certificates,
      'notificationPrefs': notificationPrefs.toJson(),
    };
  }
}
