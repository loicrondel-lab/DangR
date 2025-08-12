import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/providers.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
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
    _refreshController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _refreshController.repeat();
    // Rafraîchir les données
    await Future.delayed(const Duration(seconds: 1));
    _refreshController.stop();
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
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.primaryOrange,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Activité',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: AnimatedBuilder(
                    animation: _refreshController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _refreshController.value * 2 * 3.14159,
                        child: const Icon(Icons.refresh, color: Colors.white),
                      );
                    },
                  ),
                  onPressed: _onRefresh,
                ),
              ],
            ),

            // Statistiques
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aujourd\'hui',
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
                          child: _StatCard(
                            title: 'Incidents',
                            value: '12',
                            icon: Icons.warning,
                            color: AppTheme.error,
                            gradient: const LinearGradient(
                              colors: [AppTheme.error, Color(0xFFFF6B6B)],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Résolus',
                            value: '8',
                            icon: Icons.check_circle,
                            color: AppTheme.success,
                            gradient: const LinearGradient(
                              colors: [AppTheme.success, Color(0xFF4CAF50)],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Votes',
                            value: '156',
                            icon: Icons.thumb_up,
                            color: AppTheme.primaryOrange,
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryOrange, Color(0xFFFF8A65)],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Utilisateurs',
                            value: '89',
                            icon: Icons.people,
                            color: AppTheme.info,
                            gradient: const LinearGradient(
                              colors: [AppTheme.info, Color(0xFF42A5F5)],
                            ),
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

            // Liste des incidents récents
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Incidents récents',
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

            // Liste des incidents
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // Données d'exemple - à remplacer par les vraies données
                  final incidents = [
                    {
                      'type': 'Accident',
                      'severity': 3,
                      'time': DateTime.now().subtract(const Duration(minutes: 15)),
                      'location': 'Rue de la Paix, Paris',
                      'description': 'Accident de voiture, circulation ralentie',
                      'votes': 12,
                    },
                    {
                      'type': 'Travaux',
                      'severity': 2,
                      'time': DateTime.now().subtract(const Duration(hours: 2)),
                      'location': 'Avenue des Champs-Élysées',
                      'description': 'Travaux de voirie en cours',
                      'votes': 8,
                    },
                    {
                      'type': 'Météo',
                      'severity': 4,
                      'time': DateTime.now().subtract(const Duration(hours: 4)),
                      'location': 'Boulevard Saint-Germain',
                      'description': 'Route glissante, prudence requise',
                      'votes': 25,
                    },
                    {
                      'type': 'Obstacle',
                      'severity': 1,
                      'time': DateTime.now().subtract(const Duration(hours: 6)),
                      'location': 'Place de la Concorde',
                      'description': 'Arbre tombé sur la chaussée',
                      'votes': 5,
                    },
                  ];

                  if (index >= incidents.length) return null;

                  final incident = incidents[index];
                  return _IncidentCard(
                    type: incident['type'] as String,
                    severity: incident['severity'] as int,
                    time: incident['time'] as DateTime,
                    location: incident['location'] as String,
                    description: incident['description'] as String,
                    votes: incident['votes'] as int,
                    onTap: () {
                      // Naviguer vers la carte avec l'incident sélectionné
                      context.go('/');
                    },
                  );
                },
                childCount: 4, // Nombre d'incidents d'exemple
              ),
            ),

            // Espace en bas
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final LinearGradient gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
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
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final String type;
  final int severity;
  final DateTime time;
  final String location;
  final String description;
  final int votes;
  final VoidCallback onTap;

  const _IncidentCard({
    required this.type,
    required this.severity,
    required this.time,
    required this.location,
    required this.description,
    required this.votes,
    required this.onTap,
  });

  Color _getSeverityColor() {
    switch (severity) {
      case 1:
        return AppTheme.success;
      case 2:
        return AppTheme.warning;
      case 3:
        return AppTheme.error;
      case 4:
        return AppTheme.error;
      default:
        return AppTheme.success;
    }
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else {
      return 'Il y a ${difference.inDays}j';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getSeverityColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: _getSeverityColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _getTimeAgo(),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                location,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.thumb_up,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$votes votes',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: severity / 4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getSeverityColor(),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
