import 'chapter.dart';

class Story {
  final String id;
  final String title;
  final String author;
  final String content; // Keep for backward compatibility
  final String category;
  final String coverImageUrl;
  final DateTime publishedDate;
  final int views;
  final int likes;
  final List<String> tags;
  final bool isFeatured;
  final String synopsis;
  final int readingTimeMinutes;
  final List<Chapter> chapters; // New field for structured chapters

  Story({
    required this.id,
    required this.title,
    required this.author,
    this.content = '', // Make optional for chapter-based stories
    required this.category,
    required this.coverImageUrl,
    required this.publishedDate,
    this.views = 0,
    this.likes = 0,
    this.tags = const [],
    this.isFeatured = false,
    required this.synopsis,
    required this.readingTimeMinutes,
    this.chapters = const [], // Empty by default
  });

  factory Story.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Story(
      id: documentId,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      content: data['content'] ?? '',
      category: data['category'] ?? '',
      coverImageUrl: data['coverImageUrl'] ?? '',
      publishedDate: data['publishedDate'] != null
          ? DateTime.parse(data['publishedDate'])
          : DateTime.now(),
      views: data['views'] ?? 0,
      likes: data['likes'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
      isFeatured: data['isFeatured'] ?? false,
      synopsis: data['synopsis'] ?? '',
      readingTimeMinutes: data['readingTimeMinutes'] ?? 0,
      chapters: (data['chapters'] as List?)
              ?.map((c) => Chapter.fromMap(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'content': content,
      'category': category,
      'coverImageUrl': coverImageUrl,
      'publishedDate': publishedDate.toIso8601String(),
      'views': views,
      'likes': likes,
      'tags': tags,
      'isFeatured': isFeatured,
      'synopsis': synopsis,
      'readingTimeMinutes': readingTimeMinutes,
      'chapters': chapters.map((c) => c.toMap()).toList(),
    };
  }

  Story copyWith({
    String? id,
    String? title,
    String? author,
    String? content,
    String? category,
    String? coverImageUrl,
    DateTime? publishedDate,
    int? views,
    int? likes,
    List<String>? tags,
    bool? isFeatured,
    String? synopsis,
    int? readingTimeMinutes,
    List<Chapter>? chapters,
  }) {
    return Story(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      content: content ?? this.content,
      category: category ?? this.category,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      publishedDate: publishedDate ?? this.publishedDate,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      synopsis: synopsis ?? this.synopsis,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
      chapters: chapters ?? this.chapters,
    );
  }

  // Helper to check if story uses chapter structure
  bool get hasChapters => chapters.isNotEmpty;

  // Get total chapter count
  int get chapterCount => chapters.length;

  // Get total verse count across all chapters
  int get totalVerseCount =>
      chapters.fold(0, (sum, chapter) => sum + chapter.verseCount);
}
