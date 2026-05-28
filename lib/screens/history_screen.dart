import 'package:flutter/material.dart';
import '../services/measurement_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Measurement> _measurements = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final list = await MeasurementService.loadAll();
    setState(() {
      _measurements = list;
      _loading = false;
    });
  }

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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _measurements.isEmpty
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
                      const SizedBox(height: 8),
                      Text(
                        '完成测量后会自动保存到这里',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
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
                          child: Icon(_getIcon(m.type), color: _getColor(m.type)),
                        ),
                        title: Text(
                          m.displayValue,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text('${m.type} · ${m.displayTime}'),
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
      case '标定测量':
        return Colors.teal;
      case '拍照测量':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case '屏幕尺子':
        return Icons.straighten;
      case 'AR 测量':
        return Icons.view_in_ar;
      case '水平仪':
        return Icons.explore;
      case '标定测量':
        return Icons.grid_on;
      case '拍照测量':
        return Icons.camera_alt;
      default:
        return Icons.history;
    }
  }

  Future<void> _delete(int index) async {
    await MeasurementService.delete(index);
    await _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已删除')),
      );
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空历史'),
        content: const Text('确定要清空所有测量记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await MeasurementService.clearAll();
      await _loadData();
    }
  }
}
