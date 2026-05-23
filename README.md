# Emby Flutter Client

A cross-platform Emby media client built with Flutter, featuring modern UI, responsive design, and seamless media playback.

> **Version**: 1.0.0  
> **Architecture**: MVVM + Clean Architecture  
> **State Management**: Riverpod 3.0  
> **Video Playback**: media_kit (libmpv)

---

## Screenshots (Planned)

| Login | Home | Library | Detail | Player | Settings |
|-------|------|---------|--------|--------|----------|
| Server config + auth | Hero carousel + continue watching | Grid/list adaptive browsing | Poster + metadata + cast | Full-screen with controls | Theme + server + cache |

---

## Features

### Authentication
- Server URL configuration with connection testing
- Username/password authentication via Emby API
- Secure token storage (flutter_secure_storage)
- Auto-login with token persistence

### Media Library
- Browse all Emby libraries with adaptive grid (2-6 columns)
- Sort by name, date added, rating, year
- Grid/List view mode toggle
- Pull-to-refresh and infinite scroll loading
- Search functionality

### Home Dashboard
- Hero carousel with auto-play (featured content)
- Continue watching row with progress indicators
- Recently added section
- Responsive layout for all screen sizes

### Media Details
- Full-screen hero with backdrop blur
- Palette-based dynamic theming (extracted from poster)
- Metadata chips (type, year, rating, runtime, resolution)
- Cast & crew horizontal list
- Season/episode list with expandable sections
- Similar recommendations

### Video Player
- Full-screen playback via media_kit (libmpv)
- Custom controls overlay (play/pause/seek/volume)
- Progress slider with time display
- Gesture controls (tap to toggle, double-tap seek, vertical swipe for volume/brightness)
- Audio track & subtitle selection
- Playback speed control

### Settings
- Theme mode: System / Light / Dark / OLED Black
- Dynamic color extraction from posters
- Server connection management
- Cache size display & clear
- About section with version info

### Responsive Design
- **Compact** (<600dp): Bottom navigation bar
- **Medium** (600-840dp): Navigation rail
- **Expanded** (840-1200dp): Navigation drawer
- **Large** (1200-1600dp): Wider drawer + more columns
- **Extra Large** (>1600dp): Maximum content density

---

## Architecture

```
lib/
|
+-- core/                          # Platform infrastructure
|   +-- api/                       # Dio + Emby API endpoints
|   |   +-- dio_client.dart
|   |   +-- emby_api_service.dart
|   |   +-- auth_interceptor.dart
|   |
|   +-- models/                    # Data models (DTOs)
|   |   +-- base_item_dto.dart     # Core media item model
|   |   +-- user_dto.dart
|   |   +-- authentication_result.dart
|   |   +-- playback_info.dart
|   |   +-- media_source_info.dart
|   |   +-- media_stream.dart
|   |   +-- query_result.dart
|   |   +-- user_item_data.dart
|   |
|   +-- theme/                     # flex_color_scheme config
|   |   +-- app_theme.dart
|   |   +-- theme_notifier.dart
|   |
|   +-- responsive/                # Adaptive layout utilities
|   |   +-- screen_layout.dart
|   |   +-- adaptive_grid.dart
|   |
|   +-- utils/
|       +-- extensions.dart
|
+-- services/repositories/         # Data layer
|   +-- media_repository.dart      # Media data access
|   +-- auth_repository.dart       # Authentication
|
+-- features/                      # Feature modules
|   +-- auth/                      # Login & server config
|   +-- home/                      # Dashboard with carousel
|   +-- library/                   # Media browsing
|   +-- detail/                    # Item details
|   +-- player/                    # Video playback
|   +-- settings/                  # App settings
|   +-- shared/                    # Reusable widgets
|
+-- main.dart                      # Entry point
+-- app.dart                       # MaterialApp config
+-- routes.dart                    # GoRouter configuration
+-- app_shell.dart                 # Responsive navigation shell
```

### Tech Stack

| Category | Package | Purpose |
|----------|---------|---------|
| State Management | `flutter_riverpod` | Dependency injection + reactive state |
| Video Playback | `media_kit` | Cross-platform libmpv-based player |
| Image Caching | `cached_network_image` | Network image with LRU cache |
| Routing | `go_router` | Declarative routing with deep links |
| HTTP | `dio` | HTTP client with interceptors |
| Theme | `flex_color_scheme` | Material 3 dynamic theming |
| Storage | `flutter_secure_storage` + `shared_preferences` | Secure + general storage |
| Shimmer | `shimmer` + `skeletonizer` | Loading placeholders |
| Color Extraction | `palette_generator` | Dynamic theming from images |

---

## Getting Started

### Prerequisites
- Flutter SDK >= 3.27.0
- Dart SDK >= 3.6.0
- An Emby Server instance

### Installation

```bash
# Clone the repository
git clone <repo-url>
cd emby_client

# Install dependencies
flutter pub get

# Run code generation (for Riverpod + Freezed + JSON)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | Planned | API 21+ |
| iOS | Planned | iOS 12+ |
| Windows | Planned | Windows 10+ |
| macOS | Planned | macOS 10.14+ |
| Linux | Planned | Most distributions |
| Web | Experimental | Limited by CORS |

---

## API Integration

This client uses the [Emby REST API](https://dev.emby.media/):

- **Authentication**: `POST /Users/AuthenticateByName`
- **Libraries**: `GET /Users/{userId}/Views`
- **Items**: `GET /Users/{userId}/Items`
- **Details**: `GET /Users/{userId}/Items/{id}`
- **Playback**: `GET /Items/{id}/PlaybackInfo`
- **Images**: `GET /Items/{id}/Images/{type}`

---

## Research Foundation

This project was built on comprehensive research of the Emby/Jellyfin open-source ecosystem:

| Project | Language | Key Learnings |
|---------|----------|---------------|
| [Fladder](https://github.com/DonutWare/Fladder) | Flutter | Riverpod + multi-engine playback + adaptive layout |
| [JellyCine](https://github.com/sureshfizzy/JellyCine) | Kotlin/Compose | Modular architecture + ExoPlayer + offline support |
| [NipaPlay-Reload](https://github.com/AimesSoft/NipaPlay-Reload) | Flutter | FVP/MediaKit multi-engine + Emby integration |

Research reports: `/mnt/agents/output/research/`

---

## License

MIT License
