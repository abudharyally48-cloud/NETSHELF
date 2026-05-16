# NetShelf 📚

**A professional personal digital library for networking & programming books**

Built with Flutter — clean architecture, cyber aesthetic, offline-first.

---

## Features

- **Home Dashboard** — Stats, recent books, category overview, animated search bar
- **PDF Reader** — Full reader with page tracking, bookmarks, zoom & scroll
- **6 Categories** — Networking, CCNA, Cybersecurity, Linux, Databases, Programming
- **12 Language Sub-tags** — Python, JS, Java, C++, Rust, Go, Dart, Swift + custom
- **Search** — Real-time search across title, author, category, language
- **Favorites** — Star and collect books in a dedicated screen
- **Notes** — Per-book notes saved locally
- **Bookmarks** — Save PDF pages with labels, jump back instantly
- **Dark / Light Mode** — Cyber dark (default) or clean light theme
- **Reading Progress** — Page tracking, progress bars, last-opened timestamps
- **Animations** — Smooth entrance animations on every screen

---

## Project Structure

```
lib/
├── main.dart                        # App entry point
├── models/
│   ├── book.dart                    # Book data model
│   ├── note.dart                    # Note model
│   ├── bookmark.dart                # Bookmark model
│   └── category.dart                # Category + default categories
├── database/
│   └── database_helper.dart         # SQLite setup & CRUD (sqflite)
├── providers/
│   ├── library_provider.dart        # Central state (books, notes, search)
│   └── theme_provider.dart          # Dark/light mode state
├── services/
│   └── file_service.dart            # PDF file picking & storage
├── theme/
│   └── app_theme.dart               # Design tokens, dark/light themes
├── widgets/
│   └── common_widgets.dart          # BookCard, CategoryCard, EmptyState, etc.
└── screens/
    ├── splash/
    │   └── splash_screen.dart        # Animated splash with loading
    ├── home/
    │   ├── home_screen.dart          # Bottom nav shell
    │   └── home_content.dart         # Dashboard: stats, recent, categories
    ├── books/
    │   ├── books_screen.dart         # Full library with grid/list toggle
    │   ├── add_book_screen.dart      # PDF picker + metadata form
    │   └── book_detail_screen.dart   # Detail, notes, bookmarks
    ├── reader/
    │   └── pdf_reader_screen.dart    # SfPdfViewer with controls
    ├── categories/
    │   └── categories_screen.dart    # Category grid + subcategory pills
    ├── search/
    │   └── search_screen.dart        # Live search results
    ├── favorites/
    │   └── favorites_screen.dart     # Favorite books grid
    └── settings/
        └── settings_screen.dart      # Theme toggle, storage info, app info
```

---

## Setup & Installation

### Prerequisites

- Flutter SDK `>=3.0.0`
- Android Studio or VS Code with Flutter plugin
- Android device / emulator (API 21+)

### 1. Clone & Install

```bash
git clone <repo-url>
cd netshelf
flutter pub get
```

### 2. Run

```bash
# Debug
flutter run

# Release APK
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`

---

## Dependencies

| Package | Purpose |
|--------|---------|
| `provider` | State management |
| `sqflite` | Local SQLite database |
| `path` / `path_provider` | File system paths |
| `file_picker` | PDF file selection from storage |
| `syncfusion_flutter_pdfviewer` | In-app PDF reader |
| `google_fonts` | Inter + Space Mono typography |
| `flutter_animate` | Smooth UI animations |
| `shared_preferences` | Theme persistence |
| `uuid` | Unique IDs for books/notes/bookmarks |
| `percent_indicator` | Reading progress bars |
| `intl` | Date formatting |

---

## Design System

| Token | Value |
|-------|-------|
| Primary Blue | `#2979FF` |
| Primary Purple | `#7C4DFF` |
| Accent Cyan | `#00E5FF` |
| Dark Background | `#0A0E1A` |
| Dark Card | `#141D35` |
| Dark Border | `#1E2D4A` |
| Font (UI) | Inter |
| Font (Code/Mono) | Space Mono |
| Border Radius | 8 / 12 / 16 / 24 px |

---

## Database Schema

### `books`
| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT PK | UUID |
| `title` | TEXT | Book title |
| `author` | TEXT | Author name |
| `category` | TEXT | Category ID |
| `sub_category` | TEXT | Language sub-category ID |
| `file_path` | TEXT | Path to stored PDF |
| `date_added` | TEXT | ISO 8601 date |
| `is_favorite` | INTEGER | 0 or 1 |
| `last_read_page` | INTEGER | Last page number |
| `total_pages` | INTEGER | Total page count |
| `last_opened_at` | TEXT | ISO 8601 timestamp |
| `tags` | TEXT | Comma-separated tags |

### `notes`
| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT PK | UUID |
| `book_id` | TEXT FK | References books.id |
| `content` | TEXT | Note text |
| `page_number` | INTEGER | Optional page reference |
| `created_at` | TEXT | Timestamp |
| `updated_at` | TEXT | Timestamp |

### `bookmarks`
| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT PK | UUID |
| `book_id` | TEXT FK | References books.id |
| `page_number` | INTEGER | Bookmarked page |
| `label` | TEXT | Optional label |
| `created_at` | TEXT | Timestamp |

### `categories`
| Column | Type | Description |
|--------|------|-------------|
| `id` | TEXT PK | Category ID |
| `name` | TEXT | Display name |
| `parent_id` | TEXT | Parent category (for sub-cats) |
| `icon_code` | INTEGER | Material icon code point |
| `color_value` | INTEGER | ARGB color value |
| `is_custom` | INTEGER | 0 = default, 1 = user-created |

---

## Key Architecture Decisions

- **Offline-first**: All data stored locally using SQLite via `sqflite`. No network required.
- **Provider pattern**: `LibraryProvider` manages all books/notes/bookmarks state. `ThemeProvider` handles appearance.
- **Clean architecture**: Models → Database → Services → Providers → Screens/Widgets
- **File handling**: PDFs are copied into the app's internal storage directory (`getApplicationDocumentsDirectory()/books/`) so they remain accessible even if the original file is moved or deleted.
- **Cascade deletes**: When a book is deleted, its notes and bookmarks are automatically removed via SQLite foreign key constraints.

---

## Permissions Required (Android)

```xml
READ_EXTERNAL_STORAGE   <!-- Android < 13 -->
READ_MEDIA_IMAGES       <!-- Android 13+ -->
```

These are requested automatically by `file_picker` when the user taps "Add Book".

---

## License

MIT — free to use, modify, and distribute.
