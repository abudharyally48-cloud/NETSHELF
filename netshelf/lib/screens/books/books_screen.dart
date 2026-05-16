// screens/books/books_screen.dart
// Full library screen with list/grid toggle and sorting

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        actions: [
          // Sort button
          PopupMenuButton<SortOrder>(
            icon: const Icon(Icons.sort_rounded),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (order) => context.read<LibraryProvider>().setSortOrder(order),
            itemBuilder: (_) => [
              _sortItem(SortOrder.dateAdded, Icons.calendar_today_rounded, 'Date Added'),
              _sortItem(SortOrder.title, Icons.sort_by_alpha_rounded, 'Title'),
              _sortItem(SortOrder.author, Icons.person_outline_rounded, 'Author'),
              _sortItem(SortOrder.lastOpened, Icons.history_rounded, 'Last Opened'),
            ],
          ),
          // View toggle
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<LibraryProvider>(
        builder: (context, library, _) {
          final books = library.allBooks;

          if (library.isLoading) {
            return _isGridView ? _buildGridShimmer() : _buildListShimmer();
          }

          if (books.isEmpty) {
            return EmptyState(
              icon: Icons.menu_book_rounded,
              title: 'Your Library is Empty',
              message: 'Add PDF books to start building your personal tech library.',
              actionLabel: 'Add First Book',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddBookScreen()),
              ).then((_) => library.refreshAll()),
            );
          }

          return _isGridView
              ? _buildGridView(context, library, books)
              : _buildListView(context, library, books);
        },
      ),
    );
  }

  Widget _buildGridView(BuildContext context, LibraryProvider library, books) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookCard(
          book: book,
          onTap: () => _openBook(context, book),
          onLongPress: () => _showBookOptions(context, book, library),
        ).animate(delay: Duration(milliseconds: index * 40))
            .fadeIn(duration: 300.ms)
            .scale(begin: const Offset(0.9, 0.9));
      },
    );
  }

  Widget _buildListView(BuildContext context, LibraryProvider library, books) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: books.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final book = books[index];
        return BookListTile(
          book: book,
          onTap: () => _openBook(context, book),
          onFavoriteTap: () => library.toggleFavorite(book),
          onDeleteTap: () => library.deleteBook(book.id),
        ).animate(delay: Duration(milliseconds: index * 40))
            .fadeIn(duration: 300.ms)
            .slideX(begin: -0.1, end: 0);
      },
    );
  }

  Widget _buildGridShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const ShimmerBookCard(),
    );
  }

  Widget _buildListShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Container(
        height: 88,
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms),
    );
  }

  PopupMenuItem<SortOrder> _sortItem(SortOrder order, IconData icon, String label) {
    return PopupMenuItem(
      value: order,
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  void _openBook(BuildContext context, book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
    ).then((_) => context.read<LibraryProvider>().refreshAll());
  }

  void _showBookOptions(BuildContext context, book, LibraryProvider library) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _BookOptionsSheet(book: book, library: library),
    );
  }
}

class _BookOptionsSheet extends StatelessWidget {
  final book;
  final LibraryProvider library;

  const _BookOptionsSheet({required this.book, required this.library});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: Icon(
              book.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: book.isFavorite ? const Color(0xFFFF4081) : null,
            ),
            title: Text(book.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
            onTap: () {
              Navigator.pop(context);
              library.toggleFavorite(book);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('Book Details'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            title: const Text('Delete Book', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              library.deleteBook(book.id);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
