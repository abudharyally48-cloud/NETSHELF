// database/database_helper.dart
// SQLite database setup and CRUD operations for NetShelf

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';
import '../models/note.dart';
import '../models/bookmark.dart';
import '../models/category.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  static const String _dbName = 'netshelf.db';
  static const int _dbVersion = 1;

  // Table names
  static const String tableBooks = 'books';
  static const String tableNotes = 'notes';
  static const String tableBookmarks = 'bookmarks';
  static const String tableCategories = 'categories';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create all tables on first launch
  Future<void> _onCreate(Database db, int version) async {
    // Books table
    await db.execute('''
      CREATE TABLE $tableBooks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT,
        category TEXT NOT NULL,
        sub_category TEXT,
        file_path TEXT NOT NULL,
        date_added TEXT NOT NULL,
        is_favorite INTEGER DEFAULT 0,
        last_read_page INTEGER DEFAULT 0,
        total_pages INTEGER DEFAULT 0,
        last_opened_at TEXT,
        cover_image_path TEXT,
        tags TEXT DEFAULT ''
      )
    ''');

    // Notes table
    await db.execute('''
      CREATE TABLE $tableNotes (
        id TEXT PRIMARY KEY,
        book_id TEXT NOT NULL,
        content TEXT NOT NULL,
        page_number INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (book_id) REFERENCES $tableBooks (id) ON DELETE CASCADE
      )
    ''');

    // Bookmarks table
    await db.execute('''
      CREATE TABLE $tableBookmarks (
        id TEXT PRIMARY KEY,
        book_id TEXT NOT NULL,
        page_number INTEGER NOT NULL,
        label TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (book_id) REFERENCES $tableBooks (id) ON DELETE CASCADE
      )
    ''');

    // Custom categories table
    await db.execute('''
      CREATE TABLE $tableCategories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        parent_id TEXT,
        icon_code INTEGER NOT NULL,
        icon_font_family TEXT,
        color_value INTEGER NOT NULL,
        is_custom INTEGER DEFAULT 1
      )
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future migrations here
  }

  /// Seed default categories into database
  Future<void> _insertDefaultCategories(Database db) async {
    final batch = db.batch();
    for (final category in DefaultCategories.all) {
      batch.insert(tableCategories, category.toMap());
    }
    await batch.commit(noResult: true);
  }

  // ─── BOOK CRUD ────────────────────────────────────────────────────────────

  Future<int> insertBook(Book book) async {
    final db = await database;
    return await db.insert(
      tableBooks,
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Book>> getAllBooks() async {
    final db = await database;
    final maps = await db.query(tableBooks, orderBy: 'date_added DESC');
    return maps.map((m) => Book.fromMap(m)).toList();
  }

  Future<List<Book>> getBooksByCategory(String category) async {
    final db = await database;
    final maps = await db.query(
      tableBooks,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date_added DESC',
    );
    return maps.map((m) => Book.fromMap(m)).toList();
  }

  Future<List<Book>> getBooksBySubCategory(String subCategory) async {
    final db = await database;
    final maps = await db.query(
      tableBooks,
      where: 'sub_category = ?',
      whereArgs: [subCategory],
      orderBy: 'date_added DESC',
    );
    return maps.map((m) => Book.fromMap(m)).toList();
  }

  Future<List<Book>> getFavoriteBooks() async {
    final db = await database;
    final maps = await db.query(
      tableBooks,
      where: 'is_favorite = 1',
      orderBy: 'date_added DESC',
    );
    return maps.map((m) => Book.fromMap(m)).toList();
  }

  Future<List<Book>> getRecentBooks({int limit = 6}) async {
    final db = await database;
    final maps = await db.query(
      tableBooks,
      where: 'last_opened_at IS NOT NULL',
      orderBy: 'last_opened_at DESC',
      limit: limit,
    );
    return maps.map((m) => Book.fromMap(m)).toList();
  }

  Future<List<Book>> searchBooks(String query) async {
    final db = await database;
    final q = '%${query.toLowerCase()}%';
    final maps = await db.query(
      tableBooks,
      where: 'LOWER(title) LIKE ? OR LOWER(author) LIKE ? OR LOWER(category) LIKE ? OR LOWER(sub_category) LIKE ? OR LOWER(tags) LIKE ?',
      whereArgs: [q, q, q, q, q],
      orderBy: 'date_added DESC',
    );
    return maps.map((m) => Book.fromMap(m)).toList();
  }

  Future<Book?> getBookById(String id) async {
    final db = await database;
    final maps = await db.query(tableBooks, where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Book.fromMap(maps.first);
  }

  Future<int> updateBook(Book book) async {
    final db = await database;
    return await db.update(
      tableBooks,
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future<int> updateReadingProgress(String bookId, int lastPage, int totalPages) async {
    final db = await database;
    return await db.update(
      tableBooks,
      {
        'last_read_page': lastPage,
        'total_pages': totalPages,
        'last_opened_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  Future<int> toggleFavorite(String bookId, bool isFavorite) async {
    final db = await database;
    return await db.update(
      tableBooks,
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  Future<int> deleteBook(String bookId) async {
    final db = await database;
    return await db.delete(tableBooks, where: 'id = ?', whereArgs: [bookId]);
  }

  // ─── NOTES CRUD ───────────────────────────────────────────────────────────

  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert(tableNotes, note.toMap());
  }

  Future<List<Note>> getNotesByBook(String bookId) async {
    final db = await database;
    final maps = await db.query(
      tableNotes,
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      tableNotes,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(String noteId) async {
    final db = await database;
    return await db.delete(tableNotes, where: 'id = ?', whereArgs: [noteId]);
  }

  // ─── BOOKMARKS CRUD ───────────────────────────────────────────────────────

  Future<int> insertBookmark(Bookmark bookmark) async {
    final db = await database;
    return await db.insert(tableBookmarks, bookmark.toMap());
  }

  Future<List<Bookmark>> getBookmarksByBook(String bookId) async {
    final db = await database;
    final maps = await db.query(
      tableBookmarks,
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'page_number ASC',
    );
    return maps.map((m) => Bookmark.fromMap(m)).toList();
  }

  Future<int> deleteBookmark(String bookmarkId) async {
    final db = await database;
    return await db.delete(tableBookmarks, where: 'id = ?', whereArgs: [bookmarkId]);
  }

  // ─── CATEGORY CRUD ────────────────────────────────────────────────────────

  Future<List<AppCategory>> getAllCategories() async {
    final db = await database;
    final maps = await db.query(tableCategories);
    return maps.map((m) => AppCategory.fromMap(m)).toList();
  }

  Future<int> insertCategory(AppCategory category) async {
    final db = await database;
    return await db.insert(
      tableCategories,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> deleteCategory(String categoryId) async {
    final db = await database;
    return await db.delete(tableCategories, where: 'id = ?', whereArgs: [categoryId]);
  }

  /// Get total book count
  Future<int> getBookCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $tableBooks');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get book count by category
  Future<Map<String, int>> getBookCountByCategory() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT category, COUNT(*) as count FROM $tableBooks GROUP BY category',
    );
    final map = <String, int>{};
    for (final row in result) {
      map[row['category'] as String] = row['count'] as int;
    }
    return map;
  }

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
