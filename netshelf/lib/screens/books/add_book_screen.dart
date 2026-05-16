// screens/books/add_book_screen.dart
// Screen for adding new books with PDF file picker and metadata form

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/book.dart';
import '../../models/category.dart';
import '../../providers/library_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/file_service.dart';
import '../../theme/app_theme.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final FileService _fileService = FileService();

  String? _selectedFilePath;
  String? _selectedFileName;
  String _selectedCategoryId = 'cat_networking';
  String? _selectedSubCategoryId;
  bool _isUploading = false;
  double? _fileSizeMB;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Book'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // File picker section
            _buildFilePicker(context, isDark),
            const SizedBox(height: 24),

            // Book metadata
            _buildFormSection(context, isDark),
            const SizedBox(height: 32),

            // Submit button
            _buildSubmitButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePicker(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: _pickFile,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: _selectedFilePath != null
                ? AppTheme.primaryBlue
                : isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            width: _selectedFilePath != null ? 1.5 : 1,
          ),
        ),
        child: _selectedFilePath != null
            ? _buildSelectedFile(isDark)
            : _buildFilePickerPlaceholder(isDark),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildFilePickerPlaceholder(bool isDark) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.upload_file_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 16),
        Text(
          'Select PDF File',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.darkText : AppTheme.lightText,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tap to browse your device storage',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
          ),
          child: Text(
            'PDF format only',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedFile(bool isDark) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
          ),
          child: const Icon(Icons.picture_as_pdf_rounded, color: AppTheme.primaryBlue, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedFileName ?? 'Selected File',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkText : AppTheme.lightText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _fileSizeMB != null
                    ? '${_fileSizeMB!.toStringAsFixed(1)} MB • PDF'
                    : 'PDF Document',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_rounded, color: AppTheme.accentGreen, size: 16),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: _pickFile,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Change',
                style: GoogleFonts.inter(fontSize: 11, color: AppTheme.primaryBlue),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormSection(BuildContext context, bool isDark) {
    return Consumer<LibraryProvider>(
      builder: (context, library, _) {
        final topLevelCategories = library.topLevelCategories;
        final isProgramming = _selectedCategoryId == DefaultCategories.programmingLanguagesId;
        final subCategories = library.programmingSubCategories;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            _buildLabel('Book Title *', isDark),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'e.g. Computer Networks: A Top-Down Approach',
                prefixIcon: Icon(Icons.book_outlined, size: 20),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),

            // Author
            _buildLabel('Author', isDark),
            const SizedBox(height: 8),
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                hintText: 'e.g. James F. Kurose',
                prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 16),

            // Category
            _buildLabel('Category *', isDark),
            const SizedBox(height: 8),
            _buildCategoryDropdown(topLevelCategories, isDark),
            const SizedBox(height: 16),

            // Sub-category (only for Programming Languages)
            if (isProgramming) ...[
              _buildLabel('Programming Language', isDark),
              const SizedBox(height: 8),
              _buildSubCategoryDropdown(subCategories, isDark),
              const SizedBox(height: 16),
            ],
          ],
        );
      },
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildCategoryDropdown(List categories, bool isDark) {
    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.category_outlined, size: 20),
      ),
      items: categories.map<DropdownMenuItem<String>>((category) {
        return DropdownMenuItem(
          value: category.id,
          child: Row(
            children: [
              Icon(category.icon, size: 18, color: category.color),
              const SizedBox(width: 8),
              Text(category.name),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value!;
          _selectedSubCategoryId = null;
        });
      },
    );
  }

  Widget _buildSubCategoryDropdown(List subCategories, bool isDark) {
    return DropdownButtonFormField<String>(
      value: _selectedSubCategoryId,
      decoration: const InputDecoration(
        hintText: 'Select language (optional)',
        prefixIcon: Icon(Icons.code_rounded, size: 20),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('None / General')),
        ...subCategories.map<DropdownMenuItem<String>>((cat) {
          return DropdownMenuItem(
            value: cat.id,
            child: Row(
              children: [
                Icon(cat.icon, size: 16, color: cat.color),
                const SizedBox(width: 8),
                Text(cat.name),
              ],
            ),
          );
        }),
      ],
      onChanged: (value) => setState(() => _selectedSubCategoryId = value),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: _selectedFilePath != null && !_isUploading
            ? AppTheme.primaryGradient
            : const LinearGradient(colors: [Color(0xFF555), Color(0xFF555)]),
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: _selectedFilePath != null
            ? [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: _selectedFilePath != null && !_isUploading ? _submitBook : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
        ),
        child: _isUploading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.library_add_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Add to Library',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final file = await _fileService.pickPdfFile();
    if (file == null) return;

    setState(() {
      _selectedFilePath = file.path;
      _selectedFileName = file.name;
    });

    // Get file size
    if (file.path != null) {
      final size = await _fileService.getFileSizeMB(file.path!);
      setState(() => _fileSizeMB = size);
    }

    // Auto-fill title from filename if empty
    if (_titleController.text.isEmpty && file.name.isNotEmpty) {
      _titleController.text = _fileService.extractTitleFromFileName(file.name);
    }
  }

  Future<void> _submitBook() async {
    if (!_formKey.currentState!.validate() || _selectedFilePath == null) return;

    setState(() => _isUploading = true);

    try {
      // Copy to app storage
      final savedPath = await _fileService.copyToAppStorage(
        _selectedFilePath!,
        _selectedFileName ?? 'book.pdf',
      );

      if (savedPath == null) {
        _showError('Failed to save file. Please try again.');
        return;
      }

      final book = Book(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        author: _authorController.text.trim().isEmpty
            ? 'Unknown Author'
            : _authorController.text.trim(),
        category: _selectedCategoryId,
        subCategory: _selectedSubCategoryId,
        filePath: savedPath,
        dateAdded: DateTime.now(),
      );

      await context.read<LibraryProvider>().addBook(book);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('"${book.title}" added to your library!'),
              ],
            ),
            backgroundColor: AppTheme.accentGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Error adding book: $e');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
