class Category {
  final int id;
  final String name;
  final int order;
  const Category({required this.id, required this.name, required this.order});
  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(id: json['id'] as int, name: json['name'] as String, order: (json['order'] as num?)?.toInt() ?? 0);
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'order': order};
}

class ExamSummary {
  final int id;
  final String title;
  final int categoryId;
  final int questionCount;
  final bool published;
  const ExamSummary({required this.id, required this.title, required this.categoryId, required this.questionCount, required this.published});
  factory ExamSummary.fromJson(Map<String, dynamic> json) => ExamSummary(
        id: json['id'] as int,
        title: json['title'] as String,
        categoryId: json['categoryId'] as int,
        questionCount: (json['questionCount'] as num?)?.toInt() ?? 0,
        published: json['published'] as bool? ?? false,
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'categoryId': categoryId,
        'questionCount': questionCount,
        'published': published,
      };
}

