class AppNotification {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String content;
  final Map<String, dynamic>? payload;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.content,
    this.payload,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      userId: map['user_id'],
      type: map['type'],
      title: map['title'],
      content: map['content'],
      payload: map['payload'],
      isRead: map['is_read'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
