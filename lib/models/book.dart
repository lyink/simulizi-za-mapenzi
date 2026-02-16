import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String synopsis;
  final String coverImageUrl;
  final List<String> pageImageUrls;
  final List<String> pageTexts; // Swahili story text per page
  final String category;
  final DateTime createdAt;
  final int views;
  final bool isFeatured;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.synopsis,
    required this.coverImageUrl,
    required this.pageImageUrls,
    this.pageTexts = const [],
    required this.category,
    required this.createdAt,
    this.views = 0,
    this.isFeatured = false,
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? 'AI Generated',
      synopsis: data['synopsis'] ?? '',
      coverImageUrl: data['coverImageUrl'] ?? '',
      pageImageUrls: List<String>.from(data['pageImageUrls'] ?? []),
      pageTexts: List<String>.from(data['pageTexts'] ?? []),
      category: data['category'] ?? 'General',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      views: data['views'] ?? 0,
      isFeatured: data['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'synopsis': synopsis,
      'coverImageUrl': coverImageUrl,
      'pageImageUrls': pageImageUrls,
      'pageTexts': pageTexts,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'views': views,
      'isFeatured': isFeatured,
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? synopsis,
    String? coverImageUrl,
    List<String>? pageImageUrls,
    List<String>? pageTexts,
    String? category,
    DateTime? createdAt,
    int? views,
    bool? isFeatured,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      synopsis: synopsis ?? this.synopsis,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      pageImageUrls: pageImageUrls ?? this.pageImageUrls,
      pageTexts: pageTexts ?? this.pageTexts,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      views: views ?? this.views,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}
