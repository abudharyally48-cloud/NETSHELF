// screens/home/home_content.dart
// Dashboard home with stats, recent books, and category overview

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../providers/library_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../books/book_detail_screen.dart';
import '../books/books_screen.dart';
import '../categories/categories_screen.dart';
import '../search/search_screen.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Consumer<LibraryProvider>(
          builder: (context, library, _) {
            if (library.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                _buildSearchBar(context),
                _buildStatsRow(context, library),
                _buildRecentBooks(context, library),
                _buildCategoriesPreview(context, library),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final now = DateTime.now();
    final greeting = now.hour < 12 ? 'Good morning' : now.hour < 17 ? 'Good afternoon' : 'Good evening';

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    ),
                  ),
                  Text(
                    'NetShelf',
                    style: GoogleFonts.spaceMono(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.darkText : AppTheme.lightText,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            // Logo icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 22),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded,
                    size: 20,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                const SizedBox(width: 10),
                Text(
                  'Search books, authors, categories...',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isDark ? AppTheme.darkTextMuted : const Color(0xFFADB5C8),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                  ),
                  child: Text(
                    '⌘K',
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildStatsRow(BuildContext context, LibraryProvider library) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Row(
          children: [
            Expanded(
              child: StatCard(
                value: '${library.totalBooks}',
                label: 'Total Books',
                icon: Icons.menu_book_rounded,
                color: AppTheme.primaryBlue,
              ).animate(delay: 150.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                value: '${library.favoriteBooks.length}',
                label: 'Favorites',
                icon: Icons.favorite_rounded,
                color: const Color(0xFFFF4081),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                value: '${library.recentBooks.length}',
                label: 'In Progress',
                icon: Icons.auto_stories_rounded,
                color: AppTheme.accentGreen,
              ).animate(delay: 250.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBooks(BuildContext context, LibraryProvider library) {
    final recent = library.recentBooks;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          SectionHeader(
            title: 'Continue Reading',
            actionLabel: 'See all',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BooksScreen()),
            ),
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 16),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: EmptyState(
                icon: Icons.auto_stories_rounded,
                title: 'No Recent Books',
                message: 'Start reading a book and it will appear here.',
              ),
            )
          else
            SizedBox(
              height: 230,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: recent.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final book = recent[index];
                  return SizedBox(
                    width: 145,
                    child: BookCard(
                      book: book,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookDetailScreen(book: book),
                        ),
                      ),
                    ).animate(delay: Duration(milliseconds: 350 + index * 60))
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: 0.2, end: 0),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoriesPreview(BuildContext context, LibraryProvider library) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final categories = library.topLevelCategories;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          SectionHeader(
            title: 'Browse Categories',
            actionLabel: 'All',
            onAction: () {
              // Switch to categories tab - handled via HomeScreen
            },
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 16),
          GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final count = library.getBookCountForCategory(category.id);

              return CategoryCard(
                category: category,
                bookCount: count,
                animationIndex: index,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryBooksScreen(category: category),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
