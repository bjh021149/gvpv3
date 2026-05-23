# 播放器 UI 重构 TODO

## 背景
基于用户要求对播放器 UI 进行重构，统一使用中文，删除 Setting 按钮，新增轨道/源选择功能。

## 修改清单

### 1. 通用组件
- [x] **创建 `AppTextButton`**：`lib/core/widgets/app_text_button.dart`
  - Material 3 风格，支持 text/outlined/filled 三种变体
  - 颜色和文字样式从 ThemeData/ColorScheme 获取
  - 支持 width/height/padding 控制
  - 可复用于整个项目

### 2. 顶部栏改造
- [x] 删除 Setting 按钮（齿轮图标）
- [x] Back 按钮返回详情页（`goNamed('detail', id: itemId)`）
- [x] 添加 Home 按钮（小房子图标，回首页）
- [x] 添加"轨道"文字按钮（AppTextButton.outlined）
- [x] 添加"源"文字按钮（AppTextButton.outlined）

### 3. 播放控制面板改造
- [x] **删除 playback rate（速度）功能**
  - 删除 `PlayerState.speed` 字段
  - 删除 `PlayerViewModel.setSpeed()` 方法
  - 删除 `_buildSpeedTile` / `_buildSpeedPicker` / `_showSpeedPicker`
- [x] **轨道选择改为 Dialog 形式**
  - 新建 `_showTrackDialog`：AlertDialog 展示 video/audio/subtitle 轨道列表
  - 轨道间用 Divider 分隔
  - 显示格式：`#{index} displayTitle`
  - 支持 video/audio/subtitle 切换
- [x] **MediaSource 选择改为 Dialog 形式**
  - 新建 `_showSourceDialog`：AlertDialog 展示可用 media source 列表
  - 显示 source.name 和基本信息（分辨率、码率等）
  - 点击切换：调用 `viewModel.switchMediaSource(sourceId)`

### 4. PlayerViewModel 增强
- [x] 添加 `videoTracks` / `selectedVideoIndex` 到 PlayerState
- [x] 添加 `mediaSources` / `selectedMediaSourceId` 到 PlayerState
- [x] 添加 `selectVideoTrack()` 方法
- [x] 添加 `switchMediaSource()` 方法
- [x] 删除 `setSpeed()` 方法
- [x] 删除 `speed` 相关字段
- [x] 字幕默认激活逻辑（`isDefault` → 第一个字幕 index = 0）
- [x] fvp 初始化时设置默认 active tracks

### 5. 中文本地化
- [x] `player_controls_overlay.dart`
  - Loading... → 加载中...
  - Playback Error → 播放错误
  - Go Back → 返回
  - Back tooltip → 返回
  - Home tooltip → 首页
  - 轨道按钮文字 → 轨道
  - 源按钮文字 → 源
  - 播放/暂停 tooltip
  - 快进/快退 tooltip
- [x] `player_page.dart`
  - Loading... → 加载中...
  - Playback Error → 播放错误
  - Go Back → 返回
  - Brightness → 亮度
  - Volume → 音量
  - Seek 指示器文字 → 快进/快退

### 6. 详情页 Studio 图片
- [x] 扩展 `StudioDto` 添加 `imageTags` 字段
- [x] `getItemDetail` 添加可选 `fields` 参数
- [x] `EmbyApiService` 添加 `getStudioDetail(int studioId)` 方法
- [x] `MediaRepository` 添加 `getStudioDetail` 接口和实现
- [x] `DetailState` 添加 `studioDetails` 字段
- [x] `DetailViewModel` 加载 studio 详情
- [x] 创建 `StudioSection` 组件显示 studio 图片
- [x] `DetailPage` 集成 `StudioSection`
- [x] Genre 已显示在 `MetadataChips` 中

### 7. 验证
- [x] `flutter analyze` 无错误
- [x] `flutter test` 62/62 全部通过

## 已完成（前置工作）
- fvp 播放器引擎迁移
- UnifiedPlayerGestures 手势组件
- NavigationHistoryService 导航历史
- Video track 显示
- Back 按钮返回详情页逻辑
