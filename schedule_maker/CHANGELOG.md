# Project Changelog

## [Day 1 Prototype] - 2026-02-16

### Added
- **Project Structure**: Initialized Flutter project with `flutter_riverpod` and `google_fonts`.
- **Data Model**: Created `ClassBlock` model (`lib/models/class_model.dart`) with properties for id, name, time, day, and color.
- **State Management**: Implemented `ScheduleNotifier` using Riverpod `Notifier` (`lib/providers/schedule_provider.dart`) seeded with 5 dummy classes.
- **UI Implementation**: Created `ScheduleScreen` (`lib/screens/schedule_screen.dart`) featuring:
    - Glassmorphism design (Blur + Transparency).
    - Background image from Unsplash.
    - Grid layout for class blocks.
- **Entry Point**: Updated `lib/main.dart` to include `ProviderScope` and set `GoogleFonts.lato` as the default font.
