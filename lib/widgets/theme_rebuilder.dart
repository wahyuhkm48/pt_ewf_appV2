// widgets/theme_rebuilder.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme_controller.dart';

class ThemeRebuilder extends StatefulWidget {
  final Widget child;
  const ThemeRebuilder({super.key, required this.child});

  @override
  State<ThemeRebuilder> createState() => _ThemeRebuilderState();
}

class _ThemeRebuilderState extends State<ThemeRebuilder> {
  late final ThemeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<ThemeController>();
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    // Tunggu frame berikutnya supaya MaterialApp sudah memakai tema baru
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      void rebuild(Element el) {
        el.markNeedsBuild();
        el.visitChildren(rebuild);
      }

      (context as Element).visitChildren(rebuild);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}