// screens/favorites/favorites_screen.dart
// Displays all favorited books

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../books/add_book_screen.dart';
import '../books/book_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(Icons.favorite_rounded, color: const Color(0xFFFF4081), size: 22),
          ),
        ],
      ),
      body: Consumer<LibraryProvider>(
        builder: (context, library, _) {
          final favorites = library.favoriteBooks;

          if (library.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue));
          }

          if (favorites.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'No Favorites Yet',
              message: 'Mark books as favorites to quickly access them here.',
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.65,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final book = favorites[index];
              return BookCard(
                book: book,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
                ).then((_) => library.refreshAll()),
                onLongPress: () {
                  library.toggleFavorite(book);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Removed from favorites'),
                      backgroundColor: AppTheme.darkCard,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
              ).animate(delay: Duration(milliseconds: index * 60))
                  .fadeIn(duration: 300.ms)
                  .scale(begin: const Offset(0.9, 0.9));
            },
          );
        },
      ),
    );
  }
}
