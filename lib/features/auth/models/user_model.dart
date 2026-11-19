class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final int points;
  final int watchedVideosCount;
  final int completedTasksCount;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.points = 0,
    this.watchedVideosCount = 0,
    this.completedTasksCount = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Kullanıcı',
      points: (map['points'] as num?)?.toInt() ?? 0,
      watchedVideosCount: (map['watchedVideosCount'] as num?)?.toInt() ?? 0,
      completedTasksCount: (map['completedTasksCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'points': points,
      'watchedVideosCount': watchedVideosCount,
      'completedTasksCount': completedTasksCount,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    int? points,
    int? watchedVideosCount,
    int? completedTasksCount,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      points: points ?? this.points,
      watchedVideosCount: watchedVideosCount ?? this.watchedVideosCount,
      completedTasksCount: completedTasksCount ?? this.completedTasksCount,
    );
  }
}
