// models/book.dart
// Core data model representing a book in the library

class Book {
  final String id;
  final String title;
  final String author;
  final String category;
  final String? subCategory; // For programming languages
  final String filePath;
  final DateTime dateAdded;
  bool isFavorite;
  int lastReadPage;
  int totalPages;
  DateTime? lastOpenedAt;
  String? coverImagePath;
  List<String> tags;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    this.subCategory,
    required this.filePath,
    required this.dateAdded,
    this.isFavorite = false,
    this.lastReadPage = 0,
    this.totalPages = 0,
    this.lastOpenedAt,
    this.coverImagePath,
    List<String>? tags,
  }) : tags = tags ?? [];

  /// Reading progress percentage (0.0 - 1.0)
  double get readingProgress {
    if (totalPages == 0) return 0.0;
    return (lastReadPage / totalPages).clamp(0.0, 1.0);
  }

  /// Convert Book to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'category': category,
      'sub_category': subCategory,
      'file_path': filePath,
      'date_added': dateAdded.toIso8601String(),
      'is_favorite': isFavorite ? 1 : 0,
      'last_read_page': lastReadPage,
      'total_pages': totalPages,
      'last_opened_at': lastOpenedAt?.toIso8601String(),
      'cover_image_path': coverImagePath,
      'tags': tags.join(','),
    };
  }

  /// Create Book from SQLite Map
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as String,
      title: map['title'] as String,
      author: map['author'] as String? ?? 'Unknown Author',
      category: map['category'] as String,
      subCategory: map['sub_category'] as String?,
      filePath: map['file_path'] as String,
      dateAdded: DateTime.parse(map['date_added'] as String),
      isFavorite: (map['is_favorite'] as int) == 1,
      lastReadPage: map['last_read_page'] as int? ?? 0,
      totalPages: map['total_pages'] as int? ?? 0,
      lastOpenedAt: map['last_opened_at'] != null
          ? DateTime.parse(map['last_opened_at'] as String)
          : null,
      coverImagePath: map['cover_image_path'] as String?,
      tags: map['tags'] != null && (map['tags'] as String).isNotEmpty
          ? (map['tags'] as String).split(',')
          : [],
    );
  }

  /// Create a copy of Book with updated fields
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? category,
    String? subCategory,
    String? filePath,
    DateTime? dateAdded,
    bool? isFavorite,
    int? lastReadPage,
    int? totalPages,
    DateTime? lastOpenedAt,
    String? coverImagePath,
    List<String>? tags,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      filePath: filePath ?? this.filePath,
      dateAdded: dateAdded ?? this.dateAdded,
      isFavorite: isFavorite ?? this.isFavorite,
      lastReadPage: lastReadPage ?? this.lastReadPage,
      totalPages: totalPages ?? this.totalPages,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      tags: tags ?? List.from(this.tags),
    );
  }

  @override
  String toString() => 'Book(id: $id, title: $title, category: $category)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Book && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
