# 代码清理追踪

> 目标：清除 `flutter analyze` 产生的所有 warning 和 info。

---

## 一、Warnings（31个）

### 1.1 Unused Import（16个）

| # | 文件 | 行 | 导入 | 修复状态 |
|---|------|-----|------|----------|
| 1 | `lib/core/api/emby_api_service.dart` | 19 | `auth_interceptor.dart` | ✅ |
| 2 | `lib/core/api/emby_api_service.dart` | 13 | `../models/media_source_info.dart` | ✅ |
| 3 | `lib/core/api/emby_api_service.dart` | 14 | `../models/media_stream.dart` | ✅ |
| 4 | `lib/core/api/emby_api_service.dart` | 17 | `../models/user_dto.dart` | ✅ |
| 5 | `lib/core/api/emby_api_service.dart` | 18 | `../models/user_item_data.dart` | ✅ |
| 6 | `lib/core/api/auth_interceptor.dart` | 10 | `../utils/extensions.dart` | ✅ |
| 7 | `lib/app_shell.dart` | 2 | `flutter_riverpod` | ✅ |
| 8 | `lib/core/theme/theme_notifier.dart` | 1 | `flex_color_scheme` | ✅ |
| 9 | `lib/features/auth/auth_viewmodel.dart` | 7 | `auth_repository.dart` | ✅ |
| 10 | `lib/features/settings/settings_viewmodel.dart` | 4 | `auth_repository.dart` | ✅ |
| 11 | `lib/features/detail/detail_viewmodel.dart` | 3 | `media_repository.dart` | ✅ |
| 12 | `lib/features/player/player_viewmodel.dart` | 2 | `dart:convert` | ✅ |
| 13 | `lib/features/player/player_viewmodel.dart` | 12 | `playback_info.dart` | ✅ |
| 14 | `lib/features/player/player_viewmodel.dart` | 14 | `media_repository.dart` | ✅ |
| 15 | `lib/features/player/player_page.dart` | 4 | `media_kit` | ✅ |
| 16 | `lib/features/player/volume_brightness_control.dart` | 1 | `dart:math` | ✅ |
| 17 | `lib/features/settings/settings_page.dart` | 4 | `responsive_nav` | ✅ |
| 18 | `test/services/auth_repository_impl_test.dart` | 7 | `authentication_result.dart` | ✅ |
| 19 | `test/services/resumable_media_mock_test.dart` | 7 | `base_item_dto.dart` | ✅ |
| 20 | `test/services/resumable_media_mock_test.dart` | 8 | `query_result.dart` | ✅ |
| 21 | `test/services/resumable_media_mock_test.dart` | 9 | `user_item_data.dart` | ✅ |

### 1.2 Duplicate Import（1个）

| # | 文件 | 行 | 说明 | 修复状态 |
|---|------|-----|------|----------|
| 1 | `lib/core/api/emby_api_service.dart` | 20 | `dio_client.dart` 重复导入 | ✅ |

### 1.3 Unused Local Variable（3个）

| # | 文件 | 行 | 变量 | 修复状态 |
|---|------|-----|------|----------|
| 1 | `lib/features/detail/metadata_chips.dart` | 28 | `colorScheme` | ✅ |
| 2 | `lib/features/detail/metadata_chips.dart` | 29 | `textTheme` | ✅ |
| 3 | `lib/features/detail/metadata_chips.dart` | 48 | `textTheme` | ✅ |

### 1.4 Unreachable Switch Case（2个）

| # | 文件 | 行 | 说明 | 修复状态 |
|---|------|-----|------|----------|
| 1 | `lib/features/settings/theme_mode_selector.dart` | 17 | case 被前面的 cases 覆盖 | ✅ |
| 2 | `lib/features/settings/theme_mode_selector.dart` | 26 | case 被前面的 cases 覆盖 | ✅ |

### 1.5 Null Safety 相关（4个）

| # | 文件 | 行 | 说明 | 修复状态 |
|---|------|-----|------|----------|
| 1 | `lib/features/player/player_viewmodel.dart` | 140 | `invalid_null_aware_operator` | ✅ |
| 2 | `lib/features/player/player_viewmodel.dart` | 145 | `unnecessary_null_comparison` | ✅ |
| 3 | `lib/features/player/player_viewmodel.dart` | 161 | `dead_null_aware_expression` | ✅ |
| 4 | `lib/features/player/player_viewmodel.dart` | 328 | `body_might_complete_normally_catch_error` | ✅ |

### 1.6 配置文件（1个）

| # | 文件 | 行 | 说明 | 修复状态 |
|---|------|-----|------|----------|
| 1 | `analysis_options.yaml` | 1 | `flutter_lints/flutter.yaml` URI 找不到 | ✅ |

---

## 二、Deprecated Warnings（6个）

| # | 文件 | 行 | 说明 | 修复状态 |
|---|------|-----|------|----------|
| 1 | `lib/core/theme/app_theme.dart` | 171 | `dialogBackgroundColor` → `DialogThemeData.backgroundColor` | ✅ |
| 2 | `lib/core/api/dio_client.dart` | 70 | `encryptedSharedPreferences` 弃用 | ✅ |
| 3 | `lib/services/repositories/auth_repository_impl.dart` | 71 | `encryptedSharedPreferences` 弃用 | ✅ |
| 4 | `lib/features/detail/detail_hero_section.dart` | 195 | `errorWidget` → `errorBuilder` | ✅ |
| 5 | `lib/features/detail/detail_hero_section.dart` | 264 | `errorWidget` → `errorBuilder` | ✅ |
| 6 | `lib/features/detail/season_episode_list.dart` | 445 | `errorWidget` → `errorBuilder` | ✅ |
| 7 | `lib/features/player/player_page.dart` | 80 | `WillPopScope` → `PopScope` | ✅ |

