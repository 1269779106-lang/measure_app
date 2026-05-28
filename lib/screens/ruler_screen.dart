import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/measurement_service.dart';

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

  // 获取真实屏幕 PPI
  double get _ppi {
    // Flutter 中可以通过 window.devicePixelRatio 获取设备像素比
    // 但 PPI 需要物理尺寸，这里使用常见设备的估算值
    // Android 设备通常在 160-640 PPI 之间
    // 使用 devicePixelRatio * 160 作为估算（Android 基准 160 PPI）
    final dpr = window.devicePixelRatio;
    // 大多数 Android 设备的基准 PPI 是 160，乘以 devicePixelRatio 得到实际 PPI
    // 但这个值可能不准确，最好使用 device_info_plus 获取真实值
    // 这里先用一个更合理的估算：中端手机通常 400-440 PPI
    return 160.0 * dpr;
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
          // PPI 信息
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(Icons.phone_android, size: 16, color: Colors.blue[400]),
                const SizedBox(width: 4),
                Text(
                  '屏幕 PPI: ${_ppi.toStringAsFixed(0)}',
                  style: TextStyle(color: Colors.blue[400], fontSize: 12),
                ),
                const Spacer(),
                Text(
                  '像素比: ${window.devicePixelRatio.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.blue[400], fontSize: 12),
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
              child: Column(
                children: [
                  Row(
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
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => setState(() {
                          _startY = 0;
                          _endY = 0;
                          _result = null;
                        }),
                        icon: const Icon(Icons.refresh),
                        label: const Text('重新测量'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _saveResult,
                        icon: const Icon(Icons.save),
                        label: const Text('保存'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
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

  Future<void> _saveResult() async {
    if (_result == null) return;

    await MeasurementService.save(Measurement(
      type: '屏幕尺子',
      value: _result!.toStringAsFixed(1),
      unit: _unit,
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('测量结果已保存')),
      );
    }
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

      // 显示测量距离
      if (!measuring && startY > 0 && endY > 0) {
        double pixels = (endY - startY).abs();
        double cm = pixels * pixelToCm;
        String text;
        if (unit == 'mm') {
          text = '${(cm * 10).toStringAsFixed(1)} mm';
        } else if (unit == 'inch') {
          text = '${(cm / 2.54).toStringAsFixed(2)} in';
        } else {
          text = '${cm.toStringAsFixed(1)} cm';
        }

        final textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              backgroundColor: Color(0x80FFFFFF),
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(size.width / 2 + 10, (startY + endY) / 2 - 7),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
