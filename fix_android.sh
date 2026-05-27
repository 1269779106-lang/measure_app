#!/bin/bash
export PATH="/d/flutter/bin:$PATH"
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
cd /d/mimo_soft/measure_app
# 备份 lib 目录
cp -r lib /tmp/measure_lib_backup
# 用 flutter create 重建 Android/iOS 项目文件
flutter create --org com.example --project-name measure_app . 2>&1
# 恢复 lib 目录
rm -rf lib
cp -r /tmp/measure_lib_backup lib
rm -rf /tmp/measure_lib_backup
echo "Done"