---

## 三、Info — Directives Ordering（import 排序，大量文件）

| # | 文件 | 修复状态 |
|---|------|----------|
| 1 | `lib/app.dart` | ✅ |
| 2 | `lib/app_shell.dart` | ✅ |
| 3 | `lib/core/api/auth_interceptor.dart` | ✅ |
| 4 | `lib/core/api/dio_client.dart` | ✅ |
| 5 | `lib/core/api/emby_api_service.dart` | ✅ |
| 6 | `lib/features/detail/cast_horizontal_list.dart` | ✅ |
| 7 | `lib/features/detail/detail_hero_section.dart` | ✅ |
| 8 | `lib/features/detail/detail_page.dart` | ✅ |
| 9 | `lib/features/detail/detail_viewmodel.dart` | ✅ |
| 10 | `lib/features/detail/metadata_chips.dart` | ✅ |
| 11 | `lib/features/detail/season_episode_list.dart` | ✅ |
| 12 | `lib/features/detail/similar_items_row.dart` | ✅ |
| 13 | `lib/features/library/filter_sort_bar.dart` | ✅ |
| 14 | `lib/features/library/library_page.dart` | ✅ |
| 15 | `lib/features/library/library_viewmodel.dart` | ✅ |
| 16 | `lib/features/library/media_grid.dart` | ✅ |
| 17 | `lib/features/library/view_mode_toggle.dart` | ✅ |
| 18 | `lib/features/player/player_page.dart` | ✅ |
| 19 | `lib/features/player/player_viewmodel.dart` | ✅ |
| 20 | `lib/features/player/video_surface.dart` | ✅ |
| 21 | `lib/features/player/volume_brightness_control.dart` | ✅ |
| 22 | `lib/features/settings/about_app_section.dart` | ✅ |
| 23 | `lib/features/settings/settings_page.dart` | ✅ |
| 24 | `lib/features/settings/settings_viewmodel.dart` | ✅ |
| 25 | `lib/features/shared/media_card.dart` | ✅ |
| 26 | `lib/features/shared/responsive_nav.dart` | ✅ |
| 27 | `lib/main.dart` | ✅ |
| 28 | `lib/routes.dart` | ✅ |
| 29 | `lib/services/repositories/auth_repository_impl.dart` | ✅ |
| 30 | `lib/services/repositories/media_repository_impl.dart` | ✅ |
| 31 | `test/services/auth_repository_impl_test.dart` | ✅ |
| 32 | `test/services/resumable_media_mock_test.dart` | ✅ |
| 33 | `test/services/resumable_media_test.dart` | ✅ |

---

## 四、Info — Always Use Package Imports（相对路径 → package:）

| # | 文件 | 修复状态 |
|---|------|----------|
| 1 | `lib/core/api/auth_interceptor.dart` | ✅ |
| 2 | `lib/core/api/dio_client.dart` | ✅ |
| 3 | `lib/core/api/emby_api_service.dart` | ✅ |
| 4 | `lib/core/models/authentication_result.dart` | ✅ |
| 5 | `lib/core/models/base_item_dto.dart` | ✅ |
| 6 | `lib/core/models/media_source_info.dart` | ✅ |
| 7 | `lib/core/models/playback_info.dart` | ✅ |
| 8 | `lib/core/responsive/adaptive_grid.dart` | ✅ |
| 9 | `lib/features/player/player_controls_overlay.dart` | ✅ |
| 10 | `lib/features/player/player_page.dart` | ✅ |
| 11 | `lib/features/settings/cache_management.dart` | ✅ |
| 12 | `lib/features/settings/server_connection_editor.dart` | ✅ |
| 13 | `lib/features/settings/settings_page.dart` | ✅ |
| 14 | `lib/features/settings/theme_mode_selector.dart` | ✅ |

---

## 五、Info — Other

| # | 文件 | 行 | 说明 | 修复状态 |
|---|------|-----|------|----------|
| 1 | `lib/core/models/media_stream.dart` | 4 | unnecessary_import: `json_annotation` | ✅ |
| 2 | `lib/features/player/volume_brightness_control.dart` | 4 | unnecessary_import: `services.dart` | ✅ |
| 3 | `lib/core/theme/app_theme.dart` | 22 | prefer_const_constructors | ✅ |
| 4 | `lib/core/theme/app_theme.dart` | 53 | prefer_const_constructors | ✅ |
| 5 | `lib/features/library/filter_sort_bar.dart` | 42 | prefer_const_literals_to_create_immutables | ✅ |
| 6 | `lib/features/library/filter_sort_bar.dart` | 43,48,53,58 | prefer_const_constructors | ✅ |
| 7 | `test/utils/auth_info_decryptor.dart` | 36 | prefer_const_constructors | ✅ |
| 8 | `test/services/auth_repository_impl_test.dart` | 318-324 | avoid_print | ✅ |
| 9 | `lib/features/settings/server_connection_editor.dart` | 239 | use_build_context_synchronously | ✅ |
---\n\n## 清理结果\n\n- **flutter analyze**: No issues found! ✅\n- **flutter test**: 22/22 passed ✅\n- **dart fix**: 自动修复 79 处问题\n- **手动修复**: 30+ 处问题
