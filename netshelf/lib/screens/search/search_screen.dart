// screens/search/search_screen.dart
// Full-text search across books

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../books/book_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    context.read<LibraryProvider>().clearSearch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: (q) => context.read<LibraryProvider>().search(q),
          style: GoogleFonts.inter(
            fontSize: 15,
            color: isDark ? AppTheme.darkText : AppTheme.lightText,
          ),
          decoration: InputDecoration(
            hintText: 'Search title, author, category...',
            border: InputBorder.none,
            filled: false,
            hintStyle: GoogleFonts.inter(
              color: isDark ? AppTheme.darkTextMuted : const Color(0xFFADB5C8),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<LibraryProvider>(
            builder: (_, lib, __) => lib.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _controller.clear();
                      lib.clearSearch();
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Consumer<LibraryProvider>(
        builder: (context, library, _) {
          if (library.searchQuery.isEmpty) {
            return _buildSearchHint(isDark);
          }

          if (library.isSearching) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBlue),
            );
          }

          if (library.searchResults.isEmpty) {
            return EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No Results',
              message: 'No books found for "${library.searchQuery}".\nTry a different search term.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            itemCount: library.searchResults.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final book = library.searchResults[index];
              return BookListTile(
                book: book,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
                ),
                onFavoriteTap: () => library.toggleFavorite(book),
                onDeleteTap: () => library.deleteBook(book.id),
              ).animate(delay: Duration(milliseconds: index * 40))
                  .fadeIn(duration: 250.ms)
                  .slideY(begin: 0.1, end: 0);
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchHint(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.1),
                  AppTheme.primaryPurple.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_rounded, size: 40, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 20),
          Text(
            'Search Your Library',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search by title, author, or category',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
