import 'package:flutter/material.dart';
import 'ruler_screen.dart';
import 'ar_screen.dart';
import 'level_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 标题
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.straighten,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '手机测量器',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '屏幕尺子 · AR测量 · 水平仪',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // 功能网格
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _FeatureCard(
                      icon: Icons.straighten,
                      title: '屏幕尺子',
                      subtitle: '小物件精确测量',
                      color: Colors.blue,
                      onTap: () => _navigate(context, const RulerScreen()),
                    ),
                    _FeatureCard(
                      icon: Icons.view_in_ar,
                      title: 'AR 测量',
                      subtitle: '相机实时测距',
                      color: Colors.green,
                      onTap: () => _navigate(context, const ArScreen()),
                    ),
                    _FeatureCard(
                      icon: Icons.explore,
                      title: '水平仪',
                      subtitle: '角度和倾斜',
                      color: Colors.orange,
                      onTap: () => _navigate(context, const LevelScreen()),
                    ),
                    _FeatureCard(
                      icon: Icons.history,
                      title: '测量历史',
                      subtitle: '查看历史记录',
                      color: Colors.purple,
                      onTap: () => _navigate(context, const HistoryScreen()),
                    ),
                  ],
                ),
              ),
            ),
            // 底部提示
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '提示：屏幕尺子适合测量小物件，AR测量适合中等距离',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
