// screens/settings/settings_screen.dart
// App settings: dark mode toggle, storage info, app info

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/file_service.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _storageUsed = 'Calculating...';

  @override
  void initState() {
    super.initState();
    _loadStorage();
  }

  Future<void> _loadStorage() async {
    final size = await FileService().getTotalStorageUsed();
    if (mounted) setState(() => _storageUsed = size);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final themeProvider = context.watch<ThemeProvider>();
    final library = context.watch<LibraryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // App header
          _buildAppHeader(isDark).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),

          // Appearance section
          _buildSection(
            isDark,
            title: 'Appearance',
            icon: Icons.palette_outlined,
            children: [
              _SettingsTile(
                isDark: isDark,
                icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                iconColor: isDark ? const Color(0xFF7C4DFF) : const Color(0xFFFFA726),
                title: 'Dark Mode',
                subtitle: isDark ? 'Currently using dark theme' : 'Currently using light theme',
                trailing: Switch(
                  value: isDark,
                  onChanged: (v) => themeProvider.setDarkMode(v),
                  activeColor: AppTheme.primaryBlue,
                ),
              ),
            ],
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          // Library section
          _buildSection(
            isDark,
            title: 'Library',
            icon: Icons.menu_book_rounded,
            children: [
              _SettingsTile(
                isDark: isDark,
                icon: Icons.storage_rounded,
                iconColor: AppTheme.accentCyan,
                title: 'Storage Used',
                subtitle: _storageUsed,
              ),
              _SettingsTile(
                isDark: isDark,
                icon: Icons.auto_stories_rounded,
                iconColor: AppTheme.accentGreen,
                title: 'Total Books',
                subtitle: '${library.totalBooks} books in library',
              ),
              _SettingsTile(
                isDark: isDark,
                icon: Icons.favorite_rounded,
                iconColor: const Color(0xFFFF4081),
                title: 'Favorites',
                subtitle: '${library.favoriteBooks.length} books marked as favorite',
              ),
            ],
          ).animate(delay: 150.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          // About section
          _buildSection(
            isDark,
            title: 'About',
            icon: Icons.info_outline_rounded,
            children: [
              _SettingsTile(
                isDark: isDark,
                icon: Icons.apps_rounded,
                iconColor: AppTheme.primaryBlue,
                title: 'NetShelf',
                subtitle: 'Version 1.0.0',
              ),
              _SettingsTile(
                isDark: isDark,
                icon: Icons.description_outlined,
                iconColor: AppTheme.primaryPurple,
                title: 'Description',
                subtitle: 'Personal digital library for networking\nand programming books',
              ),
              _SettingsTile(
                isDark: isDark,
                icon: Icons.code_rounded,
                iconColor: AppTheme.accentGreen,
                title: 'Built With',
                subtitle: 'Flutter • SQLite • Provider',
              ),
            ],
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAppHeader(bool isDark) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 14),
          Text(
            'NetShelf',
            style: GoogleFonts.spaceMono(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkText : AppTheme.lightText,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your Digital Tech Library',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(bool isDark, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Icon(icon, size: 15, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
          ),
          child: Column(
            children: children
                .asMap()
                .entries
                .map((e) => Column(
                      children: [
                        e.value,
                        if (e.key < children.length - 1)
                          Divider(
                            height: 1,
                            indent: 56,
                            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                          ),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? AppTheme.darkText : AppTheme.lightText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
          height: 1.4,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
