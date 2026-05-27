# 手机测量器 (MeasureApp)

轻量级手机测量工具 App，支持屏幕尺子、AR 测量、水平仪三种模式。

## 功能

- **屏幕尺子**：手机屏幕当尺子，精确测量小物件（±0.5mm）
- **AR 测量**：相机实时测距，点击两点测量距离（±2cm）
- **水平仪**：利用陀螺仪检测倾斜角度
- **测量历史**：保存和查看历史测量记录
- **单位切换**：支持 mm/cm/m/inch/ft

## 安装

### 安装 Flutter SDK

1. 下载 Flutter SDK：https://flutter.dev/docs/get-started/install/windows
2. 解压到 `D:\flutter`
3. 添加环境变量：`D:\flutter\bin`
4. 运行 `flutter doctor` 检查环境

### 运行项目

```bash
cd D:\mimo_soft\measure_app
flutter pub get
flutter run
```

### 构建 APK

```bash
flutter build apk --release
```

生成文件：`build/app/outputs/flutter-apk/app-release.apk`

## 项目结构

```
lib/
├── main.dart              # 入口
├── screens/
│   ├── home_screen.dart   # 主页
│   ├── ruler_screen.dart  # 屏幕尺子
│   ├── ar_screen.dart     # AR 测量
│   ├── level_screen.dart  # 水平仪
│   └── history_screen.dart # 历史记录
├── widgets/
├── models/
├── services/
└── utils/
```

## 技术栈

- Flutter 3.x
- Dart
- sensors_plus（陀螺仪/加速度计）
- permission_handler（权限管理）
- shared_preferences（本地存储）

## 测量精度

| 模式 | 精度 | 适用场景 |
|------|------|----------|
| 屏幕尺子 | ±0.5mm | 小物件（硬币、钥匙） |
| AR 测量 | ±2cm | 中等距离（桌子、房间） |
| 水平仪 | ±0.5° | 检测水平/垂直 |

## License

[MIT](LICENSE)
