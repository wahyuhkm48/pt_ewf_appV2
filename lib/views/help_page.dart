import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  static const _faqs = <(IconData, String, String)>[
    (
      Icons.calculate_outlined,
      'Bagaimana cara menghitung Pivot Point atau Nest?',
      'Buka menu Kalkulator, ketuk Konsep Transaksi, lalu pilih Pivot Point atau Nest. '
          'Pilih Sumber Data (Ambil dari Pasar atau Input Manual), lalu ketuk Hitung.',
    ),
    (
      Icons.analytics_outlined,
      'Apa bedanya Pivot Point dan Nest?',
      'Pivot Point menghitung titik pivot beserta level resistance (R1 sampai R4) dan '
          'support (S1 sampai S4) dari High, Low, dan Close, lengkap dengan sinyal buy atau sell. '
          'Nest membandingkan Close kemarin dengan Open hari ini untuk menghasilkan sinyal harian.',
    ),
    (
      Icons.swap_horiz_rounded,
      'Apa itu Ambil dari Pasar dan Input Manual?',
      'Ambil dari Pasar memakai data harga pada tanggal dan produk (Gold, JPK, atau HKK) '
          'yang kamu pilih, dan hasilnya tersimpan di History. Input Manual membuatmu mengisi '
          'sendiri angkanya (High, Low, Close, atau Close kemarin dan Open hari ini untuk Nest). '
          'Hasilnya hanya dihitung di aplikasi dan tidak tersimpan.',
    ),
    (
      Icons.savings_outlined,
      'Bagaimana cara menghitung Emas Fisik?',
      'Buka menu Kalkulator, pilih Emas Fisik, lalu isi Harga Beli dan Harga Jual '
          '(USD per toz), Kurs USD ke IDR (terisi otomatis dengan kurs terkini), dan Modal dalam rupiah. '
          'Hasilnya berisi HHB, HHJ, selisih, berat emas dalam gram, dan keuntungan.',
    ),
    (
      Icons.history_rounded,
      'Bagaimana cara melihat riwayat perhitungan?',
      'Buka menu History di bar bawah, lalu pilih tab Pivot Point, Nest, atau Emas Fisik. '
          'Riwayat terbaru juga tampil di halaman Home, dan view all akan membawamu ke History.',
    ),
    (
      Icons.show_chart_rounded,
      'Bagaimana cara melihat grafik dan data historis?',
      'Buka menu Chart, lalu pilih Gold, JPK (Nikkei), atau HKK (Hang Seng). Di bawah grafik '
          'ada tabel Data Historis 90 hari terakhir berisi Open, High, Low, dan Close, '
          'dengan tombol Excel untuk mengunduhnya.',
    ),
    (
      Icons.newspaper_rounded,
      'Di mana saya bisa membaca berita pasar?',
      'Berita terbaru dari Bloomberg, CNBC, dan Reuters tampil di bagian Information pada '
          'halaman Home. Ketuk view all untuk daftar lengkap, dan tarik layar ke bawah untuk memperbarui.',
    ),
    (
      Icons.person_outline_rounded,
      'Bagaimana cara mengubah informasi akun saya?',
      'Buka Settings, lalu Account Information. Nama lengkap, nomor telepon, dan foto profil '
          '(dari galeri) bisa diubah. Email dan tanggal bergabung tidak bisa diubah.',
    ),
    (
      Icons.lock_outline_rounded,
      'Bagaimana cara mengganti password?',
      'Buka Settings, lalu Password. Isi password saat ini, password baru '
          '(minimal 8 karakter dengan huruf dan angka), lalu konfirmasi password baru.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // BAGIAN ATAS PUTIH
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ada yang bisa kami bantu?',
                    style: AppTextStyles.h2(),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Temukan jawaban dan informasi seputar aplikasi.',
                    style: AppTextStyles.bodySm().copyWith(height: 1.4),
                  ),
                ],
              ),
            ),

            // BAGIAN BAWAH PUTIH
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._faqs.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HelpTile(icon: f.$1, title: f.$2, answer: f.$3),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // CONTACT SUPPORT
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryTint,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.support_agent_rounded,
                              color: AppColors.primary,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Masih butuh bantuan?',
                                  style: AppTextStyles.labelLg(),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Hubungi tim support kami untuk bantuan lebih lanjut.',
                                  style: AppTextStyles.caption(),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: AppColors.secondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpTile extends StatefulWidget {
  final String title;
  final IconData icon;
  final String answer;

  const _HelpTile({
    required this.title,
    required this.icon,
    required this.answer,
  });

  @override
  State<_HelpTile> createState() => _HelpTileState();
}

class _HelpTileState extends State<_HelpTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryTint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(widget.icon, color: AppColors.primary, size: 22),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTextStyles.labelBase(),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(bottom: 14, right: 4),
              child: Text(
                widget.answer,
                style: AppTextStyles.bodySm().copyWith(height: 1.5),
              ),
            ),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}