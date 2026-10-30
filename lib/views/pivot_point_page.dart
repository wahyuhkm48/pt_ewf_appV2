// views/pivot_point_page.dart
import 'package:flutter/material.dart';
import 'konsep_transaksi_page.dart';

/// Halaman kalkulator Pivot Point (berdiri sendiri).
class PivotPointPage extends StatelessWidget {
  const PivotPointPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const KonsepTransaksiPage(mode: KalkulatorMode.pivotPoint);
  }
}