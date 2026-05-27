import 'package:flutter/material.dart';

class RulerScreen extends StatefulWidget {
  const RulerScreen({super.key});

  @override
  State<RulerScreen> createState() => _RulerScreenState();
}

class _RulerScreenState extends State<RulerScreen> {
  String _unit = 'cm';
  double _startY = 0;
  double _endY = 0;
  bool _measuring = false;
  double? _result;

  // 屏幕 PPI（每英寸像素数），Android 通常 160-640
  // 这里用 MediaQuery 获取设备像素比，再换算
  double get _ppi {
    // 1 英寸 = 2.54 cm
    // 假设标准 PPI 为 160（Android mdpi），实际应从设备获取
    return 160.0;
  }

  double get _pixelToCm => 2.54 / _ppi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('屏幕尺子'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => setState(() => _unit = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'mm', child: Text('毫米 (mm)')),
              const PopupMenuItem(value: 'cm', child: Text('厘米 (cm)')),
              const PopupMenuItem(value: 'inch', child: Text('英寸 (in)')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Chip(label: Text(_unit)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 提示
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '将物体放在屏幕上，拖动标记起点和终点',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ),
          // 尺子区域
          Expanded(
            child: GestureDetector(
              onVerticalDragStart: (d) {
                setState(() {
                  _startY = d.localPosition.dy;
                  _endY = d.localPosition.dy;
                  _measuring = true;
                  _result = null;
                });
              },
              onVerticalDragUpdate: (d) {
                setState(() {
                  _endY = d.localPosition.dy;
                });
              },
              onVerticalDragEnd: (d) {
                setState(() {
                  _measuring = false;
                  double pixels = (_endY - _startY).abs();
                  double cm = pixels * _pixelToCm;
                  if (_unit == 'mm') {
                    _result = cm * 10;
                  } else if (_unit == 'inch') {
                    _result = cm / 2.54;
                  } else {
                    _result = cm;
                  }
                });
              },
              child: CustomPaint(
                painter: _RulerPainter(
                  startY: _startY,
                  endY: _endY,
                  measuring: _measuring,
                  unit: _unit,
                  pixelToCm: _pixelToCm,
                ),
                size: Size.infinite,
              ),
            ),
          ),
          // 结果显示
          if (_result != null)
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.straighten, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Text(
                    '${_result!.toStringAsFixed(1)} $_unit',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  final double startY;
  final double endY;
  final bool measuring;
  final String unit;
  final double pixelToCm;

  _RulerPainter({
    required this.startY,
    required this.endY,
    required this.measuring,
    required this.unit,
    required this.pixelToCm,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    // 画刻度线
    double cmPerPixel = pixelToCm;
    double pixelsPerCm = 1.0 / cmPerPixel;

    for (double y = 0; y < size.height; y += pixelsPerCm / 10) {
      double cm = y * cmPerPixel;
      bool isCm = (cm * 10).round() % 10 == 0;
      bool isHalf = (cm * 10).round() % 5 == 0;

      double lineWidth = isCm ? 40 : (isHalf ? 25 : 15);
      paint.color = isCm ? Colors.grey[600]! : Colors.grey[400]!;
      paint.strokeWidth = isCm ? 2 : 1;

      canvas.drawLine(
        Offset(0, y),
        Offset(lineWidth, y),
        paint,
      );

      // 厘米标注
      if (isCm) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${cm.toStringAsFixed(0)}',
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(45, y - 6));
      }
    }

    // 测量标记线
    if (measuring || (startY > 0 && endY > 0)) {
      final markerPaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 2;

      canvas.drawLine(
        Offset(0, startY),
        Offset(size.width, startY),
        markerPaint,
      );
      canvas.drawLine(
        Offset(0, endY),
        Offset(size.width, endY),
        markerPaint,
      );

      // 起点圆点
      canvas.drawCircle(Offset(size.width / 2, startY), 6, markerPaint);
      canvas.drawCircle(Offset(size.width / 2, endY), 6, markerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
