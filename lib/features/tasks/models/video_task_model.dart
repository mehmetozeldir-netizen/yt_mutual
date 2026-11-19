class VideoTaskModel {
  final String id;
  final String ownerUid;
  final String youtubeUrl;
  final String videoId;
  final String title;
  final int rewardPoints;
  final int requiredSeconds;
  final bool isActive;

  const VideoTaskModel({
    required this.id,
    required this.ownerUid,
    required this.youtubeUrl,
    required this.videoId,
    required this.title,
    this.rewardPoints = 10,
    this.requiredSeconds = 30,
    this.isActive = true,
  });

  factory VideoTaskModel.fromMap(Map<String, dynamic> map, String id) {
    return VideoTaskModel(
      id: id,
      ownerUid: map['ownerUid'] as String? ?? '',
      youtubeUrl: map['youtubeUrl'] as String? ?? '',
      videoId: map['videoId'] as String? ?? '',
      title: map['title'] as String? ?? 'Video Görevi',
      rewardPoints: (map['rewardPoints'] as num?)?.toInt() ?? 10,
      requiredSeconds: (map['requiredSeconds'] as num?)?.toInt() ?? 30,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerUid': ownerUid,
      'youtubeUrl': youtubeUrl,
      'videoId': videoId,
      'title': title,
      'rewardPoints': rewardPoints,
      'requiredSeconds': requiredSeconds,
      'isActive': isActive,
    };
  }
}
