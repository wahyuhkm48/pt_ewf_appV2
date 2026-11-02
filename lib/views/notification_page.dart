import 'package:flutter/material.dart' hide Text;
import '../widgets/app_text.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _enableAll = true;
  bool _priceAlert = true;
  bool _priceIncrease = true;
  bool _priceDecrease = true;
  bool _latestNews = true;

  void _toggleAll(bool value) {
    setState(() {
      _enableAll = value;
      _priceAlert = value;
      _priceIncrease = value;
      _priceDecrease = value;
      _latestNews = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aktifkan Semua Notifikasi',
                        style: AppTextStyles.labelLg(),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Terima semua notifikasi dari aplikasi.',
                        style: AppTextStyles.caption(),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _enableAll,
                  activeThumbColor: AppColors.primary,
                  onChanged: _toggleAll,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Pengaturan Notifikasi',
            style: AppTextStyles.labelBase(color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          _NotificationTile(
            icon: Icons.notifications_none_rounded,
            title: 'Peringatan Harga',
            subtitle: 'Dapatkan notifikasi saat harga mencapai target kamu',
            value: _priceAlert,
            onChanged: (v) => setState(() => _priceAlert = v),
          ),
          _NotificationTile(
            icon: Icons.trending_up_rounded,
            title: 'Harga Naik',
            subtitle: 'Beri tahu saat harga naik',
            value: _priceIncrease,
            onChanged: (v) => setState(() => _priceIncrease = v),
          ),
          _NotificationTile(
            icon: Icons.trending_down_rounded,
            title: 'Harga Turun',
            subtitle: 'Beri tahu saat harga turun',
            value: _priceDecrease,
            onChanged: (v) => setState(() => _priceDecrease = v),
          ),
          _NotificationTile(
            icon: Icons.article_outlined,
            title: 'Berita Terbaru',
            subtitle: 'Dapatkan notifikasi tentang berita dan pembaruan terbaru',
            value: _latestNews,
            onChanged: (v) => setState(() => _latestNews = v),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelBase()),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption()),
              ],
            ),
          ),
          Switch(value: value, activeThumbColor: AppColors.primary, onChanged: onChanged),
        ],
      ),
    );
  }
}