// models/bookmark.dart
// Data model for PDF page bookmarks

class Bookmark {
  final String id;
  final String bookId;
  final int pageNumber;
  final String? label;
  final DateTime createdAt;

  Bookmark({
    required this.id,
    required this.bookId,
    required this.pageNumber,
    this.label,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'page_number': pageNumber,
      'label': label,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Bookmark.fromMap(Map<String, dynamic> map) {
    return Bookmark(
      id: map['id'] as String,
      bookId: map['book_id'] as String,
      pageNumber: map['page_number'] as int,
      label: map['label'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
