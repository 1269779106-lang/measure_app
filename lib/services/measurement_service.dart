import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Measurement {
  final String type;
  final String value;
  final String unit;
  final DateTime time;
  final String? imagePath;

  Measurement({
    required this.type,
    required this.value,
    required this.unit,
    DateTime? time,
    this.imagePath,
  }) : time = time ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'type': type,
        'value': value,
        'unit': unit,
        'time': time.toIso8601String(),
        'imagePath': imagePath,
      };

  factory Measurement.fromJson(Map<String, dynamic> json) => Measurement(
        type: json['type'] as String,
        value: json['value'] as String,
        unit: json['unit'] as String,
        time: DateTime.parse(json['time'] as String),
        imagePath: json['imagePath'] as String?,
      );

  String get displayValue => '$value $unit';

  String get displayTime {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
    if (diff.inDays < 1) return '${diff.inHours} 小时前';
    if (diff.inDays < 7) return '${diff.inDays} 天前';

    return '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';
  }
}

class MeasurementService {
  static const String _key = 'measurements';
  static const int _maxRecords = 100;

  static Future<List<Measurement>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList
        .map((json) => Measurement.fromJson(json as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.time.compareTo(a.time));
  }

  static Future<void> save(Measurement measurement) async {
    final list = await loadAll();
    list.insert(0, measurement);

    // 限制最大记录数
    if (list.length > _maxRecords) {
      list.removeRange(_maxRecords, list.length);
    }

    await _saveAll(list);
  }

  static Future<void> delete(int index) async {
    final list = await loadAll();
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      await _saveAll(list);
    }
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> _saveAll(List<Measurement> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(list.map((m) => m.toJson()).toList());
    await prefs.setString(_key, jsonStr);
  }
}
