// widgets/offline_widgets.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/connectivity_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

const kPesanOfflineUmum =
    'Fitur ini membutuhkan internet. Saat offline, hanya hitung manual Pivot Point dan Nest yang bisa dipakai.';

/// Dipasang di MaterialApp.builder: strip status di atas SEMUA halaman.
class OfflineBannerHost extends StatelessWidget {
  final Widget child;
  const OfflineBannerHost({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final net = context.watch<ConnectivityService>();
    final show = net.isOffline || net.justReconnected;

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          alignment: Alignment.topCenter,
          child: show
              ? _StatusBanner(offline: net.isOffline)
              : const SizedBox(width: double.infinity),
        ),
        Expanded(
          // saat strip tampil, strip itu yang menutupi status bar,
          // jadi halaman di bawahnya tidak perlu padding atas lagi
          child: MediaQuery.removePadding(
            context: context,
            removeTop: show,
            child: child,
          ),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final bool offline;
  const _StatusBanner({required this.offline});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: offline ? AppColors.textPrimary : AppColors.success,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(offline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                  size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  offline
                      ? 'Tidak ada koneksi internet. Hanya hitung manual yang tersedia.'
                      : 'Koneksi kembali tersambung.',
                  style: AppTextStyles.bodySm(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Keterangan "butuh internet". compact = kartu kecil, tidak compact = layar penuh.
class OfflineNotice extends StatefulWidget {
  final String title;
  final String message;
  final bool compact;
  final String? alternativeLabel;
  final VoidCallback? onAlternative;

  const OfflineNotice({
    super.key,
    this.title = 'Tidak ada koneksi internet',
    this.message = kPesanOfflineUmum,
    this.compact = false,
    this.alternativeLabel,
    this.onAlternative,
  });

  @override
  State<OfflineNotice> createState() => _OfflineNoticeState();
}

class _OfflineNoticeState extends State<OfflineNotice> {
  bool _checking = false;

  Future<void> _cobaLagi() async {
    setState(() => _checking = true);
    final online = await context.read<ConnectivityService>().check();
    if (!mounted) return;
    setState(() => _checking = false);
    if (!online) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masih belum tersambung ke internet.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.compact ? _buildCompact() : _buildFull();
  }

  Widget _buildFull() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76, height: 76,
              decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
              child: Icon(Icons.wifi_off_rounded, size: 36, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Text(widget.title, style: AppTextStyles.h3(), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(widget.message, style: AppTextStyles.bodyMd(), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            if (widget.alternativeLabel != null && widget.onAlternative != null) ...[
              ElevatedButton(
                onPressed: widget.onAlternative,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(widget.alternativeLabel!),
              ),
              const SizedBox(height: 8),
            ],
            OutlinedButton.icon(
              onPressed: _checking ? null : _cobaLagi,
              icon: _checking
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                  : const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba lagi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompact() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.wifi_off_rounded, size: 22, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: AppTextStyles.labelBase()),
                const SizedBox(height: 2),
                Text(widget.message, style: AppTextStyles.bodySm()),
                const SizedBox(height: 4),
                Wrap(
                  children: [
                    if (widget.alternativeLabel != null && widget.onAlternative != null)
                      TextButton(
                        onPressed: widget.onAlternative,
                        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                        child: Text(widget.alternativeLabel!),
                      ),
                    TextButton(
                      onPressed: _checking ? null : _cobaLagi,
                      style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                      child: Text(_checking ? 'Memeriksa...' : 'Coba lagi'),
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
}

/// Bungkus bagian halaman yang butuh internet. Online -> [child] tampil normal.
/// Offline -> diganti [OfflineNotice]. [onReconnect] jalan sekali saat koneksi kembali.
class OnlineGate extends StatefulWidget {
  final Widget child;
  final String title;
  final String message;
  final bool compact;
  final VoidCallback? onReconnect;

  const OnlineGate({
    super.key,
    required this.child,
    this.title = 'Fitur ini butuh internet',
    this.message = kPesanOfflineUmum,
    this.compact = false,
    this.onReconnect,
  });

  @override
  State<OnlineGate> createState() => _OnlineGateState();
}

class _OnlineGateState extends State<OnlineGate> {
  bool? _wasOnline;

  @override
  Widget build(BuildContext context) {
    final online = context.select<ConnectivityService, bool>((n) => n.isOnline);

    if (_wasOnline == false && online) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onReconnect?.call();
      });
    }
    _wasOnline = online;

    if (online) return widget.child;
    return OfflineNotice(title: widget.title, message: widget.message, compact: widget.compact);
  }
}

/// Pengganti satu halaman penuh saat offline (tetap punya AppBar + tombol kembali).
class OfflinePageScaffold extends StatelessWidget {
  final String title;
  final String message;
  const OfflinePageScaffold({super.key, required this.title, this.message = kPesanOfflineUmum});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: OfflineNotice(title: '$title butuh internet', message: message),
      ),
    );
  }
}