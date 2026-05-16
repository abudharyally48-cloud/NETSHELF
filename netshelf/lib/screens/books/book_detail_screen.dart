// screens/books/book_detail_screen.dart
// Book detail page with metadata, reading progress, notes, bookmarks, and open PDF

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/book.dart';
import '../../models/note.dart';
import '../../models/bookmark.dart';
import '../../providers/library_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../reader/pdf_reader_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Book _book;
  List<Note> _notes = [];
  List<Bookmark> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final library = context.read<LibraryProvider>();
    final notes = await library.getNotesForBook(_book.id);
    final bookmarks = await library.getBookmarksForBook(_book.id);
    if (mounted) {
      setState(() {
        _notes = notes;
        _bookmarks = bookmarks;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final colors = AppTheme.categoryGradients[_book.category] ??
        [AppTheme.primaryBlue, AppTheme.primaryPurple];

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 220,
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
            actions: [
              Consumer<LibraryProvider>(
                builder: (_, library, __) => GestureDetector(
                  onTap: () async {
                    await library.toggleFavorite(_book);
                    setState(() => _book = _book.copyWith(isFavorite: !_book.isFavorite));
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _book.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _book.isFavorite ? const Color(0xFFFF4081) : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
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
                    Positioned.fill(child: CustomPaint(painter: _GridPatternPainter())),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Book spine visual
                            Container(
                              width: 70,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              child: Icon(
                                _getCategoryIcon(_book.category),
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    _book.title,
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _book.author,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
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

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reading progress
                if (_book.totalPages > 0) _buildProgressSection(isDark),

                // Open PDF button
                _buildOpenButton(context),

                // Meta info chips
                _buildMetaChips(isDark),

                // Tab bar for Notes & Bookmarks
                _buildTabSection(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Reading Progress',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
                const Spacer(),
                Text(
                  'Page ${_book.lastReadPage} of ${_book.totalPages}',
                  style: GoogleFonts.spaceMono(
                    fontSize: 12,
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _book.readingProgress,
                minHeight: 6,
                backgroundColor: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                valueColor: const AlwaysStoppedAnimation(AppTheme.primaryBlue),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(_book.readingProgress * 100).toInt()}% completed',
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.primaryBlue),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildOpenButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () => _openPdfReader(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full)),
            ),
            icon: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
            label: Text(
              _book.lastReadPage > 0 ? 'Continue Reading' : 'Open Book',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ).animate(delay: 100.ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
    );
  }

  Widget _buildMetaChips(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _MetaChip(
            icon: Icons.calendar_today_rounded,
            label: DateFormat('MMM d, yyyy').format(_book.dateAdded),
            isDark: isDark,
          ),
          if (_book.subCategory != null)
            _MetaChip(
              icon: Icons.code_rounded,
              label: _book.subCategory!.replaceAll('cat_lang_', '').capitalize(),
              isDark: isDark,
              color: AppTheme.primaryPurple,
            ),
          if (_book.lastOpenedAt != null)
            _MetaChip(
              icon: Icons.history_rounded,
              label: 'Last: ${DateFormat('MMM d').format(_book.lastOpenedAt!)}',
              isDark: isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildTabSection(bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _TabButton(
                  label: 'Notes',
                  icon: Icons.notes_rounded,
                  count: _notes.length,
                  isSelected: _tabController.index == 0,
                  onTap: () => setState(() => _tabController.animateTo(0)),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TabButton(
                  label: 'Bookmarks',
                  icon: Icons.bookmark_rounded,
                  count: _bookmarks.length,
                  isSelected: _tabController.index == 1,
                  onTap: () => setState(() => _tabController.animateTo(1)),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _tabController.index == 0
              ? _buildNotesTab(isDark)
              : _buildBookmarksTab(isDark),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildNotesTab(bool isDark) {
    return Column(
      key: const ValueKey('notes'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'My Notes',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkText : AppTheme.lightText,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showAddNoteDialog(isDark),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add Note'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.primaryBlue),
              ),
            ],
          ),
        ),
        if (_notes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: EmptyState(
              icon: Icons.notes_rounded,
              title: 'No Notes Yet',
              message: 'Add notes while reading to capture key insights.',
            ),
          )
        else
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final note = _notes[index];
              return _NoteCard(
                note: note,
                isDark: isDark,
                onDelete: () => _deleteNote(note),
              );
            },
          ),
      ],
    );
  }

  Widget _buildBookmarksTab(bool isDark) {
    return Column(
      key: const ValueKey('bookmarks'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Bookmarks',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_bookmarks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'No Bookmarks',
              message: 'Bookmark pages in the reader for quick access.',
            ),
          )
        else
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _bookmarks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final bookmark = _bookmarks[index];
              return _BookmarkTile(
                bookmark: bookmark,
                isDark: isDark,
                onTap: () => _openPdfReader(context, page: bookmark.pageNumber),
                onDelete: () async {
                  await context.read<LibraryProvider>().deleteBookmark(bookmark.id);
                  _loadData();
                },
              );
            },
          ),
      ],
    );
  }

  void _openPdfReader(BuildContext context, {int? page}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfReaderScreen(
          book: _book,
          initialPage: page ?? _book.lastReadPage,
        ),
      ),
    ).then((_) {
      _loadData();
      // Refresh book data
      context.read<LibraryProvider>().getBooksByCategory(_book.category);
    });
  }

  void _showAddNoteDialog(bool isDark) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Note',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Write your note here...',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (controller.text.trim().isNotEmpty) {
                      final note = Note(
                        id: const Uuid().v4(),
                        bookId: _book.id,
                        content: controller.text.trim(),
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      await context.read<LibraryProvider>().addNote(note);
                      Navigator.pop(ctx);
                      _loadData();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full)),
                  ),
                  child: const Text('Save Note'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteNote(Note note) async {
    await context.read<LibraryProvider>().deleteNote(note.id);
    _loadData();
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'cat_networking': Icons.wifi_rounded,
      'cat_ccna': Icons.router_rounded,
      'cat_cybersecurity': Icons.security_rounded,
      'cat_linux': Icons.terminal_rounded,
      'cat_databases': Icons.storage_rounded,
      'cat_programming': Icons.code_rounded,
    };
    return icons[category] ?? Icons.menu_book_rounded;
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, required this.isDark, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: c),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: c, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _TabButton({
    required this.label, required this.icon, required this.count,
    required this.isSelected, required this.onTap, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withOpacity(0.1)
              : isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue.withOpacity(0.4) : AppTheme.darkBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16,
                color: isSelected ? AppTheme.primaryBlue : AppTheme.darkTextSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.primaryBlue : AppTheme.darkTextSecondary,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryBlue : AppTheme.darkTextSecondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.inter(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final bool isDark;
  final VoidCallback onDelete;

  const _NoteCard({required this.note, required this.isDark, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.notes_rounded, size: 14, color: AppTheme.primaryPurple),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('MMM d, yyyy').format(note.createdAt),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note.content,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookmarkTile extends StatelessWidget {
  final Bookmark bookmark;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BookmarkTile({required this.bookmark, required this.isDark, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppTheme.accentCyan.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.bookmark_rounded, color: AppTheme.accentCyan, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bookmark.label ?? 'Page ${bookmark.pageNumber}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.darkText : AppTheme.lightText,
                    ),
                  ),
                  Text(
                    'Page ${bookmark.pageNumber}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.accentCyan,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.darkTextSecondary),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.close_rounded, size: 18, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension StringCapitalize on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
