> 文档版本: v1.0 | 生成时间: 2026-05-15T10:15:42+08:00

# skeletonizer ^2.1.3 使用方法

## 1. 概述

`skeletonizer` 是 Flutter 生态中最现代的骨架屏加载库。与手动创建骨架布局不同，它自动将真实 UI 组件转换为骨架样式，保持布局一致性的同时大幅减少样板代码。

**核心优势：**
- 自动骨架化：将真实 Widget 自动转换为骨架，无需维护两套布局
- 多种动画效果：Shimmer、Pulse、Painting
- 支持 Sliver 和 Nested
- 全局主题配置
- 自定义 Bone 组件

---

## 2. 基础用法

### 2.1 包裹现有布局
```dart
import 'package:skeletonizer/skeletonizer.dart';

Skeletonizer(
  enabled: isLoading, // true = 显示骨架，false = 显示真实内容
  child: ListView.builder(
    itemCount: users.length,
    itemBuilder: (context, index) {
      return ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(users[index].avatar),
        ),
        title: Text(users[index].name),
        subtitle: Text(users[index].email),
      );
    },
  ),
)
```

### 2.2 配合 AsyncValue
```dart
final usersAsync = ref.watch(usersProvider);

return usersAsync.when(
  data: (users) => UserList(users: users),
  loading: () => Skeletonizer(
    enabled: true,
    child: UserList(users: List.filled(5, User.placeholder())),
  ),
  error: (err, _) => ErrorWidget(err),
);
```

---

## 3. 自定义动画效果

### 3.1 ShimmerEffect（默认）
```dart
Skeletonizer(
  enabled: true,
  effect: ShimmerEffect(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    duration: Duration(seconds: 1),
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
  ),
  child: MyWidget(),
)
```

### 3.2 PulseEffect
```dart
Skeletonizer(
  enabled: true,
  effect: PulseEffect(
    from: Colors.grey[300]!,
    to: Colors.grey[100]!,
    duration: Duration(seconds: 1),
  ),
  child: MyWidget(),
)
```

### 3.3 PaintingEffect
```dart
Skeletonizer(
  enabled: true,
  effect: PaintingEffect(
    color: Colors.grey[300]!,
  ),
  child: MyWidget(),
)
```

---

## 4. 骨架化注解

### 4.1 Skeleton.ignore — 忽略骨架化
```dart
ListTile(
  leading: Skeleton.ignore( // 头像保持原样
    child: CircleAvatar(child: Icon(Icons.person)),
  ),
  title: Text('User Name'), // 会被骨架化
)
```

### 4.2 Skeleton.replace — 替换为骨架块
```dart
ListTile(
  leading: Skeleton.replace( // 用矩形骨架替代
    width: 48,
    height: 48,
    child: CircleAvatar(
      backgroundImage: NetworkImage(avatarUrl),
    ),
  ),
)
```

### 4.3 Skeleton.unite — 合并多个子组件
```dart
Skeleton.unite(
  child: Row(
    children: [
      Icon(Icons.star),
      SizedBox(width: 8),
      Icon(Icons.star),
    ],
  ),
)
```

### 4.4 Skeleton.leaf — 将容器作为叶节点
```dart
Skeleton.leaf(
  child: Card(
    child: ListTile(
      title: Text('Title'),
    ),
  ),
)
```

---

## 5. 手动构建骨架（Bone）

当自动骨架化不够精确时，使用 Bone 组件：

```dart
Skeletonizer.zone( // 只有 Bone 会被骨架化
  child: Card(
    child: ListTile(
      leading: Bone.circle(size: 48),           // 圆形骨架
      title: Bone.text(words: 2),               // 2 个词的文本
      subtitle: Bone.text(words: 3),            // 3 个词的文本
      trailing: Bone.icon(),                    // 图标大小的骨架
    ),
  ),
)
```

### Bone 类型
```dart
Bone.text(words: 3)              // 文本骨架（默认 3 词）
Bone.text(words: 1, style: TextStyle(fontSize: 20)) // 自定义字体
Bone.multiText(lines: 3)         // 多行文本
Bone.circle(size: 40)            // 圆形
Bone.square(size: 50)            // 正方形
Bone(width: 100, height: 50)     // 矩形
Bone.icon()                      // 图标大小
Bone.button()                    // 按钮大小
Bone.iconButton()                // 图标按钮大小
Bone.ignore(                     // 区域内不骨架化
  child: Text('Keep this'),
)
```

---

## 6. Sliver 支持

```dart
CustomScrollView(
  slivers: [
    SliverSkeletonizer(
      enabled: isLoading,
      child: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => ListTile(
            title: Text('Item $index'),
          ),
          childCount: 10,
        ),
      ),
    ),
  ],
)
```

---

## 7. 全局主题配置

### 7.1 通过 ThemeData Extension
```dart
MaterialApp(
  theme: ThemeData(
    extensions: const [
      SkeletonizerConfigData(), // 默认亮色配置
    ],
  ),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    extensions: const [
      SkeletonizerConfigData.dark(), // 暗色配置
    ],
  ),
)
```

### 7.2 通过 SkeletonizerConfig
```dart
SkeletonizerConfig(
  data: SkeletonizerConfigData(
    effect: ShimmerEffect(),
    justifyMultiLineText: true,
    textBorderRadius: TextBoneBorderRadius.fromHeightFactor(0.5),
    ignoreContainers: false,
  ),
  child: MaterialApp(
    home: HomePage(),
  ),
)
```

---

## 8. 切换动画

```dart
Skeletonizer(
  enabled: isLoading,
  enableSwitchAnimation: true, // 骨架/内容切换时有淡入淡出动画
  switchAnimationConfig: SwitchAnimationConfig(
    duration: Duration(milliseconds: 300),
    switchInCurve: Curves.easeIn,
    switchOutCurve: Curves.easeOut,
  ),
  child: MyWidget(),
)
```

---

## 9. 使用假数据（BoneMock）

```dart
final fakeUsers = List.filled(5, User(
  name: BoneMock.name,           // 随机名字
  email: BoneMock.email,         // 随机邮箱
  jobTitle: BoneMock.words(2),   // 随机 2 个词
  createdAt: BoneMock.date,      // 随机日期
));

Skeletonizer(
  enabled: true,
  child: UserList(users: fakeUsers),
)
```

---

## 10. 项目集成建议

当前项目已正确使用 `skeletonizer`。建议改进：

1. **统一使用自动骨架化**：当前项目部分页面使用 `ShimmerCard` 手动实现，可统一改用 `Skeletonizer` 包裹真实布局
2. **使用 `SkeletonizerConfigData` 全局配置**：在 `MaterialApp` 的 `ThemeData.extensions` 中设置，避免每个 Skeletonizer 重复配置
3. **暗色主题骨架色**：确保暗色模式下 `baseColor` / `highlightColor` 使用深灰色系
4. **Sliver 支持**：首页 `CustomScrollView` 中的骨架加载可改用 `SliverSkeletonizer`
5. **配合 `AsyncValue`**：`AsyncValue.when` 的 `loading` 状态可直接用 `Skeletonizer` + 占位数据
6. **网络图片处理**：骨架化时 `NetworkImage` 会报错，使用 `Skeleton.replace` 或条件渲染 `backgroundImage: loading ? null : NetworkImage(url)`
