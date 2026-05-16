// screens/reader/pdf_reader_screen.dart
// Full PDF reader with bookmarks, progress tracking, and zoom

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:uuid/uuid.dart';
import '../../models/book.dart';
import '../../models/bookmark.dart';
import '../../providers/library_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';

class PdfReaderScreen extends StatefulWidget {
  final Book book;
  final int initialPage;

  const PdfReaderScreen({
    super.key,
    required this.book,
    this.initialPage = 0,
  });

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  final PdfViewerController _pdfController = PdfViewerController();
  bool _showControls = true;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
  }

  @override
  void dispose() {
    // Save progress before leaving
    _saveProgress();
    _pdfController.dispose();
    super.dispose();
  }

  Future<void> _saveProgress() async {
    if (_currentPage > 0 && _totalPages > 0) {
      await context.read<LibraryProvider>().updateReadingProgress(
            widget.book.id,
            _currentPage,
            _totalPages,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // PDF Viewer
          GestureDetector(
            onTap: () => setState(() => _showControls = !_showControls),
            child: _buildPdfViewer(),
          ),

          // Top bar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            top: _showControls ? 0 : -120,
            left: 0,
            right: 0,
            child: _buildTopBar(context, isDark),
          ),

          // Bottom bar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            bottom: _showControls ? 0 : -100,
            left: 0,
            right: 0,
            child: _buildBottomBar(isDark),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: isDark ? AppTheme.darkBg : AppTheme.lightBg,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPdfViewer() {
    final file = File(widget.book.filePath);

    if (!file.existsSync()) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.errorRed),
            const SizedBox(height: 16),
            Text(
              'File not found',
              style: GoogleFonts.inter(fontSize: 16, color: AppTheme.darkText),
            ),
            const SizedBox(height: 8),
            Text(
              widget.book.filePath,
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.darkTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SfPdfViewer.file(
      file,
      controller: _pdfController,
      initialScrollOffset: widget.initialPage > 0
          ? Offset(0, widget.initialPage.toDouble())
          : Offset.zero,
      canShowScrollHead: true,
      canShowScrollStatus: true,
      enableDoubleTapZooming: true,
      enableTextSelection: true,
      onDocumentLoaded: (details) {
        setState(() {
          _totalPages = details.document.pages.count;
          _isLoading = false;
          if (widget.initialPage > 0 && widget.initialPage <= _totalPages) {
            _pdfController.jumpToPage(widget.initialPage);
          }
        });
      },
      onPageChanged: (details) {
        setState(() => _currentPage = details.newPageNumber);
      },
      onDocumentLoadFailed: (details) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load PDF: ${details.description}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface.withOpacity(0.95) : Colors.white.withOpacity(0.95),
        border: Border(
          bottom: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  _saveProgress();
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.book.title,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.darkText : AppTheme.lightText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.book.author,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_add_rounded, color: AppTheme.accentCyan),
                onPressed: _addBookmark,
                tooltip: 'Bookmark this page',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    final progress = _totalPages > 0 ? _currentPage / _totalPages : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface.withOpacity(0.95) : Colors.white.withOpacity(0.95),
        border: Border(
          top: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Page $_currentPage',
                style: GoogleFonts.spaceMono(
                  fontSize: 12,
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                      activeTrackColor: AppTheme.primaryBlue,
                      inactiveTrackColor: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                      thumbColor: AppTheme.primaryBlue,
                      overlayColor: AppTheme.primaryBlue.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: progress.clamp(0.0, 1.0),
                      onChanged: (value) {
                        final page = (value * _totalPages).round().clamp(1, _totalPages);
                        _pdfController.jumpToPage(page);
                      },
                    ),
                  ),
                ),
              ),
              Text(
                '$_totalPages',
                style: GoogleFonts.spaceMono(
                  fontSize: 12,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${(progress * 100).toInt()}% completed',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addBookmark() async {
    if (_currentPage == 0) return;

    final labelController = TextEditingController(text: 'Page $_currentPage');
    final label = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Bookmark'),
        content: TextField(
          controller: labelController,
          decoration: const InputDecoration(
            hintText: 'Bookmark label (optional)',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, labelController.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (label != null) {
      final bookmark = Bookmark(
        id: const Uuid().v4(),
        bookId: widget.book.id,
        pageNumber: _currentPage,
        label: label.isEmpty ? null : label,
        createdAt: DateTime.now(),
      );

      await context.read<LibraryProvider>().addBookmark(bookmark);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.bookmark_added_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text('Bookmarked page $_currentPage'),
              ],
            ),
            backgroundColor: AppTheme.accentCyan,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
}
