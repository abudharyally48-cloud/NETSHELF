// models/category.dart
// Data model for book categories and subcategories

import 'package:flutter/material.dart';

class AppCategory {
  final String id;
  final String name;
  final String? parentId; // null = top-level category
  final IconData icon;
  final Color color;
  final bool isCustom; // User-created categories

  const AppCategory({
    required this.id,
    required this.name,
    this.parentId,
    required this.icon,
    required this.color,
    this.isCustom = false,
  });

  bool get isSubCategory => parentId != null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'icon_code': icon.codePoint,
      'icon_font_family': icon.fontFamily,
      'color_value': color.value,
      'is_custom': isCustom ? 1 : 0,
    };
  }

  factory AppCategory.fromMap(Map<String, dynamic> map) {
    return AppCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      parentId: map['parent_id'] as String?,
      icon: IconData(
        map['icon_code'] as int,
        fontFamily: map['icon_font_family'] as String? ?? 'MaterialIcons',
      ),
      color: Color(map['color_value'] as int),
      isCustom: (map['is_custom'] as int) == 1,
    );
  }
}

/// Predefined categories for NetShelf
class DefaultCategories {
  static const programmingLanguagesId = 'cat_programming';

  static List<AppCategory> get all => [
    ...topLevel,
    ...programmingSubCategories,
  ];

  static List<AppCategory> get topLevel => [
    AppCategory(
      id: 'cat_networking',
      name: 'Networking',
      icon: Icons.wifi_rounded,
      color: const Color(0xFF2196F3),
    ),
    AppCategory(
      id: 'cat_ccna',
      name: 'CCNA',
      icon: Icons.router_rounded,
      color: const Color(0xFF1565C0),
    ),
    AppCategory(
      id: 'cat_cybersecurity',
      name: 'Cybersecurity',
      icon: Icons.security_rounded,
      color: const Color(0xFFE53935),
    ),
    AppCategory(
      id: 'cat_linux',
      name: 'Linux',
      icon: Icons.terminal_rounded,
      color: const Color(0xFF43A047),
    ),
    AppCategory(
      id: 'cat_databases',
      name: 'Databases',
      icon: Icons.storage_rounded,
      color: const Color(0xFFFF6F00),
    ),
    AppCategory(
      id: programmingLanguagesId,
      name: 'Programming Languages',
      icon: Icons.code_rounded,
      color: const Color(0xFF7B1FA2),
    ),
  ];

  static List<AppCategory> get programmingSubCategories => [
    _lang('Python', Icons.code, const Color(0xFF3776AB)),
    _lang('JavaScript', Icons.javascript_rounded, const Color(0xFFF7DF1E), textColor: Colors.black),
    _lang('Java', Icons.coffee_rounded, const Color(0xFF007396)),
    _lang('C++', Icons.memory_rounded, const Color(0xFF00599C)),
    _lang('C#', Icons.window_rounded, const Color(0xFF68217A)),
    _lang('PHP', Icons.php_rounded, const Color(0xFF777BB4)),
    _lang('Go', Icons.sports_score_rounded, const Color(0xFF00ACD7)),
    _lang('Rust', Icons.construction_rounded, const Color(0xFFCE4A00)),
    _lang('Kotlin', Icons.android_rounded, const Color(0xFF7F52FF)),
    _lang('Dart', Icons.flutter_dash_rounded, const Color(0xFF0175C2)),
    _lang('Swift', Icons.apple_rounded, const Color(0xFFFA7343)),
    _lang('TypeScript', Icons.text_fields_rounded, const Color(0xFF3178C6)),
  ];

  static AppCategory _lang(String name, IconData icon, Color color, {Color? textColor}) {
    return AppCategory(
      id: 'cat_lang_${name.toLowerCase()}',
      name: name,
      parentId: programmingLanguagesId,
      icon: icon,
      color: color,
    );
  }
}
