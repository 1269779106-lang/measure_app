import 'package:flutter/material.dart';

class ArScreen extends StatefulWidget {
  const ArScreen({super.key});

  @override
  State<ArScreen> createState() => _ArScreenState();
}

class _ArScreenState extends State<ArScreen> {
  List<Offset> _points = [];
  double? _distance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR 测量'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {
              _points = [];
              _distance = null;
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          // 提示
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.green[50],
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.green[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '点击屏幕放置两个点来测量距离',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ),
              ],
            ),
          ),
          // 相机预览区域（模拟）
          Expanded(
            child: GestureDetector(
              onTapUp: (details) {
                setState(() {
                  if (_points.length < 2) {
                    _points.add(details.localPosition);
                    if (_points.length == 2) {
                      _calculateDistance();
                    }
                  }
                });
              },
              child: Container(
                color: Colors.grey[200],
                child: CustomPaint(
                  painter: _ArPainter(points: _points),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
          // 结果
          if (_distance != null)
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey[100],
              child: Column(
                children: [
                  Text(
                    '${(_distance! / 100).toStringAsFixed(2)} m',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  Text(
                    '${_distance!.toStringAsFixed(1)} cm',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => setState(() {
                          _points = [];
                          _distance = null;
                        }),
                        icon: const Icon(Icons.refresh),
                        label: const Text('重新测量'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _saveResult,
                        icon: const Icon(Icons.save),
                        label: const Text('保存'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
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

  void _calculateDistance() {
    if (_points.length != 2) return;
    // 模拟计算：像素距离 * 换算系数
    double dx = _points[1].dx - _points[0].dx;
    double dy = _points[1].dy - _points[0].dy;
    double pixels = (dx * dx + dy * dy);
    if (pixels > 0) {
      pixels = _sqrt(pixels);
    }
    // 假设 100 像素 = 30 cm（实际需要 AR 标定）
    _distance = pixels * 0.3;
  }

  double _sqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  void _saveResult() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('测量结果已保存')),
    );
  }
}

class _ArPainter extends CustomPainter {
  final List<Offset> points;

  _ArPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.fill;

    // 画点
    for (var point in points) {
      canvas.drawCircle(point, 8, paint);
    }

    // 画线
    if (points.length == 2) {
      final linePaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 2;
      canvas.drawLine(points[0], points[1], linePaint);

      // 计算距离
      double dx = points[1].dx - points[0].dx;
      double dy = points[1].dy - points[0].dy;
      double dist = (dx * dx + dy * dy);
      if (dist > 0) {
        dist = _sqrt(dist);
      }
      double cm = dist * 0.3;

      // 显示距离
      Offset mid = Offset(
        (points[0].dx + points[1].dx) / 2,
        (points[0].dy + points[1].dy) / 2,
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${cm.toStringAsFixed(1)} cm',
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            backgroundColor: Color(0x80FFFFFF),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(mid.dx - 30, mid.dy - 20));
    }

    // 提示文字
    if (points.isEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '点击屏幕放置起点',
          style: TextStyle(color: Colors.grey[600], fontSize: 18),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(
        (size.width - textPainter.width) / 2,
        size.height / 2,
      ));
    } else if (points.length == 1) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '点击屏幕放置终点',
          style: TextStyle(color: Colors.grey[600], fontSize: 18),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(
        (size.width - textPainter.width) / 2,
        size.height / 2,
      ));
    }
  }

  double _sqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
