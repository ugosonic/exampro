class Category {
  final int id;
  final String name;
  final int order;
<<<<<<< HEAD
  const Category({required this.id, required this.name, required this.order});
  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(id: json['id'] as int, name: json['name'] as String, order: (json['order'] as num?)?.toInt() ?? 0);
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'order': order};
=======
  final String imageUrl;
  final bool locked;
  const Category({required this.id, required this.name, required this.order, this.imageUrl = '', this.locked = false});
  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as int,
        name: json['name'] as String,
        order: (json['order'] as num?)?.toInt() ?? 0,
        imageUrl: json['imageUrl'] as String? ?? '',
        locked: json['locked'] as bool? ?? false,
      );
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'order': order, 'imageUrl': imageUrl, 'locked': locked};
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
}

class ExamSummary {
  final int id;
  final String title;
  final int categoryId;
<<<<<<< HEAD
  final int questionCount;
  final bool published;
  const ExamSummary({required this.id, required this.title, required this.categoryId, required this.questionCount, required this.published});
=======
  final int? subcategoryId;
  final int questionCount;
  final bool published;
  final int themeKey;
  const ExamSummary({required this.id, required this.title, required this.categoryId, this.subcategoryId, required this.questionCount, required this.published, this.themeKey = 0});
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
  factory ExamSummary.fromJson(Map<String, dynamic> json) => ExamSummary(
        id: json['id'] as int,
        title: json['title'] as String,
        categoryId: json['categoryId'] as int,
<<<<<<< HEAD
        questionCount: (json['questionCount'] as num?)?.toInt() ?? 0,
        published: json['published'] as bool? ?? false,
=======
        subcategoryId: (json['subcategoryId'] as num?)?.toInt(),
        questionCount: (json['questionCount'] as num?)?.toInt() ?? 0,
        published: json['published'] as bool? ?? false,
        themeKey: (json['themeKey'] as num?)?.toInt() ?? 0,
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'categoryId': categoryId,
<<<<<<< HEAD
        'questionCount': questionCount,
        'published': published,
      };
}

=======
        'subcategoryId': subcategoryId,
        'questionCount': questionCount,
        'published': published,
        'themeKey': themeKey,
      };
}
>>>>>>> 5a2d59ed86ee8512b858a9e9b9cc72883f1a7e45
