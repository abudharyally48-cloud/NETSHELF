// screens/categories/categories_screen.dart
// Categories browsing with programming language subcategories and custom tag creation

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../models/category.dart';
import '../../providers/library_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../books/book_detail_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Consumer<LibraryProvider>(
        builder: (context, library, _) {
          final categories = library.topLevelCategories;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final count = library.getBookCountForCategory(cat.id);
              return CategoryCard(
                category: cat,
                bookCount: count,
                animationIndex: index,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CategoryBooksScreen(category: cat),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─── Category Books Screen ────────────────────────────────────────────────────

class CategoryBooksScreen extends StatefulWidget {
  final AppCategory category;

  const CategoryBooksScreen({super.key, required this.category});

  @override
  State<CategoryBooksScreen> createState() => _CategoryBooksScreenState();
}

class _CategoryBooksScreenState extends State<CategoryBooksScreen> {
  List<Book> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    final books = await context.read<LibraryProvider>().getBooksByCategory(widget.category.id);
    if (mounted) setState(() { _books = books; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final colors = AppTheme.categoryGradients[widget.category.id] ??
        [widget.category.color, widget.category.color.withOpacity(0.7)];
    final isProgramming = widget.category.id == DefaultCategories.programmingLanguagesId;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Colored app bar
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: colors.first,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(child: CustomPaint(painter: _GridPainter())),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(widget.category.icon, color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.category.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${_books.length} books',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Sub-categories for Programming Languages
          if (isProgramming)
            SliverToBoxAdapter(
              child: _ProgrammingSubCategories(
                onSubCategorySelected: (subCatId) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubCategoryBooksScreen(subCategoryId: subCatId),
                  ),
                ),
              ),
            ),

          // Book list
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
            )
          else if (_books.isEmpty)
            SliverFillRemaining(
              child: EmptyState(
                icon: widget.category.icon,
                title: 'No Books Yet',
                message: 'Add books in the "${widget.category.name}" category to see them here.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final book = _books[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: BookListTile(
                        book: book,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
                        ).then((_) => _loadBooks()),
                        onFavoriteTap: () async {
                          await context.read<LibraryProvider>().toggleFavorite(book);
                          _loadBooks();
                        },
                        onDeleteTap: () async {
                          await context.read<LibraryProvider>().deleteBook(book.id);
                          _loadBooks();
                        },
                      )
                          .animate(delay: Duration(milliseconds: index * 50))
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.1, end: 0),
                    );
                  },
                  childCount: _books.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ─── Programming Language Sub-categories Row ─────────────────────────────────

class _ProgrammingSubCategories extends StatelessWidget {
  final void Function(String) onSubCategorySelected;

  const _ProgrammingSubCategories({required this.onSubCategorySelected});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final library = context.watch<LibraryProvider>();
    final subCats = library.programmingSubCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              SectionHeader(title: 'Languages'),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showAddLanguageDialog(context),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.primaryBlue),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: subCats.length,
            itemBuilder: (context, index) {
              final cat = subCats[index];
              return GestureDetector(
                onTap: () => onSubCategorySelected(cat.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: cat.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: cat.color.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat.icon, size: 16, color: cat.color),
                      const SizedBox(width: 6),
                      Text(
                        cat.name,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: cat.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: Duration(milliseconds: index * 40))
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: 0.1, end: 0);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
          child: SectionHeader(title: 'All Programming Books'),
        ),
      ],
    );
  }

  void _showAddLanguageDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Programming Language'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'e.g. Ruby, Scala, Elixir...',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await context.read<LibraryProvider>().addCustomProgrammingLanguage(
                      name,
                      Icons.code.codePoint,
                      AppTheme.primaryPurple.value,
                    );
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-Category Books Screen ────────────────────────────────────────────────

class SubCategoryBooksScreen extends StatefulWidget {
  final String subCategoryId;

  const SubCategoryBooksScreen({super.key, required this.subCategoryId});

  @override
  State<SubCategoryBooksScreen> createState() => _SubCategoryBooksScreenState();
}

class _SubCategoryBooksScreenState extends State<SubCategoryBooksScreen> {
  List<Book> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final books = await context.read<LibraryProvider>().getBooksBySubCategory(widget.subCategoryId);
    if (mounted) setState(() { _books = books; _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final library = context.read<LibraryProvider>();
    final cat = library.getCategoryById(widget.subCategoryId);
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(cat?.name ?? 'Books'),
        leading: const BackButton(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : _books.isEmpty
              ? EmptyState(
                  icon: Icons.code_rounded,
                  title: 'No Books',
                  message: 'No books found for ${cat?.name ?? 'this language'}.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _books.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final book = _books[index];
                    return BookListTile(
                      book: book,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
                      ).then((_) => _load()),
                      onFavoriteTap: () async {
                        await context.read<LibraryProvider>().toggleFavorite(book);
                        _load();
                      },
                      onDeleteTap: () async {
                        await context.read<LibraryProvider>().deleteBook(book.id);
                        _load();
                      },
                    );
                  },
                ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    const s = 24.0;
    for (double x = 0; x < size.width; x += s) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += s) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
