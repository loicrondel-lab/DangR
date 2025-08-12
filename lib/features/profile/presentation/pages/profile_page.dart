import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/providers.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authServiceProvider.notifier).signOut();
      if (mounted) {
        context.go('/auth');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.primaryOrange,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Profil',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Utilisateur DangR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Statistiques personnelles
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mes statistiques',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _PersonalStatCard(
                            title: 'Incidents signalés',
                            value: '23',
                            icon: Icons.report,
                            color: AppTheme.primaryOrange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PersonalStatCard(
                            title: 'Votes donnés',
                            value: '156',
                            icon: Icons.thumb_up,
                            color: AppTheme.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _PersonalStatCard(
                            title: 'Points gagnés',
                            value: '1,247',
                            icon: Icons.stars,
                            color: AppTheme.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PersonalStatCard(
                            title: 'Jours actifs',
                            value: '45',
                            icon: Icons.calendar_today,
                            color: AppTheme.warning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Séparateur
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(height: 32),
              ),
            ),

            // Paramètres
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paramètres',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Liste des paramètres
            SliverList(
              delegate: SliverChildListDelegate([
                _SettingsSection(
                  title: 'Notifications',
                  items: [
                    _SettingsItem(
                      icon: Icons.notifications,
                      title: 'Notifications push',
                      subtitle: 'Recevoir des alertes en temps réel',
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {
                          // Gérer le changement de paramètre
                        },
                        activeColor: AppTheme.primaryOrange,
                      ),
                    ),
                    _SettingsItem(
                      icon: Icons.location_on,
                      title: 'Alertes géolocalisées',
                      subtitle: 'Notifications pour les incidents proches',
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {
                          // Gérer le changement de paramètre
                        },
                        activeColor: AppTheme.primaryOrange,
                      ),
                    ),
                    _SettingsItem(
                      icon: Icons.emergency,
                      title: 'Alertes d\'urgence',
                      subtitle: 'Notifications pour les incidents graves',
                      trailing: Switch(
                        value: false,
                        onChanged: (value) {
                          // Gérer le changement de paramètre
                        },
                        activeColor: AppTheme.primaryOrange,
                      ),
                    ),
                  ],
                ),
                _SettingsSection(
                  title: 'Carte',
                  items: [
                    _SettingsItem(
                      icon: Icons.map,
                      title: 'Style de carte',
                      subtitle: 'Satellite',
                      onTap: () {
                        // Ouvrir les options de style de carte
                      },
                    ),
                    _SettingsItem(
                      icon: Icons.filter_list,
                      title: 'Filtres par défaut',
                      subtitle: 'Accidents, Travaux, Météo',
                      onTap: () {
                        // Ouvrir les filtres
                      },
                    ),
                    _SettingsItem(
                      icon: Icons.visibility,
                      title: 'Rayon de visibilité',
                      subtitle: '5 km',
                      onTap: () {
                        // Ajuster le rayon
                      },
                    ),
                  ],
                ),
                _SettingsSection(
                  title: 'Compte',
                  items: [
                    _SettingsItem(
                      icon: Icons.person,
                      title: 'Modifier le profil',
                      subtitle: 'Nom, photo, préférences',
                      onTap: () {
                        // Ouvrir l'édition du profil
                      },
                    ),
                    _SettingsItem(
                      icon: Icons.security,
                      title: 'Confidentialité',
                      subtitle: 'Gérer vos données personnelles',
                      onTap: () {
                        // Ouvrir les paramètres de confidentialité
                      },
                    ),
                    _SettingsItem(
                      icon: Icons.help,
                      title: 'Aide et support',
                      subtitle: 'FAQ, contact, tutoriel',
                      onTap: () {
                        // Ouvrir l'aide
                      },
                    ),
                    _SettingsItem(
                      icon: Icons.info,
                      title: 'À propos',
                      subtitle: 'Version 1.0.0',
                      onTap: () {
                        // Afficher les informations de l'app
                      },
                    ),
                  ],
                ),
              ]),
            ),

            // Bouton de déconnexion
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Se déconnecter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Espace en bas
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonalStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _PersonalStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryDark,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isLast = index == items.length - 1;

                return Column(
                  children: [
                    item,
                    if (!isLast)
                      const Divider(
                        height: 1,
                        indent: 56,
                        endIndent: 16,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryOrange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryOrange,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimaryDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: onTap,
    );
  }
}
