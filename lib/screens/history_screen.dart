import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<_Measurement> _measurements = [
    _Measurement(
      type: '屏幕尺子',
      value: '5.2 cm',
      time: '2026-05-27 14:30',
      icon: Icons.straighten,
    ),
    _Measurement(
      type: 'AR 测量',
      value: '1.25 m',
      time: '2026-05-27 14:25',
      icon: Icons.view_in_ar,
    ),
    _Measurement(
      type: '水平仪',
      value: '0.5°',
      time: '2026-05-27 14:20',
      icon: Icons.explore,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('测量历史'),
        actions: [
          if (_measurements.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAll,
            ),
        ],
      ),
      body: _measurements.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    '暂无测量记录',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _measurements.length,
              itemBuilder: (context, index) {
                final m = _measurements[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getColor(m.type).withOpacity(0.1),
                      child: Icon(m.icon, color: _getColor(m.type)),
                    ),
                    title: Text(
                      m.value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text('${m.type} · ${m.time}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(index),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getColor(String type) {
    switch (type) {
      case '屏幕尺子':
        return Colors.blue;
      case 'AR 测量':
        return Colors.green;
      case '水平仪':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _delete(int index) {
    setState(() {
      _measurements.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已删除')),
    );
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空历史'),
        content: const Text('确定要清空所有测量记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _measurements.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

class _Measurement {
  final String type;
  final String value;
  final String time;
  final IconData icon;

  _Measurement({
    required this.type,
    required this.value,
    required this.time,
    required this.icon,
  });
}
