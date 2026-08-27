class GrammarExample {
  final String jp;
  final String translation;

  const GrammarExample({required this.jp, required this.translation});

  factory GrammarExample.fromJson(Map<String, dynamic> json) {
    return GrammarExample(
      jp: json['jp'] as String,
      translation: json['translation'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'jp': jp, 'translation': translation};
}

class GrammarPoint {
  final int id;
  final int lessonId;
  final String title; // masalan "〜masu / 〜masen (fe'lning hozirgi-kelasi zamoni)"
  final String explanation;
  final List<GrammarExample> examples;

  const GrammarPoint({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.explanation,
    required this.examples,
  });
}
