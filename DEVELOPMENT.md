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

已下载命令行工具到 `%LOCALAPPDATA%\Android\Sdk\cmdline-tools\`

**需要 Java 11+ 才能使用**（当前 Java 8 太旧）

```bash
# 安装 Java 17 后执行
export ANDROID_HOME="%LOCALAPPDATA%/Android/Sdk"
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
│   ├── home_screen.dart         # 主页：6个功能卡片网格
│   ├── ruler_screen.dart        # 屏幕尺子：拖动测量 + CustomPainter
│   ├── ar_screen.dart           # AR测量：点击两点 + 距离计算
│   ├── level_screen.dart        # 水平仪：加速度计实时数据
│   ├── calibrate_screen.dart    # 标定测量：参考物校准
│   ├── photo_screen.dart        # 拍照测量：拍照记录结果
│   └── history_screen.dart      # 测量历史：持久化存储
├── services/
│   └── measurement_service.dart # 测量数据持久化服务
├── widgets/                     # 可复用组件（待扩展）
├── models/                      # 数据模型（待扩展）
└── utils/                       # 工具函数（待扩展）
```

## 技术要点

### 屏幕尺子
- 使用 `CustomPainter` 绘制刻度
- `GestureDetector` 捕获拖动事件
- 使用 `window.devicePixelRatio` 估算 PPI
- 支持 mm/cm/inch 单位切换

### AR 测量
- 点击放置两个锚点
- 欧几里得距离计算
- 换算系数：100 像素 ≈ 30 cm（需要 AR 标定）

### 水平仪
- 使用 `sensors_plus` 获取加速度计数据
- 实时计算 roll/pitch 角度
- 支持校准功能（设置零点）
- 气泡可视化倾斜状态

### 标定测量
- 支持多种参考物：硬币、信用卡、A4纸
- 两步测量：先校准参考物，再测量目标
- 显示像素/厘米精度

### 拍照测量
- 使用 `image_picker` 拍照或从相册选择
- 支持手动输入测量值
- 图片和测量结果一起保存

### 测量历史
- 使用 `SharedPreferences` 持久化存储
- 最多保存 100 条记录
- 支持删除单条和清空全部
- 显示相对时间（刚刚、X分钟前）

## 已完成的功能

1. ✅ 测量历史持久化存储
2. ✅ 从设备获取屏幕 PPI（使用 devicePixelRatio 估算）
3. ✅ 接入 sensors_plus 实现真实水平仪
4. ✅ 标定物测量模式
5. ✅ 拍照保存测量结果

## 待优化

1. 屏幕 PPI 需要从设备动态获取真实值（需要 device_info_plus）
2. AR 测量需要集成 ARCore 实现真正的 AR 功能
3. 水平仪精度可以进一步优化（融合陀螺仪数据）
4. 测量历史可以添加搜索和筛选功能
5. 可以添加测量结果分享功能

## 后续计划

- [ ] 集成 ARCore 实现真正的 AR 测量
- [ ] 使用 device_info_plus 获取真实屏幕 PPI
- [ ] 融合陀螺仪数据提高水平仪精度
- [ ] 测量历史搜索和筛选
- [ ] 测量结果分享功能
- [ ] 多语言支持
