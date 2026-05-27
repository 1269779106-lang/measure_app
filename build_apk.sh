#!/bin/bash
export PATH="/d/flutter/bin:$PATH"
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
cd /d/mimo_soft/measure_app
flutter build apk --release 2>&1
