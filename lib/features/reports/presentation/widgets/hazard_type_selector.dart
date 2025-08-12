import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/providers.dart';

class HazardTypeSelector extends StatelessWidget {
  final HazardType? selectedType;
  final Function(HazardType) onTypeSelected;

  const HazardTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: HazardType.values.map((type) {
        final isSelected = selectedType == type;
        return _HazardTypeCard(
          type: type,
          isSelected: isSelected,
          onTap: () => onTypeSelected(type),
        );
      }).toList(),
    );
  }
}

class _HazardTypeCard extends StatelessWidget {
  final HazardType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _HazardTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected 
              ? _getTypeColor(type).withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? _getTypeColor(type)
                : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _getTypeColor(type).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? _getTypeColor(type)
                      : _getTypeColor(type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTypeIcon(type),
                  color: isSelected
                      ? Colors.white
                      : _getTypeColor(type),
                  size: 24,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Nom du type
              Text(
                _getTypeName(type),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? _getTypeColor(type)
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(HazardType type) {
    switch (type) {
      case HazardType.verbalAggression:
      case HazardType.harassment:
        return AppTheme.primaryRed;
      case HazardType.aggressiveGroup:
        return AppTheme.primaryOrange;
      case HazardType.intoxication:
        return AppTheme.primaryYellow;
      case HazardType.theft:
        return const Color(0xFF9B59B6);
      case HazardType.suspiciousActivity:
        return AppTheme.primaryBlue;
      case HazardType.other:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(HazardType type) {
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

  String _getTypeName(HazardType type) {
    switch (type) {
      case HazardType.verbalAggression:
        return 'Agression\nverbale';
      case HazardType.aggressiveGroup:
        return 'Groupe\nagressif';
      case HazardType.intoxication:
        return 'Personne\nivre';
      case HazardType.harassment:
        return 'Harcèlement';
      case HazardType.theft:
        return 'Vol';
      case HazardType.suspiciousActivity:
        return 'Activité\nsuspecte';
      case HazardType.other:
        return 'Autre';
    }
  }
}
