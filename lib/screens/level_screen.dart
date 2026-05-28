import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import '../services/measurement_service.dart';

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  double _roll = 0;
  double _pitch = 0;
  double _angle = 0;
  StreamSubscription<AccelerometerEvent>? _subscription;
  bool _isCalibrated = false;
  double _calibrateRoll = 0;
  double _calibratePitch = 0;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _startListening() {
    // 使用加速度计传感器，每 100ms 更新一次
    _subscription = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 100),
    ).listen((event) {
      if (mounted) {
        setState(() {
          // 从加速度计算倾斜角度
          // x: 左右倾斜 (roll), y: 前后倾斜 (pitch)
          _roll = _calculateAngle(event.x, event.y, event.z);
          _pitch = _calculateAngle(event.y, event.x, event.z);

          // 应用校准偏移
          if (_isCalibrated) {
            _roll -= _calibrateRoll;
            _pitch -= _calibratePitch;
          }

          // 计算综合倾斜角度
          _angle = sqrt(_roll * _roll + _pitch * _pitch);
        });
      }
    });
  }

  double _calculateAngle(double a, double b, double c) {
    // 使用 atan2 计算角度，转换为度数
    double radians = atan2(a, sqrt(b * b + c * c));
    return radians * 180 / pi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('水平仪'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _calibrate,
            tooltip: '校准',
          ),
        ],
      ),
      body: Column(
        children: [
          // 提示
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.orange[50],
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '将手机放在平面上，圆圈居中表示水平',
                    style: TextStyle(color: Colors.orange[700]),
                  ),
                ),
              ],
            ),
          ),
          // 传感器状态
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            color: Colors.orange[50],
            child: Row(
              children: [
                Icon(Icons.sensors, size: 16, color: Colors.orange[400]),
                const SizedBox(width: 4),
                Text(
                  '加速度计实时数据',
                  style: TextStyle(color: Colors.orange[400], fontSize: 12),
                ),
                const Spacer(),
                if (_isCalibrated)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '已校准',
                      style: TextStyle(color: Colors.green[700], fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
          // 水平仪显示
          Expanded(
            child: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: CustomPaint(
                  painter: _LevelPainter(
                    roll: _roll,
                    pitch: _pitch,
                  ),
                ),
              ),
            ),
          ),
          // 角度显示
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.grey[100],
            child: Column(
              children: [
                Text(
                  '${_angle.toStringAsFixed(1)}°',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _isLevel ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLevel ? '水平' : '倾斜',
                  style: TextStyle(
                    fontSize: 18,
                    color: _isLevel ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _AngleDisplay(label: 'X (左右)', value: _roll),
                    _AngleDisplay(label: 'Y (前后)', value: _pitch),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _calibrate,
                      icon: const Icon(Icons.tune),
                      label: const Text('校准'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _saveResult,
                      icon: const Icon(Icons.save),
                      label: const Text('保存角度'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _isLevel => _angle < 2;

  void _calibrate() {
    setState(() {
      _calibrateRoll = _roll;
      _calibratePitch = _pitch;
      _isCalibrated = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已校准，当前角度设为零点')),
    );
  }

  Future<void> _saveResult() async {
    await MeasurementService.save(Measurement(
      type: '水平仪',
      value: _angle.toStringAsFixed(1),
      unit: '°',
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('测量结果已保存')),
      );
    }
  }
}

class _AngleDisplay extends StatelessWidget {
  final String label;
  final double value;

  const _AngleDisplay({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          '${value.toStringAsFixed(1)}°',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _LevelPainter extends CustomPainter {
  final double roll;
  final double pitch;

  _LevelPainter({required this.roll, required this.pitch});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // 外圈
    final outerPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, outerPaint);

    // 内圈
    final innerPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.75, innerPaint);
    canvas.drawCircle(center, radius * 0.5, innerPaint);
    canvas.drawCircle(center, radius * 0.25, innerPaint);

    // 十字线
    final crossPaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      crossPaint,
    );

    // 中心点
    final centerPaint = Paint()
      ..color = Colors.grey[600]!
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, centerPaint);

    // 气泡（根据倾斜移动）
    // roll: 左右倾斜，pitch: 前后倾斜
    double bubbleX = center.dx + roll * 3;
    double bubbleY = center.dy + pitch * 3;

    // 限制在圆内
    double dx = bubbleX - center.dx;
    double dy = bubbleY - center.dy;
    double dist = sqrt(dx * dx + dy * dy);
    if (dist > radius * 0.8) {
      double scale = radius * 0.8 / dist;
      bubbleX = center.dx + dx * scale;
      bubbleY = center.dy + dy * scale;
    }

    // 气泡颜色：水平时绿色，倾斜时红色
    double totalAngle = sqrt(roll * roll + pitch * pitch);
    final bubblePaint = Paint()
      ..color = totalAngle < 2 ? Colors.green : Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(bubbleX, bubbleY), 15, bubblePaint);

    // 气泡边框
    final bubbleBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(bubbleX, bubbleY), 15, bubbleBorderPaint);

    // 显示角度值
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${totalAngle.toStringAsFixed(1)}°',
        style: TextStyle(
          color: totalAngle < 2 ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(
      center.dx - textPainter.width / 2,
      center.dy + radius + 10,
    ));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
