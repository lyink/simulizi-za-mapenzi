class BibleVerse {
  final String bookName;
  final int book;
  final int chapter;
  final int verse;
  final String text;

  BibleVerse({
    required this.bookName,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      bookName: json['book_name'] ?? '',
      book: json['book'] ?? 0,
      chapter: json['chapter'] ?? 0,
      verse: json['verse'] ?? 0,
      text: json['text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_name': bookName,
      'book': book,
      'chapter': chapter,
      'verse': verse,
      'text': text,
    };
  }

  String get reference => '$bookName $chapter:$verse';

  String get fullReference => '$bookName ${chapter}:${verse}';
}

class BibleMetadata {
  final String name;
  final String shortname;
  final String module;
  final String year;
  final String? publisher;
  final String? owner;
  final String description;
  final String lang;
  final String langShort;
  final int copyright;
  final String copyrightStatement;

  BibleMetadata({
    required this.name,
    required this.shortname,
    required this.module,
    required this.year,
    this.publisher,
    this.owner,
    required this.description,
    required this.lang,
    required this.langShort,
    required this.copyright,
    required this.copyrightStatement,
  });

  factory BibleMetadata.fromJson(Map<String, dynamic> json) {
    return BibleMetadata(
      name: json['name'] ?? '',
      shortname: json['shortname'] ?? '',
      module: json['module'] ?? '',
      year: json['year'] ?? '',
      publisher: json['publisher'],
      owner: json['owner'],
      description: json['description'] ?? '',
      lang: json['lang'] ?? '',
      langShort: json['lang_short'] ?? '',
      copyright: json['copyright'] ?? 0,
      copyrightStatement: json['copyright_statement'] ?? '',
    );
  }
}

class Bible {
  final BibleMetadata metadata;
  final List<BibleVerse> verses;

  Bible({
    required this.metadata,
    required this.verses,
  });

  factory Bible.fromJson(Map<String, dynamic> json) {
    final metadata = BibleMetadata.fromJson(json['metadata'] ?? {});
    final verses = (json['verses'] as List<dynamic>?)
        ?.map((verse) => BibleVerse.fromJson(verse))
        .toList() ?? [];

    return Bible(
      metadata: metadata,
      verses: verses,
    );
  }
}