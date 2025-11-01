// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _passPercentMeta = const VerificationMeta(
    'passPercent',
  );
  @override
  late final GeneratedColumn<int> passPercent = GeneratedColumn<int>(
    'pass_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(60),
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _lockedMeta = const VerificationMeta('locked');
  @override
  late final GeneratedColumn<bool> locked = GeneratedColumn<bool>(
    'locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    order,
    passPercent,
    imageUrl,
    locked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    if (data.containsKey('pass_percent')) {
      context.handle(
        _passPercentMeta,
        passPercent.isAcceptableOrUnknown(
          data['pass_percent']!,
          _passPercentMeta,
        ),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('locked')) {
      context.handle(
        _lockedMeta,
        locked.isAcceptableOrUnknown(data['locked']!, _lockedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      )!,
      passPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pass_percent'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      )!,
      locked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}locked'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final int order;
  final int passPercent;
  final String imageUrl;
  final bool locked;
  const Category({
    required this.id,
    required this.name,
    required this.order,
    required this.passPercent,
    required this.imageUrl,
    required this.locked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['order'] = Variable<int>(order);
    map['pass_percent'] = Variable<int>(passPercent);
    map['image_url'] = Variable<String>(imageUrl);
    map['locked'] = Variable<bool>(locked);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      order: Value(order),
      passPercent: Value(passPercent),
      imageUrl: Value(imageUrl),
      locked: Value(locked),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      order: serializer.fromJson<int>(json['order']),
      passPercent: serializer.fromJson<int>(json['passPercent']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      locked: serializer.fromJson<bool>(json['locked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'order': serializer.toJson<int>(order),
      'passPercent': serializer.toJson<int>(passPercent),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'locked': serializer.toJson<bool>(locked),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    int? order,
    int? passPercent,
    String? imageUrl,
    bool? locked,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    order: order ?? this.order,
    passPercent: passPercent ?? this.passPercent,
    imageUrl: imageUrl ?? this.imageUrl,
    locked: locked ?? this.locked,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      order: data.order.present ? data.order.value : this.order,
      passPercent: data.passPercent.present
          ? data.passPercent.value
          : this.passPercent,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      locked: data.locked.present ? data.locked.value : this.locked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('order: $order, ')
          ..write('passPercent: $passPercent, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('locked: $locked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, order, passPercent, imageUrl, locked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.order == this.order &&
          other.passPercent == this.passPercent &&
          other.imageUrl == this.imageUrl &&
          other.locked == this.locked);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> order;
  final Value<int> passPercent;
  final Value<String> imageUrl;
  final Value<bool> locked;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.order = const Value.absent(),
    this.passPercent = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.locked = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.order = const Value.absent(),
    this.passPercent = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.locked = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? order,
    Expression<int>? passPercent,
    Expression<String>? imageUrl,
    Expression<bool>? locked,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (order != null) 'order': order,
      if (passPercent != null) 'pass_percent': passPercent,
      if (imageUrl != null) 'image_url': imageUrl,
      if (locked != null) 'locked': locked,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? order,
    Value<int>? passPercent,
    Value<String>? imageUrl,
    Value<bool>? locked,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      passPercent: passPercent ?? this.passPercent,
      imageUrl: imageUrl ?? this.imageUrl,
      locked: locked ?? this.locked,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (passPercent.present) {
      map['pass_percent'] = Variable<int>(passPercent.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (locked.present) {
      map['locked'] = Variable<bool>(locked.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('order: $order, ')
          ..write('passPercent: $passPercent, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('locked: $locked')
          ..write(')'))
        .toString();
  }
}

class $SubcategoriesTable extends Subcategories
    with TableInfo<$SubcategoriesTable, Subcategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubcategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _lockedMeta = const VerificationMeta('locked');
  @override
  late final GeneratedColumn<bool> locked = GeneratedColumn<bool>(
    'locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    name,
    order,
    imageUrl,
    locked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subcategories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subcategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('locked')) {
      context.handle(
        _lockedMeta,
        locked.isAcceptableOrUnknown(data['locked']!, _lockedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subcategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subcategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      )!,
      locked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}locked'],
      )!,
    );
  }

  @override
  $SubcategoriesTable createAlias(String alias) {
    return $SubcategoriesTable(attachedDatabase, alias);
  }
}

class Subcategory extends DataClass implements Insertable<Subcategory> {
  final int id;
  final int categoryId;
  final String name;
  final int order;
  final String imageUrl;
  final bool locked;
  const Subcategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.order,
    required this.imageUrl,
    required this.locked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    map['name'] = Variable<String>(name);
    map['order'] = Variable<int>(order);
    map['image_url'] = Variable<String>(imageUrl);
    map['locked'] = Variable<bool>(locked);
    return map;
  }

  SubcategoriesCompanion toCompanion(bool nullToAbsent) {
    return SubcategoriesCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      name: Value(name),
      order: Value(order),
      imageUrl: Value(imageUrl),
      locked: Value(locked),
    );
  }

  factory Subcategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subcategory(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      order: serializer.fromJson<int>(json['order']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      locked: serializer.fromJson<bool>(json['locked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'name': serializer.toJson<String>(name),
      'order': serializer.toJson<int>(order),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'locked': serializer.toJson<bool>(locked),
    };
  }

  Subcategory copyWith({
    int? id,
    int? categoryId,
    String? name,
    int? order,
    String? imageUrl,
    bool? locked,
  }) => Subcategory(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    order: order ?? this.order,
    imageUrl: imageUrl ?? this.imageUrl,
    locked: locked ?? this.locked,
  );
  Subcategory copyWithCompanion(SubcategoriesCompanion data) {
    return Subcategory(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      order: data.order.present ? data.order.value : this.order,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      locked: data.locked.present ? data.locked.value : this.locked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subcategory(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('order: $order, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('locked: $locked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, categoryId, name, order, imageUrl, locked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subcategory &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.order == this.order &&
          other.imageUrl == this.imageUrl &&
          other.locked == this.locked);
}

class SubcategoriesCompanion extends UpdateCompanion<Subcategory> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<String> name;
  final Value<int> order;
  final Value<String> imageUrl;
  final Value<bool> locked;
  const SubcategoriesCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.order = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.locked = const Value.absent(),
  });
  SubcategoriesCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    required String name,
    this.order = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.locked = const Value.absent(),
  }) : categoryId = Value(categoryId),
       name = Value(name);
  static Insertable<Subcategory> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<String>? name,
    Expression<int>? order,
    Expression<String>? imageUrl,
    Expression<bool>? locked,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (order != null) 'order': order,
      if (imageUrl != null) 'image_url': imageUrl,
      if (locked != null) 'locked': locked,
    });
  }

  SubcategoriesCompanion copyWith({
    Value<int>? id,
    Value<int>? categoryId,
    Value<String>? name,
    Value<int>? order,
    Value<String>? imageUrl,
    Value<bool>? locked,
  }) {
    return SubcategoriesCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      order: order ?? this.order,
      imageUrl: imageUrl ?? this.imageUrl,
      locked: locked ?? this.locked,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (locked.present) {
      map['locked'] = Variable<bool>(locked.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubcategoriesCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('order: $order, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('locked: $locked')
          ..write(')'))
        .toString();
  }
}

class $ExamsTable extends Exams with TableInfo<$ExamsTable, Exam> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _subcategoryIdMeta = const VerificationMeta(
    'subcategoryId',
  );
  @override
  late final GeneratedColumn<int> subcategoryId = GeneratedColumn<int>(
    'subcategory_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subcategories (id)',
    ),
  );
  static const VerificationMeta _questionCountMeta = const VerificationMeta(
    'questionCount',
  );
  @override
  late final GeneratedColumn<int> questionCount = GeneratedColumn<int>(
    'question_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _publishedMeta = const VerificationMeta(
    'published',
  );
  @override
  late final GeneratedColumn<bool> published = GeneratedColumn<bool>(
    'published',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("published" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _timeLimitMinutesMeta = const VerificationMeta(
    'timeLimitMinutes',
  );
  @override
  late final GeneratedColumn<int> timeLimitMinutes = GeneratedColumn<int>(
    'time_limit_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _shuffleOptionsMeta = const VerificationMeta(
    'shuffleOptions',
  );
  @override
  late final GeneratedColumn<bool> shuffleOptions = GeneratedColumn<bool>(
    'shuffle_options',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("shuffle_options" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _negativeMarkingMeta = const VerificationMeta(
    'negativeMarking',
  );
  @override
  late final GeneratedColumn<bool> negativeMarking = GeneratedColumn<bool>(
    'negative_marking',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("negative_marking" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _passPercentMeta = const VerificationMeta(
    'passPercent',
  );
  @override
  late final GeneratedColumn<int> passPercent = GeneratedColumn<int>(
    'pass_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(60),
  );
  static const VerificationMeta _themeKeyMeta = const VerificationMeta(
    'themeKey',
  );
  @override
  late final GeneratedColumn<int> themeKey = GeneratedColumn<int>(
    'theme_key',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pdfUrlMeta = const VerificationMeta('pdfUrl');
  @override
  late final GeneratedColumn<String> pdfUrl = GeneratedColumn<String>(
    'pdf_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    categoryId,
    subcategoryId,
    questionCount,
    published,
    timeLimitMinutes,
    shuffleOptions,
    negativeMarking,
    passPercent,
    themeKey,
    pdfUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exams';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exam> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('subcategory_id')) {
      context.handle(
        _subcategoryIdMeta,
        subcategoryId.isAcceptableOrUnknown(
          data['subcategory_id']!,
          _subcategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('question_count')) {
      context.handle(
        _questionCountMeta,
        questionCount.isAcceptableOrUnknown(
          data['question_count']!,
          _questionCountMeta,
        ),
      );
    }
    if (data.containsKey('published')) {
      context.handle(
        _publishedMeta,
        published.isAcceptableOrUnknown(data['published']!, _publishedMeta),
      );
    }
    if (data.containsKey('time_limit_minutes')) {
      context.handle(
        _timeLimitMinutesMeta,
        timeLimitMinutes.isAcceptableOrUnknown(
          data['time_limit_minutes']!,
          _timeLimitMinutesMeta,
        ),
      );
    }
    if (data.containsKey('shuffle_options')) {
      context.handle(
        _shuffleOptionsMeta,
        shuffleOptions.isAcceptableOrUnknown(
          data['shuffle_options']!,
          _shuffleOptionsMeta,
        ),
      );
    }
    if (data.containsKey('negative_marking')) {
      context.handle(
        _negativeMarkingMeta,
        negativeMarking.isAcceptableOrUnknown(
          data['negative_marking']!,
          _negativeMarkingMeta,
        ),
      );
    }
    if (data.containsKey('pass_percent')) {
      context.handle(
        _passPercentMeta,
        passPercent.isAcceptableOrUnknown(
          data['pass_percent']!,
          _passPercentMeta,
        ),
      );
    }
    if (data.containsKey('theme_key')) {
      context.handle(
        _themeKeyMeta,
        themeKey.isAcceptableOrUnknown(data['theme_key']!, _themeKeyMeta),
      );
    }
    if (data.containsKey('pdf_url')) {
      context.handle(
        _pdfUrlMeta,
        pdfUrl.isAcceptableOrUnknown(data['pdf_url']!, _pdfUrlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exam map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exam(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      subcategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subcategory_id'],
      ),
      questionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_count'],
      )!,
      published: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}published'],
      )!,
      timeLimitMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_limit_minutes'],
      )!,
      shuffleOptions: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}shuffle_options'],
      )!,
      negativeMarking: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}negative_marking'],
      )!,
      passPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pass_percent'],
      )!,
      themeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}theme_key'],
      )!,
      pdfUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pdf_url'],
      )!,
    );
  }

  @override
  $ExamsTable createAlias(String alias) {
    return $ExamsTable(attachedDatabase, alias);
  }
}

class Exam extends DataClass implements Insertable<Exam> {
  final int id;
  final String title;
  final String description;
  final int categoryId;
  final int? subcategoryId;
  final int questionCount;
  final bool published;
  final int timeLimitMinutes;
  final bool shuffleOptions;
  final bool negativeMarking;
  final int passPercent;
  final int themeKey;
  final String pdfUrl;
  const Exam({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    this.subcategoryId,
    required this.questionCount,
    required this.published,
    required this.timeLimitMinutes,
    required this.shuffleOptions,
    required this.negativeMarking,
    required this.passPercent,
    required this.themeKey,
    required this.pdfUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['category_id'] = Variable<int>(categoryId);
    if (!nullToAbsent || subcategoryId != null) {
      map['subcategory_id'] = Variable<int>(subcategoryId);
    }
    map['question_count'] = Variable<int>(questionCount);
    map['published'] = Variable<bool>(published);
    map['time_limit_minutes'] = Variable<int>(timeLimitMinutes);
    map['shuffle_options'] = Variable<bool>(shuffleOptions);
    map['negative_marking'] = Variable<bool>(negativeMarking);
    map['pass_percent'] = Variable<int>(passPercent);
    map['theme_key'] = Variable<int>(themeKey);
    map['pdf_url'] = Variable<String>(pdfUrl);
    return map;
  }

  ExamsCompanion toCompanion(bool nullToAbsent) {
    return ExamsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      categoryId: Value(categoryId),
      subcategoryId: subcategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(subcategoryId),
      questionCount: Value(questionCount),
      published: Value(published),
      timeLimitMinutes: Value(timeLimitMinutes),
      shuffleOptions: Value(shuffleOptions),
      negativeMarking: Value(negativeMarking),
      passPercent: Value(passPercent),
      themeKey: Value(themeKey),
      pdfUrl: Value(pdfUrl),
    );
  }

  factory Exam.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exam(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      subcategoryId: serializer.fromJson<int?>(json['subcategoryId']),
      questionCount: serializer.fromJson<int>(json['questionCount']),
      published: serializer.fromJson<bool>(json['published']),
      timeLimitMinutes: serializer.fromJson<int>(json['timeLimitMinutes']),
      shuffleOptions: serializer.fromJson<bool>(json['shuffleOptions']),
      negativeMarking: serializer.fromJson<bool>(json['negativeMarking']),
      passPercent: serializer.fromJson<int>(json['passPercent']),
      themeKey: serializer.fromJson<int>(json['themeKey']),
      pdfUrl: serializer.fromJson<String>(json['pdfUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'categoryId': serializer.toJson<int>(categoryId),
      'subcategoryId': serializer.toJson<int?>(subcategoryId),
      'questionCount': serializer.toJson<int>(questionCount),
      'published': serializer.toJson<bool>(published),
      'timeLimitMinutes': serializer.toJson<int>(timeLimitMinutes),
      'shuffleOptions': serializer.toJson<bool>(shuffleOptions),
      'negativeMarking': serializer.toJson<bool>(negativeMarking),
      'passPercent': serializer.toJson<int>(passPercent),
      'themeKey': serializer.toJson<int>(themeKey),
      'pdfUrl': serializer.toJson<String>(pdfUrl),
    };
  }

  Exam copyWith({
    int? id,
    String? title,
    String? description,
    int? categoryId,
    Value<int?> subcategoryId = const Value.absent(),
    int? questionCount,
    bool? published,
    int? timeLimitMinutes,
    bool? shuffleOptions,
    bool? negativeMarking,
    int? passPercent,
    int? themeKey,
    String? pdfUrl,
  }) => Exam(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    categoryId: categoryId ?? this.categoryId,
    subcategoryId: subcategoryId.present
        ? subcategoryId.value
        : this.subcategoryId,
    questionCount: questionCount ?? this.questionCount,
    published: published ?? this.published,
    timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
    shuffleOptions: shuffleOptions ?? this.shuffleOptions,
    negativeMarking: negativeMarking ?? this.negativeMarking,
    passPercent: passPercent ?? this.passPercent,
    themeKey: themeKey ?? this.themeKey,
    pdfUrl: pdfUrl ?? this.pdfUrl,
  );
  Exam copyWithCompanion(ExamsCompanion data) {
    return Exam(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      subcategoryId: data.subcategoryId.present
          ? data.subcategoryId.value
          : this.subcategoryId,
      questionCount: data.questionCount.present
          ? data.questionCount.value
          : this.questionCount,
      published: data.published.present ? data.published.value : this.published,
      timeLimitMinutes: data.timeLimitMinutes.present
          ? data.timeLimitMinutes.value
          : this.timeLimitMinutes,
      shuffleOptions: data.shuffleOptions.present
          ? data.shuffleOptions.value
          : this.shuffleOptions,
      negativeMarking: data.negativeMarking.present
          ? data.negativeMarking.value
          : this.negativeMarking,
      passPercent: data.passPercent.present
          ? data.passPercent.value
          : this.passPercent,
      themeKey: data.themeKey.present ? data.themeKey.value : this.themeKey,
      pdfUrl: data.pdfUrl.present ? data.pdfUrl.value : this.pdfUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exam(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('subcategoryId: $subcategoryId, ')
          ..write('questionCount: $questionCount, ')
          ..write('published: $published, ')
          ..write('timeLimitMinutes: $timeLimitMinutes, ')
          ..write('shuffleOptions: $shuffleOptions, ')
          ..write('negativeMarking: $negativeMarking, ')
          ..write('passPercent: $passPercent, ')
          ..write('themeKey: $themeKey, ')
          ..write('pdfUrl: $pdfUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    categoryId,
    subcategoryId,
    questionCount,
    published,
    timeLimitMinutes,
    shuffleOptions,
    negativeMarking,
    passPercent,
    themeKey,
    pdfUrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exam &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.categoryId == this.categoryId &&
          other.subcategoryId == this.subcategoryId &&
          other.questionCount == this.questionCount &&
          other.published == this.published &&
          other.timeLimitMinutes == this.timeLimitMinutes &&
          other.shuffleOptions == this.shuffleOptions &&
          other.negativeMarking == this.negativeMarking &&
          other.passPercent == this.passPercent &&
          other.themeKey == this.themeKey &&
          other.pdfUrl == this.pdfUrl);
}

class ExamsCompanion extends UpdateCompanion<Exam> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> description;
  final Value<int> categoryId;
  final Value<int?> subcategoryId;
  final Value<int> questionCount;
  final Value<bool> published;
  final Value<int> timeLimitMinutes;
  final Value<bool> shuffleOptions;
  final Value<bool> negativeMarking;
  final Value<int> passPercent;
  final Value<int> themeKey;
  final Value<String> pdfUrl;
  const ExamsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.subcategoryId = const Value.absent(),
    this.questionCount = const Value.absent(),
    this.published = const Value.absent(),
    this.timeLimitMinutes = const Value.absent(),
    this.shuffleOptions = const Value.absent(),
    this.negativeMarking = const Value.absent(),
    this.passPercent = const Value.absent(),
    this.themeKey = const Value.absent(),
    this.pdfUrl = const Value.absent(),
  });
  ExamsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required int categoryId,
    this.subcategoryId = const Value.absent(),
    this.questionCount = const Value.absent(),
    this.published = const Value.absent(),
    this.timeLimitMinutes = const Value.absent(),
    this.shuffleOptions = const Value.absent(),
    this.negativeMarking = const Value.absent(),
    this.passPercent = const Value.absent(),
    this.themeKey = const Value.absent(),
    this.pdfUrl = const Value.absent(),
  }) : title = Value(title),
       categoryId = Value(categoryId);
  static Insertable<Exam> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? categoryId,
    Expression<int>? subcategoryId,
    Expression<int>? questionCount,
    Expression<bool>? published,
    Expression<int>? timeLimitMinutes,
    Expression<bool>? shuffleOptions,
    Expression<bool>? negativeMarking,
    Expression<int>? passPercent,
    Expression<int>? themeKey,
    Expression<String>? pdfUrl,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (categoryId != null) 'category_id': categoryId,
      if (subcategoryId != null) 'subcategory_id': subcategoryId,
      if (questionCount != null) 'question_count': questionCount,
      if (published != null) 'published': published,
      if (timeLimitMinutes != null) 'time_limit_minutes': timeLimitMinutes,
      if (shuffleOptions != null) 'shuffle_options': shuffleOptions,
      if (negativeMarking != null) 'negative_marking': negativeMarking,
      if (passPercent != null) 'pass_percent': passPercent,
      if (themeKey != null) 'theme_key': themeKey,
      if (pdfUrl != null) 'pdf_url': pdfUrl,
    });
  }

  ExamsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? description,
    Value<int>? categoryId,
    Value<int?>? subcategoryId,
    Value<int>? questionCount,
    Value<bool>? published,
    Value<int>? timeLimitMinutes,
    Value<bool>? shuffleOptions,
    Value<bool>? negativeMarking,
    Value<int>? passPercent,
    Value<int>? themeKey,
    Value<String>? pdfUrl,
  }) {
    return ExamsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      questionCount: questionCount ?? this.questionCount,
      published: published ?? this.published,
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      shuffleOptions: shuffleOptions ?? this.shuffleOptions,
      negativeMarking: negativeMarking ?? this.negativeMarking,
      passPercent: passPercent ?? this.passPercent,
      themeKey: themeKey ?? this.themeKey,
      pdfUrl: pdfUrl ?? this.pdfUrl,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (subcategoryId.present) {
      map['subcategory_id'] = Variable<int>(subcategoryId.value);
    }
    if (questionCount.present) {
      map['question_count'] = Variable<int>(questionCount.value);
    }
    if (published.present) {
      map['published'] = Variable<bool>(published.value);
    }
    if (timeLimitMinutes.present) {
      map['time_limit_minutes'] = Variable<int>(timeLimitMinutes.value);
    }
    if (shuffleOptions.present) {
      map['shuffle_options'] = Variable<bool>(shuffleOptions.value);
    }
    if (negativeMarking.present) {
      map['negative_marking'] = Variable<bool>(negativeMarking.value);
    }
    if (passPercent.present) {
      map['pass_percent'] = Variable<int>(passPercent.value);
    }
    if (themeKey.present) {
      map['theme_key'] = Variable<int>(themeKey.value);
    }
    if (pdfUrl.present) {
      map['pdf_url'] = Variable<String>(pdfUrl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExamsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('categoryId: $categoryId, ')
          ..write('subcategoryId: $subcategoryId, ')
          ..write('questionCount: $questionCount, ')
          ..write('published: $published, ')
          ..write('timeLimitMinutes: $timeLimitMinutes, ')
          ..write('shuffleOptions: $shuffleOptions, ')
          ..write('negativeMarking: $negativeMarking, ')
          ..write('passPercent: $passPercent, ')
          ..write('themeKey: $themeKey, ')
          ..write('pdfUrl: $pdfUrl')
          ..write(')'))
        .toString();
  }
}

