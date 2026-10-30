// views/nest_page.dart
import 'package:flutter/material.dart';
import 'konsep_transaksi_page.dart';

/// Halaman kalkulator Nest (berdiri sendiri).
class NestPage extends StatelessWidget {
  const NestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const KonsepTransaksiPage(mode: KalkulatorMode.nest);
  }
}