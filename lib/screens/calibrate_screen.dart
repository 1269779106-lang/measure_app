import 'package:flutter/material.dart';
import '../services/measurement_service.dart';

class CalibrateScreen extends StatefulWidget {
  const CalibrateScreen({super.key});

  @override
  State<CalibrateScreen> createState() => _CalibrateScreenState();
}

class _CalibrateScreenState extends State<CalibrateScreen> {
  String _selectedRef = 'coin_1yuan';
  double _startY = 0;
  double _endY = 0;
  bool _measuring = false;
  double? _result;
  double? _pixelsPerCm;

  // 参考物的实际尺寸（厘米）
  static const Map<String, double> _refSizes = {
    'coin_1yuan': 2.5, // 1元硬币直径 2.5cm
    'coin_5mao': 2.05, // 5角硬币直径 2.05cm
    'card_credit': 8.56, // 信用卡长度 8.56cm
    'card_id': 8.56, // 身份证长度 8.56cm
    'a4_width': 21.0, // A4纸宽度 21cm
    'a4_height': 29.7, // A4纸高度 29.7cm
  };

  static const Map<String, String> _refNames = {
    'coin_1yuan': '1元硬币 (2.5cm)',
    'coin_5mao': '5角硬币 (2.05cm)',
    'card_credit': '信用卡 (8.56cm)',
    'card_id': '身份证 (8.56cm)',
    'a4_width': 'A4纸宽 (21cm)',
    'a4_height': 'A4纸高 (29.7cm)',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('标定测量'),
      ),
      body: Column(
        children: [
          // 提示
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.teal[50],
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.teal[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '使用已知尺寸的物品校准，提高测量精度',
                    style: TextStyle(color: Colors.teal[700]),
                  ),
                ),
              ],
            ),
          ),
          // 选择参考物
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '选择参考物',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _refSizes.keys.map((key) {
                    final isSelected = _selectedRef == key;
                    return ChoiceChip(
                      label: Text(_refNames[key]!),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedRef = key;
                            _pixelsPerCm = null;
                            _result = null;
                            _startY = 0;
                            _endY = 0;
                          });
                        }
                      },
                      selectedColor: Colors.teal[100],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.teal[700] : Colors.grey[700],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // 状态提示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: _pixelsPerCm == null ? Colors.blue[50] : Colors.green[50],
            child: Row(
              children: [
                Icon(
                  _pixelsPerCm == null ? Icons.straighten : Icons.check_circle,
                  color: _pixelsPerCm == null ? Colors.blue[700] : Colors.green[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _pixelsPerCm == null
                        ? '第一步：拖动测量参考物的长度'
                        : '第二步：拖动测量目标物体',
                    style: TextStyle(
                      color: _pixelsPerCm == null ? Colors.blue[700] : Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 测量区域
          Expanded(
            child: GestureDetector(
              onVerticalDragStart: (d) {
                setState(() {
                  _startY = d.localPosition.dy;
                  _endY = d.localPosition.dy;
                  _measuring = true;
                  if (_pixelsPerCm != null) {
                    _result = null;
                  }
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

                  if (_pixelsPerCm == null) {
                    // 校准阶段：计算 pixels/cm
                    double refSize = _refSizes[_selectedRef]!;
                    _pixelsPerCm = pixels / refSize;
                    _result = null;
                  } else {
                    // 测量阶段：计算实际尺寸
                    _result = pixels / _pixelsPerCm!;
                  }
                });
              },
              child: CustomPaint(
                painter: _CalibratePainter(
                  startY: _startY,
                  endY: _endY,
                  measuring: _measuring,
                  isCalibrated: _pixelsPerCm != null,
                ),
                size: Size.infinite,
              ),
            ),
          ),
          // 结果显示
          if (_pixelsPerCm != null && _result != null)
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.grey[100],
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.straighten, color: Colors.teal[700]),
                      const SizedBox(width: 12),
                      Text(
                        '${_result!.toStringAsFixed(2)} cm',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '精度: ${_pixelsPerCm!.toStringAsFixed(1)} 像素/厘米',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => setState(() {
                          _pixelsPerCm = null;
                          _result = null;
                          _startY = 0;
                          _endY = 0;
                        }),
                        icon: const Icon(Icons.refresh),
                        label: const Text('重新校准'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _saveResult,
                        icon: const Icon(Icons.save),
                        label: const Text('保存'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
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
      type: '标定测量',
      value: _result!.toStringAsFixed(2),
      unit: 'cm',
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('测量结果已保存')),
      );
    }
  }
}

class _CalibratePainter extends CustomPainter {
  final double startY;
  final double endY;
  final bool measuring;
  final bool isCalibrated;

  _CalibratePainter({
    required this.startY,
    required this.endY,
    required this.measuring,
    required this.isCalibrated,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 背景网格
    final gridPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 测量标记线
    if (measuring || (startY > 0 && endY > 0)) {
      final markerPaint = Paint()
        ..color = isCalibrated ? Colors.teal : Colors.blue
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

      // 连接线
      final linePaint = Paint()
        ..color = (isCalibrated ? Colors.teal : Colors.blue).withOpacity(0.3)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, endY),
        linePaint,
      );

      // 端点
      final dotPaint = Paint()
        ..color = isCalibrated ? Colors.teal : Colors.blue
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width / 2, startY), 6, dotPaint);
      canvas.drawCircle(Offset(size.width / 2, endY), 6, dotPaint);

      // 白色边框
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(size.width / 2, startY), 6, borderPaint);
      canvas.drawCircle(Offset(size.width / 2, endY), 6, borderPaint);
    }

    // 提示文字
    String hint;
    if (startY == 0 && endY == 0) {
      hint = isCalibrated ? '拖动测量目标物体' : '拖动测量参考物';
    } else {
      hint = '';
    }

    if (hint.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: hint,
          style: TextStyle(color: Colors.grey[500], fontSize: 16),
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