class $QuestionsTable extends Questions
    with TableInfo<$QuestionsTable, Question> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _multipleMeta = const VerificationMeta(
    'multiple',
  );
  @override
  late final GeneratedColumn<bool> multiple = GeneratedColumn<bool>(
    'multiple',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("multiple" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lockedMeta = const VerificationMeta('locked');
  @override
  late final GeneratedColumn<bool> locked = GeneratedColumn<bool>(
    'locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    body,
    explanation,
    multiple,
    locked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'questions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Question> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    }
    if (data.containsKey('multiple')) {
      context.handle(
        _multipleMeta,
        multiple.isAcceptableOrUnknown(data['multiple']!, _multipleMeta),
      );
    }
    if (data.containsKey('locked')) {
      context.handle(
        _lockedMeta,
        locked.isAcceptableOrUnknown(data['locked']!, _lockedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Question map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Question(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      )!,
      multiple: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}multiple'],
      )!,
      locked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}locked'],
      )!,
    );
  }

  @override
  $QuestionsTable createAlias(String alias) {
    return $QuestionsTable(attachedDatabase, alias);
  }
}

class Question extends DataClass implements Insertable<Question> {
  final int id;
  final String body;
  final String explanation;
  final bool multiple;
  final bool locked;
  const Question({
    required this.id,
    required this.body,
    required this.explanation,
    required this.multiple,
    required this.locked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['body'] = Variable<String>(body);
    map['explanation'] = Variable<String>(explanation);
    map['multiple'] = Variable<bool>(multiple);
    map['locked'] = Variable<bool>(locked);
    return map;
  }

  QuestionsCompanion toCompanion(bool nullToAbsent) {
    return QuestionsCompanion(
      id: Value(id),
      body: Value(body),
      explanation: Value(explanation),
      multiple: Value(multiple),
      locked: Value(locked),
    );
  }

  factory Question.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Question(
      id: serializer.fromJson<int>(json['id']),
      body: serializer.fromJson<String>(json['body']),
      explanation: serializer.fromJson<String>(json['explanation']),
      multiple: serializer.fromJson<bool>(json['multiple']),
      locked: serializer.fromJson<bool>(json['locked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'body': serializer.toJson<String>(body),
      'explanation': serializer.toJson<String>(explanation),
      'multiple': serializer.toJson<bool>(multiple),
      'locked': serializer.toJson<bool>(locked),
    };
  }

  Question copyWith({
    int? id,
    String? body,
    String? explanation,
    bool? multiple,
    bool? locked,
  }) => Question(
    id: id ?? this.id,
    body: body ?? this.body,
    explanation: explanation ?? this.explanation,
    multiple: multiple ?? this.multiple,
    locked: locked ?? this.locked,
  );
  Question copyWithCompanion(QuestionsCompanion data) {
    return Question(
      id: data.id.present ? data.id.value : this.id,
      body: data.body.present ? data.body.value : this.body,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      multiple: data.multiple.present ? data.multiple.value : this.multiple,
      locked: data.locked.present ? data.locked.value : this.locked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Question(')
          ..write('id: $id, ')
          ..write('body: $body, ')
          ..write('explanation: $explanation, ')
          ..write('multiple: $multiple, ')
          ..write('locked: $locked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, body, explanation, multiple, locked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Question &&
          other.id == this.id &&
          other.body == this.body &&
          other.explanation == this.explanation &&
          other.multiple == this.multiple &&
          other.locked == this.locked);
}

class QuestionsCompanion extends UpdateCompanion<Question> {
  final Value<int> id;
  final Value<String> body;
  final Value<String> explanation;
  final Value<bool> multiple;
  final Value<bool> locked;
  const QuestionsCompanion({
    this.id = const Value.absent(),
    this.body = const Value.absent(),
    this.explanation = const Value.absent(),
    this.multiple = const Value.absent(),
    this.locked = const Value.absent(),
  });
  QuestionsCompanion.insert({
    this.id = const Value.absent(),
    required String body,
    this.explanation = const Value.absent(),
    this.multiple = const Value.absent(),
    this.locked = const Value.absent(),
  }) : body = Value(body);
  static Insertable<Question> custom({
    Expression<int>? id,
    Expression<String>? body,
    Expression<String>? explanation,
    Expression<bool>? multiple,
    Expression<bool>? locked,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (body != null) 'body': body,
      if (explanation != null) 'explanation': explanation,
      if (multiple != null) 'multiple': multiple,
      if (locked != null) 'locked': locked,
    });
  }

  QuestionsCompanion copyWith({
    Value<int>? id,
    Value<String>? body,
    Value<String>? explanation,
    Value<bool>? multiple,
    Value<bool>? locked,
  }) {
    return QuestionsCompanion(
      id: id ?? this.id,
      body: body ?? this.body,
      explanation: explanation ?? this.explanation,
      multiple: multiple ?? this.multiple,
      locked: locked ?? this.locked,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (multiple.present) {
      map['multiple'] = Variable<bool>(multiple.value);
    }
    if (locked.present) {
      map['locked'] = Variable<bool>(locked.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionsCompanion(')
          ..write('id: $id, ')
          ..write('body: $body, ')
          ..write('explanation: $explanation, ')
          ..write('multiple: $multiple, ')
          ..write('locked: $locked')
          ..write(')'))
        .toString();
  }
}

class $ChoicesTable extends Choices with TableInfo<$ChoicesTable, Choice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<int> questionId = GeneratedColumn<int>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES questions (id)',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    questionId,
    label,
    isCorrect,
    order,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'choices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Choice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Choice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Choice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      )!,
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      )!,
    );
  }

  @override
  $ChoicesTable createAlias(String alias) {
    return $ChoicesTable(attachedDatabase, alias);
  }
}

class Choice extends DataClass implements Insertable<Choice> {
  final int id;
  final int questionId;
  final String label;
  final bool isCorrect;
  final int order;
  const Choice({
    required this.id,
    required this.questionId,
    required this.label,
    required this.isCorrect,
    required this.order,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['question_id'] = Variable<int>(questionId);
    map['label'] = Variable<String>(label);
    map['is_correct'] = Variable<bool>(isCorrect);
    map['order'] = Variable<int>(order);
    return map;
  }

  ChoicesCompanion toCompanion(bool nullToAbsent) {
    return ChoicesCompanion(
      id: Value(id),
      questionId: Value(questionId),
      label: Value(label),
      isCorrect: Value(isCorrect),
      order: Value(order),
    );
  }

  factory Choice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Choice(
      id: serializer.fromJson<int>(json['id']),
      questionId: serializer.fromJson<int>(json['questionId']),
      label: serializer.fromJson<String>(json['label']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
      order: serializer.fromJson<int>(json['order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'questionId': serializer.toJson<int>(questionId),
      'label': serializer.toJson<String>(label),
      'isCorrect': serializer.toJson<bool>(isCorrect),
      'order': serializer.toJson<int>(order),
    };
  }

  Choice copyWith({
    int? id,
    int? questionId,
    String? label,
    bool? isCorrect,
    int? order,
  }) => Choice(
    id: id ?? this.id,
    questionId: questionId ?? this.questionId,
    label: label ?? this.label,
    isCorrect: isCorrect ?? this.isCorrect,
    order: order ?? this.order,
  );
  Choice copyWithCompanion(ChoicesCompanion data) {
    return Choice(
      id: data.id.present ? data.id.value : this.id,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      label: data.label.present ? data.label.value : this.label,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      order: data.order.present ? data.order.value : this.order,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Choice(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('label: $label, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, questionId, label, isCorrect, order);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Choice &&
          other.id == this.id &&
          other.questionId == this.questionId &&
          other.label == this.label &&
          other.isCorrect == this.isCorrect &&
          other.order == this.order);
}

class ChoicesCompanion extends UpdateCompanion<Choice> {
  final Value<int> id;
  final Value<int> questionId;
  final Value<String> label;
  final Value<bool> isCorrect;
  final Value<int> order;
  const ChoicesCompanion({
    this.id = const Value.absent(),
    this.questionId = const Value.absent(),
    this.label = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.order = const Value.absent(),
  });
  ChoicesCompanion.insert({
    this.id = const Value.absent(),
    required int questionId,
    required String label,
    this.isCorrect = const Value.absent(),
    this.order = const Value.absent(),
  }) : questionId = Value(questionId),
       label = Value(label);
  static Insertable<Choice> custom({
    Expression<int>? id,
    Expression<int>? questionId,
    Expression<String>? label,
    Expression<bool>? isCorrect,
    Expression<int>? order,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questionId != null) 'question_id': questionId,
      if (label != null) 'label': label,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (order != null) 'order': order,
    });
  }

  ChoicesCompanion copyWith({
    Value<int>? id,
    Value<int>? questionId,
    Value<String>? label,
    Value<bool>? isCorrect,
    Value<int>? order,
  }) {
    return ChoicesCompanion(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      label: label ?? this.label,
      isCorrect: isCorrect ?? this.isCorrect,
      order: order ?? this.order,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChoicesCompanion(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('label: $label, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }
}

class $ExamQuestionsTable extends ExamQuestions
    with TableInfo<$ExamQuestionsTable, ExamQuestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamQuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _examIdMeta = const VerificationMeta('examId');
  @override
  late final GeneratedColumn<int> examId = GeneratedColumn<int>(
    'exam_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exams (id)',
    ),
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<int> questionId = GeneratedColumn<int>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES questions (id)',
    ),
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<int> points = GeneratedColumn<int>(
    'points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [id, examId, questionId, order, points];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exam_questions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExamQuestion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exam_id')) {
      context.handle(
        _examIdMeta,
        examId.isAcceptableOrUnknown(data['exam_id']!, _examIdMeta),
      );
    } else if (isInserting) {
      context.missing(_examIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    if (data.containsKey('points')) {
      context.handle(
        _pointsMeta,
        points.isAcceptableOrUnknown(data['points']!, _pointsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExamQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExamQuestion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      examId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exam_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_id'],
      )!,
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      )!,
      points: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points'],
      )!,
    );
  }

  @override
  $ExamQuestionsTable createAlias(String alias) {
    return $ExamQuestionsTable(attachedDatabase, alias);
  }
}

class ExamQuestion extends DataClass implements Insertable<ExamQuestion> {
  final int id;
  final int examId;
  final int questionId;
  final int order;
  final int points;
  const ExamQuestion({
    required this.id,
    required this.examId,
    required this.questionId,
    required this.order,
    required this.points,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exam_id'] = Variable<int>(examId);
    map['question_id'] = Variable<int>(questionId);
    map['order'] = Variable<int>(order);
    map['points'] = Variable<int>(points);
    return map;
  }

  ExamQuestionsCompanion toCompanion(bool nullToAbsent) {
    return ExamQuestionsCompanion(
      id: Value(id),
      examId: Value(examId),
      questionId: Value(questionId),
      order: Value(order),
      points: Value(points),
    );
  }

  factory ExamQuestion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExamQuestion(
      id: serializer.fromJson<int>(json['id']),
      examId: serializer.fromJson<int>(json['examId']),
      questionId: serializer.fromJson<int>(json['questionId']),
      order: serializer.fromJson<int>(json['order']),
      points: serializer.fromJson<int>(json['points']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'examId': serializer.toJson<int>(examId),
      'questionId': serializer.toJson<int>(questionId),
      'order': serializer.toJson<int>(order),
      'points': serializer.toJson<int>(points),
    };
  }

  ExamQuestion copyWith({
    int? id,
    int? examId,
    int? questionId,
    int? order,
    int? points,
  }) => ExamQuestion(
    id: id ?? this.id,
    examId: examId ?? this.examId,
    questionId: questionId ?? this.questionId,
    order: order ?? this.order,
    points: points ?? this.points,
  );
  ExamQuestion copyWithCompanion(ExamQuestionsCompanion data) {
    return ExamQuestion(
      id: data.id.present ? data.id.value : this.id,
      examId: data.examId.present ? data.examId.value : this.examId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      order: data.order.present ? data.order.value : this.order,
      points: data.points.present ? data.points.value : this.points,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExamQuestion(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('questionId: $questionId, ')
          ..write('order: $order, ')
          ..write('points: $points')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, examId, questionId, order, points);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExamQuestion &&
          other.id == this.id &&
          other.examId == this.examId &&
          other.questionId == this.questionId &&
          other.order == this.order &&
          other.points == this.points);
}

class ExamQuestionsCompanion extends UpdateCompanion<ExamQuestion> {
  final Value<int> id;
  final Value<int> examId;
  final Value<int> questionId;
  final Value<int> order;
  final Value<int> points;
  const ExamQuestionsCompanion({
    this.id = const Value.absent(),
    this.examId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.order = const Value.absent(),
    this.points = const Value.absent(),
  });
  ExamQuestionsCompanion.insert({
    this.id = const Value.absent(),
    required int examId,
    required int questionId,
    this.order = const Value.absent(),
    this.points = const Value.absent(),
  }) : examId = Value(examId),
       questionId = Value(questionId);
  static Insertable<ExamQuestion> custom({
    Expression<int>? id,
    Expression<int>? examId,
    Expression<int>? questionId,
    Expression<int>? order,
    Expression<int>? points,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (examId != null) 'exam_id': examId,
      if (questionId != null) 'question_id': questionId,
      if (order != null) 'order': order,
      if (points != null) 'points': points,
    });
  }

  ExamQuestionsCompanion copyWith({
    Value<int>? id,
    Value<int>? examId,
    Value<int>? questionId,
    Value<int>? order,
    Value<int>? points,
  }) {
    return ExamQuestionsCompanion(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      questionId: questionId ?? this.questionId,
      order: order ?? this.order,
      points: points ?? this.points,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (examId.present) {
      map['exam_id'] = Variable<int>(examId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (points.present) {
      map['points'] = Variable<int>(points.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExamQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('questionId: $questionId, ')
          ..write('order: $order, ')
          ..write('points: $points')
          ..write(')'))
        .toString();
  }
}

class $ExamGradeBandsTable extends ExamGradeBands
    with TableInfo<$ExamGradeBandsTable, ExamGradeBand> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamGradeBandsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _examIdMeta = const VerificationMeta('examId');
  @override
  late final GeneratedColumn<int> examId = GeneratedColumn<int>(
    'exam_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exams (id)',
    ),
  );
  static const VerificationMeta _minPercentMeta = const VerificationMeta(
    'minPercent',
  );
  @override
  late final GeneratedColumn<int> minPercent = GeneratedColumn<int>(
    'min_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#4CAF50'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, examId, minPercent, label, color];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exam_grade_bands';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExamGradeBand> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exam_id')) {
      context.handle(
        _examIdMeta,
        examId.isAcceptableOrUnknown(data['exam_id']!, _examIdMeta),
      );
    } else if (isInserting) {
      context.missing(_examIdMeta);
    }
    if (data.containsKey('min_percent')) {
      context.handle(
        _minPercentMeta,
        minPercent.isAcceptableOrUnknown(data['min_percent']!, _minPercentMeta),
      );
    } else if (isInserting) {
      context.missing(_minPercentMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExamGradeBand map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExamGradeBand(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      examId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exam_id'],
      )!,
      minPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_percent'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
    );
  }

  @override
  $ExamGradeBandsTable createAlias(String alias) {
    return $ExamGradeBandsTable(attachedDatabase, alias);
  }
}

class ExamGradeBand extends DataClass implements Insertable<ExamGradeBand> {
  final int id;
  final int examId;
  final int minPercent;
  final String label;
  final String color;
  const ExamGradeBand({
    required this.id,
    required this.examId,
    required this.minPercent,
    required this.label,
    required this.color,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exam_id'] = Variable<int>(examId);
    map['min_percent'] = Variable<int>(minPercent);
    map['label'] = Variable<String>(label);
    map['color'] = Variable<String>(color);
    return map;
  }

  ExamGradeBandsCompanion toCompanion(bool nullToAbsent) {
    return ExamGradeBandsCompanion(
      id: Value(id),
      examId: Value(examId),
      minPercent: Value(minPercent),
      label: Value(label),
      color: Value(color),
    );
  }

  factory ExamGradeBand.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExamGradeBand(
      id: serializer.fromJson<int>(json['id']),
      examId: serializer.fromJson<int>(json['examId']),
      minPercent: serializer.fromJson<int>(json['minPercent']),
      label: serializer.fromJson<String>(json['label']),
      color: serializer.fromJson<String>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'examId': serializer.toJson<int>(examId),
      'minPercent': serializer.toJson<int>(minPercent),
      'label': serializer.toJson<String>(label),
      'color': serializer.toJson<String>(color),
    };
  }

  ExamGradeBand copyWith({
    int? id,
    int? examId,
    int? minPercent,
    String? label,
    String? color,
  }) => ExamGradeBand(
    id: id ?? this.id,
    examId: examId ?? this.examId,
    minPercent: minPercent ?? this.minPercent,
    label: label ?? this.label,
    color: color ?? this.color,
  );
  ExamGradeBand copyWithCompanion(ExamGradeBandsCompanion data) {
    return ExamGradeBand(
      id: data.id.present ? data.id.value : this.id,
      examId: data.examId.present ? data.examId.value : this.examId,
      minPercent: data.minPercent.present
          ? data.minPercent.value
          : this.minPercent,
      label: data.label.present ? data.label.value : this.label,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExamGradeBand(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('minPercent: $minPercent, ')
          ..write('label: $label, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, examId, minPercent, label, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExamGradeBand &&
          other.id == this.id &&
          other.examId == this.examId &&
          other.minPercent == this.minPercent &&
          other.label == this.label &&
          other.color == this.color);
}

class ExamGradeBandsCompanion extends UpdateCompanion<ExamGradeBand> {
  final Value<int> id;
  final Value<int> examId;
  final Value<int> minPercent;
  final Value<String> label;
  final Value<String> color;
  const ExamGradeBandsCompanion({
    this.id = const Value.absent(),
    this.examId = const Value.absent(),
    this.minPercent = const Value.absent(),
    this.label = const Value.absent(),
    this.color = const Value.absent(),
  });
  ExamGradeBandsCompanion.insert({
    this.id = const Value.absent(),
    required int examId,
    required int minPercent,
    required String label,
    this.color = const Value.absent(),
  }) : examId = Value(examId),
       minPercent = Value(minPercent),
       label = Value(label);
  static Insertable<ExamGradeBand> custom({
    Expression<int>? id,
    Expression<int>? examId,
    Expression<int>? minPercent,
    Expression<String>? label,
    Expression<String>? color,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (examId != null) 'exam_id': examId,
      if (minPercent != null) 'min_percent': minPercent,
      if (label != null) 'label': label,
      if (color != null) 'color': color,
    });
  }

  ExamGradeBandsCompanion copyWith({
    Value<int>? id,
    Value<int>? examId,
    Value<int>? minPercent,
    Value<String>? label,
    Value<String>? color,
  }) {
    return ExamGradeBandsCompanion(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      minPercent: minPercent ?? this.minPercent,
      label: label ?? this.label,
      color: color ?? this.color,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (examId.present) {
      map['exam_id'] = Variable<int>(examId.value);
    }
    if (minPercent.present) {
      map['min_percent'] = Variable<int>(minPercent.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExamGradeBandsCompanion(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('minPercent: $minPercent, ')
          ..write('label: $label, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }
}

class $QuestionCategoriesTable extends QuestionCategories
    with TableInfo<$QuestionCategoriesTable, QuestionCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<int> questionId = GeneratedColumn<int>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES questions (id)',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, questionId, categoryId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'question_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestionCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestionCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
    );
  }

  @override
  $QuestionCategoriesTable createAlias(String alias) {
    return $QuestionCategoriesTable(attachedDatabase, alias);
  }
}

class QuestionCategory extends DataClass
    implements Insertable<QuestionCategory> {
  final int id;
  final int questionId;
  final int categoryId;
  const QuestionCategory({
    required this.id,
    required this.questionId,
    required this.categoryId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['question_id'] = Variable<int>(questionId);
    map['category_id'] = Variable<int>(categoryId);
    return map;
  }

  QuestionCategoriesCompanion toCompanion(bool nullToAbsent) {
    return QuestionCategoriesCompanion(
      id: Value(id),
      questionId: Value(questionId),
      categoryId: Value(categoryId),
    );
  }

  factory QuestionCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionCategory(
      id: serializer.fromJson<int>(json['id']),
      questionId: serializer.fromJson<int>(json['questionId']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'questionId': serializer.toJson<int>(questionId),
      'categoryId': serializer.toJson<int>(categoryId),
    };
  }

  QuestionCategory copyWith({int? id, int? questionId, int? categoryId}) =>
      QuestionCategory(
        id: id ?? this.id,
        questionId: questionId ?? this.questionId,
        categoryId: categoryId ?? this.categoryId,
      );
  QuestionCategory copyWithCompanion(QuestionCategoriesCompanion data) {
    return QuestionCategory(
      id: data.id.present ? data.id.value : this.id,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionCategory(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, questionId, categoryId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionCategory &&
          other.id == this.id &&
          other.questionId == this.questionId &&
          other.categoryId == this.categoryId);
}

class QuestionCategoriesCompanion extends UpdateCompanion<QuestionCategory> {
  final Value<int> id;
  final Value<int> questionId;
  final Value<int> categoryId;
  const QuestionCategoriesCompanion({
    this.id = const Value.absent(),
    this.questionId = const Value.absent(),
    this.categoryId = const Value.absent(),
  });
  QuestionCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required int questionId,
    required int categoryId,
  }) : questionId = Value(questionId),
       categoryId = Value(categoryId);
  static Insertable<QuestionCategory> custom({
    Expression<int>? id,
    Expression<int>? questionId,
    Expression<int>? categoryId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questionId != null) 'question_id': questionId,
      if (categoryId != null) 'category_id': categoryId,
    });
  }

  QuestionCategoriesCompanion copyWith({
    Value<int>? id,
    Value<int>? questionId,
    Value<int>? categoryId,
  }) {
    return QuestionCategoriesCompanion(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }
}

class $QuestionSubcategoriesTable extends QuestionSubcategories
    with TableInfo<$QuestionSubcategoriesTable, QuestionSubcategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionSubcategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<int> questionId = GeneratedColumn<int>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES questions (id)',
    ),
  );
  static const VerificationMeta _subcategoryIdMeta = const VerificationMeta(
    'subcategoryId',
  );
  @override
  late final GeneratedColumn<int> subcategoryId = GeneratedColumn<int>(
    'subcategory_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subcategories (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, questionId, subcategoryId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'question_subcategories';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestionSubcategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('subcategory_id')) {
      context.handle(
        _subcategoryIdMeta,
        subcategoryId.isAcceptableOrUnknown(
          data['subcategory_id']!,
          _subcategoryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subcategoryIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestionSubcategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionSubcategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_id'],
      )!,
      subcategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subcategory_id'],
      )!,
    );
  }

  @override
  $QuestionSubcategoriesTable createAlias(String alias) {
    return $QuestionSubcategoriesTable(attachedDatabase, alias);
  }
}

class QuestionSubcategory extends DataClass
    implements Insertable<QuestionSubcategory> {
  final int id;
  final int questionId;
  final int subcategoryId;
  const QuestionSubcategory({
    required this.id,
    required this.questionId,
    required this.subcategoryId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['question_id'] = Variable<int>(questionId);
    map['subcategory_id'] = Variable<int>(subcategoryId);
    return map;
  }

  QuestionSubcategoriesCompanion toCompanion(bool nullToAbsent) {
    return QuestionSubcategoriesCompanion(
      id: Value(id),
      questionId: Value(questionId),
      subcategoryId: Value(subcategoryId),
    );
  }

  factory QuestionSubcategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionSubcategory(
      id: serializer.fromJson<int>(json['id']),
      questionId: serializer.fromJson<int>(json['questionId']),
      subcategoryId: serializer.fromJson<int>(json['subcategoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'questionId': serializer.toJson<int>(questionId),
      'subcategoryId': serializer.toJson<int>(subcategoryId),
    };
  }

  QuestionSubcategory copyWith({
    int? id,
    int? questionId,
    int? subcategoryId,
  }) => QuestionSubcategory(
    id: id ?? this.id,
    questionId: questionId ?? this.questionId,
    subcategoryId: subcategoryId ?? this.subcategoryId,
  );
  QuestionSubcategory copyWithCompanion(QuestionSubcategoriesCompanion data) {
    return QuestionSubcategory(
      id: data.id.present ? data.id.value : this.id,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      subcategoryId: data.subcategoryId.present
          ? data.subcategoryId.value
          : this.subcategoryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionSubcategory(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('subcategoryId: $subcategoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, questionId, subcategoryId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionSubcategory &&
          other.id == this.id &&
          other.questionId == this.questionId &&
          other.subcategoryId == this.subcategoryId);
}

class QuestionSubcategoriesCompanion
    extends UpdateCompanion<QuestionSubcategory> {
  final Value<int> id;
  final Value<int> questionId;
  final Value<int> subcategoryId;
  const QuestionSubcategoriesCompanion({
    this.id = const Value.absent(),
    this.questionId = const Value.absent(),
    this.subcategoryId = const Value.absent(),
  });
  QuestionSubcategoriesCompanion.insert({
    this.id = const Value.absent(),
    required int questionId,
    required int subcategoryId,
  }) : questionId = Value(questionId),
       subcategoryId = Value(subcategoryId);
  static Insertable<QuestionSubcategory> custom({
    Expression<int>? id,
    Expression<int>? questionId,
    Expression<int>? subcategoryId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questionId != null) 'question_id': questionId,
      if (subcategoryId != null) 'subcategory_id': subcategoryId,
    });
  }

  QuestionSubcategoriesCompanion copyWith({
    Value<int>? id,
    Value<int>? questionId,
    Value<int>? subcategoryId,
  }) {
    return QuestionSubcategoriesCompanion(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (subcategoryId.present) {
      map['subcategory_id'] = Variable<int>(subcategoryId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionSubcategoriesCompanion(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('subcategoryId: $subcategoryId')
          ..write(')'))
        .toString();
  }
}

class $AttemptsTable extends Attempts with TableInfo<$AttemptsTable, Attempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _examIdMeta = const VerificationMeta('examId');
  @override
  late final GeneratedColumn<int> examId = GeneratedColumn<int>(
    'exam_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exams (id)',
    ),
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scorePercentMeta = const VerificationMeta(
    'scorePercent',
  );
  @override
  late final GeneratedColumn<int> scorePercent = GeneratedColumn<int>(
    'score_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _gradeLabelMeta = const VerificationMeta(
    'gradeLabel',
  );
  @override
  late final GeneratedColumn<String> gradeLabel = GeneratedColumn<String>(
    'grade_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _userEmailMeta = const VerificationMeta(
    'userEmail',
  );
  @override
  late final GeneratedColumn<String> userEmail = GeneratedColumn<String>(
    'user_email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('guest@local'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    examId,
    mode,
    startedAt,
    endedAt,
    score,
    scorePercent,
    gradeLabel,
    synced,
    userEmail,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exam_id')) {
      context.handle(
        _examIdMeta,
        examId.isAcceptableOrUnknown(data['exam_id']!, _examIdMeta),
      );
    } else if (isInserting) {
      context.missing(_examIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('score_percent')) {
      context.handle(
        _scorePercentMeta,
        scorePercent.isAcceptableOrUnknown(
          data['score_percent']!,
          _scorePercentMeta,
        ),
      );
    }
    if (data.containsKey('grade_label')) {
      context.handle(
        _gradeLabelMeta,
        gradeLabel.isAcceptableOrUnknown(data['grade_label']!, _gradeLabelMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('user_email')) {
      context.handle(
        _userEmailMeta,
        userEmail.isAcceptableOrUnknown(data['user_email']!, _userEmailMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attempt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      examId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exam_id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      ),
      scorePercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score_percent'],
      )!,
      gradeLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade_label'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      userEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_email'],
      )!,
    );
  }

  @override
  $AttemptsTable createAlias(String alias) {
    return $AttemptsTable(attachedDatabase, alias);
  }
}

class Attempt extends DataClass implements Insertable<Attempt> {
  final int id;
  final int examId;
  final String mode;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? score;
  final int scorePercent;
  final String gradeLabel;
  final bool synced;
  final String userEmail;
  const Attempt({
    required this.id,
    required this.examId,
    required this.mode,
    required this.startedAt,
    this.endedAt,
    this.score,
    required this.scorePercent,
    required this.gradeLabel,
    required this.synced,
    required this.userEmail,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exam_id'] = Variable<int>(examId);
    map['mode'] = Variable<String>(mode);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<int>(score);
    }
    map['score_percent'] = Variable<int>(scorePercent);
    map['grade_label'] = Variable<String>(gradeLabel);
    map['synced'] = Variable<bool>(synced);
    map['user_email'] = Variable<String>(userEmail);
    return map;
  }

  AttemptsCompanion toCompanion(bool nullToAbsent) {
    return AttemptsCompanion(
      id: Value(id),
      examId: Value(examId),
      mode: Value(mode),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      score: score == null && nullToAbsent
          ? const Value.absent()
          : Value(score),
      scorePercent: Value(scorePercent),
      gradeLabel: Value(gradeLabel),
      synced: Value(synced),
      userEmail: Value(userEmail),
    );
  }

  factory Attempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attempt(
      id: serializer.fromJson<int>(json['id']),
      examId: serializer.fromJson<int>(json['examId']),
      mode: serializer.fromJson<String>(json['mode']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      score: serializer.fromJson<int?>(json['score']),
      scorePercent: serializer.fromJson<int>(json['scorePercent']),
      gradeLabel: serializer.fromJson<String>(json['gradeLabel']),
      synced: serializer.fromJson<bool>(json['synced']),
      userEmail: serializer.fromJson<String>(json['userEmail']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'examId': serializer.toJson<int>(examId),
      'mode': serializer.toJson<String>(mode),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'score': serializer.toJson<int?>(score),
      'scorePercent': serializer.toJson<int>(scorePercent),
      'gradeLabel': serializer.toJson<String>(gradeLabel),
      'synced': serializer.toJson<bool>(synced),
      'userEmail': serializer.toJson<String>(userEmail),
    };
  }

  Attempt copyWith({
    int? id,
    int? examId,
    String? mode,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    Value<int?> score = const Value.absent(),
    int? scorePercent,
    String? gradeLabel,
    bool? synced,
    String? userEmail,
  }) => Attempt(
    id: id ?? this.id,
    examId: examId ?? this.examId,
    mode: mode ?? this.mode,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    score: score.present ? score.value : this.score,
    scorePercent: scorePercent ?? this.scorePercent,
    gradeLabel: gradeLabel ?? this.gradeLabel,
    synced: synced ?? this.synced,
    userEmail: userEmail ?? this.userEmail,
  );
  Attempt copyWithCompanion(AttemptsCompanion data) {
    return Attempt(
      id: data.id.present ? data.id.value : this.id,
      examId: data.examId.present ? data.examId.value : this.examId,
      mode: data.mode.present ? data.mode.value : this.mode,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      score: data.score.present ? data.score.value : this.score,
      scorePercent: data.scorePercent.present
          ? data.scorePercent.value
          : this.scorePercent,
      gradeLabel: data.gradeLabel.present
          ? data.gradeLabel.value
          : this.gradeLabel,
      synced: data.synced.present ? data.synced.value : this.synced,
      userEmail: data.userEmail.present ? data.userEmail.value : this.userEmail,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attempt(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('mode: $mode, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('score: $score, ')
          ..write('scorePercent: $scorePercent, ')
          ..write('gradeLabel: $gradeLabel, ')
          ..write('synced: $synced, ')
          ..write('userEmail: $userEmail')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    examId,
    mode,
    startedAt,
    endedAt,
    score,
    scorePercent,
    gradeLabel,
    synced,
    userEmail,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attempt &&
          other.id == this.id &&
          other.examId == this.examId &&
          other.mode == this.mode &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.score == this.score &&
          other.scorePercent == this.scorePercent &&
          other.gradeLabel == this.gradeLabel &&
          other.synced == this.synced &&
          other.userEmail == this.userEmail);
}

class AttemptsCompanion extends UpdateCompanion<Attempt> {
  final Value<int> id;
  final Value<int> examId;
  final Value<String> mode;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int?> score;
  final Value<int> scorePercent;
  final Value<String> gradeLabel;
  final Value<bool> synced;
  final Value<String> userEmail;
  const AttemptsCompanion({
    this.id = const Value.absent(),
    this.examId = const Value.absent(),
    this.mode = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.score = const Value.absent(),
    this.scorePercent = const Value.absent(),
    this.gradeLabel = const Value.absent(),
    this.synced = const Value.absent(),
    this.userEmail = const Value.absent(),
  });
  AttemptsCompanion.insert({
    this.id = const Value.absent(),
    required int examId,
    required String mode,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.score = const Value.absent(),
    this.scorePercent = const Value.absent(),
    this.gradeLabel = const Value.absent(),
    this.synced = const Value.absent(),
    this.userEmail = const Value.absent(),
  }) : examId = Value(examId),
       mode = Value(mode),
       startedAt = Value(startedAt);
  static Insertable<Attempt> custom({
    Expression<int>? id,
    Expression<int>? examId,
    Expression<String>? mode,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? score,
    Expression<int>? scorePercent,
    Expression<String>? gradeLabel,
    Expression<bool>? synced,
    Expression<String>? userEmail,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (examId != null) 'exam_id': examId,
      if (mode != null) 'mode': mode,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (score != null) 'score': score,
      if (scorePercent != null) 'score_percent': scorePercent,
      if (gradeLabel != null) 'grade_label': gradeLabel,
      if (synced != null) 'synced': synced,
      if (userEmail != null) 'user_email': userEmail,
    });
  }

  AttemptsCompanion copyWith({
    Value<int>? id,
    Value<int>? examId,
    Value<String>? mode,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int?>? score,
    Value<int>? scorePercent,
    Value<String>? gradeLabel,
    Value<bool>? synced,
    Value<String>? userEmail,
  }) {
    return AttemptsCompanion(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      mode: mode ?? this.mode,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      score: score ?? this.score,
      scorePercent: scorePercent ?? this.scorePercent,
      gradeLabel: gradeLabel ?? this.gradeLabel,
      synced: synced ?? this.synced,
      userEmail: userEmail ?? this.userEmail,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (examId.present) {
      map['exam_id'] = Variable<int>(examId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (scorePercent.present) {
      map['score_percent'] = Variable<int>(scorePercent.value);
    }
    if (gradeLabel.present) {
      map['grade_label'] = Variable<String>(gradeLabel.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (userEmail.present) {
      map['user_email'] = Variable<String>(userEmail.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttemptsCompanion(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('mode: $mode, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('score: $score, ')
          ..write('scorePercent: $scorePercent, ')
          ..write('gradeLabel: $gradeLabel, ')
          ..write('synced: $synced, ')
          ..write('userEmail: $userEmail')
          ..write(')'))
        .toString();
  }
}

class $AttemptAnswersTable extends AttemptAnswers
    with TableInfo<$AttemptAnswersTable, AttemptAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttemptAnswersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _attemptIdMeta = const VerificationMeta(
    'attemptId',
  );
  @override
  late final GeneratedColumn<int> attemptId = GeneratedColumn<int>(
    'attempt_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES attempts (id)',
    ),
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<int> questionId = GeneratedColumn<int>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES questions (id)',
    ),
  );
  static const VerificationMeta _selectedMeta = const VerificationMeta(
    'selected',
  );
  @override
  late final GeneratedColumn<String> selected = GeneratedColumn<String>(
    'selected',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMsMeta = const VerificationMeta('timeMs');
  @override
  late final GeneratedColumn<int> timeMs = GeneratedColumn<int>(
    'time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<int> points = GeneratedColumn<int>(
    'points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    attemptId,
    questionId,
    selected,
    timeMs,
    isCorrect,
    points,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attempt_answers';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttemptAnswer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('attempt_id')) {
      context.handle(
        _attemptIdMeta,
        attemptId.isAcceptableOrUnknown(data['attempt_id']!, _attemptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('selected')) {
      context.handle(
        _selectedMeta,
        selected.isAcceptableOrUnknown(data['selected']!, _selectedMeta),
      );
    } else if (isInserting) {
      context.missing(_selectedMeta);
    }
    if (data.containsKey('time_ms')) {
      context.handle(
        _timeMsMeta,
        timeMs.isAcceptableOrUnknown(data['time_ms']!, _timeMsMeta),
      );
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    }
    if (data.containsKey('points')) {
      context.handle(
        _pointsMeta,
        points.isAcceptableOrUnknown(data['points']!, _pointsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttemptAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttemptAnswer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      attemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_id'],
      )!,
      selected: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected'],
      )!,
      timeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_ms'],
      )!,
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      )!,
      points: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points'],
      )!,
    );
  }

  @override
  $AttemptAnswersTable createAlias(String alias) {
    return $AttemptAnswersTable(attachedDatabase, alias);
  }
}

class AttemptAnswer extends DataClass implements Insertable<AttemptAnswer> {
  final int id;
  final int attemptId;
  final int questionId;
  final String selected;
  final int timeMs;
  final bool isCorrect;
  final int points;
  const AttemptAnswer({
    required this.id,
    required this.attemptId,
    required this.questionId,
    required this.selected,
    required this.timeMs,
    required this.isCorrect,
    required this.points,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['attempt_id'] = Variable<int>(attemptId);
    map['question_id'] = Variable<int>(questionId);
    map['selected'] = Variable<String>(selected);
    map['time_ms'] = Variable<int>(timeMs);
    map['is_correct'] = Variable<bool>(isCorrect);
    map['points'] = Variable<int>(points);
    return map;
  }

  AttemptAnswersCompanion toCompanion(bool nullToAbsent) {
    return AttemptAnswersCompanion(
      id: Value(id),
      attemptId: Value(attemptId),
      questionId: Value(questionId),
      selected: Value(selected),
      timeMs: Value(timeMs),
      isCorrect: Value(isCorrect),
      points: Value(points),
    );
  }

  factory AttemptAnswer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttemptAnswer(
      id: serializer.fromJson<int>(json['id']),
      attemptId: serializer.fromJson<int>(json['attemptId']),
      questionId: serializer.fromJson<int>(json['questionId']),
      selected: serializer.fromJson<String>(json['selected']),
      timeMs: serializer.fromJson<int>(json['timeMs']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
      points: serializer.fromJson<int>(json['points']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'attemptId': serializer.toJson<int>(attemptId),
      'questionId': serializer.toJson<int>(questionId),
      'selected': serializer.toJson<String>(selected),
      'timeMs': serializer.toJson<int>(timeMs),
      'isCorrect': serializer.toJson<bool>(isCorrect),
      'points': serializer.toJson<int>(points),
    };
  }

  AttemptAnswer copyWith({
    int? id,
    int? attemptId,
    int? questionId,
    String? selected,
    int? timeMs,
    bool? isCorrect,
    int? points,
  }) => AttemptAnswer(
    id: id ?? this.id,
    attemptId: attemptId ?? this.attemptId,
    questionId: questionId ?? this.questionId,
    selected: selected ?? this.selected,
    timeMs: timeMs ?? this.timeMs,
    isCorrect: isCorrect ?? this.isCorrect,
    points: points ?? this.points,
  );
  AttemptAnswer copyWithCompanion(AttemptAnswersCompanion data) {
    return AttemptAnswer(
      id: data.id.present ? data.id.value : this.id,
      attemptId: data.attemptId.present ? data.attemptId.value : this.attemptId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      selected: data.selected.present ? data.selected.value : this.selected,
      timeMs: data.timeMs.present ? data.timeMs.value : this.timeMs,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      points: data.points.present ? data.points.value : this.points,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttemptAnswer(')
          ..write('id: $id, ')
          ..write('attemptId: $attemptId, ')
          ..write('questionId: $questionId, ')
          ..write('selected: $selected, ')
          ..write('timeMs: $timeMs, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('points: $points')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    attemptId,
    questionId,
    selected,
    timeMs,
    isCorrect,
    points,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttemptAnswer &&
          other.id == this.id &&
          other.attemptId == this.attemptId &&
          other.questionId == this.questionId &&
          other.selected == this.selected &&
          other.timeMs == this.timeMs &&
          other.isCorrect == this.isCorrect &&
          other.points == this.points);
}

class AttemptAnswersCompanion extends UpdateCompanion<AttemptAnswer> {
  final Value<int> id;
  final Value<int> attemptId;
  final Value<int> questionId;
  final Value<String> selected;
  final Value<int> timeMs;
  final Value<bool> isCorrect;
  final Value<int> points;
  const AttemptAnswersCompanion({
    this.id = const Value.absent(),
    this.attemptId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.selected = const Value.absent(),
    this.timeMs = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.points = const Value.absent(),
  });
  AttemptAnswersCompanion.insert({
    this.id = const Value.absent(),
    required int attemptId,
    required int questionId,
    required String selected,
    this.timeMs = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.points = const Value.absent(),
  }) : attemptId = Value(attemptId),
       questionId = Value(questionId),
       selected = Value(selected);
  static Insertable<AttemptAnswer> custom({
    Expression<int>? id,
    Expression<int>? attemptId,
    Expression<int>? questionId,
    Expression<String>? selected,
    Expression<int>? timeMs,
    Expression<bool>? isCorrect,
    Expression<int>? points,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (attemptId != null) 'attempt_id': attemptId,
      if (questionId != null) 'question_id': questionId,
      if (selected != null) 'selected': selected,
      if (timeMs != null) 'time_ms': timeMs,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (points != null) 'points': points,
    });
  }

  AttemptAnswersCompanion copyWith({
    Value<int>? id,
    Value<int>? attemptId,
    Value<int>? questionId,
    Value<String>? selected,
    Value<int>? timeMs,
    Value<bool>? isCorrect,
    Value<int>? points,
  }) {
    return AttemptAnswersCompanion(
      id: id ?? this.id,
      attemptId: attemptId ?? this.attemptId,
      questionId: questionId ?? this.questionId,
      selected: selected ?? this.selected,
      timeMs: timeMs ?? this.timeMs,
      isCorrect: isCorrect ?? this.isCorrect,
      points: points ?? this.points,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (attemptId.present) {
      map['attempt_id'] = Variable<int>(attemptId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (selected.present) {
      map['selected'] = Variable<String>(selected.value);
    }
    if (timeMs.present) {
      map['time_ms'] = Variable<int>(timeMs.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (points.present) {
      map['points'] = Variable<int>(points.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttemptAnswersCompanion(')
          ..write('id: $id, ')
          ..write('attemptId: $attemptId, ')
          ..write('questionId: $questionId, ')
          ..write('selected: $selected, ')
          ..write('timeMs: $timeMs, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('points: $points')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, DbUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('user'),
  );
  static const VerificationMeta _isProMeta = const VerificationMeta('isPro');
  @override
  late final GeneratedColumn<bool> isPro = GeneratedColumn<bool>(
    'is_pro',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pro" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, email, password, role, isPro];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('is_pro')) {
      context.handle(
        _isProMeta,
        isPro.isAcceptableOrUnknown(data['is_pro']!, _isProMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DbUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      isPro: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pro'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class DbUser extends DataClass implements Insertable<DbUser> {
  final int id;
  final String email;
  final String password;
  final String role;
  final bool isPro;
  const DbUser({
    required this.id,
    required this.email,
    required this.password,
    required this.role,
    required this.isPro,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['email'] = Variable<String>(email);
    map['password'] = Variable<String>(password);
    map['role'] = Variable<String>(role);
    map['is_pro'] = Variable<bool>(isPro);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      password: Value(password),
      role: Value(role),
      isPro: Value(isPro),
    );
  }

  factory DbUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbUser(
      id: serializer.fromJson<int>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      password: serializer.fromJson<String>(json['password']),
      role: serializer.fromJson<String>(json['role']),
      isPro: serializer.fromJson<bool>(json['isPro']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'email': serializer.toJson<String>(email),
      'password': serializer.toJson<String>(password),
      'role': serializer.toJson<String>(role),
      'isPro': serializer.toJson<bool>(isPro),
    };
  }

  DbUser copyWith({
    int? id,
    String? email,
    String? password,
    String? role,
    bool? isPro,
  }) => DbUser(
    id: id ?? this.id,
    email: email ?? this.email,
    password: password ?? this.password,
    role: role ?? this.role,
    isPro: isPro ?? this.isPro,
  );
  DbUser copyWithCompanion(UsersCompanion data) {
    return DbUser(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      password: data.password.present ? data.password.value : this.password,
      role: data.role.present ? data.role.value : this.role,
      isPro: data.isPro.present ? data.isPro.value : this.isPro,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbUser(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('password: $password, ')
          ..write('role: $role, ')
          ..write('isPro: $isPro')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, email, password, role, isPro);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbUser &&
          other.id == this.id &&
          other.email == this.email &&
          other.password == this.password &&
          other.role == this.role &&
          other.isPro == this.isPro);
}

class UsersCompanion extends UpdateCompanion<DbUser> {
  final Value<int> id;
  final Value<String> email;
  final Value<String> password;
  final Value<String> role;
  final Value<bool> isPro;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.password = const Value.absent(),
    this.role = const Value.absent(),
    this.isPro = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String email,
    required String password,
    this.role = const Value.absent(),
    this.isPro = const Value.absent(),
  }) : email = Value(email),
       password = Value(password);
  static Insertable<DbUser> custom({
    Expression<int>? id,
    Expression<String>? email,
    Expression<String>? password,
    Expression<String>? role,
    Expression<bool>? isPro,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      if (role != null) 'role': role,
      if (isPro != null) 'is_pro': isPro,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? email,
    Value<String>? password,
    Value<String>? role,
    Value<bool>? isPro,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      isPro: isPro ?? this.isPro,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (isPro.present) {
      map['is_pro'] = Variable<bool>(isPro.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('password: $password, ')
          ..write('role: $role, ')
          ..write('isPro: $isPro')
          ..write(')'))
        .toString();
  }
}

class $SavedQuestionsTable extends SavedQuestions
    with TableInfo<$SavedQuestionsTable, SavedQuestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedQuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<int> questionId = GeneratedColumn<int>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES questions (id)',
    ),
  );
  static const VerificationMeta _userEmailMeta = const VerificationMeta(
    'userEmail',
  );
  @override
  late final GeneratedColumn<String> userEmail = GeneratedColumn<String>(
    'user_email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, questionId, userEmail, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_questions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedQuestion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('user_email')) {
      context.handle(
        _userEmailMeta,
        userEmail.isAcceptableOrUnknown(data['user_email']!, _userEmailMeta),
      );
    } else if (isInserting) {
      context.missing(_userEmailMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedQuestion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_id'],
      )!,
      userEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_email'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SavedQuestionsTable createAlias(String alias) {
    return $SavedQuestionsTable(attachedDatabase, alias);
  }
}

class SavedQuestion extends DataClass implements Insertable<SavedQuestion> {
  final int id;
  final int questionId;
  final String userEmail;
  final DateTime createdAt;
  const SavedQuestion({
    required this.id,
    required this.questionId,
    required this.userEmail,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['question_id'] = Variable<int>(questionId);
    map['user_email'] = Variable<String>(userEmail);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SavedQuestionsCompanion toCompanion(bool nullToAbsent) {
    return SavedQuestionsCompanion(
      id: Value(id),
      questionId: Value(questionId),
      userEmail: Value(userEmail),
      createdAt: Value(createdAt),
    );
  }

  factory SavedQuestion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedQuestion(
      id: serializer.fromJson<int>(json['id']),
      questionId: serializer.fromJson<int>(json['questionId']),
      userEmail: serializer.fromJson<String>(json['userEmail']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'questionId': serializer.toJson<int>(questionId),
      'userEmail': serializer.toJson<String>(userEmail),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SavedQuestion copyWith({
    int? id,
    int? questionId,
    String? userEmail,
    DateTime? createdAt,
  }) => SavedQuestion(
    id: id ?? this.id,
    questionId: questionId ?? this.questionId,
    userEmail: userEmail ?? this.userEmail,
    createdAt: createdAt ?? this.createdAt,
  );
  SavedQuestion copyWithCompanion(SavedQuestionsCompanion data) {
    return SavedQuestion(
      id: data.id.present ? data.id.value : this.id,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      userEmail: data.userEmail.present ? data.userEmail.value : this.userEmail,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedQuestion(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('userEmail: $userEmail, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, questionId, userEmail, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedQuestion &&
          other.id == this.id &&
          other.questionId == this.questionId &&
          other.userEmail == this.userEmail &&
          other.createdAt == this.createdAt);
}

class SavedQuestionsCompanion extends UpdateCompanion<SavedQuestion> {
  final Value<int> id;
  final Value<int> questionId;
  final Value<String> userEmail;
  final Value<DateTime> createdAt;
  const SavedQuestionsCompanion({
    this.id = const Value.absent(),
    this.questionId = const Value.absent(),
    this.userEmail = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SavedQuestionsCompanion.insert({
    this.id = const Value.absent(),
    required int questionId,
    required String userEmail,
    this.createdAt = const Value.absent(),
  }) : questionId = Value(questionId),
       userEmail = Value(userEmail);
  static Insertable<SavedQuestion> custom({
    Expression<int>? id,
    Expression<int>? questionId,
    Expression<String>? userEmail,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questionId != null) 'question_id': questionId,
      if (userEmail != null) 'user_email': userEmail,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SavedQuestionsCompanion copyWith({
    Value<int>? id,
    Value<int>? questionId,
    Value<String>? userEmail,
    Value<DateTime>? createdAt,
  }) {
    return SavedQuestionsCompanion(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      userEmail: userEmail ?? this.userEmail,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (userEmail.present) {
      map['user_email'] = Variable<String>(userEmail.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('userEmail: $userEmail, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ReportsTable extends Reports with TableInfo<$ReportsTable, Report> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _examIdMeta = const VerificationMeta('examId');
  @override
  late final GeneratedColumn<int> examId = GeneratedColumn<int>(
    'exam_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exams (id)',
    ),
  );
  static const VerificationMeta _userEmailMeta = const VerificationMeta(
    'userEmail',
  );
  @override
  late final GeneratedColumn<String> userEmail = GeneratedColumn<String>(
    'user_email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedMeta = const VerificationMeta(
    'resolved',
  );
  @override
  late final GeneratedColumn<bool> resolved = GeneratedColumn<bool>(
    'resolved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("resolved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    examId,
    userEmail,
    comment,
    resolved,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<Report> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exam_id')) {
      context.handle(
        _examIdMeta,
        examId.isAcceptableOrUnknown(data['exam_id']!, _examIdMeta),
      );
    } else if (isInserting) {
      context.missing(_examIdMeta);
    }
    if (data.containsKey('user_email')) {
      context.handle(
        _userEmailMeta,
        userEmail.isAcceptableOrUnknown(data['user_email']!, _userEmailMeta),
      );
    } else if (isInserting) {
      context.missing(_userEmailMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    } else if (isInserting) {
      context.missing(_commentMeta);
    }
    if (data.containsKey('resolved')) {
      context.handle(
        _resolvedMeta,
        resolved.isAcceptableOrUnknown(data['resolved']!, _resolvedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Report map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Report(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      examId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exam_id'],
      )!,
      userEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_email'],
      )!,
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      )!,
      resolved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}resolved'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReportsTable createAlias(String alias) {
    return $ReportsTable(attachedDatabase, alias);
  }
}

class Report extends DataClass implements Insertable<Report> {
  final int id;
  final int examId;
  final String userEmail;
  final String comment;
  final bool resolved;
  final DateTime createdAt;
  const Report({
    required this.id,
    required this.examId,
    required this.userEmail,
    required this.comment,
    required this.resolved,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exam_id'] = Variable<int>(examId);
    map['user_email'] = Variable<String>(userEmail);
    map['comment'] = Variable<String>(comment);
    map['resolved'] = Variable<bool>(resolved);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReportsCompanion toCompanion(bool nullToAbsent) {
    return ReportsCompanion(
      id: Value(id),
      examId: Value(examId),
      userEmail: Value(userEmail),
      comment: Value(comment),
      resolved: Value(resolved),
      createdAt: Value(createdAt),
    );
  }

  factory Report.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Report(
      id: serializer.fromJson<int>(json['id']),
      examId: serializer.fromJson<int>(json['examId']),
      userEmail: serializer.fromJson<String>(json['userEmail']),
      comment: serializer.fromJson<String>(json['comment']),
      resolved: serializer.fromJson<bool>(json['resolved']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'examId': serializer.toJson<int>(examId),
      'userEmail': serializer.toJson<String>(userEmail),
      'comment': serializer.toJson<String>(comment),
      'resolved': serializer.toJson<bool>(resolved),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Report copyWith({
    int? id,
    int? examId,
    String? userEmail,
    String? comment,
    bool? resolved,
    DateTime? createdAt,
  }) => Report(
    id: id ?? this.id,
    examId: examId ?? this.examId,
    userEmail: userEmail ?? this.userEmail,
    comment: comment ?? this.comment,
    resolved: resolved ?? this.resolved,
    createdAt: createdAt ?? this.createdAt,
  );
  Report copyWithCompanion(ReportsCompanion data) {
    return Report(
      id: data.id.present ? data.id.value : this.id,
      examId: data.examId.present ? data.examId.value : this.examId,
      userEmail: data.userEmail.present ? data.userEmail.value : this.userEmail,
      comment: data.comment.present ? data.comment.value : this.comment,
      resolved: data.resolved.present ? data.resolved.value : this.resolved,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Report(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('userEmail: $userEmail, ')
          ..write('comment: $comment, ')
          ..write('resolved: $resolved, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, examId, userEmail, comment, resolved, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Report &&
          other.id == this.id &&
          other.examId == this.examId &&
          other.userEmail == this.userEmail &&
          other.comment == this.comment &&
          other.resolved == this.resolved &&
          other.createdAt == this.createdAt);
}

class ReportsCompanion extends UpdateCompanion<Report> {
  final Value<int> id;
  final Value<int> examId;
  final Value<String> userEmail;
  final Value<String> comment;
  final Value<bool> resolved;
  final Value<DateTime> createdAt;
  const ReportsCompanion({
    this.id = const Value.absent(),
    this.examId = const Value.absent(),
    this.userEmail = const Value.absent(),
    this.comment = const Value.absent(),
    this.resolved = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ReportsCompanion.insert({
    this.id = const Value.absent(),
    required int examId,
    required String userEmail,
    required String comment,
    this.resolved = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : examId = Value(examId),
       userEmail = Value(userEmail),
       comment = Value(comment);
  static Insertable<Report> custom({
    Expression<int>? id,
    Expression<int>? examId,
    Expression<String>? userEmail,
    Expression<String>? comment,
    Expression<bool>? resolved,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (examId != null) 'exam_id': examId,
      if (userEmail != null) 'user_email': userEmail,
      if (comment != null) 'comment': comment,
      if (resolved != null) 'resolved': resolved,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ReportsCompanion copyWith({
    Value<int>? id,
    Value<int>? examId,
    Value<String>? userEmail,
    Value<String>? comment,
    Value<bool>? resolved,
    Value<DateTime>? createdAt,
  }) {
    return ReportsCompanion(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      userEmail: userEmail ?? this.userEmail,
      comment: comment ?? this.comment,
      resolved: resolved ?? this.resolved,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (examId.present) {
      map['exam_id'] = Variable<int>(examId.value);
    }
    if (userEmail.present) {
      map['user_email'] = Variable<String>(userEmail.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (resolved.present) {
      map['resolved'] = Variable<bool>(resolved.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReportsCompanion(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('userEmail: $userEmail, ')
          ..write('comment: $comment, ')
          ..write('resolved: $resolved, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DailyGoalsTable extends DailyGoals
    with TableInfo<$DailyGoalsTable, DailyGoal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _minutesTargetMeta = const VerificationMeta(
    'minutesTarget',
  );
  @override
  late final GeneratedColumn<int> minutesTarget = GeneratedColumn<int>(
    'minutes_target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(15),
  );
  static const VerificationMeta _notifyMeta = const VerificationMeta('notify');
  @override
  late final GeneratedColumn<bool> notify = GeneratedColumn<bool>(
    'notify',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notify" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _reminderHourMeta = const VerificationMeta(
    'reminderHour',
  );
  @override
  late final GeneratedColumn<int> reminderHour = GeneratedColumn<int>(
    'reminder_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(9),
  );
  static const VerificationMeta _reminderMinuteMeta = const VerificationMeta(
    'reminderMinute',
  );
  @override
  late final GeneratedColumn<int> reminderMinute = GeneratedColumn<int>(
    'reminder_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _examDateMeta = const VerificationMeta(
    'examDate',
  );
  @override
  late final GeneratedColumn<DateTime> examDate = GeneratedColumn<DateTime>(
    'exam_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    minutesTarget,
    notify,
    reminderHour,
    reminderMinute,
    examDate,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyGoal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('minutes_target')) {
      context.handle(
        _minutesTargetMeta,
        minutesTarget.isAcceptableOrUnknown(
          data['minutes_target']!,
          _minutesTargetMeta,
        ),
      );
    }
    if (data.containsKey('notify')) {
      context.handle(
        _notifyMeta,
        notify.isAcceptableOrUnknown(data['notify']!, _notifyMeta),
      );
    }
    if (data.containsKey('reminder_hour')) {
      context.handle(
        _reminderHourMeta,
        reminderHour.isAcceptableOrUnknown(
          data['reminder_hour']!,
          _reminderHourMeta,
        ),
      );
    }
    if (data.containsKey('reminder_minute')) {
      context.handle(
        _reminderMinuteMeta,
        reminderMinute.isAcceptableOrUnknown(
          data['reminder_minute']!,
          _reminderMinuteMeta,
        ),
      );
    }
    if (data.containsKey('exam_date')) {
      context.handle(
        _examDateMeta,
        examDate.isAcceptableOrUnknown(data['exam_date']!, _examDateMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailyGoal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyGoal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      minutesTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes_target'],
      )!,
      notify: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notify'],
      )!,
      reminderHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_hour'],
      )!,
      reminderMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_minute'],
      )!,
      examDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}exam_date'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $DailyGoalsTable createAlias(String alias) {
    return $DailyGoalsTable(attachedDatabase, alias);
  }
}

class DailyGoal extends DataClass implements Insertable<DailyGoal> {
  final int id;
  final int minutesTarget;
  final bool notify;
  final int reminderHour;
  final int reminderMinute;
  final DateTime? examDate;
  final bool active;
  const DailyGoal({
    required this.id,
    required this.minutesTarget,
    required this.notify,
    required this.reminderHour,
    required this.reminderMinute,
    this.examDate,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['minutes_target'] = Variable<int>(minutesTarget);
    map['notify'] = Variable<bool>(notify);
    map['reminder_hour'] = Variable<int>(reminderHour);
    map['reminder_minute'] = Variable<int>(reminderMinute);
    if (!nullToAbsent || examDate != null) {
      map['exam_date'] = Variable<DateTime>(examDate);
    }
    map['active'] = Variable<bool>(active);
    return map;
  }

  DailyGoalsCompanion toCompanion(bool nullToAbsent) {
    return DailyGoalsCompanion(
      id: Value(id),
      minutesTarget: Value(minutesTarget),
      notify: Value(notify),
      reminderHour: Value(reminderHour),
      reminderMinute: Value(reminderMinute),
      examDate: examDate == null && nullToAbsent
          ? const Value.absent()
          : Value(examDate),
      active: Value(active),
    );
  }

  factory DailyGoal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyGoal(
      id: serializer.fromJson<int>(json['id']),
      minutesTarget: serializer.fromJson<int>(json['minutesTarget']),
      notify: serializer.fromJson<bool>(json['notify']),
      reminderHour: serializer.fromJson<int>(json['reminderHour']),
      reminderMinute: serializer.fromJson<int>(json['reminderMinute']),
      examDate: serializer.fromJson<DateTime?>(json['examDate']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'minutesTarget': serializer.toJson<int>(minutesTarget),
      'notify': serializer.toJson<bool>(notify),
      'reminderHour': serializer.toJson<int>(reminderHour),
      'reminderMinute': serializer.toJson<int>(reminderMinute),
      'examDate': serializer.toJson<DateTime?>(examDate),
      'active': serializer.toJson<bool>(active),
    };
  }

  DailyGoal copyWith({
    int? id,
    int? minutesTarget,
    bool? notify,
    int? reminderHour,
    int? reminderMinute,
    Value<DateTime?> examDate = const Value.absent(),
    bool? active,
  }) => DailyGoal(
    id: id ?? this.id,
    minutesTarget: minutesTarget ?? this.minutesTarget,
    notify: notify ?? this.notify,
    reminderHour: reminderHour ?? this.reminderHour,
    reminderMinute: reminderMinute ?? this.reminderMinute,
    examDate: examDate.present ? examDate.value : this.examDate,
    active: active ?? this.active,
  );
  DailyGoal copyWithCompanion(DailyGoalsCompanion data) {
    return DailyGoal(
      id: data.id.present ? data.id.value : this.id,
      minutesTarget: data.minutesTarget.present
          ? data.minutesTarget.value
          : this.minutesTarget,
      notify: data.notify.present ? data.notify.value : this.notify,
      reminderHour: data.reminderHour.present
          ? data.reminderHour.value
          : this.reminderHour,
      reminderMinute: data.reminderMinute.present
          ? data.reminderMinute.value
          : this.reminderMinute,
      examDate: data.examDate.present ? data.examDate.value : this.examDate,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyGoal(')
          ..write('id: $id, ')
          ..write('minutesTarget: $minutesTarget, ')
          ..write('notify: $notify, ')
          ..write('reminderHour: $reminderHour, ')
          ..write('reminderMinute: $reminderMinute, ')
          ..write('examDate: $examDate, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    minutesTarget,
    notify,
    reminderHour,
    reminderMinute,
    examDate,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyGoal &&
          other.id == this.id &&
          other.minutesTarget == this.minutesTarget &&
          other.notify == this.notify &&
          other.reminderHour == this.reminderHour &&
          other.reminderMinute == this.reminderMinute &&
          other.examDate == this.examDate &&
          other.active == this.active);
}

class DailyGoalsCompanion extends UpdateCompanion<DailyGoal> {
  final Value<int> id;
  final Value<int> minutesTarget;
  final Value<bool> notify;
  final Value<int> reminderHour;
  final Value<int> reminderMinute;
  final Value<DateTime?> examDate;
  final Value<bool> active;
  const DailyGoalsCompanion({
    this.id = const Value.absent(),
    this.minutesTarget = const Value.absent(),
    this.notify = const Value.absent(),
    this.reminderHour = const Value.absent(),
    this.reminderMinute = const Value.absent(),
    this.examDate = const Value.absent(),
    this.active = const Value.absent(),
  });
  DailyGoalsCompanion.insert({
    this.id = const Value.absent(),
    this.minutesTarget = const Value.absent(),
    this.notify = const Value.absent(),
    this.reminderHour = const Value.absent(),
    this.reminderMinute = const Value.absent(),
    this.examDate = const Value.absent(),
    this.active = const Value.absent(),
  });
  static Insertable<DailyGoal> custom({
    Expression<int>? id,
    Expression<int>? minutesTarget,
    Expression<bool>? notify,
    Expression<int>? reminderHour,
    Expression<int>? reminderMinute,
    Expression<DateTime>? examDate,
    Expression<bool>? active,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (minutesTarget != null) 'minutes_target': minutesTarget,
      if (notify != null) 'notify': notify,
      if (reminderHour != null) 'reminder_hour': reminderHour,
      if (reminderMinute != null) 'reminder_minute': reminderMinute,
      if (examDate != null) 'exam_date': examDate,
      if (active != null) 'active': active,
    });
  }

  DailyGoalsCompanion copyWith({
    Value<int>? id,
    Value<int>? minutesTarget,
    Value<bool>? notify,
    Value<int>? reminderHour,
    Value<int>? reminderMinute,
    Value<DateTime?>? examDate,
    Value<bool>? active,
  }) {
    return DailyGoalsCompanion(
      id: id ?? this.id,
      minutesTarget: minutesTarget ?? this.minutesTarget,
      notify: notify ?? this.notify,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      examDate: examDate ?? this.examDate,
      active: active ?? this.active,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (minutesTarget.present) {
      map['minutes_target'] = Variable<int>(minutesTarget.value);
    }
    if (notify.present) {
      map['notify'] = Variable<bool>(notify.value);
    }
    if (reminderHour.present) {
      map['reminder_hour'] = Variable<int>(reminderHour.value);
    }
    if (reminderMinute.present) {
      map['reminder_minute'] = Variable<int>(reminderMinute.value);
    }
    if (examDate.present) {
      map['exam_date'] = Variable<DateTime>(examDate.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyGoalsCompanion(')
          ..write('id: $id, ')
          ..write('minutesTarget: $minutesTarget, ')
          ..write('notify: $notify, ')
          ..write('reminderHour: $reminderHour, ')
          ..write('reminderMinute: $reminderMinute, ')
          ..write('examDate: $examDate, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userEmailMeta = const VerificationMeta(
    'userEmail',
  );
  @override
  late final GeneratedColumn<String> userEmail = GeneratedColumn<String>(
    'user_email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stripePaymentIntentIdMeta =
      const VerificationMeta('stripePaymentIntentId');
  @override
  late final GeneratedColumn<String> stripePaymentIntentId =
      GeneratedColumn<String>(
        'stripe_payment_intent_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('paid'),
  );
  static const VerificationMeta _refundedMeta = const VerificationMeta(
    'refunded',
  );
  @override
  late final GeneratedColumn<bool> refunded = GeneratedColumn<bool>(
    'refunded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("refunded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userEmail,
    amountMinor,
    currency,
    stripePaymentIntentId,
    status,
    refunded,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_email')) {
      context.handle(
        _userEmailMeta,
        userEmail.isAcceptableOrUnknown(data['user_email']!, _userEmailMeta),
      );
    } else if (isInserting) {
      context.missing(_userEmailMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('stripe_payment_intent_id')) {
      context.handle(
        _stripePaymentIntentIdMeta,
        stripePaymentIntentId.isAcceptableOrUnknown(
          data['stripe_payment_intent_id']!,
          _stripePaymentIntentIdMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('refunded')) {
      context.handle(
        _refundedMeta,
        refunded.isAcceptableOrUnknown(data['refunded']!, _refundedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_email'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      stripePaymentIntentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stripe_payment_intent_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      refunded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}refunded'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final int id;
  final String userEmail;
  final int amountMinor;
  final String currency;
  final String stripePaymentIntentId;
  final String status;
  final bool refunded;
  final DateTime createdAt;
  const Payment({
    required this.id,
    required this.userEmail,
    required this.amountMinor,
    required this.currency,
    required this.stripePaymentIntentId,
    required this.status,
    required this.refunded,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_email'] = Variable<String>(userEmail);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    map['stripe_payment_intent_id'] = Variable<String>(stripePaymentIntentId);
    map['status'] = Variable<String>(status);
    map['refunded'] = Variable<bool>(refunded);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      userEmail: Value(userEmail),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      stripePaymentIntentId: Value(stripePaymentIntentId),
      status: Value(status),
      refunded: Value(refunded),
      createdAt: Value(createdAt),
    );
  }

  factory Payment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<int>(json['id']),
      userEmail: serializer.fromJson<String>(json['userEmail']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      stripePaymentIntentId: serializer.fromJson<String>(
        json['stripePaymentIntentId'],
      ),
      status: serializer.fromJson<String>(json['status']),
      refunded: serializer.fromJson<bool>(json['refunded']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userEmail': serializer.toJson<String>(userEmail),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'stripePaymentIntentId': serializer.toJson<String>(stripePaymentIntentId),
      'status': serializer.toJson<String>(status),
      'refunded': serializer.toJson<bool>(refunded),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Payment copyWith({
    int? id,
    String? userEmail,
    int? amountMinor,
    String? currency,
    String? stripePaymentIntentId,
    String? status,
    bool? refunded,
    DateTime? createdAt,
  }) => Payment(
    id: id ?? this.id,
    userEmail: userEmail ?? this.userEmail,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    stripePaymentIntentId: stripePaymentIntentId ?? this.stripePaymentIntentId,
    status: status ?? this.status,
    refunded: refunded ?? this.refunded,
    createdAt: createdAt ?? this.createdAt,
  );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      userEmail: data.userEmail.present ? data.userEmail.value : this.userEmail,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      stripePaymentIntentId: data.stripePaymentIntentId.present
          ? data.stripePaymentIntentId.value
          : this.stripePaymentIntentId,
      status: data.status.present ? data.status.value : this.status,
      refunded: data.refunded.present ? data.refunded.value : this.refunded,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('userEmail: $userEmail, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('stripePaymentIntentId: $stripePaymentIntentId, ')
          ..write('status: $status, ')
          ..write('refunded: $refunded, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userEmail,
    amountMinor,
    currency,
    stripePaymentIntentId,
    status,
    refunded,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.userEmail == this.userEmail &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.stripePaymentIntentId == this.stripePaymentIntentId &&
          other.status == this.status &&
          other.refunded == this.refunded &&
          other.createdAt == this.createdAt);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<int> id;
  final Value<String> userEmail;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<String> stripePaymentIntentId;
  final Value<String> status;
  final Value<bool> refunded;
  final Value<DateTime> createdAt;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.userEmail = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.stripePaymentIntentId = const Value.absent(),
    this.status = const Value.absent(),
    this.refunded = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PaymentsCompanion.insert({
    this.id = const Value.absent(),
    required String userEmail,
    required int amountMinor,
    required String currency,
    this.stripePaymentIntentId = const Value.absent(),
    this.status = const Value.absent(),
    this.refunded = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : userEmail = Value(userEmail),
       amountMinor = Value(amountMinor),
       currency = Value(currency);
  static Insertable<Payment> custom({
    Expression<int>? id,
    Expression<String>? userEmail,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? stripePaymentIntentId,
    Expression<String>? status,
    Expression<bool>? refunded,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userEmail != null) 'user_email': userEmail,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (stripePaymentIntentId != null)
        'stripe_payment_intent_id': stripePaymentIntentId,
      if (status != null) 'status': status,
      if (refunded != null) 'refunded': refunded,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PaymentsCompanion copyWith({
    Value<int>? id,
    Value<String>? userEmail,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<String>? stripePaymentIntentId,
    Value<String>? status,
    Value<bool>? refunded,
    Value<DateTime>? createdAt,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      userEmail: userEmail ?? this.userEmail,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      stripePaymentIntentId:
          stripePaymentIntentId ?? this.stripePaymentIntentId,
      status: status ?? this.status,
      refunded: refunded ?? this.refunded,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userEmail.present) {
      map['user_email'] = Variable<String>(userEmail.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (stripePaymentIntentId.present) {
      map['stripe_payment_intent_id'] = Variable<String>(
        stripePaymentIntentId.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (refunded.present) {
      map['refunded'] = Variable<bool>(refunded.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('userEmail: $userEmail, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('stripePaymentIntentId: $stripePaymentIntentId, ')
          ..write('status: $status, ')
          ..write('refunded: $refunded, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $SubcategoriesTable subcategories = $SubcategoriesTable(this);
  late final $ExamsTable exams = $ExamsTable(this);
  late final $QuestionsTable questions = $QuestionsTable(this);
  late final $ChoicesTable choices = $ChoicesTable(this);
  late final $ExamQuestionsTable examQuestions = $ExamQuestionsTable(this);
  late final $ExamGradeBandsTable examGradeBands = $ExamGradeBandsTable(this);
  late final $QuestionCategoriesTable questionCategories =
      $QuestionCategoriesTable(this);
  late final $QuestionSubcategoriesTable questionSubcategories =
      $QuestionSubcategoriesTable(this);
  late final $AttemptsTable attempts = $AttemptsTable(this);
  late final $AttemptAnswersTable attemptAnswers = $AttemptAnswersTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $SavedQuestionsTable savedQuestions = $SavedQuestionsTable(this);
  late final $ReportsTable reports = $ReportsTable(this);
  late final $DailyGoalsTable dailyGoals = $DailyGoalsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    subcategories,
    exams,
    questions,
    choices,
    examQuestions,
    examGradeBands,
    questionCategories,
    questionSubcategories,
    attempts,
    attemptAnswers,
    users,
    savedQuestions,
    reports,
    dailyGoals,
    appSettings,
    payments,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      Value<int> order,
      Value<int> passPercent,
      Value<String> imageUrl,
      Value<bool> locked,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> order,
      Value<int> passPercent,
      Value<String> imageUrl,
      Value<bool> locked,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SubcategoriesTable, List<Subcategory>>
  _subcategoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.subcategories,
    aliasName: $_aliasNameGenerator(
      db.categories.id,
      db.subcategories.categoryId,
    ),
  );

  $$SubcategoriesTableProcessedTableManager get subcategoriesRefs {
    final manager = $$SubcategoriesTableTableManager(
      $_db,
      $_db.subcategories,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_subcategoriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExamsTable, List<Exam>> _examsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.exams,
    aliasName: $_aliasNameGenerator(db.categories.id, db.exams.categoryId),
  );

  $$ExamsTableProcessedTableManager get examsRefs {
    final manager = $$ExamsTableTableManager(
      $_db,
      $_db.exams,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_examsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QuestionCategoriesTable, List<QuestionCategory>>
  _questionCategoriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.questionCategories,
        aliasName: $_aliasNameGenerator(
          db.categories.id,
          db.questionCategories.categoryId,
        ),
      );

  $$QuestionCategoriesTableProcessedTableManager get questionCategoriesRefs {
    final manager = $$QuestionCategoriesTableTableManager(
      $_db,
      $_db.questionCategories,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _questionCategoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passPercent => $composableBuilder(
    column: $table.passPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> subcategoriesRefs(
    Expression<bool> Function($$SubcategoriesTableFilterComposer f) f,
  ) {
    final $$SubcategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subcategories,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubcategoriesTableFilterComposer(
            $db: $db,
            $table: $db.subcategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> examsRefs(
    Expression<bool> Function($$ExamsTableFilterComposer f) f,
  ) {
    final $$ExamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableFilterComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> questionCategoriesRefs(
    Expression<bool> Function($$QuestionCategoriesTableFilterComposer f) f,
  ) {
    final $$QuestionCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questionCategories,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.questionCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passPercent => $composableBuilder(
    column: $table.passPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<int> get passPercent => $composableBuilder(
    column: $table.passPercent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<bool> get locked =>
      $composableBuilder(column: $table.locked, builder: (column) => column);

  Expression<T> subcategoriesRefs<T extends Object>(
    Expression<T> Function($$SubcategoriesTableAnnotationComposer a) f,
  ) {
    final $$SubcategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subcategories,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubcategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.subcategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> examsRefs<T extends Object>(
    Expression<T> Function($$ExamsTableAnnotationComposer a) f,
  ) {
    final $$ExamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableAnnotationComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> questionCategoriesRefs<T extends Object>(
    Expression<T> Function($$QuestionCategoriesTableAnnotationComposer a) f,
  ) {
    final $$QuestionCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.questionCategories,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$QuestionCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.questionCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({
            bool subcategoriesRefs,
            bool examsRefs,
            bool questionCategoriesRefs,
          })
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> order = const Value.absent(),
                Value<int> passPercent = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<bool> locked = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                order: order,
                passPercent: passPercent,
                imageUrl: imageUrl,
                locked: locked,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> order = const Value.absent(),
                Value<int> passPercent = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<bool> locked = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                order: order,
                passPercent: passPercent,
                imageUrl: imageUrl,
                locked: locked,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                subcategoriesRefs = false,
                examsRefs = false,
                questionCategoriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (subcategoriesRefs) db.subcategories,
                    if (examsRefs) db.exams,
                    if (questionCategoriesRefs) db.questionCategories,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (subcategoriesRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Subcategory
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._subcategoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).subcategoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (examsRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          Exam
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._examsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).examsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (questionCategoriesRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          QuestionCategory
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._questionCategoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).questionCategoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({
        bool subcategoriesRefs,
        bool examsRefs,
        bool questionCategoriesRefs,
      })
    >;
typedef $$SubcategoriesTableCreateCompanionBuilder =
    SubcategoriesCompanion Function({
      Value<int> id,
      required int categoryId,
      required String name,
      Value<int> order,
      Value<String> imageUrl,
      Value<bool> locked,
    });
typedef $$SubcategoriesTableUpdateCompanionBuilder =
    SubcategoriesCompanion Function({
      Value<int> id,
      Value<int> categoryId,
      Value<String> name,
      Value<int> order,
      Value<String> imageUrl,
      Value<bool> locked,
    });

final class $$SubcategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $SubcategoriesTable, Subcategory> {
  $$SubcategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.subcategories.categoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExamsTable, List<Exam>> _examsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.exams,
    aliasName: $_aliasNameGenerator(
      db.subcategories.id,
      db.exams.subcategoryId,
    ),
  );

  $$ExamsTableProcessedTableManager get examsRefs {
    final manager = $$ExamsTableTableManager(
      $_db,
      $_db.exams,
    ).filter((f) => f.subcategoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_examsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $QuestionSubcategoriesTable,
    List<QuestionSubcategory>
  >
  _questionSubcategoriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.questionSubcategories,
        aliasName: $_aliasNameGenerator(
          db.subcategories.id,
          db.questionSubcategories.subcategoryId,
        ),
      );

  $$QuestionSubcategoriesTableProcessedTableManager
  get questionSubcategoriesRefs {
    final manager = $$QuestionSubcategoriesTableTableManager(
      $_db,
      $_db.questionSubcategories,
    ).filter((f) => f.subcategoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _questionSubcategoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SubcategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $SubcategoriesTable> {
  $$SubcategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> examsRefs(
    Expression<bool> Function($$ExamsTableFilterComposer f) f,
  ) {
    final $$ExamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.subcategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableFilterComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> questionSubcategoriesRefs(
    Expression<bool> Function($$QuestionSubcategoriesTableFilterComposer f) f,
  ) {
    final $$QuestionSubcategoriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.questionSubcategories,
          getReferencedColumn: (t) => t.subcategoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$QuestionSubcategoriesTableFilterComposer(
                $db: $db,
                $table: $db.questionSubcategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SubcategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SubcategoriesTable> {
  $$SubcategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubcategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubcategoriesTable> {
  $$SubcategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<bool> get locked =>
      $composableBuilder(column: $table.locked, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> examsRefs<T extends Object>(
    Expression<T> Function($$ExamsTableAnnotationComposer a) f,
  ) {
    final $$ExamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.subcategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableAnnotationComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> questionSubcategoriesRefs<T extends Object>(
    Expression<T> Function($$QuestionSubcategoriesTableAnnotationComposer a) f,
  ) {
    final $$QuestionSubcategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.questionSubcategories,
          getReferencedColumn: (t) => t.subcategoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$QuestionSubcategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.questionSubcategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SubcategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubcategoriesTable,
          Subcategory,
          $$SubcategoriesTableFilterComposer,
          $$SubcategoriesTableOrderingComposer,
          $$SubcategoriesTableAnnotationComposer,
          $$SubcategoriesTableCreateCompanionBuilder,
          $$SubcategoriesTableUpdateCompanionBuilder,
          (Subcategory, $$SubcategoriesTableReferences),
          Subcategory,
          PrefetchHooks Function({
            bool categoryId,
            bool examsRefs,
            bool questionSubcategoriesRefs,
          })
        > {
  $$SubcategoriesTableTableManager(_$AppDatabase db, $SubcategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubcategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubcategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubcategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> order = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<bool> locked = const Value.absent(),
              }) => SubcategoriesCompanion(
                id: id,
                categoryId: categoryId,
                name: name,
                order: order,
                imageUrl: imageUrl,
                locked: locked,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int categoryId,
                required String name,
                Value<int> order = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<bool> locked = const Value.absent(),
              }) => SubcategoriesCompanion.insert(
                id: id,
                categoryId: categoryId,
                name: name,
                order: order,
                imageUrl: imageUrl,
                locked: locked,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SubcategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                examsRefs = false,
                questionSubcategoriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (examsRefs) db.exams,
                    if (questionSubcategoriesRefs) db.questionSubcategories,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$SubcategoriesTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$SubcategoriesTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (examsRefs)
                        await $_getPrefetchedData<
                          Subcategory,
                          $SubcategoriesTable,
                          Exam
                        >(
                          currentTable: table,
                          referencedTable: $$SubcategoriesTableReferences
                              ._examsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SubcategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).examsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.subcategoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (questionSubcategoriesRefs)
                        await $_getPrefetchedData<
                          Subcategory,
                          $SubcategoriesTable,
                          QuestionSubcategory
                        >(
                          currentTable: table,
                          referencedTable: $$SubcategoriesTableReferences
                              ._questionSubcategoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SubcategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).questionSubcategoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.subcategoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SubcategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubcategoriesTable,
      Subcategory,
      $$SubcategoriesTableFilterComposer,
      $$SubcategoriesTableOrderingComposer,
      $$SubcategoriesTableAnnotationComposer,
      $$SubcategoriesTableCreateCompanionBuilder,
      $$SubcategoriesTableUpdateCompanionBuilder,
      (Subcategory, $$SubcategoriesTableReferences),
      Subcategory,
      PrefetchHooks Function({
        bool categoryId,
        bool examsRefs,
        bool questionSubcategoriesRefs,
      })
    >;
typedef $$ExamsTableCreateCompanionBuilder =
    ExamsCompanion Function({
      Value<int> id,
      required String title,
      Value<String> description,
      required int categoryId,
      Value<int?> subcategoryId,
      Value<int> questionCount,
      Value<bool> published,
      Value<int> timeLimitMinutes,
      Value<bool> shuffleOptions,
      Value<bool> negativeMarking,
      Value<int> passPercent,
      Value<int> themeKey,
      Value<String> pdfUrl,
    });
typedef $$ExamsTableUpdateCompanionBuilder =
    ExamsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> description,
      Value<int> categoryId,
      Value<int?> subcategoryId,
      Value<int> questionCount,
      Value<bool> published,
      Value<int> timeLimitMinutes,
      Value<bool> shuffleOptions,
      Value<bool> negativeMarking,
      Value<int> passPercent,
      Value<int> themeKey,
      Value<String> pdfUrl,
    });

final class $$ExamsTableReferences
    extends BaseReferences<_$AppDatabase, $ExamsTable, Exam> {
  $$ExamsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) => db.categories
      .createAlias($_aliasNameGenerator(db.exams.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SubcategoriesTable _subcategoryIdTable(_$AppDatabase db) =>
      db.subcategories.createAlias(
        $_aliasNameGenerator(db.exams.subcategoryId, db.subcategories.id),
      );

  $$SubcategoriesTableProcessedTableManager? get subcategoryId {
    final $_column = $_itemColumn<int>('subcategory_id');
    if ($_column == null) return null;
    final manager = $$SubcategoriesTableTableManager(
      $_db,
      $_db.subcategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subcategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExamQuestionsTable, List<ExamQuestion>>
  _examQuestionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.examQuestions,
    aliasName: $_aliasNameGenerator(db.exams.id, db.examQuestions.examId),
  );

  $$ExamQuestionsTableProcessedTableManager get examQuestionsRefs {
    final manager = $$ExamQuestionsTableTableManager(
      $_db,
      $_db.examQuestions,
    ).filter((f) => f.examId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_examQuestionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExamGradeBandsTable, List<ExamGradeBand>>
  _examGradeBandsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.examGradeBands,
    aliasName: $_aliasNameGenerator(db.exams.id, db.examGradeBands.examId),
  );

  $$ExamGradeBandsTableProcessedTableManager get examGradeBandsRefs {
    final manager = $$ExamGradeBandsTableTableManager(
      $_db,
      $_db.examGradeBands,
    ).filter((f) => f.examId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_examGradeBandsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AttemptsTable, List<Attempt>> _attemptsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.attempts,
    aliasName: $_aliasNameGenerator(db.exams.id, db.attempts.examId),
  );

  $$AttemptsTableProcessedTableManager get attemptsRefs {
    final manager = $$AttemptsTableTableManager(
      $_db,
      $_db.attempts,
    ).filter((f) => f.examId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attemptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReportsTable, List<Report>> _reportsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.reports,
    aliasName: $_aliasNameGenerator(db.exams.id, db.reports.examId),
  );

  $$ReportsTableProcessedTableManager get reportsRefs {
    final manager = $$ReportsTableTableManager(
      $_db,
      $_db.reports,
    ).filter((f) => f.examId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_reportsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExamsTableFilterComposer extends Composer<_$AppDatabase, $ExamsTable> {
  $$ExamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get published => $composableBuilder(
    column: $table.published,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeLimitMinutes => $composableBuilder(
    column: $table.timeLimitMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shuffleOptions => $composableBuilder(
    column: $table.shuffleOptions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get negativeMarking => $composableBuilder(
    column: $table.negativeMarking,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passPercent => $composableBuilder(
    column: $table.passPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get themeKey => $composableBuilder(
    column: $table.themeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pdfUrl => $composableBuilder(
    column: $table.pdfUrl,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubcategoriesTableFilterComposer get subcategoryId {
    final $$SubcategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subcategoryId,
      referencedTable: $db.subcategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubcategoriesTableFilterComposer(
            $db: $db,
            $table: $db.subcategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> examQuestionsRefs(
    Expression<bool> Function($$ExamQuestionsTableFilterComposer f) f,
  ) {
    final $$ExamQuestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.examQuestions,
      getReferencedColumn: (t) => t.examId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamQuestionsTableFilterComposer(
            $db: $db,
            $table: $db.examQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> examGradeBandsRefs(
    Expression<bool> Function($$ExamGradeBandsTableFilterComposer f) f,
  ) {
    final $$ExamGradeBandsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.examGradeBands,
      getReferencedColumn: (t) => t.examId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamGradeBandsTableFilterComposer(
            $db: $db,
            $table: $db.examGradeBands,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attemptsRefs(
    Expression<bool> Function($$AttemptsTableFilterComposer f) f,
  ) {
    final $$AttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.examId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableFilterComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> reportsRefs(
    Expression<bool> Function($$ReportsTableFilterComposer f) f,
  ) {
    final $$ReportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reports,
      getReferencedColumn: (t) => t.examId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReportsTableFilterComposer(
            $db: $db,
            $table: $db.reports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExamsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExamsTable> {
  $$ExamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get published => $composableBuilder(
    column: $table.published,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeLimitMinutes => $composableBuilder(
    column: $table.timeLimitMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shuffleOptions => $composableBuilder(
    column: $table.shuffleOptions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get negativeMarking => $composableBuilder(
    column: $table.negativeMarking,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passPercent => $composableBuilder(
    column: $table.passPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get themeKey => $composableBuilder(
    column: $table.themeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pdfUrl => $composableBuilder(
    column: $table.pdfUrl,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubcategoriesTableOrderingComposer get subcategoryId {
    final $$SubcategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subcategoryId,
      referencedTable: $db.subcategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubcategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.subcategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExamsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExamsTable> {
  $$ExamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get published =>
      $composableBuilder(column: $table.published, builder: (column) => column);

  GeneratedColumn<int> get timeLimitMinutes => $composableBuilder(
    column: $table.timeLimitMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get shuffleOptions => $composableBuilder(
    column: $table.shuffleOptions,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get negativeMarking => $composableBuilder(
    column: $table.negativeMarking,
    builder: (column) => column,
  );

  GeneratedColumn<int> get passPercent => $composableBuilder(
    column: $table.passPercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get themeKey =>
      $composableBuilder(column: $table.themeKey, builder: (column) => column);

  GeneratedColumn<String> get pdfUrl =>
      $composableBuilder(column: $table.pdfUrl, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubcategoriesTableAnnotationComposer get subcategoryId {
    final $$SubcategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subcategoryId,
      referencedTable: $db.subcategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubcategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.subcategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> examQuestionsRefs<T extends Object>(
    Expression<T> Function($$ExamQuestionsTableAnnotationComposer a) f,
  ) {
    final $$ExamQuestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.examQuestions,
      getReferencedColumn: (t) => t.examId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamQuestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.examQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> examGradeBandsRefs<T extends Object>(
    Expression<T> Function($$ExamGradeBandsTableAnnotationComposer a) f,
  ) {
    final $$ExamGradeBandsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.examGradeBands,
      getReferencedColumn: (t) => t.examId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamGradeBandsTableAnnotationComposer(
            $db: $db,
            $table: $db.examGradeBands,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> attemptsRefs<T extends Object>(
    Expression<T> Function($$AttemptsTableAnnotationComposer a) f,
  ) {
    final $$AttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.examId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> reportsRefs<T extends Object>(
    Expression<T> Function($$ReportsTableAnnotationComposer a) f,
  ) {
    final $$ReportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reports,
      getReferencedColumn: (t) => t.examId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReportsTableAnnotationComposer(
            $db: $db,
            $table: $db.reports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExamsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExamsTable,
          Exam,
          $$ExamsTableFilterComposer,
          $$ExamsTableOrderingComposer,
          $$ExamsTableAnnotationComposer,
          $$ExamsTableCreateCompanionBuilder,
          $$ExamsTableUpdateCompanionBuilder,
          (Exam, $$ExamsTableReferences),
          Exam,
          PrefetchHooks Function({
            bool categoryId,
            bool subcategoryId,
            bool examQuestionsRefs,
            bool examGradeBandsRefs,
            bool attemptsRefs,
            bool reportsRefs,
          })
        > {
  $$ExamsTableTableManager(_$AppDatabase db, $ExamsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int?> subcategoryId = const Value.absent(),
                Value<int> questionCount = const Value.absent(),
                Value<bool> published = const Value.absent(),
                Value<int> timeLimitMinutes = const Value.absent(),
                Value<bool> shuffleOptions = const Value.absent(),
                Value<bool> negativeMarking = const Value.absent(),
                Value<int> passPercent = const Value.absent(),
                Value<int> themeKey = const Value.absent(),
                Value<String> pdfUrl = const Value.absent(),
              }) => ExamsCompanion(
                id: id,
                title: title,
                description: description,
                categoryId: categoryId,
                subcategoryId: subcategoryId,
                questionCount: questionCount,
                published: published,
                timeLimitMinutes: timeLimitMinutes,
                shuffleOptions: shuffleOptions,
                negativeMarking: negativeMarking,
                passPercent: passPercent,
                themeKey: themeKey,
                pdfUrl: pdfUrl,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String> description = const Value.absent(),
                required int categoryId,
                Value<int?> subcategoryId = const Value.absent(),
                Value<int> questionCount = const Value.absent(),
                Value<bool> published = const Value.absent(),
                Value<int> timeLimitMinutes = const Value.absent(),
                Value<bool> shuffleOptions = const Value.absent(),
                Value<bool> negativeMarking = const Value.absent(),
                Value<int> passPercent = const Value.absent(),
                Value<int> themeKey = const Value.absent(),
                Value<String> pdfUrl = const Value.absent(),
              }) => ExamsCompanion.insert(
                id: id,
                title: title,
                description: description,
                categoryId: categoryId,
                subcategoryId: subcategoryId,
                questionCount: questionCount,
                published: published,
                timeLimitMinutes: timeLimitMinutes,
                shuffleOptions: shuffleOptions,
                negativeMarking: negativeMarking,
                passPercent: passPercent,
                themeKey: themeKey,
                pdfUrl: pdfUrl,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ExamsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                subcategoryId = false,
                examQuestionsRefs = false,
                examGradeBandsRefs = false,
                attemptsRefs = false,
                reportsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (examQuestionsRefs) db.examQuestions,
                    if (examGradeBandsRefs) db.examGradeBands,
                    if (attemptsRefs) db.attempts,
                    if (reportsRefs) db.reports,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable: $$ExamsTableReferences
                                        ._categoryIdTable(db),
                                    referencedColumn: $$ExamsTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (subcategoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.subcategoryId,
                                    referencedTable: $$ExamsTableReferences
                                        ._subcategoryIdTable(db),
                                    referencedColumn: $$ExamsTableReferences
                                        ._subcategoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (examQuestionsRefs)
                        await $_getPrefetchedData<
                          Exam,
                          $ExamsTable,
                          ExamQuestion
                        >(
                          currentTable: table,
                          referencedTable: $$ExamsTableReferences
                              ._examQuestionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExamsTableReferences(
                                db,
                                table,
                                p0,
                              ).examQuestionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.examId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (examGradeBandsRefs)
                        await $_getPrefetchedData<
                          Exam,
                          $ExamsTable,
                          ExamGradeBand
                        >(
                          currentTable: table,
                          referencedTable: $$ExamsTableReferences
                              ._examGradeBandsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExamsTableReferences(
                                db,
                                table,
                                p0,
                              ).examGradeBandsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.examId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (attemptsRefs)
                        await $_getPrefetchedData<Exam, $ExamsTable, Attempt>(
                          currentTable: table,
                          referencedTable: $$ExamsTableReferences
                              ._attemptsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExamsTableReferences(
                                db,
                                table,
                                p0,
                              ).attemptsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.examId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (reportsRefs)
                        await $_getPrefetchedData<Exam, $ExamsTable, Report>(
                          currentTable: table,
                          referencedTable: $$ExamsTableReferences
                              ._reportsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExamsTableReferences(db, table, p0).reportsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.examId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExamsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExamsTable,
      Exam,
      $$ExamsTableFilterComposer,
      $$ExamsTableOrderingComposer,
      $$ExamsTableAnnotationComposer,
      $$ExamsTableCreateCompanionBuilder,
      $$ExamsTableUpdateCompanionBuilder,
      (Exam, $$ExamsTableReferences),
      Exam,
      PrefetchHooks Function({
        bool categoryId,
        bool subcategoryId,
        bool examQuestionsRefs,
        bool examGradeBandsRefs,
        bool attemptsRefs,
        bool reportsRefs,
      })
    >;
typedef $$QuestionsTableCreateCompanionBuilder =
    QuestionsCompanion Function({
      Value<int> id,
      required String body,
      Value<String> explanation,
      Value<bool> multiple,
      Value<bool> locked,
    });
typedef $$QuestionsTableUpdateCompanionBuilder =
    QuestionsCompanion Function({
      Value<int> id,
      Value<String> body,
      Value<String> explanation,
      Value<bool> multiple,
      Value<bool> locked,
    });

final class $$QuestionsTableReferences
    extends BaseReferences<_$AppDatabase, $QuestionsTable, Question> {
  $$QuestionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ChoicesTable, List<Choice>> _choicesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.choices,
    aliasName: $_aliasNameGenerator(db.questions.id, db.choices.questionId),
  );

  $$ChoicesTableProcessedTableManager get choicesRefs {
    final manager = $$ChoicesTableTableManager(
      $_db,
      $_db.choices,
    ).filter((f) => f.questionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_choicesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExamQuestionsTable, List<ExamQuestion>>
  _examQuestionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.examQuestions,
    aliasName: $_aliasNameGenerator(
      db.questions.id,
      db.examQuestions.questionId,
    ),
  );

  $$ExamQuestionsTableProcessedTableManager get examQuestionsRefs {
    final manager = $$ExamQuestionsTableTableManager(
      $_db,
      $_db.examQuestions,
    ).filter((f) => f.questionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_examQuestionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QuestionCategoriesTable, List<QuestionCategory>>
  _questionCategoriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.questionCategories,
        aliasName: $_aliasNameGenerator(
          db.questions.id,
          db.questionCategories.questionId,
        ),
      );

  $$QuestionCategoriesTableProcessedTableManager get questionCategoriesRefs {
    final manager = $$QuestionCategoriesTableTableManager(
      $_db,
      $_db.questionCategories,
    ).filter((f) => f.questionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _questionCategoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $QuestionSubcategoriesTable,
    List<QuestionSubcategory>
  >
  _questionSubcategoriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.questionSubcategories,
        aliasName: $_aliasNameGenerator(
          db.questions.id,
          db.questionSubcategories.questionId,
        ),
      );

  $$QuestionSubcategoriesTableProcessedTableManager
  get questionSubcategoriesRefs {
    final manager = $$QuestionSubcategoriesTableTableManager(
      $_db,
      $_db.questionSubcategories,
    ).filter((f) => f.questionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _questionSubcategoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AttemptAnswersTable, List<AttemptAnswer>>
  _attemptAnswersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attemptAnswers,
    aliasName: $_aliasNameGenerator(
      db.questions.id,
      db.attemptAnswers.questionId,
    ),
  );

  $$AttemptAnswersTableProcessedTableManager get attemptAnswersRefs {
    final manager = $$AttemptAnswersTableTableManager(
      $_db,
      $_db.attemptAnswers,
    ).filter((f) => f.questionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attemptAnswersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SavedQuestionsTable, List<SavedQuestion>>
  _savedQuestionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.savedQuestions,
    aliasName: $_aliasNameGenerator(
      db.questions.id,
      db.savedQuestions.questionId,
    ),
  );

  $$SavedQuestionsTableProcessedTableManager get savedQuestionsRefs {
    final manager = $$SavedQuestionsTableTableManager(
      $_db,
      $_db.savedQuestions,
    ).filter((f) => f.questionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_savedQuestionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$QuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get multiple => $composableBuilder(
    column: $table.multiple,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> choicesRefs(
    Expression<bool> Function($$ChoicesTableFilterComposer f) f,
  ) {
    final $$ChoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.choices,
      getReferencedColumn: (t) => t.questionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChoicesTableFilterComposer(
            $db: $db,
            $table: $db.choices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> examQuestionsRefs(
    Expression<bool> Function($$ExamQuestionsTableFilterComposer f) f,
  ) {
    final $$ExamQuestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.examQuestions,
      getReferencedColumn: (t) => t.questionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamQuestionsTableFilterComposer(
            $db: $db,
            $table: $db.examQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> questionCategoriesRefs(
    Expression<bool> Function($$QuestionCategoriesTableFilterComposer f) f,
  ) {
    final $$QuestionCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.questionCategories,
      getReferencedColumn: (t) => t.questionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.questionCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> questionSubcategoriesRefs(
    Expression<bool> Function($$QuestionSubcategoriesTableFilterComposer f) f,
  ) {
    final $$QuestionSubcategoriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.questionSubcategories,
          getReferencedColumn: (t) => t.questionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$QuestionSubcategoriesTableFilterComposer(
                $db: $db,
                $table: $db.questionSubcategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> attemptAnswersRefs(
    Expression<bool> Function($$AttemptAnswersTableFilterComposer f) f,
  ) {
    final $$AttemptAnswersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attemptAnswers,
      getReferencedColumn: (t) => t.questionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptAnswersTableFilterComposer(
            $db: $db,
            $table: $db.attemptAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> savedQuestionsRefs(
    Expression<bool> Function($$SavedQuestionsTableFilterComposer f) f,
  ) {
    final $$SavedQuestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savedQuestions,
      getReferencedColumn: (t) => t.questionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedQuestionsTableFilterComposer(
            $db: $db,
            $table: $db.savedQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get multiple => $composableBuilder(
    column: $table.multiple,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get multiple =>
      $composableBuilder(column: $table.multiple, builder: (column) => column);

  GeneratedColumn<bool> get locked =>
      $composableBuilder(column: $table.locked, builder: (column) => column);

  Expression<T> choicesRefs<T extends Object>(
    Expression<T> Function($$ChoicesTableAnnotationComposer a) f,
  ) {
    final $$ChoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.choices,
      getReferencedColumn: (t) => t.questionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.choices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> examQuestionsRefs<T extends Object>(
    Expression<T> Function($$ExamQuestionsTableAnnotationComposer a) f,
  ) {
    final $$ExamQuestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.examQuestions,
      getReferencedColumn: (t) => t.questionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamQuestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.examQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> questionCategoriesRefs<T extends Object>(
    Expression<T> Function($$QuestionCategoriesTableAnnotationComposer a) f,
  ) {
    final $$QuestionCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.questionCategories,
          getReferencedColumn: (t) => t.questionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$QuestionCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.questionCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> questionSubcategoriesRefs<T extends Object>(
    Expression<T> Function($$QuestionSubcategoriesTableAnnotationComposer a) f,
  ) {
    final $$QuestionSubcategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.questionSubcategories,
          getReferencedColumn: (t) => t.questionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$QuestionSubcategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.questionSubcategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> attemptAnswersRefs<T extends Object>(
    Expression<T> Function($$AttemptAnswersTableAnnotationComposer a) f,
  ) {
    final $$AttemptAnswersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attemptAnswers,
      getReferencedColumn: (t) => t.questionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptAnswersTableAnnotationComposer(
            $db: $db,
            $table: $db.attemptAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> savedQuestionsRefs<T extends Object>(
    Expression<T> Function($$SavedQuestionsTableAnnotationComposer a) f,
  ) {
    final $$SavedQuestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savedQuestions,
      getReferencedColumn: (t) => t.questionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavedQuestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.savedQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestionsTable,
          Question,
          $$QuestionsTableFilterComposer,
          $$QuestionsTableOrderingComposer,
          $$QuestionsTableAnnotationComposer,
          $$QuestionsTableCreateCompanionBuilder,
          $$QuestionsTableUpdateCompanionBuilder,
          (Question, $$QuestionsTableReferences),
          Question,
          PrefetchHooks Function({
            bool choicesRefs,
            bool examQuestionsRefs,
            bool questionCategoriesRefs,
            bool questionSubcategoriesRefs,
            bool attemptAnswersRefs,
            bool savedQuestionsRefs,
          })
        > {
  $$QuestionsTableTableManager(_$AppDatabase db, $QuestionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> explanation = const Value.absent(),
                Value<bool> multiple = const Value.absent(),
                Value<bool> locked = const Value.absent(),
              }) => QuestionsCompanion(
                id: id,
                body: body,
                explanation: explanation,
                multiple: multiple,
                locked: locked,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String body,
                Value<String> explanation = const Value.absent(),
                Value<bool> multiple = const Value.absent(),
                Value<bool> locked = const Value.absent(),
              }) => QuestionsCompanion.insert(
                id: id,
                body: body,
                explanation: explanation,
                multiple: multiple,
                locked: locked,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$QuestionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                choicesRefs = false,
                examQuestionsRefs = false,
                questionCategoriesRefs = false,
                questionSubcategoriesRefs = false,
                attemptAnswersRefs = false,
                savedQuestionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (choicesRefs) db.choices,
                    if (examQuestionsRefs) db.examQuestions,
                    if (questionCategoriesRefs) db.questionCategories,
                    if (questionSubcategoriesRefs) db.questionSubcategories,
                    if (attemptAnswersRefs) db.attemptAnswers,
                    if (savedQuestionsRefs) db.savedQuestions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (choicesRefs)
                        await $_getPrefetchedData<
                          Question,
                          $QuestionsTable,
                          Choice
                        >(
                          currentTable: table,
                          referencedTable: $$QuestionsTableReferences
                              ._choicesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$QuestionsTableReferences(
                                db,
                                table,
                                p0,
                              ).choicesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.questionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (examQuestionsRefs)
                        await $_getPrefetchedData<
                          Question,
                          $QuestionsTable,
                          ExamQuestion
                        >(
                          currentTable: table,
                          referencedTable: $$QuestionsTableReferences
                              ._examQuestionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$QuestionsTableReferences(
                                db,
                                table,
                                p0,
                              ).examQuestionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.questionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (questionCategoriesRefs)
                        await $_getPrefetchedData<
                          Question,
                          $QuestionsTable,
                          QuestionCategory
                        >(
                          currentTable: table,
                          referencedTable: $$QuestionsTableReferences
                              ._questionCategoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$QuestionsTableReferences(
                                db,
                                table,
                                p0,
                              ).questionCategoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.questionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (questionSubcategoriesRefs)
                        await $_getPrefetchedData<
                          Question,
                          $QuestionsTable,
                          QuestionSubcategory
                        >(
                          currentTable: table,
                          referencedTable: $$QuestionsTableReferences
                              ._questionSubcategoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$QuestionsTableReferences(
                                db,
                                table,
                                p0,
                              ).questionSubcategoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.questionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (attemptAnswersRefs)
                        await $_getPrefetchedData<
                          Question,
                          $QuestionsTable,
                          AttemptAnswer
                        >(
                          currentTable: table,
                          referencedTable: $$QuestionsTableReferences
                              ._attemptAnswersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$QuestionsTableReferences(
                                db,
                                table,
                                p0,
                              ).attemptAnswersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.questionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (savedQuestionsRefs)
                        await $_getPrefetchedData<
                          Question,
                          $QuestionsTable,
                          SavedQuestion
                        >(
                          currentTable: table,
                          referencedTable: $$QuestionsTableReferences
                              ._savedQuestionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$QuestionsTableReferences(
                                db,
                                table,
                                p0,
                              ).savedQuestionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.questionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$QuestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestionsTable,
      Question,
      $$QuestionsTableFilterComposer,
      $$QuestionsTableOrderingComposer,
      $$QuestionsTableAnnotationComposer,
      $$QuestionsTableCreateCompanionBuilder,
      $$QuestionsTableUpdateCompanionBuilder,
      (Question, $$QuestionsTableReferences),
      Question,
      PrefetchHooks Function({
        bool choicesRefs,
        bool examQuestionsRefs,
        bool questionCategoriesRefs,
        bool questionSubcategoriesRefs,
        bool attemptAnswersRefs,
        bool savedQuestionsRefs,
      })
    >;
typedef $$ChoicesTableCreateCompanionBuilder =
    ChoicesCompanion Function({
      Value<int> id,
      required int questionId,
      required String label,
      Value<bool> isCorrect,
      Value<int> order,
    });
typedef $$ChoicesTableUpdateCompanionBuilder =
    ChoicesCompanion Function({
      Value<int> id,
      Value<int> questionId,
      Value<String> label,
      Value<bool> isCorrect,
      Value<int> order,
    });

final class $$ChoicesTableReferences
    extends BaseReferences<_$AppDatabase, $ChoicesTable, Choice> {
  $$ChoicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $QuestionsTable _questionIdTable(_$AppDatabase db) =>
      db.questions.createAlias(
        $_aliasNameGenerator(db.choices.questionId, db.questions.id),
      );

  $$QuestionsTableProcessedTableManager get questionId {
    final $_column = $_itemColumn<int>('question_id')!;

    final manager = $$QuestionsTableTableManager(
      $_db,
      $_db.questions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChoicesTableFilterComposer
    extends Composer<_$AppDatabase, $ChoicesTable> {
  $$ChoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  $$QuestionsTableFilterComposer get questionId {
    final $$QuestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableFilterComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChoicesTable> {
  $$ChoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  $$QuestionsTableOrderingComposer get questionId {
    final $$QuestionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableOrderingComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChoicesTable> {
  $$ChoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  $$QuestionsTableAnnotationComposer get questionId {
    final $$QuestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChoicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChoicesTable,
          Choice,
          $$ChoicesTableFilterComposer,
          $$ChoicesTableOrderingComposer,
          $$ChoicesTableAnnotationComposer,
          $$ChoicesTableCreateCompanionBuilder,
          $$ChoicesTableUpdateCompanionBuilder,
          (Choice, $$ChoicesTableReferences),
          Choice,
          PrefetchHooks Function({bool questionId})
        > {
  $$ChoicesTableTableManager(_$AppDatabase db, $ChoicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> questionId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<bool> isCorrect = const Value.absent(),
                Value<int> order = const Value.absent(),
              }) => ChoicesCompanion(
                id: id,
                questionId: questionId,
                label: label,
                isCorrect: isCorrect,
                order: order,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int questionId,
                required String label,
                Value<bool> isCorrect = const Value.absent(),
                Value<int> order = const Value.absent(),
              }) => ChoicesCompanion.insert(
                id: id,
                questionId: questionId,
                label: label,
                isCorrect: isCorrect,
                order: order,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChoicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({questionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (questionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.questionId,
                                referencedTable: $$ChoicesTableReferences
                                    ._questionIdTable(db),
                                referencedColumn: $$ChoicesTableReferences
                                    ._questionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChoicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChoicesTable,
      Choice,
      $$ChoicesTableFilterComposer,
      $$ChoicesTableOrderingComposer,
      $$ChoicesTableAnnotationComposer,
      $$ChoicesTableCreateCompanionBuilder,
      $$ChoicesTableUpdateCompanionBuilder,
      (Choice, $$ChoicesTableReferences),
      Choice,
      PrefetchHooks Function({bool questionId})
    >;
typedef $$ExamQuestionsTableCreateCompanionBuilder =
    ExamQuestionsCompanion Function({
      Value<int> id,
      required int examId,
      required int questionId,
      Value<int> order,
      Value<int> points,
    });
typedef $$ExamQuestionsTableUpdateCompanionBuilder =
    ExamQuestionsCompanion Function({
      Value<int> id,
      Value<int> examId,
      Value<int> questionId,
      Value<int> order,
      Value<int> points,
    });

final class $$ExamQuestionsTableReferences
    extends BaseReferences<_$AppDatabase, $ExamQuestionsTable, ExamQuestion> {
  $$ExamQuestionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExamsTable _examIdTable(_$AppDatabase db) => db.exams.createAlias(
    $_aliasNameGenerator(db.examQuestions.examId, db.exams.id),
  );

  $$ExamsTableProcessedTableManager get examId {
    final $_column = $_itemColumn<int>('exam_id')!;

    final manager = $$ExamsTableTableManager(
      $_db,
      $_db.exams,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_examIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $QuestionsTable _questionIdTable(_$AppDatabase db) =>
      db.questions.createAlias(
        $_aliasNameGenerator(db.examQuestions.questionId, db.questions.id),
      );

  $$QuestionsTableProcessedTableManager get questionId {
    final $_column = $_itemColumn<int>('question_id')!;

    final manager = $$QuestionsTableTableManager(
      $_db,
      $_db.questions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExamQuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $ExamQuestionsTable> {
  $$ExamQuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnFilters(column),
  );

  $$ExamsTableFilterComposer get examId {
    final $$ExamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableFilterComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$QuestionsTableFilterComposer get questionId {
    final $$QuestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableFilterComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExamQuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExamQuestionsTable> {
  $$ExamQuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExamsTableOrderingComposer get examId {
    final $$ExamsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableOrderingComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$QuestionsTableOrderingComposer get questionId {
    final $$QuestionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableOrderingComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExamQuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExamQuestionsTable> {
  $$ExamQuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<int> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  $$ExamsTableAnnotationComposer get examId {
    final $$ExamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableAnnotationComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$QuestionsTableAnnotationComposer get questionId {
    final $$QuestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExamQuestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExamQuestionsTable,
          ExamQuestion,
          $$ExamQuestionsTableFilterComposer,
          $$ExamQuestionsTableOrderingComposer,
          $$ExamQuestionsTableAnnotationComposer,
          $$ExamQuestionsTableCreateCompanionBuilder,
          $$ExamQuestionsTableUpdateCompanionBuilder,
          (ExamQuestion, $$ExamQuestionsTableReferences),
          ExamQuestion,
          PrefetchHooks Function({bool examId, bool questionId})
        > {
  $$ExamQuestionsTableTableManager(_$AppDatabase db, $ExamQuestionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamQuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamQuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamQuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> examId = const Value.absent(),
                Value<int> questionId = const Value.absent(),
                Value<int> order = const Value.absent(),
                Value<int> points = const Value.absent(),
              }) => ExamQuestionsCompanion(
                id: id,
                examId: examId,
                questionId: questionId,
                order: order,
                points: points,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int examId,
                required int questionId,
                Value<int> order = const Value.absent(),
                Value<int> points = const Value.absent(),
              }) => ExamQuestionsCompanion.insert(
                id: id,
                examId: examId,
                questionId: questionId,
                order: order,
                points: points,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExamQuestionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({examId = false, questionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (examId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.examId,
                                referencedTable: $$ExamQuestionsTableReferences
                                    ._examIdTable(db),
                                referencedColumn: $$ExamQuestionsTableReferences
                                    ._examIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (questionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.questionId,
                                referencedTable: $$ExamQuestionsTableReferences
                                    ._questionIdTable(db),
                                referencedColumn: $$ExamQuestionsTableReferences
                                    ._questionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExamQuestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExamQuestionsTable,
      ExamQuestion,
      $$ExamQuestionsTableFilterComposer,
      $$ExamQuestionsTableOrderingComposer,
      $$ExamQuestionsTableAnnotationComposer,
      $$ExamQuestionsTableCreateCompanionBuilder,
      $$ExamQuestionsTableUpdateCompanionBuilder,
      (ExamQuestion, $$ExamQuestionsTableReferences),
      ExamQuestion,
      PrefetchHooks Function({bool examId, bool questionId})
    >;
typedef $$ExamGradeBandsTableCreateCompanionBuilder =
    ExamGradeBandsCompanion Function({
      Value<int> id,
      required int examId,
      required int minPercent,
      required String label,
      Value<String> color,
    });
typedef $$ExamGradeBandsTableUpdateCompanionBuilder =
    ExamGradeBandsCompanion Function({
      Value<int> id,
      Value<int> examId,
      Value<int> minPercent,
      Value<String> label,
      Value<String> color,
    });

final class $$ExamGradeBandsTableReferences
    extends BaseReferences<_$AppDatabase, $ExamGradeBandsTable, ExamGradeBand> {
  $$ExamGradeBandsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExamsTable _examIdTable(_$AppDatabase db) => db.exams.createAlias(
    $_aliasNameGenerator(db.examGradeBands.examId, db.exams.id),
  );

  $$ExamsTableProcessedTableManager get examId {
    final $_column = $_itemColumn<int>('exam_id')!;

    final manager = $$ExamsTableTableManager(
      $_db,
      $_db.exams,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_examIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExamGradeBandsTableFilterComposer
    extends Composer<_$AppDatabase, $ExamGradeBandsTable> {
  $$ExamGradeBandsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minPercent => $composableBuilder(
    column: $table.minPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  $$ExamsTableFilterComposer get examId {
    final $$ExamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableFilterComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExamGradeBandsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExamGradeBandsTable> {
  $$ExamGradeBandsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minPercent => $composableBuilder(
    column: $table.minPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExamsTableOrderingComposer get examId {
    final $$ExamsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableOrderingComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExamGradeBandsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExamGradeBandsTable> {
  $$ExamGradeBandsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get minPercent => $composableBuilder(
    column: $table.minPercent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  $$ExamsTableAnnotationComposer get examId {
    final $$ExamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableAnnotationComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExamGradeBandsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExamGradeBandsTable,
          ExamGradeBand,
          $$ExamGradeBandsTableFilterComposer,
          $$ExamGradeBandsTableOrderingComposer,
          $$ExamGradeBandsTableAnnotationComposer,
          $$ExamGradeBandsTableCreateCompanionBuilder,
          $$ExamGradeBandsTableUpdateCompanionBuilder,
          (ExamGradeBand, $$ExamGradeBandsTableReferences),
          ExamGradeBand,
          PrefetchHooks Function({bool examId})
        > {
  $$ExamGradeBandsTableTableManager(
    _$AppDatabase db,
    $ExamGradeBandsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamGradeBandsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamGradeBandsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamGradeBandsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> examId = const Value.absent(),
                Value<int> minPercent = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> color = const Value.absent(),
              }) => ExamGradeBandsCompanion(
                id: id,
                examId: examId,
                minPercent: minPercent,
                label: label,
                color: color,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int examId,
                required int minPercent,
                required String label,
                Value<String> color = const Value.absent(),
              }) => ExamGradeBandsCompanion.insert(
                id: id,
                examId: examId,
                minPercent: minPercent,
                label: label,
                color: color,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExamGradeBandsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({examId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (examId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.examId,
                                referencedTable: $$ExamGradeBandsTableReferences
                                    ._examIdTable(db),
                                referencedColumn:
                                    $$ExamGradeBandsTableReferences
                                        ._examIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExamGradeBandsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExamGradeBandsTable,
      ExamGradeBand,
      $$ExamGradeBandsTableFilterComposer,
      $$ExamGradeBandsTableOrderingComposer,
      $$ExamGradeBandsTableAnnotationComposer,
      $$ExamGradeBandsTableCreateCompanionBuilder,
      $$ExamGradeBandsTableUpdateCompanionBuilder,
      (ExamGradeBand, $$ExamGradeBandsTableReferences),
      ExamGradeBand,
      PrefetchHooks Function({bool examId})
    >;
typedef $$QuestionCategoriesTableCreateCompanionBuilder =
    QuestionCategoriesCompanion Function({
      Value<int> id,
      required int questionId,
      required int categoryId,
    });
typedef $$QuestionCategoriesTableUpdateCompanionBuilder =
    QuestionCategoriesCompanion Function({
      Value<int> id,
      Value<int> questionId,
      Value<int> categoryId,
    });

final class $$QuestionCategoriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $QuestionCategoriesTable,
          QuestionCategory
        > {
  $$QuestionCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $QuestionsTable _questionIdTable(_$AppDatabase db) =>
      db.questions.createAlias(
        $_aliasNameGenerator(db.questionCategories.questionId, db.questions.id),
      );

  $$QuestionsTableProcessedTableManager get questionId {
    final $_column = $_itemColumn<int>('question_id')!;

    final manager = $$QuestionsTableTableManager(
      $_db,
      $_db.questions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(
          db.questionCategories.categoryId,
          db.categories.id,
        ),
      );

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QuestionCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionCategoriesTable> {
  $$QuestionCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  $$QuestionsTableFilterComposer get questionId {
    final $$QuestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableFilterComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestionCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionCategoriesTable> {
  $$QuestionCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  $$QuestionsTableOrderingComposer get questionId {
    final $$QuestionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableOrderingComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestionCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionCategoriesTable> {
  $$QuestionCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$QuestionsTableAnnotationComposer get questionId {
    final $$QuestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestionCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestionCategoriesTable,
          QuestionCategory,
          $$QuestionCategoriesTableFilterComposer,
          $$QuestionCategoriesTableOrderingComposer,
          $$QuestionCategoriesTableAnnotationComposer,
          $$QuestionCategoriesTableCreateCompanionBuilder,
          $$QuestionCategoriesTableUpdateCompanionBuilder,
          (QuestionCategory, $$QuestionCategoriesTableReferences),
          QuestionCategory,
          PrefetchHooks Function({bool questionId, bool categoryId})
        > {
  $$QuestionCategoriesTableTableManager(
    _$AppDatabase db,
    $QuestionCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> questionId = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
              }) => QuestionCategoriesCompanion(
                id: id,
                questionId: questionId,
                categoryId: categoryId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int questionId,
                required int categoryId,
              }) => QuestionCategoriesCompanion.insert(
                id: id,
                questionId: questionId,
                categoryId: categoryId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$QuestionCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({questionId = false, categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (questionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.questionId,
                                referencedTable:
                                    $$QuestionCategoriesTableReferences
                                        ._questionIdTable(db),
                                referencedColumn:
                                    $$QuestionCategoriesTableReferences
                                        ._questionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable:
                                    $$QuestionCategoriesTableReferences
                                        ._categoryIdTable(db),
                                referencedColumn:
                                    $$QuestionCategoriesTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QuestionCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestionCategoriesTable,
      QuestionCategory,
      $$QuestionCategoriesTableFilterComposer,
      $$QuestionCategoriesTableOrderingComposer,
      $$QuestionCategoriesTableAnnotationComposer,
      $$QuestionCategoriesTableCreateCompanionBuilder,
      $$QuestionCategoriesTableUpdateCompanionBuilder,
      (QuestionCategory, $$QuestionCategoriesTableReferences),
      QuestionCategory,
      PrefetchHooks Function({bool questionId, bool categoryId})
    >;
typedef $$QuestionSubcategoriesTableCreateCompanionBuilder =
    QuestionSubcategoriesCompanion Function({
      Value<int> id,
      required int questionId,
      required int subcategoryId,
    });
typedef $$QuestionSubcategoriesTableUpdateCompanionBuilder =
    QuestionSubcategoriesCompanion Function({
      Value<int> id,
      Value<int> questionId,
      Value<int> subcategoryId,
    });

final class $$QuestionSubcategoriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $QuestionSubcategoriesTable,
          QuestionSubcategory
        > {
  $$QuestionSubcategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $QuestionsTable _questionIdTable(_$AppDatabase db) =>
      db.questions.createAlias(
        $_aliasNameGenerator(
          db.questionSubcategories.questionId,
          db.questions.id,
        ),
      );

  $$QuestionsTableProcessedTableManager get questionId {
    final $_column = $_itemColumn<int>('question_id')!;

    final manager = $$QuestionsTableTableManager(
      $_db,
      $_db.questions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SubcategoriesTable _subcategoryIdTable(_$AppDatabase db) =>
      db.subcategories.createAlias(
        $_aliasNameGenerator(
          db.questionSubcategories.subcategoryId,
          db.subcategories.id,
        ),
      );

  $$SubcategoriesTableProcessedTableManager get subcategoryId {
    final $_column = $_itemColumn<int>('subcategory_id')!;

    final manager = $$SubcategoriesTableTableManager(
      $_db,
      $_db.subcategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subcategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QuestionSubcategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionSubcategoriesTable> {
  $$QuestionSubcategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  $$QuestionsTableFilterComposer get questionId {
    final $$QuestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableFilterComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubcategoriesTableFilterComposer get subcategoryId {
    final $$SubcategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subcategoryId,
      referencedTable: $db.subcategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubcategoriesTableFilterComposer(
            $db: $db,
            $table: $db.subcategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestionSubcategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionSubcategoriesTable> {
  $$QuestionSubcategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  $$QuestionsTableOrderingComposer get questionId {
    final $$QuestionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableOrderingComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubcategoriesTableOrderingComposer get subcategoryId {
    final $$SubcategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subcategoryId,
      referencedTable: $db.subcategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubcategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.subcategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestionSubcategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionSubcategoriesTable> {
  $$QuestionSubcategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$QuestionsTableAnnotationComposer get questionId {
    final $$QuestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubcategoriesTableAnnotationComposer get subcategoryId {
    final $$SubcategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subcategoryId,
      referencedTable: $db.subcategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubcategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.subcategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestionSubcategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestionSubcategoriesTable,
          QuestionSubcategory,
          $$QuestionSubcategoriesTableFilterComposer,
          $$QuestionSubcategoriesTableOrderingComposer,
          $$QuestionSubcategoriesTableAnnotationComposer,
          $$QuestionSubcategoriesTableCreateCompanionBuilder,
          $$QuestionSubcategoriesTableUpdateCompanionBuilder,
          (QuestionSubcategory, $$QuestionSubcategoriesTableReferences),
          QuestionSubcategory,
          PrefetchHooks Function({bool questionId, bool subcategoryId})
        > {
  $$QuestionSubcategoriesTableTableManager(
    _$AppDatabase db,
    $QuestionSubcategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionSubcategoriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$QuestionSubcategoriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$QuestionSubcategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> questionId = const Value.absent(),
                Value<int> subcategoryId = const Value.absent(),
              }) => QuestionSubcategoriesCompanion(
                id: id,
                questionId: questionId,
                subcategoryId: subcategoryId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int questionId,
                required int subcategoryId,
              }) => QuestionSubcategoriesCompanion.insert(
                id: id,
                questionId: questionId,
                subcategoryId: subcategoryId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$QuestionSubcategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({questionId = false, subcategoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (questionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.questionId,
                                referencedTable:
                                    $$QuestionSubcategoriesTableReferences
                                        ._questionIdTable(db),
                                referencedColumn:
                                    $$QuestionSubcategoriesTableReferences
                                        ._questionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (subcategoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.subcategoryId,
                                referencedTable:
                                    $$QuestionSubcategoriesTableReferences
                                        ._subcategoryIdTable(db),
                                referencedColumn:
                                    $$QuestionSubcategoriesTableReferences
                                        ._subcategoryIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QuestionSubcategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestionSubcategoriesTable,
      QuestionSubcategory,
      $$QuestionSubcategoriesTableFilterComposer,
      $$QuestionSubcategoriesTableOrderingComposer,
      $$QuestionSubcategoriesTableAnnotationComposer,
      $$QuestionSubcategoriesTableCreateCompanionBuilder,
      $$QuestionSubcategoriesTableUpdateCompanionBuilder,
      (QuestionSubcategory, $$QuestionSubcategoriesTableReferences),
      QuestionSubcategory,
      PrefetchHooks Function({bool questionId, bool subcategoryId})
    >;
typedef $$AttemptsTableCreateCompanionBuilder =
    AttemptsCompanion Function({
      Value<int> id,
      required int examId,
      required String mode,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<int?> score,
      Value<int> scorePercent,
      Value<String> gradeLabel,
      Value<bool> synced,
      Value<String> userEmail,
    });
typedef $$AttemptsTableUpdateCompanionBuilder =
    AttemptsCompanion Function({
      Value<int> id,
      Value<int> examId,
      Value<String> mode,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int?> score,
      Value<int> scorePercent,
      Value<String> gradeLabel,
      Value<bool> synced,
      Value<String> userEmail,
    });

final class $$AttemptsTableReferences
    extends BaseReferences<_$AppDatabase, $AttemptsTable, Attempt> {
  $$AttemptsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExamsTable _examIdTable(_$AppDatabase db) => db.exams.createAlias(
    $_aliasNameGenerator(db.attempts.examId, db.exams.id),
  );

  $$ExamsTableProcessedTableManager get examId {
    final $_column = $_itemColumn<int>('exam_id')!;

    final manager = $$ExamsTableTableManager(
      $_db,
      $_db.exams,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_examIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AttemptAnswersTable, List<AttemptAnswer>>
  _attemptAnswersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attemptAnswers,
    aliasName: $_aliasNameGenerator(
      db.attempts.id,
      db.attemptAnswers.attemptId,
    ),
  );

  $$AttemptAnswersTableProcessedTableManager get attemptAnswersRefs {
    final manager = $$AttemptAnswersTableTableManager(
      $_db,
      $_db.attemptAnswers,
    ).filter((f) => f.attemptId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attemptAnswersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scorePercent => $composableBuilder(
    column: $table.scorePercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gradeLabel => $composableBuilder(
    column: $table.gradeLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userEmail => $composableBuilder(
    column: $table.userEmail,
    builder: (column) => ColumnFilters(column),
  );

  $$ExamsTableFilterComposer get examId {
    final $$ExamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableFilterComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> attemptAnswersRefs(
    Expression<bool> Function($$AttemptAnswersTableFilterComposer f) f,
  ) {
    final $$AttemptAnswersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attemptAnswers,
      getReferencedColumn: (t) => t.attemptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptAnswersTableFilterComposer(
            $db: $db,
            $table: $db.attemptAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scorePercent => $composableBuilder(
    column: $table.scorePercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gradeLabel => $composableBuilder(
    column: $table.gradeLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userEmail => $composableBuilder(
    column: $table.userEmail,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExamsTableOrderingComposer get examId {
    final $$ExamsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableOrderingComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get scorePercent => $composableBuilder(
    column: $table.scorePercent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gradeLabel => $composableBuilder(
    column: $table.gradeLabel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<String> get userEmail =>
      $composableBuilder(column: $table.userEmail, builder: (column) => column);

  $$ExamsTableAnnotationComposer get examId {
    final $$ExamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableAnnotationComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> attemptAnswersRefs<T extends Object>(
    Expression<T> Function($$AttemptAnswersTableAnnotationComposer a) f,
  ) {
    final $$AttemptAnswersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attemptAnswers,
      getReferencedColumn: (t) => t.attemptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptAnswersTableAnnotationComposer(
            $db: $db,
            $table: $db.attemptAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttemptsTable,
          Attempt,
          $$AttemptsTableFilterComposer,
          $$AttemptsTableOrderingComposer,
          $$AttemptsTableAnnotationComposer,
          $$AttemptsTableCreateCompanionBuilder,
          $$AttemptsTableUpdateCompanionBuilder,
          (Attempt, $$AttemptsTableReferences),
          Attempt,
          PrefetchHooks Function({bool examId, bool attemptAnswersRefs})
        > {
  $$AttemptsTableTableManager(_$AppDatabase db, $AttemptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> examId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int?> score = const Value.absent(),
                Value<int> scorePercent = const Value.absent(),
                Value<String> gradeLabel = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<String> userEmail = const Value.absent(),
              }) => AttemptsCompanion(
                id: id,
                examId: examId,
                mode: mode,
                startedAt: startedAt,
                endedAt: endedAt,
                score: score,
                scorePercent: scorePercent,
                gradeLabel: gradeLabel,
                synced: synced,
                userEmail: userEmail,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int examId,
                required String mode,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int?> score = const Value.absent(),
                Value<int> scorePercent = const Value.absent(),
                Value<String> gradeLabel = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<String> userEmail = const Value.absent(),
              }) => AttemptsCompanion.insert(
                id: id,
                examId: examId,
                mode: mode,
                startedAt: startedAt,
                endedAt: endedAt,
                score: score,
                scorePercent: scorePercent,
                gradeLabel: gradeLabel,
                synced: synced,
                userEmail: userEmail,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttemptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({examId = false, attemptAnswersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (attemptAnswersRefs) db.attemptAnswers,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (examId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.examId,
                                    referencedTable: $$AttemptsTableReferences
                                        ._examIdTable(db),
                                    referencedColumn: $$AttemptsTableReferences
                                        ._examIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (attemptAnswersRefs)
                        await $_getPrefetchedData<
                          Attempt,
                          $AttemptsTable,
                          AttemptAnswer
                        >(
                          currentTable: table,
                          referencedTable: $$AttemptsTableReferences
                              ._attemptAnswersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AttemptsTableReferences(
                                db,
                                table,
                                p0,
                              ).attemptAnswersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.attemptId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttemptsTable,
      Attempt,
      $$AttemptsTableFilterComposer,
      $$AttemptsTableOrderingComposer,
      $$AttemptsTableAnnotationComposer,
      $$AttemptsTableCreateCompanionBuilder,
      $$AttemptsTableUpdateCompanionBuilder,
      (Attempt, $$AttemptsTableReferences),
      Attempt,
      PrefetchHooks Function({bool examId, bool attemptAnswersRefs})
    >;
typedef $$AttemptAnswersTableCreateCompanionBuilder =
    AttemptAnswersCompanion Function({
      Value<int> id,
      required int attemptId,
      required int questionId,
      required String selected,
      Value<int> timeMs,
      Value<bool> isCorrect,
      Value<int> points,
    });
typedef $$AttemptAnswersTableUpdateCompanionBuilder =
    AttemptAnswersCompanion Function({
      Value<int> id,
      Value<int> attemptId,
      Value<int> questionId,
      Value<String> selected,
      Value<int> timeMs,
      Value<bool> isCorrect,
      Value<int> points,
    });

final class $$AttemptAnswersTableReferences
    extends BaseReferences<_$AppDatabase, $AttemptAnswersTable, AttemptAnswer> {
  $$AttemptAnswersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AttemptsTable _attemptIdTable(_$AppDatabase db) =>
      db.attempts.createAlias(
        $_aliasNameGenerator(db.attemptAnswers.attemptId, db.attempts.id),
      );

  $$AttemptsTableProcessedTableManager get attemptId {
    final $_column = $_itemColumn<int>('attempt_id')!;

    final manager = $$AttemptsTableTableManager(
      $_db,
      $_db.attempts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_attemptIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $QuestionsTable _questionIdTable(_$AppDatabase db) =>
      db.questions.createAlias(
        $_aliasNameGenerator(db.attemptAnswers.questionId, db.questions.id),
      );

  $$QuestionsTableProcessedTableManager get questionId {
    final $_column = $_itemColumn<int>('question_id')!;

    final manager = $$QuestionsTableTableManager(
      $_db,
      $_db.questions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttemptAnswersTableFilterComposer
    extends Composer<_$AppDatabase, $AttemptAnswersTable> {
  $$AttemptAnswersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selected => $composableBuilder(
    column: $table.selected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeMs => $composableBuilder(
    column: $table.timeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnFilters(column),
  );

  $$AttemptsTableFilterComposer get attemptId {
    final $$AttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableFilterComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$QuestionsTableFilterComposer get questionId {
    final $$QuestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableFilterComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttemptAnswersTableOrderingComposer
    extends Composer<_$AppDatabase, $AttemptAnswersTable> {
  $$AttemptAnswersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selected => $composableBuilder(
    column: $table.selected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeMs => $composableBuilder(
    column: $table.timeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );

  $$AttemptsTableOrderingComposer get attemptId {
    final $$AttemptsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableOrderingComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$QuestionsTableOrderingComposer get questionId {
    final $$QuestionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableOrderingComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttemptAnswersTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttemptAnswersTable> {
  $$AttemptAnswersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get selected =>
      $composableBuilder(column: $table.selected, builder: (column) => column);

  GeneratedColumn<int> get timeMs =>
      $composableBuilder(column: $table.timeMs, builder: (column) => column);

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<int> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  $$AttemptsTableAnnotationComposer get attemptId {
    final $$AttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$QuestionsTableAnnotationComposer get questionId {
    final $$QuestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttemptAnswersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttemptAnswersTable,
          AttemptAnswer,
          $$AttemptAnswersTableFilterComposer,
          $$AttemptAnswersTableOrderingComposer,
          $$AttemptAnswersTableAnnotationComposer,
          $$AttemptAnswersTableCreateCompanionBuilder,
          $$AttemptAnswersTableUpdateCompanionBuilder,
          (AttemptAnswer, $$AttemptAnswersTableReferences),
          AttemptAnswer,
          PrefetchHooks Function({bool attemptId, bool questionId})
        > {
  $$AttemptAnswersTableTableManager(
    _$AppDatabase db,
    $AttemptAnswersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttemptAnswersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttemptAnswersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttemptAnswersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> attemptId = const Value.absent(),
                Value<int> questionId = const Value.absent(),
                Value<String> selected = const Value.absent(),
                Value<int> timeMs = const Value.absent(),
                Value<bool> isCorrect = const Value.absent(),
                Value<int> points = const Value.absent(),
              }) => AttemptAnswersCompanion(
                id: id,
                attemptId: attemptId,
                questionId: questionId,
                selected: selected,
                timeMs: timeMs,
                isCorrect: isCorrect,
                points: points,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int attemptId,
                required int questionId,
                required String selected,
                Value<int> timeMs = const Value.absent(),
                Value<bool> isCorrect = const Value.absent(),
                Value<int> points = const Value.absent(),
              }) => AttemptAnswersCompanion.insert(
                id: id,
                attemptId: attemptId,
                questionId: questionId,
                selected: selected,
                timeMs: timeMs,
                isCorrect: isCorrect,
                points: points,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttemptAnswersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({attemptId = false, questionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (attemptId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.attemptId,
                                referencedTable: $$AttemptAnswersTableReferences
                                    ._attemptIdTable(db),
                                referencedColumn:
                                    $$AttemptAnswersTableReferences
                                        ._attemptIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (questionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.questionId,
                                referencedTable: $$AttemptAnswersTableReferences
                                    ._questionIdTable(db),
                                referencedColumn:
                                    $$AttemptAnswersTableReferences
                                        ._questionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AttemptAnswersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttemptAnswersTable,
      AttemptAnswer,
      $$AttemptAnswersTableFilterComposer,
      $$AttemptAnswersTableOrderingComposer,
      $$AttemptAnswersTableAnnotationComposer,
      $$AttemptAnswersTableCreateCompanionBuilder,
      $$AttemptAnswersTableUpdateCompanionBuilder,
      (AttemptAnswer, $$AttemptAnswersTableReferences),
      AttemptAnswer,
      PrefetchHooks Function({bool attemptId, bool questionId})
    >;
typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      required String email,
      required String password,
      Value<String> role,
      Value<bool> isPro,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> email,
      Value<String> password,
      Value<String> role,
      Value<bool> isPro,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPro => $composableBuilder(
    column: $table.isPro,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPro => $composableBuilder(
    column: $table.isPro,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isPro =>
      $composableBuilder(column: $table.isPro, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          DbUser,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (DbUser, BaseReferences<_$AppDatabase, $UsersTable, DbUser>),
          DbUser,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> password = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<bool> isPro = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                email: email,
                password: password,
                role: role,
                isPro: isPro,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String email,
                required String password,
                Value<String> role = const Value.absent(),
                Value<bool> isPro = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                email: email,
                password: password,
                role: role,
                isPro: isPro,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      DbUser,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (DbUser, BaseReferences<_$AppDatabase, $UsersTable, DbUser>),
      DbUser,
      PrefetchHooks Function()
    >;
typedef $$SavedQuestionsTableCreateCompanionBuilder =
    SavedQuestionsCompanion Function({
      Value<int> id,
      required int questionId,
      required String userEmail,
      Value<DateTime> createdAt,
    });
typedef $$SavedQuestionsTableUpdateCompanionBuilder =
    SavedQuestionsCompanion Function({
      Value<int> id,
      Value<int> questionId,
      Value<String> userEmail,
      Value<DateTime> createdAt,
    });

final class $$SavedQuestionsTableReferences
    extends BaseReferences<_$AppDatabase, $SavedQuestionsTable, SavedQuestion> {
  $$SavedQuestionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $QuestionsTable _questionIdTable(_$AppDatabase db) =>
      db.questions.createAlias(
        $_aliasNameGenerator(db.savedQuestions.questionId, db.questions.id),
      );

  $$QuestionsTableProcessedTableManager get questionId {
    final $_column = $_itemColumn<int>('question_id')!;

    final manager = $$QuestionsTableTableManager(
      $_db,
      $_db.questions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SavedQuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $SavedQuestionsTable> {
  $$SavedQuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userEmail => $composableBuilder(
    column: $table.userEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$QuestionsTableFilterComposer get questionId {
    final $$QuestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableFilterComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedQuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedQuestionsTable> {
  $$SavedQuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userEmail => $composableBuilder(
    column: $table.userEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$QuestionsTableOrderingComposer get questionId {
    final $$QuestionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableOrderingComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedQuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedQuestionsTable> {
  $$SavedQuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userEmail =>
      $composableBuilder(column: $table.userEmail, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$QuestionsTableAnnotationComposer get questionId {
    final $$QuestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.questions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.questions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavedQuestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedQuestionsTable,
          SavedQuestion,
          $$SavedQuestionsTableFilterComposer,
          $$SavedQuestionsTableOrderingComposer,
          $$SavedQuestionsTableAnnotationComposer,
          $$SavedQuestionsTableCreateCompanionBuilder,
          $$SavedQuestionsTableUpdateCompanionBuilder,
          (SavedQuestion, $$SavedQuestionsTableReferences),
          SavedQuestion,
          PrefetchHooks Function({bool questionId})
        > {
  $$SavedQuestionsTableTableManager(
    _$AppDatabase db,
    $SavedQuestionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedQuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedQuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedQuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> questionId = const Value.absent(),
                Value<String> userEmail = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SavedQuestionsCompanion(
                id: id,
                questionId: questionId,
                userEmail: userEmail,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int questionId,
                required String userEmail,
                Value<DateTime> createdAt = const Value.absent(),
              }) => SavedQuestionsCompanion.insert(
                id: id,
                questionId: questionId,
                userEmail: userEmail,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SavedQuestionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({questionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (questionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.questionId,
                                referencedTable: $$SavedQuestionsTableReferences
                                    ._questionIdTable(db),
                                referencedColumn:
                                    $$SavedQuestionsTableReferences
                                        ._questionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SavedQuestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedQuestionsTable,
      SavedQuestion,
      $$SavedQuestionsTableFilterComposer,
      $$SavedQuestionsTableOrderingComposer,
      $$SavedQuestionsTableAnnotationComposer,
      $$SavedQuestionsTableCreateCompanionBuilder,
      $$SavedQuestionsTableUpdateCompanionBuilder,
      (SavedQuestion, $$SavedQuestionsTableReferences),
      SavedQuestion,
      PrefetchHooks Function({bool questionId})
    >;
typedef $$ReportsTableCreateCompanionBuilder =
    ReportsCompanion Function({
      Value<int> id,
      required int examId,
      required String userEmail,
      required String comment,
      Value<bool> resolved,
      Value<DateTime> createdAt,
    });
typedef $$ReportsTableUpdateCompanionBuilder =
    ReportsCompanion Function({
      Value<int> id,
      Value<int> examId,
      Value<String> userEmail,
      Value<String> comment,
      Value<bool> resolved,
      Value<DateTime> createdAt,
    });

final class $$ReportsTableReferences
    extends BaseReferences<_$AppDatabase, $ReportsTable, Report> {
  $$ReportsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExamsTable _examIdTable(_$AppDatabase db) => db.exams.createAlias(
    $_aliasNameGenerator(db.reports.examId, db.exams.id),
  );

  $$ExamsTableProcessedTableManager get examId {
    final $_column = $_itemColumn<int>('exam_id')!;

    final manager = $$ExamsTableTableManager(
      $_db,
      $_db.exams,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_examIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReportsTableFilterComposer
    extends Composer<_$AppDatabase, $ReportsTable> {
  $$ReportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userEmail => $composableBuilder(
    column: $table.userEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get resolved => $composableBuilder(
    column: $table.resolved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ExamsTableFilterComposer get examId {
    final $$ExamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableFilterComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReportsTable> {
  $$ReportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userEmail => $composableBuilder(
    column: $table.userEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get resolved => $composableBuilder(
    column: $table.resolved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExamsTableOrderingComposer get examId {
    final $$ExamsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableOrderingComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReportsTable> {
  $$ReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userEmail =>
      $composableBuilder(column: $table.userEmail, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<bool> get resolved =>
      $composableBuilder(column: $table.resolved, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ExamsTableAnnotationComposer get examId {
    final $$ExamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableAnnotationComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReportsTable,
          Report,
          $$ReportsTableFilterComposer,
          $$ReportsTableOrderingComposer,
          $$ReportsTableAnnotationComposer,
          $$ReportsTableCreateCompanionBuilder,
          $$ReportsTableUpdateCompanionBuilder,
          (Report, $$ReportsTableReferences),
          Report,
          PrefetchHooks Function({bool examId})
        > {
  $$ReportsTableTableManager(_$AppDatabase db, $ReportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> examId = const Value.absent(),
                Value<String> userEmail = const Value.absent(),
                Value<String> comment = const Value.absent(),
                Value<bool> resolved = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ReportsCompanion(
                id: id,
                examId: examId,
                userEmail: userEmail,
                comment: comment,
                resolved: resolved,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int examId,
                required String userEmail,
                required String comment,
                Value<bool> resolved = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ReportsCompanion.insert(
                id: id,
                examId: examId,
                userEmail: userEmail,
                comment: comment,
                resolved: resolved,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReportsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({examId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (examId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.examId,
                                referencedTable: $$ReportsTableReferences
                                    ._examIdTable(db),
                                referencedColumn: $$ReportsTableReferences
                                    ._examIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReportsTable,
      Report,
      $$ReportsTableFilterComposer,
      $$ReportsTableOrderingComposer,
      $$ReportsTableAnnotationComposer,
      $$ReportsTableCreateCompanionBuilder,
      $$ReportsTableUpdateCompanionBuilder,
      (Report, $$ReportsTableReferences),
      Report,
      PrefetchHooks Function({bool examId})
    >;
typedef $$DailyGoalsTableCreateCompanionBuilder =
    DailyGoalsCompanion Function({
      Value<int> id,
      Value<int> minutesTarget,
      Value<bool> notify,
      Value<int> reminderHour,
      Value<int> reminderMinute,
      Value<DateTime?> examDate,
      Value<bool> active,
    });
typedef $$DailyGoalsTableUpdateCompanionBuilder =
    DailyGoalsCompanion Function({
      Value<int> id,
      Value<int> minutesTarget,
      Value<bool> notify,
      Value<int> reminderHour,
      Value<int> reminderMinute,
      Value<DateTime?> examDate,
      Value<bool> active,
    });

class $$DailyGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyGoalsTable> {
  $$DailyGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutesTarget => $composableBuilder(
    column: $table.minutesTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notify => $composableBuilder(
    column: $table.notify,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get examDate => $composableBuilder(
    column: $table.examDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyGoalsTable> {
  $$DailyGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutesTarget => $composableBuilder(
    column: $table.minutesTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notify => $composableBuilder(
    column: $table.notify,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get examDate => $composableBuilder(
    column: $table.examDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyGoalsTable> {
  $$DailyGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get minutesTarget => $composableBuilder(
    column: $table.minutesTarget,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notify =>
      $composableBuilder(column: $table.notify, builder: (column) => column);

  GeneratedColumn<int> get reminderHour => $composableBuilder(
    column: $table.reminderHour,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderMinute => $composableBuilder(
    column: $table.reminderMinute,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get examDate =>
      $composableBuilder(column: $table.examDate, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);
}

class $$DailyGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyGoalsTable,
          DailyGoal,
          $$DailyGoalsTableFilterComposer,
          $$DailyGoalsTableOrderingComposer,
          $$DailyGoalsTableAnnotationComposer,
          $$DailyGoalsTableCreateCompanionBuilder,
          $$DailyGoalsTableUpdateCompanionBuilder,
          (
            DailyGoal,
            BaseReferences<_$AppDatabase, $DailyGoalsTable, DailyGoal>,
          ),
          DailyGoal,
          PrefetchHooks Function()
        > {
  $$DailyGoalsTableTableManager(_$AppDatabase db, $DailyGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> minutesTarget = const Value.absent(),
                Value<bool> notify = const Value.absent(),
                Value<int> reminderHour = const Value.absent(),
                Value<int> reminderMinute = const Value.absent(),
                Value<DateTime?> examDate = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => DailyGoalsCompanion(
                id: id,
                minutesTarget: minutesTarget,
                notify: notify,
                reminderHour: reminderHour,
                reminderMinute: reminderMinute,
                examDate: examDate,
                active: active,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> minutesTarget = const Value.absent(),
                Value<bool> notify = const Value.absent(),
                Value<int> reminderHour = const Value.absent(),
                Value<int> reminderMinute = const Value.absent(),
                Value<DateTime?> examDate = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => DailyGoalsCompanion.insert(
                id: id,
                minutesTarget: minutesTarget,
                notify: notify,
                reminderHour: reminderHour,
                reminderMinute: reminderMinute,
                examDate: examDate,
                active: active,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyGoalsTable,
      DailyGoal,
      $$DailyGoalsTableFilterComposer,
      $$DailyGoalsTableOrderingComposer,
      $$DailyGoalsTableAnnotationComposer,
      $$DailyGoalsTableCreateCompanionBuilder,
      $$DailyGoalsTableUpdateCompanionBuilder,
      (DailyGoal, BaseReferences<_$AppDatabase, $DailyGoalsTable, DailyGoal>),
      DailyGoal,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      Value<String> value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$PaymentsTableCreateCompanionBuilder =
    PaymentsCompanion Function({
      Value<int> id,
      required String userEmail,
      required int amountMinor,
      required String currency,
      Value<String> stripePaymentIntentId,
      Value<String> status,
      Value<bool> refunded,
      Value<DateTime> createdAt,
    });
typedef $$PaymentsTableUpdateCompanionBuilder =
    PaymentsCompanion Function({
      Value<int> id,
      Value<String> userEmail,
      Value<int> amountMinor,
      Value<String> currency,
      Value<String> stripePaymentIntentId,
      Value<String> status,
      Value<bool> refunded,
      Value<DateTime> createdAt,
    });

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userEmail => $composableBuilder(
    column: $table.userEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stripePaymentIntentId => $composableBuilder(
    column: $table.stripePaymentIntentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get refunded => $composableBuilder(
    column: $table.refunded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userEmail => $composableBuilder(
    column: $table.userEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stripePaymentIntentId => $composableBuilder(
    column: $table.stripePaymentIntentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get refunded => $composableBuilder(
    column: $table.refunded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userEmail =>
      $composableBuilder(column: $table.userEmail, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get stripePaymentIntentId => $composableBuilder(
    column: $table.stripePaymentIntentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get refunded =>
      $composableBuilder(column: $table.refunded, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          Payment,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
          Payment,
          PrefetchHooks Function()
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userEmail = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> stripePaymentIntentId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> refunded = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                userEmail: userEmail,
                amountMinor: amountMinor,
                currency: currency,
                stripePaymentIntentId: stripePaymentIntentId,
                status: status,
                refunded: refunded,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userEmail,
                required int amountMinor,
                required String currency,
                Value<String> stripePaymentIntentId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> refunded = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                userEmail: userEmail,
                amountMinor: amountMinor,
                currency: currency,
                stripePaymentIntentId: stripePaymentIntentId,
                status: status,
                refunded: refunded,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      Payment,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (Payment, BaseReferences<_$AppDatabase, $PaymentsTable, Payment>),
      Payment,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$SubcategoriesTableTableManager get subcategories =>
      $$SubcategoriesTableTableManager(_db, _db.subcategories);
  $$ExamsTableTableManager get exams =>
      $$ExamsTableTableManager(_db, _db.exams);
  $$QuestionsTableTableManager get questions =>
      $$QuestionsTableTableManager(_db, _db.questions);
  $$ChoicesTableTableManager get choices =>
      $$ChoicesTableTableManager(_db, _db.choices);
  $$ExamQuestionsTableTableManager get examQuestions =>
      $$ExamQuestionsTableTableManager(_db, _db.examQuestions);
  $$ExamGradeBandsTableTableManager get examGradeBands =>
      $$ExamGradeBandsTableTableManager(_db, _db.examGradeBands);
  $$QuestionCategoriesTableTableManager get questionCategories =>
      $$QuestionCategoriesTableTableManager(_db, _db.questionCategories);
  $$QuestionSubcategoriesTableTableManager get questionSubcategories =>
      $$QuestionSubcategoriesTableTableManager(_db, _db.questionSubcategories);
  $$AttemptsTableTableManager get attempts =>
      $$AttemptsTableTableManager(_db, _db.attempts);
  $$AttemptAnswersTableTableManager get attemptAnswers =>
      $$AttemptAnswersTableTableManager(_db, _db.attemptAnswers);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$SavedQuestionsTableTableManager get savedQuestions =>
      $$SavedQuestionsTableTableManager(_db, _db.savedQuestions);
  $$ReportsTableTableManager get reports =>
      $$ReportsTableTableManager(_db, _db.reports);
  $$DailyGoalsTableTableManager get dailyGoals =>
      $$DailyGoalsTableTableManager(_db, _db.dailyGoals);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
}
