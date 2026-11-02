// widgets/theme_rebuilder.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme_controller.dart';
import '../l10n/language_controller.dart';

/// Membangun ulang seluruh tampilan saat tema atau bahasa berubah.
class ThemeRebuilder extends StatefulWidget {
  final Widget child;
  const ThemeRebuilder({super.key, required this.child});

  @override
  State<ThemeRebuilder> createState() => _ThemeRebuilderState();
}

class _ThemeRebuilderState extends State<ThemeRebuilder> {
  late final ThemeController _theme;
  late final LanguageController _lang;

  @override
  void initState() {
    super.initState();
    _theme = context.read<ThemeController>();
    _lang = context.read<LanguageController>();
    _theme.addListener(_onChanged);
    _lang.addListener(_onChanged);
  }

  void _onChanged() {
    // Tunggu frame berikutnya supaya MaterialApp sudah memakai nilai baru
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
    _theme.removeListener(_onChanged);
    _lang.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}