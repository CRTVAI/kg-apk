class AnnouncementItem {
  AnnouncementItem({
    required this.id,
    required this.title,
    required this.description,
    this.createdAt,
  });

  final int id;
  final String title;
  final String description;
  final DateTime? createdAt;

  factory AnnouncementItem.fromJson(Map<String, dynamic> json) {
    return AnnouncementItem(
      id: json['id'] ?? 0,
      title: _clean(json['title'], 'Announcement'),
      description: _clean(json['description']),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }
}

String _clean(dynamic value, [String fallback = '']) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty || text.toLowerCase() == 'null' ? fallback : text;
}
