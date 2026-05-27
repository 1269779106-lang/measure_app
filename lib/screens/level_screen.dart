import 'package:flutter/material.dart';
import 'dart:math';

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  double _angle = 0;
  double _roll = 0;
  double _pitch = 0;

  @override
  void initState() {
    super.initState();
    // 模拟传感器数据（实际应使用 sensors_plus）
    _startSimulation();
  }

  void _startSimulation() {
    // 模拟水平仪数据
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _angle = 0;
          _roll = 0;
          _pitch = 0;
        });
      }
    });
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
                    _AngleDisplay(label: 'X', value: _roll),
                    _AngleDisplay(label: 'Y', value: _pitch),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _isLevel => _angle.abs() < 2;

  void _calibrate() {
    setState(() {
      _angle = 0;
      _roll = 0;
      _pitch = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已校准')),
    );
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
    double bubbleX = center.dx + roll * 2;
    double bubbleY = center.dy + pitch * 2;

    // 限制在圆内
    double dx = bubbleX - center.dx;
    double dy = bubbleY - center.dy;
    double dist = sqrt(dx * dx + dy * dy);
    if (dist > radius * 0.8) {
      double scale = radius * 0.8 / dist;
      bubbleX = center.dx + dx * scale;
      bubbleY = center.dy + dy * scale;
    }

    final bubblePaint = Paint()
      ..color = (roll.abs() < 2 && pitch.abs() < 2)
          ? Colors.green
          : Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(bubbleX, bubbleY), 15, bubblePaint);

    // 气泡边框
    final bubbleBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(bubbleX, bubbleY), 15, bubbleBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
