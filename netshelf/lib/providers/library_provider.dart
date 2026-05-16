// providers/library_provider.dart
// Central state management using Provider pattern for the entire app

import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/note.dart';
import '../models/bookmark.dart';
import '../models/category.dart';
import '../database/database_helper.dart';

enum SortOrder { dateAdded, title, author, lastOpened }

class LibraryProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  // ─── State ────────────────────────────────────────────────────────────────
  List<Book> _allBooks = [];
  List<Book> _recentBooks = [];
  List<Book> _favoriteBooks = [];
  List<Book> _searchResults = [];
  List<AppCategory> _categories = [];
  Map<String, int> _bookCountByCategory = {};

  bool _isLoading = false;
  bool _isSearching = false;
  String _searchQuery = '';
  SortOrder _sortOrder = SortOrder.dateAdded;
  String? _selectedCategory;

  // ─── Getters ──────────────────────────────────────────────────────────────
  List<Book> get allBooks => _sortBooks(_allBooks);
  List<Book> get recentBooks => _recentBooks;
  List<Book> get favoriteBooks => _favoriteBooks;
  List<Book> get searchResults => _searchResults;
  List<AppCategory> get categories => _categories;
  List<AppCategory> get topLevelCategories =>
      _categories.where((c) => c.parentId == null).toList();
  List<AppCategory> get programmingSubCategories =>
      _categories.where((c) => c.parentId == DefaultCategories.programmingLanguagesId).toList();

  Map<String, int> get bookCountByCategory => _bookCountByCategory;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;
  SortOrder get sortOrder => _sortOrder;
  String? get selectedCategory => _selectedCategory;
  int get totalBooks => _allBooks.length;

  // ─── Init ─────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    _setLoading(true);
    await Future.wait([
      _loadBooks(),
      _loadRecentBooks(),
      _loadFavoriteBooks(),
      _loadCategories(),
      _loadBookCountByCategory(),
    ]);
    _setLoading(false);
  }

  // ─── Books ────────────────────────────────────────────────────────────────

  Future<void> _loadBooks() async {
    _allBooks = await _db.getAllBooks();
    notifyListeners();
  }

  Future<void> _loadRecentBooks() async {
    _recentBooks = await _db.getRecentBooks(limit: 6);
    notifyListeners();
  }

  Future<void> _loadFavoriteBooks() async {
    _favoriteBooks = await _db.getFavoriteBooks();
    notifyListeners();
  }

  Future<void> _loadCategories() async {
    _categories = await _db.getAllCategories();
    notifyListeners();
  }

  Future<void> _loadBookCountByCategory() async {
    _bookCountByCategory = await _db.getBookCountByCategory();
    notifyListeners();
  }

  Future<List<Book>> getBooksByCategory(String categoryId) async {
    return await _db.getBooksByCategory(categoryId);
  }

  Future<List<Book>> getBooksBySubCategory(String subCategory) async {
    return await _db.getBooksBySubCategory(subCategory);
  }

  /// Add a new book to the library
  Future<void> addBook(Book book) async {
    await _db.insertBook(book);
    await initialize(); // Refresh all state
  }

  /// Remove a book from the library
  Future<void> deleteBook(String bookId) async {
    await _db.deleteBook(bookId);
    _allBooks.removeWhere((b) => b.id == bookId);
    _recentBooks.removeWhere((b) => b.id == bookId);
    _favoriteBooks.removeWhere((b) => b.id == bookId);
    _bookCountByCategory = await _db.getBookCountByCategory();
    notifyListeners();
  }

  /// Toggle favorite status for a book
  Future<void> toggleFavorite(Book book) async {
    book.isFavorite = !book.isFavorite;
    await _db.toggleFavorite(book.id, book.isFavorite);
    await _loadFavoriteBooks();
    notifyListeners();
  }

  /// Update reading progress after closing the reader
  Future<void> updateReadingProgress(String bookId, int currentPage, int totalPages) async {
    await _db.updateReadingProgress(bookId, currentPage, totalPages);
    final idx = _allBooks.indexWhere((b) => b.id == bookId);
    if (idx != -1) {
      _allBooks[idx] = _allBooks[idx].copyWith(
        lastReadPage: currentPage,
        totalPages: totalPages,
        lastOpenedAt: DateTime.now(),
      );
    }
    await _loadRecentBooks();
    notifyListeners();
  }

  /// Update book metadata
  Future<void> updateBook(Book book) async {
    await _db.updateBook(book);
    final idx = _allBooks.indexWhere((b) => b.id == book.id);
    if (idx != -1) _allBooks[idx] = book;
    notifyListeners();
  }

  // ─── Search ───────────────────────────────────────────────────────────────

  Future<void> search(String query) async {
    _searchQuery = query;
    if (query.trim().isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }
    _isSearching = true;
    notifyListeners();
    _searchResults = await _db.searchBooks(query);
    _isSearching = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }

  // ─── Notes ────────────────────────────────────────────────────────────────

  Future<List<Note>> getNotesForBook(String bookId) async {
    return await _db.getNotesByBook(bookId);
  }

  Future<void> addNote(Note note) async {
    await _db.insertNote(note);
    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    await _db.updateNote(note);
    notifyListeners();
  }

  Future<void> deleteNote(String noteId) async {
    await _db.deleteNote(noteId);
    notifyListeners();
  }

  // ─── Bookmarks ────────────────────────────────────────────────────────────

  Future<List<Bookmark>> getBookmarksForBook(String bookId) async {
    return await _db.getBookmarksByBook(bookId);
  }

  Future<void> addBookmark(Bookmark bookmark) async {
    await _db.insertBookmark(bookmark);
    notifyListeners();
  }

  Future<void> deleteBookmark(String bookmarkId) async {
    await _db.deleteBookmark(bookmarkId);
    notifyListeners();
  }

  // ─── Categories ───────────────────────────────────────────────────────────

  Future<void> addCustomProgrammingLanguage(String name, int iconCode, int colorValue) async {
    final category = AppCategory(
      id: 'cat_lang_custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      parentId: DefaultCategories.programmingLanguagesId,
      icon: const IconData(0xe25a), // code icon
      color: Color(colorValue),
      isCustom: true,
    );
    await _db.insertCategory(category);
    await _loadCategories();
  }

  Future<void> deleteCustomCategory(String categoryId) async {
    await _db.deleteCategory(categoryId);
    await _loadCategories();
  }

  // ─── Sorting ──────────────────────────────────────────────────────────────

  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  List<Book> _sortBooks(List<Book> books) {
    final sorted = List<Book>.from(books);
    switch (_sortOrder) {
      case SortOrder.title:
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOrder.author:
        sorted.sort((a, b) => a.author.compareTo(b.author));
        break;
      case SortOrder.lastOpened:
        sorted.sort((a, b) {
          if (a.lastOpenedAt == null && b.lastOpenedAt == null) return 0;
          if (a.lastOpenedAt == null) return 1;
          if (b.lastOpenedAt == null) return -1;
          return b.lastOpenedAt!.compareTo(a.lastOpenedAt!);
        });
        break;
      case SortOrder.dateAdded:
      default:
        sorted.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
    }
    return sorted;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  AppCategory? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  int getBookCountForCategory(String categoryId) {
    return _bookCountByCategory[categoryId] ?? 0;
  }

  void refreshAll() => initialize();
}
