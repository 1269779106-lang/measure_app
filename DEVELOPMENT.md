# 开发说明

## 环境搭建

### 1. Flutter SDK

已安装到 `D:\flutter`，使用国内镜像加速。

```bash
# 环境变量（已配置）
export PATH="/d/flutter/bin:$PATH"
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# 验证
flutter --version
# Flutter 3.24.5 • Dart 3.5.4
```

### 2. Android SDK

已下载命令行工具到 `C:\Users\12697\AppData\Local\Android\Sdk\cmdline-tools\`

**需要 Java 11+ 才能使用**（当前 Java 8 太旧）

```bash
# 安装 Java 17 后执行
export ANDROID_HOME="/c/Users/12697/AppData/Local/Android/Sdk"
yes | sdkmanager --licenses
sdkmanager "platforms;android-34" "build-tools;34.0.0"
```

### 3. 构建命令

```bash
# Web 版（已验证可用）
flutter build web

# APK 版（需要 Android SDK + Java 11+）
flutter build apk --release

# 调试运行
flutter run
```

## 项目结构

```
lib/
├── main.dart                    # 入口，MaterialApp 配置
├── screens/
│   ├── home_screen.dart         # 主页：4个功能卡片网格
│   ├── ruler_screen.dart        # 屏幕尺子：拖动测量 + CustomPainter
│   ├── ar_screen.dart           # AR测量：点击两点 + 距离计算
│   ├── level_screen.dart        # 水平仪：气泡 + CustomPainter
│   └── history_screen.dart      # 测量历史：列表展示
├── widgets/                     # 可复用组件（待扩展）
├── models/                      # 数据模型（待扩展）
├── services/                    # 服务层（待扩展）
└── utils/                       # 工具函数（待扩展）
```

## 技术要点

### 屏幕尺子
- 使用 `CustomPainter` 绘制刻度
- `GestureDetector` 捕获拖动事件
- 像素→厘米换算：`2.54 / PPI`
- 默认 PPI=160（需从设备获取真实值）

### AR 测量
- 点击放置两个锚点
- 欧几里得距离计算
- 换算系数：100 像素 ≈ 30 cm（需 AR 标定）

### 水平仪
- `CustomPainter` 绘制气泡和刻度盘
- 气泡位置根据 X/Y 倾斜偏移
- 限制在圆内移动

## 已知问题

1. 屏幕 PPI 硬编码为 160，应从设备动态获取
2. AR 测量使用模拟换算，需要真正的 ARCore/ARKit 集成
3. 水平仪使用模拟数据，需要接入 sensors_plus
4. 测量历史是内存数据，需要持久化到 SharedPreferences
5. 构建 APK 需要 Java 11+ 和 Android SDK

## 后续计划

- [ ] 集成 ARCore 实现真正的 AR 测量
- [ ] 从设备获取真实屏幕 PPI
- [ ] 接入 sensors_plus 实现真实水平仪
- [ ] 测量历史持久化存储
- [ ] 拍照保存测量结果
- [ ] 标定物测量模式
