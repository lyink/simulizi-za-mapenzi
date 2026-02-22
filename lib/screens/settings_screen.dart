import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.watch<ThemeProvider>().isDark;
    final textPrimary = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final textSub = theme.textTheme.bodyMedium?.color ?? Colors.grey;
    final cardColor = theme.cardTheme.color ?? Colors.white;
    final divColor =
        theme.dividerTheme.color ?? Colors.grey.withValues(alpha: 0.2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Banner ad at top
          const BannerAdWidget(),
          const SizedBox(height: 20),

          // ── Appearance section ──────────────────────────────────────
          _SectionHeader(label: 'APPEARANCE', textColor: textSub),
          const SizedBox(height: 10),

          // Theme toggle card
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: divColor),
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  iconColor: isDark ? const Color(0xFF7B9CFF) : AppTheme.gold,
                  title: 'Theme',
                  subtitle: isDark ? 'Dark mode' : 'Light mode',
                  trailing: Switch.adaptive(
                    value: isDark,
                    activeTrackColor: AppTheme.accent,
                    onChanged: (v) => context.read<ThemeProvider>().setDark(v),
                  ),
                  textPrimary: textPrimary,
                  textSub: textSub,
                ),
                Divider(height: 1, color: divColor),
                // Light / Dark explicit buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ThemeOptionBtn(
                          label: 'Light',
                          icon: Icons.light_mode_rounded,
                          selected: !isDark,
                          onTap: () =>
                              context.read<ThemeProvider>().setDark(false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ThemeOptionBtn(
                          label: 'Dark',
                          icon: Icons.dark_mode_rounded,
                          selected: isDark,
                          onTap: () =>
                              context.read<ThemeProvider>().setDark(true),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Banner ad in middle
          const BannerAdWidget(),
          const SizedBox(height: 20),

          // ── About section ────────────────────────────────────────────
          _SectionHeader(label: 'ABOUT', textColor: textSub),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: divColor),
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.auto_stories_rounded,
                  iconColor: AppTheme.accent,
                  title: 'Simulizi za Mapenzi',
                  subtitle: 'Version 1.0',
                  textPrimary: textPrimary,
                  textSub: textSub,
                ),
                Divider(height: 1, color: divColor),
                _SettingsTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppTheme.accent,
                  title: 'Description',
                  subtitle: 'Romantic love stories in Swahili.',
                  textPrimary: textPrimary,
                  textSub: textSub,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Banner ad at bottom
          const BannerAdWidget(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color textColor;
  const _SectionHeader({required this.label, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: textColor,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Color textPrimary;
  final Color textSub;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.textPrimary,
    required this.textSub,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: textSub, fontSize: 12)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _ThemeOptionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOptionBtn({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.accent.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppTheme.accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppTheme.accent : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppTheme.accent : Colors.grey,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
