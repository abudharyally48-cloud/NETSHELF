// services/file_service.dart
// Handles PDF file picking, copying to app storage, and path management

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();

  /// Pick a PDF file from device storage
  /// Returns the PlatformFile or null if cancelled
  Future<PlatformFile?> pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: false,
        withReadStream: false,
      );

      if (result == null || result.files.isEmpty) return null;
      return result.files.first;
    } catch (e) {
      debugPrint('Error picking file: $e');
      return null;
    }
  }

  /// Pick multiple PDF files at once
  Future<List<PlatformFile>> pickMultiplePdfFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
        withData: false,
      );

      if (result == null || result.files.isEmpty) return [];
      return result.files;
    } catch (e) {
      debugPrint('Error picking files: $e');
      return [];
    }
  }

  /// Copy a picked file to app's internal storage for persistence
  /// Returns the new internal path
  Future<String?> copyToAppStorage(String sourcePath, String fileName) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final booksDir = Directory(p.join(appDir.path, 'books'));

      // Create books directory if it doesn't exist
      if (!await booksDir.exists()) {
        await booksDir.create(recursive: true);
      }

      // Sanitize filename
      final sanitized = _sanitizeFileName(fileName);
      final destPath = p.join(booksDir.path, sanitized);

      // Copy file to app storage
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        debugPrint('Source file does not exist: $sourcePath');
        return null;
      }

      await sourceFile.copy(destPath);
      return destPath;
    } catch (e) {
      debugPrint('Error copying file: $e');
      return null;
    }
  }

  /// Check if a file exists at given path
  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  /// Delete a book file from app storage
  Future<bool> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  /// Get file size in MB
  Future<double> getFileSizeMB(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return 0.0;
      final bytes = await file.length();
      return bytes / (1024 * 1024);
    } catch (e) {
      return 0.0;
    }
  }

  /// Extract title from filename (remove extension, replace underscores/hyphens)
  String extractTitleFromFileName(String fileName) {
    final withoutExtension = p.basenameWithoutExtension(fileName);
    return withoutExtension
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .replaceAll('.', ' ')
        .trim()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Sanitize filename to avoid conflicts
  String _sanitizeFileName(String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = p.extension(fileName);
    final nameWithoutExt = p.basenameWithoutExtension(fileName);
    final sanitized = nameWithoutExt
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_');
    return '${sanitized}_$timestamp$ext';
  }

  /// Get total size of all stored books
  Future<String> getTotalStorageUsed() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final booksDir = Directory(p.join(appDir.path, 'books'));
      if (!await booksDir.exists()) return '0 MB';

      int totalBytes = 0;
      await for (final entity in booksDir.list()) {
        if (entity is File) {
          totalBytes += await entity.length();
        }
      }

      if (totalBytes < 1024 * 1024) {
        return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
      }
      return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return '0 MB';
    }
  }

  void debugPrint(String message) {
    // ignore: avoid_print
    print('[FileService] $message');
  }
}
