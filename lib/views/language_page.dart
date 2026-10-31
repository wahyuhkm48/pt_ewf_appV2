import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String _selectedLanguage = 'id';

  final List<_LanguageOption> _languages = [
    _LanguageOption(
      code: 'id',
      flag: '🇮🇩',
      name: 'Bahasa Indonesia',
      subtitle: 'Bahasa default aplikasi',
    ),
    _LanguageOption(
      code: 'en',
      flag: '🇬🇧',
      name: 'English',
      subtitle: 'Gunakan Bahasa Inggris',
    ),
    _LanguageOption(
      code: 'zh',
      flag: '🇨🇳',
      name: '中文',
      subtitle: '使用简体中文',
    ),
    _LanguageOption(
      code: 'ms',
      flag: '🇲🇾',
      name: 'Bahasa Melayu',
      subtitle: 'Gunakan Bahasa Melayu',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,

      appBar: AppBar(
        title: const Text('Bahasa'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),

      // ================= BODY =================
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= HEADER =================
                    Text(
                      'Pilih Bahasa',
                      style: AppTextStyles.h2(),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Pilih bahasa yang ingin kamu gunakan di aplikasi.',
                      style: AppTextStyles.bodyMd().copyWith(height: 1.4),
                    ),

                    const SizedBox(height: 24),

                    // ================= LANGUAGE LIST =================
                    ..._languages.map(
                      (language) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _LanguageTile(
                          option: language,
                          selected: _selectedLanguage == language.code,
                          onTap: () {
                            setState(() {
                              _selectedLanguage = language.code;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ================= ILLUSTRATION =================
                    const Center(
                      child: _GlobeIllustration(),
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: Text(
                        'Perubahan bahasa akan diterapkan ke seluruh aplikasi.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySm().copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ================= SAVE BUTTON =================
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: AppColors.divider,
                    width: 1,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Simpan Perubahan',
                    style: AppTextStyles.labelLg(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// LANGUAGE OPTION
// ======================================================

class _LanguageOption {
  final String code;
  final String flag;
  final String name;
  final String subtitle;

  _LanguageOption({
    required this.code,
    required this.flag,
    required this.name,
    required this.subtitle,
  });
}

// ======================================================
// LANGUAGE TILE
// ======================================================

class _LanguageTile extends StatelessWidget {
  final _LanguageOption option;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryTint
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.divider,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // FLAG
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  option.flag,
                  style: const TextStyle(fontSize: 25),
                ),
              ),

              const SizedBox(width: 14),

              // NAME + SUBTITLE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name,
                      style: AppTextStyles.labelLg(),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.subtitle,
                      style: AppTextStyles.caption(),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // CHECK
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? AppColors.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.divider,
                    width: 2,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// GLOBE ILLUSTRATION
// ======================================================

class _GlobeIllustration extends StatelessWidget {
  const _GlobeIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // GLOBE
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.globeLight,
                  AppColors.globeDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.public,
              color: Colors.white,
              size: 58,
            ),
          ),

          // ID
          Positioned(
            left: 5,
            top: 8,
            child: _LanguageBubble(
              text: 'ID',
              color: AppColors.primary
            ),
          ),

          // EN
          Positioned(
            right: 5,
            bottom: 8,
            child: _LanguageBubble(
              text: 'EN',
              color: AppColors.globeDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// LANGUAGE BUBBLE
// ======================================================

class _LanguageBubble extends StatelessWidget {
  final String text;
  final Color color;

  const _LanguageBubble({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSm(color: Colors.white),
      ),
    );
  }
}