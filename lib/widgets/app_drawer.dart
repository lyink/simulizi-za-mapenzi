import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/admin/admin_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/favorites_screen.dart';
import '../services/ad_service.dart';

// ── Simple notifier so AppDrawer can tell HomeScreen which category to select ──
class HomeScreenCategoryNotifier {
  static void Function(String)? _listener;

  static void addListener(void Function(String) fn) => _listener = fn;
  static void removeListener() => _listener = null;
  static void select(String category) => _listener?.call(category);
}

class AppDrawer extends StatelessWidget {
  final String activeCategory;
  const AppDrawer({super.key, this.activeCategory = 'All'});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg1 = isDark ? AppTheme.secondary : AppTheme.lightSecondary;
    final bg2 = isDark ? AppTheme.primary : AppTheme.lightPrimary;
    final divColor = isDark ? Colors.white10 : const Color(0xFFDDD8D0);
    final subTextColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bg1, bg2],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DrawerHeader(),
              Divider(color: divColor, height: 1),

              // ── Scrollable nav + categories ────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Navigation
                      _DrawerItem(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        isActive: activeCategory == 'All',
                        onTap: () => _goHome(context, 'All'),
                      ),
                      _DrawerItem(
                        icon: Icons.auto_stories_rounded,
                        label: 'All Books',
                        isActive: false,
                        onTap: () => _goHome(context, 'All'),
                      ),
                      _DrawerItem(
                        icon: Icons.favorite_rounded,
                        label: 'My Favorites',
                        isActive: false,
                        onTap: () {
                          Navigator.pop(context);
                          // Show interstitial ad when opening favorites
                          AdService().showInterstitialAd();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FavoritesScreen()),
                          );
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.star_rounded,
                        label: 'Featured',
                        isActive: false,
                        onTap: () => Navigator.pop(context),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Divider(color: divColor),
                      ),

                      // Categories
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 4),
                        child: Text(
                          'CATEGORIES',
                          style: TextStyle(
                            color: subTextColor?.withValues(alpha: 0.6),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      _DrawerItem(
                        icon: Icons.terrain_rounded,
                        label: 'Adventure',
                        isActive: activeCategory == 'Adventure',
                        onTap: () => _goHome(context, 'Adventure'),
                      ),
                      _DrawerItem(
                        icon: Icons.pets_rounded,
                        label: 'Animals',
                        isActive: activeCategory == 'Animals',
                        onTap: () => _goHome(context, 'Animals'),
                      ),
                      _DrawerItem(
                        icon: Icons.auto_awesome_rounded,
                        label: 'Fantasy',
                        isActive: activeCategory == 'Fantasy',
                        onTap: () => _goHome(context, 'Fantasy'),
                      ),
                      _DrawerItem(
                        icon: Icons.science_rounded,
                        label: 'Science',
                        isActive: activeCategory == 'Science',
                        onTap: () => _goHome(context, 'Science'),
                      ),
                      _DrawerItem(
                        icon: Icons.favorite_rounded,
                        label: 'Morals',
                        isActive: activeCategory == 'Morals',
                        onTap: () => _goHome(context, 'Morals'),
                      ),
                      _DrawerItem(
                        icon: Icons.park_rounded,
                        label: 'Nature',
                        isActive: activeCategory == 'Nature',
                        onTap: () => _goHome(context, 'Nature'),
                      ),
                      _DrawerItem(
                        icon: Icons.people_rounded,
                        label: 'Family',
                        isActive: activeCategory == 'Family',
                        onTap: () => _goHome(context, 'Family'),
                      ),
                    ],
                  ),
                ),
              ),

              Divider(color: divColor, height: 1),

              // ── Settings ───────────────────────────────────────────────
              _DrawerItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                isActive: false,
                onTap: () {
                  Navigator.pop(context);
                  // Show interstitial ad when opening settings
                  AdService().showInterstitialAd();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen()),
                  );
                },
              ),

              // ── Admin Panel ────────────────────────────────────────────
              // Commented out for production release
              /*
              Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accent.withValues(alpha: 0.15),
                      AppTheme.accent.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppTheme.accent.withValues(alpha: 0.3)),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded,
                        color: AppTheme.accent, size: 22),
                  ),
                  title: const Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    'Manage & generate books',
                    style: TextStyle(color: subTextColor, fontSize: 11),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminScreen()),
                    );
                  },
                ),
              ),
              */

              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Hadithi kwa Watoto v1.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: subTextColor?.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goHome(BuildContext context, String category) {
    Navigator.pop(context);
    HomeScreenCategoryNotifier.select(category);
  }
}

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/icon.png',
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.accent, Color(0xFFFF6B9D)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.auto_stories_rounded,
                    color: Colors.white, size: 28),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hadithi kwa Watoto',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Children\'s Stories',
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final iconColor = Theme.of(context).iconTheme.color;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.accent.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Icon(
          icon,
          color: isActive ? AppTheme.accent : iconColor,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.accent : textColor,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
