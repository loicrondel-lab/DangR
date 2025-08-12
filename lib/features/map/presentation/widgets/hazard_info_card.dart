import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/providers.dart';

class HazardInfoCard extends StatelessWidget {
  final Hazard hazard;
  final VoidCallback onClose;
  final Function(String, int) onVote;

  const HazardInfoCard({
    super.key,
    required this.hazard,
    required this.onClose,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // En-tête avec type et gravité
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: _getHazardGradient(hazard.type),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // Icône du type
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getHazardIcon(hazard.type),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Informations principales
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getHazardTypeName(hazard.type),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Indicateur de gravité
                          ...List.generate(5, (index) {
                            return Icon(
                              Icons.circle,
                              color: index < hazard.severity 
                                  ? Colors.white 
                                  : Colors.white.withOpacity(0.3),
                              size: 12,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            'Gravité ${hazard.severity}/5',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Bouton de fermeture
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          // Contenu principal
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statut et temps
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(hazard.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(hazard.status),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getStatusText(hazard.status),
                        style: TextStyle(
                          color: _getStatusColor(hazard.status),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _getTimeAgo(hazard.createdAt),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Distance et rayon
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppTheme.primaryOrange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rayon de ${hazard.radiusM}m',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Votes
                Row(
                  children: [
                    Expanded(
                      child: _VoteButton(
                        icon: Icons.thumb_up,
                        count: hazard.upvotes,
                        color: AppTheme.success,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onVote(hazard.id, 1);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _VoteButton(
                        icon: Icons.thumb_down,
                        count: hazard.downvotes,
                        color: AppTheme.error,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onVote(hazard.id, -1);
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Bouton d'action
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Action à implémenter (partager, signaler, etc.)
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Partager'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getHazardGradient(HazardType type) {
    switch (type) {
      case HazardType.verbalAggression:
      case HazardType.harassment:
        return AppTheme.primaryGradient;
      case HazardType.aggressiveGroup:
        return AppTheme.warningGradient;
      case HazardType.intoxication:
        return const LinearGradient(
          colors: [AppTheme.primaryYellow, AppTheme.warning],
        );
      case HazardType.theft:
        return const LinearGradient(
          colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
        );
      case HazardType.suspiciousActivity:
        return AppTheme.secondaryGradient;
      case HazardType.other:
        return const LinearGradient(
          colors: [Colors.grey, Colors.grey],
        );
    }
  }

  IconData _getHazardIcon(HazardType type) {
    switch (type) {
      case HazardType.verbalAggression:
        return Icons.record_voice_over;
      case HazardType.aggressiveGroup:
        return Icons.groups;
      case HazardType.intoxication:
        return Icons.local_bar;
      case HazardType.harassment:
        return Icons.person_off;
      case HazardType.theft:
        return Icons.security;
      case HazardType.suspiciousActivity:
        return Icons.visibility;
      case HazardType.other:
        return Icons.warning;
    }
  }

  String _getHazardTypeName(HazardType type) {
    switch (type) {
      case HazardType.verbalAggression:
        return 'Agression verbale';
      case HazardType.aggressiveGroup:
        return 'Groupe agressif';
      case HazardType.intoxication:
        return 'Personne ivre';
      case HazardType.harassment:
        return 'Harcèlement';
      case HazardType.theft:
        return 'Vol';
      case HazardType.suspiciousActivity:
        return 'Activité suspecte';
      case HazardType.other:
        return 'Autre';
    }
  }

  Color _getStatusColor(HazardStatus status) {
    switch (status) {
      case HazardStatus.pending:
        return AppTheme.warning;
      case HazardStatus.confirmed:
        return AppTheme.success;
      case HazardStatus.disputed:
        return AppTheme.error;
      case HazardStatus.expired:
        return Colors.grey;
    }
  }

  String _getStatusText(HazardStatus status) {
    switch (status) {
      case HazardStatus.pending:
        return 'En attente';
      case HazardStatus.confirmed:
        return 'Confirmé';
      case HazardStatus.disputed:
        return 'Contesté';
      case HazardStatus.expired:
        return 'Expiré';
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else {
      return DateFormat('dd/MM à HH:mm').format(dateTime);
    }
  }
}

class _VoteButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final VoidCallback onPressed;

  const _VoteButton({
    required this.icon,
    required this.count,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
