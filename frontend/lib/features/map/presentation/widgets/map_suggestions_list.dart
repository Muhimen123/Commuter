import 'package:flutter/material.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../data/photon_repository.dart';
import '../../../../shared/widgets/glass_container.dart';

class MapSuggestionsList extends StatelessWidget {
  final List<LocationSuggestion> suggestions;
  final ValueChanged<LocationSuggestion> onSuggestionSelected;

  const MapSuggestionsList({
    super.key,
    required this.suggestions,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        GlassContainer(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          padding: EdgeInsets.zero,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView.builder(
              padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return Material(
                type: MaterialType.transparency,
                child: ListTile(
                  leading: Icon(Icons.location_on_outlined, color: colorScheme.primary, size: 20),
                  title: Text(
                    suggestion.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    suggestion.displayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => onSuggestionSelected(suggestion),
                ),
              );
            },
          ),
        ),
        ),
      ],
    );
  }
}
