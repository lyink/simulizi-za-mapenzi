class Verse {
  final int number;
  final String text;

  Verse({
    required this.number,
    required this.text,
  });

  factory Verse.fromMap(Map<String, dynamic> data) {
    return Verse(
      number: data['number'] ?? 0,
      text: data['text'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'text': text,
    };
  }
}

class Chapter {
  final int number;
  final String title;
  final List<Verse> verses;

  Chapter({
    required this.number,
    required this.title,
    required this.verses,
  });

  factory Chapter.fromMap(Map<String, dynamic> data) {
    return Chapter(
      number: data['number'] ?? 0,
      title: data['title'] ?? '',
      verses: (data['verses'] as List?)
              ?.map((v) => Verse.fromMap(v as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'title': title,
      'verses': verses.map((v) => v.toMap()).toList(),
    };
  }

  // Get full chapter content as plain text
  String getFullText() {
    return verses.map((v) => '${v.number}. ${v.text}').join('\n\n');
  }

  // Get total verse count
  int get verseCount => verses.length;
}
