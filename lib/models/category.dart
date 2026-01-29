class Category {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final int storyCount;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.iconName = 'favorite',
    this.storyCount = 0,
    required this.createdAt,
  });

  factory Category.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Category(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      iconName: data['iconName'] ?? 'favorite',
      storyCount: data['storyCount'] ?? 0,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'iconName': iconName,
      'storyCount': storyCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    int? storyCount,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      storyCount: storyCount ?? this.storyCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
